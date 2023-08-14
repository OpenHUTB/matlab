classdef ResultsFilter<handle




    properties(SetAccess=private)
        TopModel char
        SUD char
    end

    methods
        function setSUD(this,sud)
            this.SUD=sud;
        end

        function setTopModel(this,topModel)
            this.TopModel=topModel;
        end
    end

    methods(Abstract)
        filteredResults=filter(this,allResults);
    end
end
