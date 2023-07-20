classdef GroundOrPartialSpecification<starepository.ioitem.Item&starepository.ioitem.DataSetChild&starepository.ioitem.DataDump





    properties
        Data=[];
        BlockPath='';
        isLogged=true
BlockPathType
SubPath
    end


    methods


        function obj=GroundOrPartialSpecification()
            obj=obj@starepository.ioitem.Item;
            obj=obj@starepository.ioitem.DataSetChild;
            obj.UIProperties=starepository.ioitemproperty.GroundOrPartialSpecificationUIProperties();
        end


        function TreeItem=getTreeItem(obj)
            TreeItem=Simulink.sigselector.SignalItem;
            TreeItem.Name=obj.Name;
            TreeItem.Selected=obj.Selected;
            TreeItem.Icon=obj.UIProperties.Icon;
        end



        function busFlag=isBus(~)
            busFlag=false;
        end



        function isitemequalflag=isItemEqual(obj,aItem)
            isitemequalflag=false;


            if isa(aItem,'starepository.item.GroundOrPartialSpecification')&&...
                strcmp(aItem.Name,obj.Name)

                isitemequalflag=true;
            end

        end


        function jsonStruct=initializeRepository(obj,fileName,onFileIndex,runID,parentSigID,...
            runTimeRange)

            obj.isEnum=false;
            obj.isBool=false;


            [~,dataSourceName,ext]=fileparts(fileName);

            obj.FileName=[dataSourceName,ext];
            obj.LastKnownFullFile=fileName;
            obj.OnFileIndex=onFileIndex;


            jsonStruct=ioitem2Structure(obj);


            [sigID,leafSigs,runTimeRange]=staCreateSignal(obj,...
            runID,parentSigID,runTimeRange);
            jsonStruct{1}.ID=sigID;

            if parentSigID~=0
                jsonStruct{1}.ParentID=parentSigID;
            end

        end


        function metaData=getMetaData(obj)
            metaData=[];

            if~obj.isDataSetElement
                metaData.dataformat='groundorpartialspecifiedbus';
            else
                metaData.dataformat='datasetElement:groundorpartialspecifiedbus';
            end

            metaData.ParentID=obj.RepoParentID;
            metaData.FileName=obj.FileName;
            metaData.LastKnownFullFile=obj.LastKnownFullFile;
            tempWhich=which(obj.LastKnownFullFile);
            fileInfo=dir(tempWhich);
            if~isempty(fileInfo)
                metaData.LastModifiedDate=fileInfo.date;
            else
                metaData.LastModifiedDate='';
            end

            metaData.FullName=getFullName(obj);
            metaData.ParentName=obj.ParentName;
        end


        function interpVal=getInterpolation(~)
            interpVal='linear';
        end


        function itemstruct=ioitem2Structure(obj)








            itemstruct.Name=obj.Name;
            itemstruct.ParentName=obj.ParentName;
            itemstruct.ParentID='input';
            if~isempty(obj.ParentID)
                itemstruct.ParentID=obj.ParentID;
            end
            itemstruct.DataSource=obj.FileName;
            itemstruct.FullDataSource=obj.LastKnownFullFile;
            itemstruct.isEnum=false;
            itemstruct.isString=false;

            [~,name,ext]=fileparts('ground_16.png');
            itemstruct.Icon=[name,ext];
            itemstruct.Type=strrep(class(obj),'starepository.ioitem.','');

            itemstruct.MinTime=[];
            itemstruct.MaxTime=[];
            itemstruct.MinData=[];
            itemstruct.MaxData=[];
            itemstruct.Units='';
            itemstruct.Interpolation='linear';
            itemstruct.BlockPath=obj.BlockPath;
            itemstruct.TreeOrder=1;


            itemstruct={itemstruct};

        end


        function numSignals=getNumSignals(~)

            numSignals=0;

        end


    end

end

