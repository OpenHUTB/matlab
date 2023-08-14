classdef EmptyLoggedVariant<starepository.ioitem.Item&starepository.ioitem.DataSetChild&starepository.ioitem.DataDump





    properties
        Data=timeseries.empty;
        BlockPath='';
        isLogged=true
BlockPathType
SubPath
    end


    methods


        function obj=EmptyLoggedVariant()
            obj=obj@starepository.ioitem.Item;
            obj=obj@starepository.ioitem.DataSetChild;
            obj.UIProperties=starepository.ioitemproperty.SignalUIProperties;
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


            if isa(aItem,'starepository.ioitem.EmptyLoggedVariant')&&...
                strcmp(aItem.Name,obj.Name)

                isitemequalflag=true;
            end

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

            [~,name,ext]=fileparts(obj.UIProperties.Icon);
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


        function metaData=getMetaData(obj)
            metaData=[];
            metaData.Value=obj.Data;
            metaData.dataformat='variantsink';
        end

    end

end

