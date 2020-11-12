@EndUserText.label: 'Projection  View for Travel'
@AccessControl.authorizationCheck: #CHECK
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity YC_RAP_TRAVEL_U_AP
  as projection on YI_RAP_TRAVEL_U_AP
{
      //YI_RAP_TRAVEL_U_AP
  key TravelID,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity : { name: '/DMO/I_Agency', element: 'AgencyID' } } ]
      AgencyID,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity : { name: '/DMO/I_Customer', element: 'CustomerID' } } ]
      CustomerID,
      BeginDate,
      EndDate,
      BookingFee,
      TotalPrice,
      @Consumption.valueHelpDefinition: [{ entity : { name: 'I_Currency', element: 'Currency' } } ]
      CurrencyCode,
      Description,
      Status,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      /* Associations */
      //YI_RAP_TRAVEL_U_AP
      _Agency,
      _Booking : redirected to composition child YC_RAP_BOOKING_U_AP,
      _Currency,
      _Customer
}
