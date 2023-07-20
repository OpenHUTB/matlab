classdef FunctionCall<starepository.ioitem.Item&starepository.ioitem.FunctionCallDataDump



    properties


Data
    end

    properties(Dependent)
UniqueData
UniqueDataCount
    end

    methods

        function obj=FunctionCall
            obj=obj@starepository.ioitem.Item;
        end

        function isitemequalflag=isItemEqual(obj,aItem)
            isitemequalflag=false;
            if aItem.isBus()
                return;
            end
            if~isequal(obj.Data,aItem.Data)
                return;
            end
            if~isequal(class(obj.Data),class(aItem.Data))
                return;
            end
            if~strcmp(obj.Name,aItem.Name)
                return;
            end
            isitemequalflag=true;

        end

        function TreeItem=getTreeItem(obj)
            TreeItem=Simulink.sigselector.SignalItem;
            TreeItem.Name=obj.Name;
            TreeItem.Selected=obj.Selected;
            TreeItem.Icon=obj.UIProperties.Icon;
        end








        function UniqueData=get.UniqueData(obj)
            UniqueData=unique(obj.Data);
        end

        function UniqueDataCount=get.UniqueDataCount(obj)
            UniqueDataCount=histc(obj.Data,obj.UniqueData);
        end

        function flag=isBus(~)
            flag=false;
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
            [~,name,ext]=fileparts(obj.UIProperties.Icon);
            itemstruct.Icon=[name,ext];
            itemstruct.Type=strrep(class(obj),'starepository.ioitem.','');
            itemstruct.TreeOrder=1;
            itemstruct.isString=false;
            itemstruct.DataType='fcn_call';
            itemstruct={itemstruct};

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


            if parentSigID~=0
                jsonStruct{1}.ParentID=parentSigID;
                obj.RepoParentID=parentSigID;
            end

            [sigID,leafSigs,runTimeRange]=staCreateSignal(obj,...
            runID,parentSigID,runTimeRange);
            jsonStruct{1}.ID=sigID;
        end

    end

end
