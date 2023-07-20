function logData(category,varargin)



    Product='VV';
    AppComponent='VV_MODEL_ADVISOR';
    EventKey=[AppComponent,'_',category];

    data=struct();
    for i=1:2:(nargin-1)
        data.(varargin{i})=varargin{i+1};
    end

    dataId=matlab.ddux.internal.DataIdentification(Product,AppComponent,EventKey);
    matlab.ddux.internal.logData(dataId,data);

end

