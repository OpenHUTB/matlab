classdef DataSet<starepository.repositorysignal.RepositorySignal






    properties
        SUPPORTED_FORMATS={'dataset'};
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

            varValue=Simulink.SimulationData.Dataset();

            dsNameProp=obj.repoUtil.getMetaDataByName(dbId,'DatasetName');

            if ischar(dsNameProp)
                varValue.Name=dsNameProp;
            else
                varValue.Name='';
            end

            kidDbId=obj.repoUtil.getChildrenIDsInSiblingOrder(dbId);


            aFactory=starepository.repositorysignal.Factory;


            for k=1:length(kidDbId)

                concreteExtractor=aFactory.getSupportedExtractor(kidDbId(k));
                concreteExtractor.castData=obj.castData;

                [varValLeaf,varNameLeaf]=concreteExtractor.extractValue(kidDbId(k));

                if isempty(varNameLeaf)
                    varValue=varValue.addElement(varValLeaf,'');
                else
                    varValue=varValue.addElement(varValLeaf,varNameLeaf);
                end


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

            itemStruct.ParentName=[];
            itemStruct.ParentID=parentID;

            itemStruct.DataSource=metaStruct.FileName;
            itemStruct.FullDataSource=metaStruct.LastKnownFullFile;
            itemStruct.Icon='variable_object.png';
            itemStruct.Type='DataSet';


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


            possibleParentID=0;

        end
    end
end

