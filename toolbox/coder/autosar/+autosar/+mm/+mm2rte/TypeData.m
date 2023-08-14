classdef TypeData<autosar.mm.mm2rte.RTEData




    methods(Access='public')
        function this=TypeData()
            this=this@autosar.mm.mm2rte.RTEData;
            this.DataItems=containers.Map('KeyType','char','ValueType','any');
            primTypes=autosar.mm.mm2rte.TypeDataItems();
            enumTypes=autosar.mm.mm2rte.TypeDataItems();
            matTypes=autosar.mm.mm2rte.TypeDataItems();
            structTypes=autosar.mm.mm2rte.TypeDataItems();
            voidPtrTypes=autosar.mm.mm2rte.TypeDataItems();

            this.DataItems('Primitive')=primTypes;
            this.DataItems('Enumeration')=enumTypes;
            this.DataItems('Array')=matTypes;
            this.DataItems('Structure')=structTypes;
            this.DataItems('VoidPointer')=voidPtrTypes;
        end

        function insertItem(this,item)

            kind=item.Kind;
            items=this.DataItems(kind);
            items.addItem(item);
        end

        function reorderStructures(this)

            stuctDataItems=this.DataItems('Structure').Items;
            origItems=stuctDataItems;
            newItems=[];









            while(~isempty(origItems))
                for i=1:length(origItems)
                    item=origItems(i);

                    if(i==length(origItems))

                        newItems=[newItems,item];%#ok<AGROW>
                        origItems(i)=[];
                        break;
                    end

                    anyBusElements=any([item.Elements.IsBus]);
                    if~anyBusElements

                        newItems=[newItems,item];%#ok<AGROW>
                        origItems(i)=[];
                        break;
                    else

                        busElements=item.Elements([item.Elements.IsBus]);
                        if isempty(intersect({busElements.Type},{origItems.name}))
                            newItems=[newItems,item];%#ok<AGROW>
                            origItems(i)=[];
                            break;
                        end
                    end
                end
            end
            this.DataItems('Structure')=autosar.mm.mm2rte.TypeDataItems(newItems);
        end
    end

    methods(Static)
        function dataItem=createEnumDataItem(enumName,impTypeName,storageType,nameValuePairs,onTransitionName,onTransitionValue)%#ok<INUSL>
            dataItem=struct(...
            'Kind',...
            'Enumeration',...
            'ImpTypeName',...
            impTypeName,...
            'BaseTypeName',...
            storageType,...
            'NameValuePairs',...
            {nameValuePairs},...
            'OnTransitionName',...
            onTransitionName,...
            'OnTransitionValue',...
            onTransitionValue);
        end
    end
end





