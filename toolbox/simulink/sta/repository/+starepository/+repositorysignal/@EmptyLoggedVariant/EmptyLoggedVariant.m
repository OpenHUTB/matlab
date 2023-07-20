classdef EmptyLoggedVariant<starepository.repositorysignal.RepositorySignal




    properties
        SUPPORTED_FORMATS={'emptyloggedvariant','datasetElement:emptyloggedvariant'};
    end


    methods

        function bool=isSupported(obj,~,dataFormat)




            bool=any(strcmpi(dataFormat,obj.SUPPORTED_FORMATS));
        end


        function[varValue,varName]=extractValue(obj,dbId)
            if isempty(dbId)
                varValue=[];
                varName=[];
                return;
            end

            varName=obj.repoUtil.getVariableName(dbId);
            varValue=timeseries.empty;

        end
    end
end