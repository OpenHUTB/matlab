classdef DataArray<starepository.repositorysignal.RepositorySignal






    properties
        SUPPORTED_FORMATS={'dataarray','datasetElement:dataarray'};
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

            kidDbId=obj.repoUtil.getChildrenIDsInSiblingOrder(dbId(1));



            varName=obj.repoUtil.getVariableName(dbId);


            dataVals=obj.repoUtil.getSignalDataValues(kidDbId(1));



            if isempty(dataVals)
                varValue=[];
                return;
            else

                varValue=zeros(length(dataVals.Time),length(kidDbId)+1);
                varValue(:,1)=dataVals.Time';
                varValue(:,2)=dataVals.Data';

                for k=2:length(kidDbId)

                    dataVals=obj.repoUtil.getSignalDataValues(kidDbId(k));



                    Vals=dataVals.Data';
                    varValue(:,k+1)=Vals;
                end


            end
        end



        function editPropStruct=updateChildrenSignalNames(obj,dbId,nameOfParent,oldParentFullName,...
            newFullNameOfParent,editPropStruct)


            childSignals=getChildrenIDsInSiblingOrder(obj.repoUtil,dbId);

            for kChild=1:length(childSignals)
                signalLabel=getSignalLabel(obj.repoUtil,childSignals(kChild));
                oldName=signalLabel;
                newName=sprintf('%s(:,%d)',nameOfParent,kChild+1);
                signalLabel=sprintf('%s(:,%d)',newFullNameOfParent,kChild+1);
                oldFullLabel=sprintf('%s(:,%d)',oldParentFullName,kChild+1);


                oldFullName=oldFullLabel;
                newFullName=signalLabel;


                tempStruct(1).id=childSignals(kChild);
                tempStruct(1).propertyname='name';
                tempStruct(1).oldValue=oldName;
                tempStruct(1).newValue=newName;


                setMetaDataByName(obj.repoUtil,childSignals(kChild),'ParentName',nameOfParent);


                tempStruct(2).id=childSignals(kChild);
                tempStruct(2).propertyname='FullName';
                tempStruct(2).oldValue=oldFullName;
                tempStruct(2).newValue=newFullName;


                editPropStruct=[editPropStruct,tempStruct];
                temptStruct=[];

            end
        end


        function jsonStruct=jsonStructFromID(obj,dbId)













            jsonStruct={};
            metaStruct=obj.repoUtil.getMetaDataStructure(dbId);

            parentID=obj.repoUtil.getParent(dbId);

            if parentID==0
                parentID='input';
            end

            jsonStruct{1}.ID=dbId;
            jsonStruct{1}.Name=getSignalLabel(obj.repoUtil,dbId);

            if isempty(metaStruct.ParentName)
                metaStruct.ParentName=[];
            end

            jsonStruct{1}.ParentName=metaStruct.ParentName;
            jsonStruct{1}.ParentID=parentID;

            jsonStruct{1}.DataSource=metaStruct.FileName;
            jsonStruct{1}.FullDataSource=metaStruct.LastKnownFullFile;
            jsonStruct{1}.Icon='variable_matrix.png';
            jsonStruct{1}.Type='DataArray';


            jsonStruct{1}.isEnum=logical(metaStruct.isEnum);
            jsonStruct{1}.isString=logical(metaStruct.isString);
            jsonStruct{1}.TreeOrder=metaStruct.TreeOrder;



            kidDbId=obj.repoUtil.getChildrenIds(dbId);
            childStruct=cell(1,length(kidDbId));

            if length(kidDbId)<2
                jsonStruct{1}.Type='SaveToWorkspaceFormatArray';

            end

            for kChild=1:length(kidDbId)

                childStruct{kChild}.ID=kidDbId(kChild);
                childStruct{kChild}.Name=sprintf('%s(:,%d)',jsonStruct{1}.Name,kChild+1);

                childStruct{kChild}.ParentName=[];
                childStruct{kChild}.ParentID=dbId;

                childStruct{kChild}.DataSource=metaStruct.FileName;
                childStruct{kChild}.FullDataSource=metaStruct.LastKnownFullFile;
                childStruct{kChild}.Icon='signal.gif';
                childStruct{kChild}.Type='Signal';


                childStruct{kChild}.isEnum=logical(metaStruct.isEnum);
                childStruct{kChild}.DataType=metaStruct.DataType;
                childStruct{kChild}.isString=logical(metaStruct.isString);
                childStruct{kChild}.TreeOrder=metaStruct.TreeOrder;


                childStruct{kChild}.TreeOrder=jsonStruct{1}.TreeOrder+kChild;

                if strcmp(jsonStruct{1}.Type,'SaveToWorkspaceFormatArray')
                    childStruct{kChild}.MinTime=metaStruct.MinTime;
                    childStruct{kChild}.MaxTime=metaStruct.MaxTime;
                    childStruct{kChild}.MinData=metaStruct.Min;
                    childStruct{kChild}.MaxData=metaStruct.Max;
                    childStruct{kChild}.Interpolation='linear';
                    childStruct{kChild}.Units='';
                    childStruct{kChild}.BlockPath=[];
                end

            end

            jsonStruct=[jsonStruct,childStruct];
        end


        function plottableIDs=getPlottableSignalIDs(obj,rootSigID)
            plottableIDs=obj.repoUtil.getChildrenIDsInSiblingOrder(rootSigID);
        end


        function propertyUpdateIDs=getIDsForPropertyUpdates(obj,rootSigID)
            propertyUpdateIDs=obj.repoUtil.getChildrenIDsInSiblingOrder(rootSigID);
        end


        function editSignalData(obj,rootSigID,sigID,newDataType,dataToSet)


            if~strcmpi(newDataType,'double')
                DAStudio.error('sl_sta_repository:sta_repository:cantcastdataarray');
            end

            if~isreal(dataToSet.Data)
                DAStudio.error('sl_sta_repository:sta_repository:nocomplexdataarray');
            end
            WAS_REAL=true;
            makeDataEdits(obj,rootSigID,WAS_REAL,dataToSet);
        end


        function removeDataPointByTime(obj,rootSigID,timeValues)

            replotIDs=getPlottableSignalIDs(obj,rootSigID);

            [numPoints,~]=size(timeValues);
            for k=1:length(replotIDs)
                for kRow=1:numPoints
                    timeToRemove=timeValues(kRow,1);
                    removeDataAtTime(obj.repoUtil,replotIDs(k),timeToRemove);
                end
            end
        end


        function addDataPointByTime(obj,rootSigID,timeValues,dataValues)
            replotIDs=getPlottableSignalIDs(obj,rootSigID);
            [numPoints,numCol]=size(timeValues);
            for k=1:numPoints
                for kID=1:length(replotIDs)

                    addDataPointAtTime(obj.repoUtil,replotIDs(kID),timeValues(k),dataValues(k,kID));
                end
            end

        end
    end

    methods(Access='private')


        function makeDataEdits(obj,rootSigID,WAS_REAL,dataToSet)

            kidIDs=obj.repoUtil.getChildrenIDsInSiblingOrder(rootSigID);

            dataForSet.Time=dataToSet.Time;
            for kChild=1:length(kidIDs)

                dataForSet.Data=dataToSet.Data(:,kChild);

                obj.repoUtil.repo.setSignalDataValues(kidIDs(kChild),dataForSet);
            end
        end

    end

    methods(Access='protected')


        function doCast(obj,rootSigID,WAS_REAL,newDataType)
            DAStudio.error('sl_sta_repository:sta_repository:cantcastdataarray');
        end
    end
end
