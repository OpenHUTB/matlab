classdef SaveToWorkspaceFormatStructItem<starepository.factory.ContainerItem





    properties


name


data
    end

    methods
        function obj=SaveToWorkspaceFormatStructItem(name,data)

            if isStringScalar(name)
                name=char(name);
            end
            obj=obj@starepository.factory.ContainerItem;
            obj.data=data;
            obj.name=name;
        end

        function Item=createSignalItemWithoutProperties(obj)
            obj.ListItems=cell(size(obj.data.signals));
            for index=1:length(obj.ListItems)
                signal=obj.data.signals(index);
                if isempty(obj.data.time)

                    ts=timeseries(signal.values);
                else


                    ts=createTimeSeries(signal.values,obj.data.time);
                end


                factory=starepository.factory.createSignalItemFactory(signal.label,ts);
                item=factory.createSignalItem();
                item.isStructSignal=true;


                isFromWorkspaceBlock=false;
                fromWorkspaceBlockSigName='';



                if isfield(signal,'blockName')
                    item.BlockName=signal.blockName;
                else
                    isFromWorkspaceBlock=true;
                    fromWorkspaceBlockSigName=obj.data.blockName;
                end
                obj.addListItem(item,index);
            end
            Item=starepository.ioitem.SaveToWorkspaceFormatStruct(obj.ListItems,obj.name);
            if isempty(obj.data.time)
                Item.StructureWithTime=false;
            else
                Item.StructureWithTime=true;
            end
            Item.isFromWorkspaceBlock=isFromWorkspaceBlock;
            Item.fromWorkspaceBlockSignalName=fromWorkspaceBlockSigName;
            Item.UIProperties=starepository.ioitemproperty.SaveToWorkspaceFormatStructUIProperties;

        end

        function Item=createSignalItemWithoutChildren(obj)
            listitems=[];
            Item=starepository.ioitem.SaveToWorkspaceFormatStruct(listitems,obj.name);
            Item.UIProperties=starepository.ioitemproperty.SaveToWorkspaceFormatStructUIProperties;

        end

        function property=buildProperties(obj)

            property=starepository.ioitem.BusProperties(obj.name);
        end
    end



    methods(Static)


        function bool=isSupported(dataValue)
            bool=false;



            if(isstruct(dataValue)&&~isempty(fieldnames(dataValue)))&&...
                length(dataValue)==1&&...
                all(isfield(dataValue,{'time','signals'}))

                bool=true;

            end
        end

    end

end

