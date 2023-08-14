classdef GroundValue<starepository.repositorysignal.RepositorySignal





    properties
        SUPPORTED_FORMATS={'groundorpartialspecifiedbus','datasetElement:groundorpartialspecifiedbus'};
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



            varValue=[];

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
            itemStruct.Icon='ground_16.png';
            itemStruct.Type='GroundOrPartialSpecification';


            itemStruct.isEnum=false;
            itemStruct.isString=false;

            itemStruct.MinTime=[];
            itemStruct.MaxTime=[];
            itemStruct.MinData=[];
            itemStruct.MaxData=[];
            itemStruct.Units='';
            itemStruct.Interpolation='linear';





            itemStruct.BlockPath='';


            itemStruct.TreeOrder=metaStruct.TreeOrder;
            itemStruct.ID=dbId;


            itemStruct.ExternalSourceID=0;

            jsonStruct{1}=itemStruct;




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

