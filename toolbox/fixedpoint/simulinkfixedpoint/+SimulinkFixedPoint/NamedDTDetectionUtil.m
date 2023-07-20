classdef NamedDTDetectionUtil<handle








    properties(Access=private)

        resultsClientOfNamedType={};
    end

    methods(Access=public)

        function detectAndAddToNamedDTList(this,result)
            dTContainerInfo=result.getSpecifiedDTContainerInfo;
            isMutableNamedDT=dTContainerInfo.traceVar();
            if isMutableNamedDT
                appendResultToList(this,result);
            end
        end

        function listOfResults=getListOfResults(this)
            listOfResults=this.resultsClientOfNamedType;
        end

    end

    methods(Access=private)
        function appendResultToList(this,result)
            this.resultsClientOfNamedType{end+1}=result;
        end
    end
end


