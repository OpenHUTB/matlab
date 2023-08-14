classdef DataIdentification<matlab.ddux.internal.Identification



    properties


        AppComponent(1,1)string;



        EventKey(1,1)string;
    end

    methods
        function obj=DataIdentification(product,appComponent,eventKey)
            obj=obj@matlab.ddux.internal.Identification(product);
            obj.AppComponent=appComponent;
            obj.EventKey=eventKey;
        end
    end
end

