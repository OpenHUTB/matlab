classdef AoB<starepository.repositorysignal.RepositorySignal






    properties
        SUPPORTED_FORMATS={'aobbusstructure','datasetElement:aobbusstructure'};
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

            kidDbId=obj.repoUtil.getChildrenIDsInSiblingOrder(dbId);



            varName=obj.repoUtil.getVariableName(dbId);


            aFactory=starepository.repositorysignal.Factory;


            for k=1:length(kidDbId)

                concreteExtractor=aFactory.getSupportedExtractor(kidDbId(k));

                [varValLeaf,varNameLeaf]=concreteExtractor.extractValue(kidDbId(k));

                evalAoB(obj,varNameLeaf(strfind(varNameLeaf,'('):end));
            end
        end



        function editPropStruct=updateChildrenSignalNames(obj,dbId,nameOfParent,oldParentFullName,...
            newFullNameOfParent,editPropStruct)


            childSignals=getChildrenIDsInSiblingOrder(obj.repoUtil,dbId);

            for kChild=1:length(childSignals)


                signalLabel=getSignalLabel(obj.repoUtil,childSignals(kChild));
                oldLabel=signalLabel;
                idxArrayStart=strfind(signalLabel,'(');
                signalLabel=[nameOfParent,signalLabel(idxArrayStart:end)];

                setSignalLabel(obj.repoUtil,childSignals(kChild),signalLabel);


                oldFullName=[oldParentFullName,'.',oldLabel];
                newFullName=[newFullNameOfParent,'.',signalLabel];


                setMetaDataByName(obj.repoUtil,childSignals(kChild),'ParentName',nameOfParent);

                tempStruct(1).id=childSignals(kChild);
                tempStruct(1).propertyname='name';
                tempStruct(1).oldValue=oldLabel;
                tempStruct(1).newValue=signalLabel;


                tempStruct(2).id=childSignals(kChild);
                tempStruct(2).propertyname='FullName';
                tempStruct(2).oldValue=oldFullName;
                tempStruct(2).newValue=newFullName;


                editPropStruct=[editPropStruct,tempStruct];
                tempStruct=[];


                aFactory=starepository.repositorysignal.Factory;
                concreteExtractor=aFactory.getSupportedExtractor(childSignals(kChild));

                editPropStruct=concreteExtractor.updateChildrenSignalNames(...
                childSignals(kChild),signalLabel,oldFullName,...
                newFullName,editPropStruct);
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
            itemStruct.Type='ArrayOfBus';


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


    methods(Access='private')


        function evalAoB(~,indexStr)
            evalStr=sprintf('%s = varValLeaf;',['varValue',indexStr]);
            evalin('caller',evalStr);
        end

    end
end

