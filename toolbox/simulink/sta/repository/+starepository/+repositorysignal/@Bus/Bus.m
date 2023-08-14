classdef Bus<starepository.repositorysignal.RepositorySignal







    properties
        SUPPORTED_FORMATS={'busstructure','datasetElement:busstructure'};
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

            varValue=struct;

            kidDbId=obj.repoUtil.getChildrenIDsInSiblingOrder(dbId);



            varName=obj.repoUtil.getVariableName(dbId);


            aFactory=starepository.repositorysignal.Factory;


            for k=1:length(kidDbId)

                concreteExtractor=aFactory.getSupportedExtractor(kidDbId(k));


                [varValLeaf,varNameLeaf]=concreteExtractor.extractValue(kidDbId(k));


                varValue.(varNameLeaf)=varValLeaf;

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

                signalType=getMetaDataByName(obj.repoUtil,childSignals(kChild),'SignalType');
                IS_COMPLEX=strcmp(signalType,getString(message('sl_sta_general:common:Complex')));

                if IS_COMPLEX



                    childIDOfComplex=getChildrenIDsInSiblingOrder(obj.repoUtil,childSignals(kChild));
                    tempStruct.id=childIDOfComplex(1);

                    editPropStruct=[editPropStruct,tempStruct];
                    tempStruct=[];
                else


                    editPropStruct=[editPropStruct,tempStruct];

                    tempStruct=[];


                    aFactory=starepository.repositorysignal.Factory;
                    concreteExtractor=aFactory.getSupportedExtractor(childSignals(kChild));

                    editPropStruct=concreteExtractor.updateChildrenSignalNames(...
                    childSignals(kChild),signalLabel,oldFullName,...
                    newFullName,editPropStruct);
                end
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
            itemStruct.Icon='bus.gif';
            itemStruct.Type='Bus';


            itemStruct.isEnum=false;
            itemStruct.isString=false;

            itemStruct.TreeOrder=metaStruct.TreeOrder;
            itemStruct.ID=dbId;


            itemStruct.ExternalSourceID=0;

            jsonStruct{1}=itemStruct;


            childIDs=obj.repoUtil.getChildrenIDsInSiblingOrder(jsonStruct{1}.ID);

            aFactory=starepository.repositorysignal.Factory;

            for kChild=1:length(childIDs)

                concreteExtractor=aFactory.getSupportedExtractor(childIDs(kChild));
                childJson=concreteExtractor.jsonStructFromID(childIDs(kChild));
                jsonStruct=[jsonStruct,childJson];
            end
        end


        function possibleParentID=findFirstPossibleParent(obj,idOfSignal,dbIdParent)
            possibleParentID=dbIdParent;

            while possibleParentID~=0



                if~isempty(obj.repoUtil.getMetaDataByName(possibleParentID,...
                    'dataformat'))
                    IS_BUS_PARENT=contains(obj.repoUtil.getMetaDataByName(possibleParentID,...
                    'dataformat'),'bus')&&~contains(obj.repoUtil.getMetaDataByName(possibleParentID,...
                    'dataformat'),'aob')&&~contains(obj.repoUtil.getMetaDataByName(possibleParentID,...
                    'dataformat'),'groundorpartialspecifiedbus');
                    HAS_AOB_LINEAGE=obj.repoUtil.hasAoBLineage(possibleParentID);
                    if strcmpi(obj.repoUtil.getMetaDataByName(possibleParentID,...
                        'dataformat'),'dataset')||...
                        (IS_BUS_PARENT&&~HAS_AOB_LINEAGE)

                        break;
                    end
                end

                possibleParentID=obj.repoUtil.getParent(possibleParentID);
            end

        end
    end
end
