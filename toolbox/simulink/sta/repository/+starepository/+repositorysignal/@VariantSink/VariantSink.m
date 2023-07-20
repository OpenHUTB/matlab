classdef VariantSink<starepository.repositorysignal.RepositorySignal




    properties
        SUPPORTED_FORMATS={'variantsink'};
    end


    methods

        function bool=isSupported(obj,dbId,dataFormat)




            bool=any(strcmpi(dataFormat,obj.SUPPORTED_FORMATS))||...
            (isempty(dataFormat)&&isempty(obj.repoUtil.getChildrenIds(dbId)))||...
            ~isempty(strfind(dataFormat,'structElementIndex:'));
        end


        function[varValue,varName]=extractValue(obj,dbId)
            if isempty(dbId)
                varValue=[];
                varName=[];
                return;
            end


            varName=obj.repoUtil.getVariableName(dbId);

            varValue=obj.repoUtil.getMetaDataByName(dbId,'Value');

        end
    end
end