@EndUserText.label: 'Projection  View for Booking'
@AccessControl.authorizationCheck: #CHECK
@Search.searchable: true
@Metadata.allowExtensions: true
define view entity YC_RAP_BOOKING_U_AP
  as projection on YI_RAP_BOOKING_U_AP
{
      //YI_RAP_BOOKING_U_AP
      @Search.defaultSearchElement:true
  key TravelID,
      @Search.defaultSearchElement: true
  key BookingID,
      BookingDate,
      @Consumption.valueHelpDefinition: [{ entity : { name: '/DMO/I_Customer', 
                                                      element: 'CustomerID' } } ]
      CustomerID,
      @Consumption.valueHelpDefinition: [{ entity : { name: '/DMO/I_Carrier', 
                                                      element: 'AirlineID' } } ]
      CarrierID,
      @Consumption.valueHelpDefinition: [{ entity : { name: '/DMO/I_Flight', element: 'ConnectionID' },
                                           additionalBinding: [ { localElement: 'FlightDate', 
                                                                   element: 'FlightDate',
                                                                   usage: #RESULT },
                                                                 { localElement: 'CarrierID',
                                                                   element: 'CarrierID',
                                                                   usage: #RESULT },
                                                                 { localElement: 'FlightPrice',
                                                                   element: 'FlightPrice',
                                                                   usage: #RESULT },
                                                                 { localElement: 'CurrencyCode',
                                                                   element: 'CurrencyCode',
                                                                   usage: #RESULT } ]
                                         } ]
      ConnectionID,
      FlightDate,
      FlightPrice,
      @Consumption.valueHelpDefinition: [{ entity : { name: 'I_Currency', 
                                                      element: 'Currency' } } ]
      CurrencyCode,
      /* Associations */
      //YI_RAP_BOOKING_U_AP
      _Carrier,
      _Connection,
      _Customer,
      _Flight,
      _Travel : redirected to parent yc_rap_travel_u_ap
}
