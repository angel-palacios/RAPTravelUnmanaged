CLASS ltcl_integration_test DEFINITION FINAL FOR TESTING
DURATION SHORT
RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    CLASS-DATA:
                  cds_test_environment TYPE REF TO if_cds_test_environment.

    CLASS-METHODS:
      class_setup,
      class_teardown.
    METHODS:
      setup,
      teardown.
    METHODS:
      create_travel FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_integration_test IMPLEMENTATION.

  METHOD class_setup.
    cds_test_environment = cl_cds_test_environment=>create_for_multiple_cds(
        i_for_entities = VALUE #( ( i_for_entity = 'YI_RAP_TRAVEL_U_AP' )
                                  ( i_for_entity = 'YI_RAP_BOOKING_U_AP' ) )
     ).
  ENDMETHOD.

  METHOD class_teardown.
    cds_test_environment->destroy( ).
  ENDMETHOD.

  METHOD create_travel.
    DATA(today) = cl_abap_context_info=>get_system_date(  ).
    DATA travels_in TYPE TABLE FOR CREATE yi_rap_travel_u_ap\\travel.

    travels_in = VALUE #( ( AgencyID = 070001
                            CustomerID = 1
                            BeginDate = today
                            EndDate = today + 30
                            BookingFee = 30
                            TotalPrice = 300
                            CurrencyCode = 'EUR'
                            Description = |Unit Test Travel Create|
                           ) ).

    MODIFY ENTITIES OF yi_rap_travel_u_ap
    ENTITY Travel
    CREATE FIELDS ( AgencyID
                    CustomerID
                    BeginDate
                    EndDate
                    BookingFee
                    TotalPrice
                    CurrencyCode
                    Description
                    Status )
                WITH travels_in
     MAPPED DATA(mapped)
     FAILED DATA(failed)
     REPORTED DATA(reported).

    cl_abap_unit_assert=>assert_initial( failed-travel ).
    cl_abap_unit_assert=>assert_initial( reported-travel ).
    COMMIT ENTITIES.
    DATA(new_travel_id) = mapped-travel[ 1 ]-TravelID.

    SELECT FROM yi_rap_travel_u_ap
    FIELDS *
    WHERE TravelID = @new_travel_id
    INTO TABLE @DATA(travel).
    cl_abap_unit_assert=>assert_not_initial( travel ).

    cl_abap_unit_assert=>assert_not_initial(
       VALUE #( travel[ TravelID = new_travel_id ] OPTIONAL ) ).
    cl_abap_unit_assert=>assert_equals(
       exp = 'N'
       act = travel[ TravelID = new_travel_id ]-Status ).
  ENDMETHOD.

  METHOD setup.

  ENDMETHOD.

  METHOD teardown.

  ENDMETHOD.

ENDCLASS.
