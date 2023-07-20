classdef FunctionCall<starepository.repositorysignal.RepositorySignal






    properties
        SUPPORTED_FORMATS={'functioncall','datasetElement:functioncall'};
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


            dataVals=obj.repoUtil.getSignalDataValues(dbId);


            if isempty(dataVals)
                varValue=[];
                varName=[];
                return;
            else


                varName=obj.repoUtil.getVariableName(dbId);


                varValue=dataVals.Data;

            end
        end


        function jsonStruct=jsonStructFromID(obj,dbId)
            jsonStruct={};
            metaStruct=obj.repoUtil.getMetaDataStructure(dbId);

            parentID=obj.repoUtil.getParent(dbId);

            if parentID==0
                parentID='input';
            end

            itemStruct.Name=getSignalLabel(obj.repoUtil,dbId);

            if isempty(metaStruct.ParentName)
                metaStruct.ParentName=[];
            end

            itemStruct.ParentName=metaStruct.ParentName;
            itemStruct.ParentID=parentID;

            itemStruct.DataSource=metaStruct.FileName;
            itemStruct.FullDataSource=metaStruct.LastKnownFullFile;
            itemStruct.Icon='variable_function_call.png';
            itemStruct.Type='FunctionCall';
            itemStruct.DataType='fcn_call';


            itemStruct.isString=false;

            itemStruct.TreeOrder=metaStruct.TreeOrder;
            itemStruct.ID=dbId;


            itemStruct.ExternalSourceID=0;

            jsonStruct{1}=itemStruct;

        end


        function editSignalData(obj,rootSigID,~,dataType,dataToSet)





            if~strcmpi(dataType,'double')
                DAStudio.error('sl_sta_repository:sta_repository:cantcastfunctioncall');
            end

            dataForSet=formatFunctionCallDataForEdit(obj,dataToSet.Time,dataToSet.Data);

            obj.repoUtil.repo.setSignalDataValues(rootSigID,dataForSet);

        end


        function dataToSet=formatFunctionCallDataForEdit(obj,timeVals,dataVals)



            fcnCallVal=[];
            [~,idxSort]=sort(timeVals);
            dataVals=dataVals(idxSort);
            timeVals=timeVals(idxSort);



            for kTime=1:length(timeVals)
                fcnCallVal=[fcnCallVal,repmat(timeVals(kTime),1,dataVals(kTime))];
            end

            varIn=fcnCallVal';

            dataToSet.Time=varIn;
            dataToSet.Data=varIn;

        end
    end

    methods(Access='protected')


        function doCast(obj,rootSigID,WAS_REAL,newDataType)
            DAStudio.error('sl_sta_repository:sta_repository:cantcastfunctioncall');
        end
    end
end
