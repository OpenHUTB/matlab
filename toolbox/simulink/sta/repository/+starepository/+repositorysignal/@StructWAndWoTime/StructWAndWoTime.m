classdef StructWAndWoTime<starepository.repositorysignal.RepositorySignal






    properties
        SUPPORTED_FORMATS={'structwithtime','structwithouttime'};
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


            if isempty(varName)
                varValue=[];
                varName=[];
                return;
            end

            varValue=struct;

            hasTime=false;
            switch lower(obj.repoUtil.getMetaDataByName(dbId,'dataformat'))
            case 'structwithtime'
                hasTime=true;
            case 'structwithouttime'
                hasTime=false;
            end

            isFromWSBlock=obj.repoUtil.getMetaDataByName(dbId,'isFromWorkspaceBlock');
            fromWSBlockSigName=obj.repoUtil.getMetaDataByName(dbId,'fromWorkspaceBlockSignalName');

            varValue.time=[];


            kidDbId=obj.repoUtil.getChildrenIDsInSiblingOrder(dbId);


            aFactory=starepository.repositorysignal.Factory;


            for k=1:length(kidDbId)



                concreteExtractor=aFactory.getSupportedExtractor(kidDbId(k));

                [varValLeaf,~]=concreteExtractor.extractValue(kidDbId(k));


                varNameKid=obj.repoUtil.getVariableName(kidDbId(k));

                if hasTime&&k==1
                    varValue.time=varValLeaf.Time;
                end

                varValue.signals(k).values=varValLeaf.Data;

                varValue.signals(k).dimensions=str2num(obj.repoUtil.getMetaDataByName(kidDbId(k),'Dimension'));
                varValue.signals(k).label=varNameKid;

                if~isFromWSBlock
                    varValue.signals(k).blockName=obj.repoUtil.getMetaDataByName(kidDbId(k),'BlockName');
                end
            end


            if isFromWSBlock
                varValue.blockName=fromWSBlockSigName;
            end

        end



        function editPropStruct=updateChildrenSignalNames(obj,dbId,nameOfParent,oldParentFullName,...
            newFullNameOfParent,editPropStruct)


            childSignals=getChildrenIDsInSiblingOrder(obj.repoUtil,dbId);

            for kChild=1:length(childSignals)


                signalLabel=getSignalLabel(obj.repoUtil,childSignals(kChild));


                oldFullName=[oldParentFullName,'.',signalLabel];
                newFullName=[newFullNameOfParent,'.',signalLabel];


                setMetaDataByName(obj.repoUtil,childSignals(kChild),'ParentName',nameOfParent);


                tempStruct.id=childSignals(kChild);
                tempStruct.propertyname='FullName';
                tempStruct.oldValue=oldFullName;
                tempStruct.newValue=newFullName;


                editPropStruct=[editPropStruct,tempStruct];

                tempStruct=[];

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
            itemStruct.Icon='variable_struct.png';
            itemStruct.Type='SaveToWorkspaceFormatStruct';


            itemStruct.isEnum=false;
            itemStruct.isString=false;

            itemStruct.TreeOrder=metaStruct.TreeOrder;
            itemStruct.ID=dbId;


            itemStruct.ExternalSourceID=0;

            jsonStruct{1}=itemStruct;


            childIDs=obj.repoUtil.getChildrenIDsInSiblingOrder(jsonStruct{1}.ID);

            aFactory=starepository.repositorysignal.Factory;

            childTreeInc=1;
            for kChild=1:length(childIDs)

                concreteExtractor=aFactory.getSupportedExtractor(childIDs(kChild));
                childJson=concreteExtractor.jsonStructFromID(childIDs(kChild));


                for kChildJson=1:length(childJson)
                    childJson{kChildJson}.TreeOrder=itemStruct.TreeOrder+childTreeInc;
                    childTreeInc=childTreeInc+1;
                end

                jsonStruct=[jsonStruct,childJson];
            end
        end
    end
end
