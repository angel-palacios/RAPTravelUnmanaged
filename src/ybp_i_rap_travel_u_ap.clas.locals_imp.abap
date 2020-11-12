CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Travel.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Travel.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Travel.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Travel.

    METHODS read FOR READ
      IMPORTING keys FOR READ Travel RESULT result.

    METHODS cba_Booking FOR MODIFY
      IMPORTING entities_cba FOR CREATE Travel\_Booking.

    METHODS rba_Booking FOR READ
      IMPORTING keys_rba FOR READ Travel\_Booking FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD create.
    DATA messages TYPE /dmo/t_message.
    DATA legacy_entity_in TYPE /dmo/travel.
    DATA legacy_entity_out TYPE /dmo/travel.

    LOOP AT entities INTO DATA(entity).
      legacy_entity_in = CORRESPONDING #( entity MAPPING FROM ENTITY USING CONTROL ).
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_CREATE'
        EXPORTING
          is_travel   = CORRESPONDING /dmo/s_travel_in( legacy_entity_in )
*         it_booking  =
*         it_booking_supplement =
        IMPORTING
          es_travel   = legacy_entity_out
*         et_booking  =
*         et_booking_supplement =
          et_messages = messages.

      IF messages IS INITIAL.
        APPEND VALUE #( %cid = entity-%cid travelID = legacy_entity_out-travel_id )
            TO mapped-travel.
      ELSE.
        "Fill failed return structure for the framework
        APPEND VALUE #( travelID = legacy_entity_in-travel_id )
            TO failed-travel.
        "Fill reported structure to be displayed on the UI
        APPEND VALUE #( travelID = legacy_entity_in-travel_id
                        %msg = new_message( id = messages[ 1 ]-msgid
                                           number = messages[ 1 ]-msgno
                                           v1 = messages[ 1 ]-msgv1
                                           v2 = messages[ 1 ]-msgv2
                                           v3 = messages[ 1 ]-msgv3
                                           v4 = messages[ 1 ]-msgv4
                                           severity = CONV #( messages[ 1 ]-msgty ) ) )
         TO reported-travel.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD delete.
    DATA messages TYPE /dmo/t_message.
    LOOP AT keys INTO DATA(key).
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_DELETE'
        EXPORTING
          iv_travel_id = key-TravelID
        IMPORTING
          et_messages  = messages.
      IF messages IS INITIAL.
        APPEND VALUE #( TravelID = key-TravelID ) TO mapped-travel.
      ELSE.
        "Fill failed return structure for the Framework
        APPEND VALUE #( TravelID = key-TravelID ) TO failed-travel.
        "Fill reported structure to be displayed on the UI
        APPEND VALUE #( TravelID = key-TravelID
                        %msg = new_message( id = messages[ 1 ]-msgid
                                            number = messages[ 1 ]-msgno
                                            v1 = messages[ 1 ]-msgv1
                                            v2 = messages[ 1 ]-msgv2
                                            v3 = messages[ 1 ]-msgv3
                                            v4 = messages[ 1 ]-msgv4
                                            severity = CONV #( messages[ 1 ]-msgty ) ) )
         TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    DATA legacy_entity_in TYPE /dmo/travel.
    DATA legacy_entity_x TYPE /dmo/s_travel_inx. "Refers to X structure (> BAPIs)
    DATA messages TYPE /dmo/t_message.
    LOOP AT entities INTO DATA(entity).
      legacy_entity_in = CORRESPONDING #( entity MAPPING FROM ENTITY ).
      legacy_entity_x-travel_id = entity-TravelID.
      legacy_entity_x-_intx = CORRESPONDING ysrap_travel_x_ap( entity MAPPING FROM ENTITY ).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = CORRESPONDING /dmo/s_travel_in( legacy_entity_in )
          is_travelx  = legacy_entity_x
*         it_booking  =
*         it_bookingx =
*         it_booking_supplement  =
*         it_booking_supplementx =
        IMPORTING
*         es_travel   =
*         et_booking  =
*         et_booking_supplement  =
          et_messages = messages.

      IF messages IS INITIAL.
        APPEND VALUE #( TravelID = legacy_entity_in-travel_id ) TO mapped-travel.
      ELSE.
        "Fill failed return structure for the Framework
        APPEND VALUE #( TravelID = legacy_entity_in-travel_id ) TO failed-travel.
        "Fill reported structure to be displayed on the UI
        APPEND VALUE #( TravelID = legacy_entity_in-travel_id
                        %msg = new_message( id = messages[ 1 ]-msgid
                                            number = messages[ 1 ]-msgno
                                            v1 = messages[ 1 ]-msgv1
                                            v2 = messages[ 1 ]-msgv2
                                            v3 = messages[ 1 ]-msgv3
                                            v4 = messages[ 1 ]-msgv4
                                            severity = CONV #( messages[ 1 ]-msgty ) ) )
         TO reported-travel.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD lock.
    "Instantiate lock object
    DATA(lock) = cl_abap_lock_object_factory=>get_instance( iv_name = '/DMO/TRAVEL' ).
    LOOP AT keys INTO DATA(key).
      TRY.
          "Enqueue Travel Instance
          lock->enqueue(
            it_parameter = VALUE #( ( name = 'TRAVEL_ID' value = REF #( key-TravelID ) ) )
          ).
          "If foreign lock exists
        CATCH cx_abap_foreign_lock INTO DATA(foreign_lock).
          "Fill failed return structure for the Framework
          APPEND VALUE #( TravelID = key-TravelID ) TO failed-travel.
          "Fill reported structure to be displayed on the UI
          APPEND VALUE #( TravelID = key-TravelID
                          %msg = new_message( id = '/DMO/CM_FLIGHT_LEGAC'
                                              number = '032'
                                              v1 = key-TravelID
                                              v2 = foreign_lock->user_name
                                              severity = CONV #( 'E' ) )
           ) TO reported-travel.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD read.

    DATA legacy_entity_out TYPE /dmo/travel.
    DATA messages TYPE /dmo/t_message.

    LOOP AT keys INTO DATA(key) GROUP BY key-TravelID.
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = key-TravelID
*         iv_include_buffer     = abap_true
        IMPORTING
          es_travel    = legacy_entity_out
*         et_booking   =
*         et_booking_supplement =
          et_messages  = messages.
      IF messages IS INITIAL.
        "Fill result parameter with flagged fields
        INSERT CORRESPONDING #( legacy_entity_out MAPPING TO ENTITY ) INTO TABLE result.
      ELSE.
        "Fill failed return structure for the Framework
        LOOP AT messages INTO DATA(message).
          APPEND VALUE #( TravelID = key-TravelID
                          %fail-cause = COND #(
                           WHEN message-msgty = 'E' AND ( message-msgno EQ '016' OR message-msgno EQ '009' )
                           THEN if_abap_behv=>cause-not_found
                           ELSE if_abap_behv=>cause-unspecific ) )
          TO failed-travel.
        ENDLOOP.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD cba_Booking.
    DATA messages TYPE /dmo/t_message.
    DATA booking_old TYPE /dmo/t_booking.
    DATA entity TYPE /dmo/booking.
    DATA last_booking_id TYPE /dmo/booking_id VALUE '0'.

    LOOP AT entities_cba INTO DATA(entity_cba).
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = entity_cba-TravelID
*         iv_include_buffer     = abap_true
        IMPORTING
*         es_travel    =
          et_booking   = booking_old
*         et_booking_supplement =
          et_messages  = messages.
      IF messages IS INITIAL.
        IF booking_old IS NOT INITIAL.
          last_booking_id = booking_old[ lines( booking_old ) ]-booking_id.
        ENDIF.
        LOOP AT entity_cba-%target INTO DATA(target_entity).
          entity = CORRESPONDING #( target_entity MAPPING FROM ENTITY USING CONTROL ).
          entity-booking_id = last_booking_id + 1.
          CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
            EXPORTING
              is_travel   = VALUE /dmo/s_travel_in( travel_id = entity_cba-TravelID )
              is_travelx  = VALUE /dmo/s_travel_inx( travel_id = entity_cba-TravelID )
              it_booking  = VALUE /dmo/t_booking_in( ( CORRESPONDING #( entity ) ) )
              it_bookingx = VALUE /dmo/t_booking_inx( ( booking_id = entity-booking_id
                                                        action_code = /dmo/if_flight_legacy=>action_code-create ) )
*             it_booking_supplement  =
*             it_booking_supplementx =
            IMPORTING
*             es_travel   =
*             et_booking  =
*             et_booking_supplement  =
              et_messages = messages.
          IF messages IS INITIAL.

            INSERT
              VALUE #(
                %cid = target_entity-%cid
                travelid = entity_cba-TravelID
                bookingid = entity-booking_id
              )
              INTO TABLE mapped-booking.

          ELSE.

            INSERT VALUE #( %cid = target_entity-%cid travelid = entity_cba-TravelID ) INTO TABLE failed-booking.

            LOOP AT messages INTO DATA(message) WHERE msgty = 'E' OR msgty = 'A'.

              INSERT
                VALUE #(
                  %cid     = target_entity-%cid
                  travelid = target_entity-TravelID
                  %msg     = new_message(
                    id       = message-msgid
                    number   = message-msgno
                    severity = if_abap_behv_message=>severity-error
                    v1       = message-msgv1
                    v2       = message-msgv2
                    v3       = message-msgv3
                    v4       = message-msgv4
                  )
                )
                INTO TABLE reported-booking.

            ENDLOOP.

          ENDIF.

        ENDLOOP.
      ELSE.

        "fill failed return structure for the framework
        APPEND VALUE #( travelid = entity_cba-TravelID ) TO failed-travel.
        "fill reported structure to be displayed on the UI
        APPEND VALUE #( travelid = entity_cba-TravelID
                        %msg = new_message( id = messages[ 1 ]-msgid
                                            number = messages[ 1 ]-msgno
                                            v1 = messages[ 1 ]-msgv1
                                            v2 = messages[ 1 ]-msgv2
                                            v3 = messages[ 1 ]-msgv3
                                            v4 = messages[ 1 ]-msgv4
                                            severity = CONV #( messages[ 1 ]-msgty ) )
       ) TO reported-travel.


      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD rba_Booking.

    DATA legacy_parent_entity_out TYPE /dmo/travel.
    DATA legacy_entities_out TYPE /dmo/t_booking.
    DATA entity LIKE LINE OF result.
    DATA message TYPE /dmo/t_message.

    LOOP AT keys_rba INTO DATA(key_rba) GROUP BY key_rba-TravelID.
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = key_rba-TravelID
*         iv_include_buffer     = abap_true
        IMPORTING
          es_travel    = legacy_parent_entity_out
          et_booking   = legacy_entities_out
*         et_booking_supplement =
          et_messages  = message.
      IF message IS INITIAL.
        LOOP AT legacy_entities_out INTO DATA(booking).
          "Fill link table with key fields
          INSERT VALUE #( source-%key = key_rba-%key
                          target-%key = VALUE #(
                             TravelID = booking-travel_id
                             BookingID = booking-booking_id

                          ) )
          INTO TABLE association_links.
          "Fill result parameter with flagged fields
          IF result_requested EQ abap_true.
            entity = CORRESPONDING #( booking MAPPING TO ENTITY  ).
            INSERT entity INTO TABLE result.
          ENDIF.

        ENDLOOP.
      ELSE.

        "Fill failed table in case of error
        failed-travel = VALUE #(
                        BASE failed-travel
                        FOR msg IN message ( %key = key_rba-TravelID
                                              %fail-cause = COND #(
                                              WHEN msg-msgty = 'E' AND  ( msg-msgno = '016' OR msg-msgno = '009' )
                                              THEN if_abap_behv=>cause-not_found
                                              ELSE if_abap_behv=>cause-unspecific ) ) ).


      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_YI_RAP_TRAVEL_U_AP DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lsc_YI_RAP_TRAVEL_U_AP IMPLEMENTATION.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD finalize.
  ENDMETHOD.

  METHOD save.
    CALL FUNCTION '/DMO/FLIGHT_TRAVEL_SAVE'.
  ENDMETHOD.

ENDCLASS.
