classdef ForEachSubSysItem<starepository.factory.ContainerItem




    properties


name

data

    end

    methods


        function obj=ForEachSubSysItem(name,data)

            if isStringScalar(name)
                name=char(name);
            end

            obj=obj@starepository.factory.ContainerItem;
            obj.data=data;
            obj.name=name;
        end


        function ForEachItem=createSignalItemWithoutProperties(obj)

            allSignals=obj.data;
            obj.ListItems=cell(1,numel(obj.data));
            itemcounter=0;

            sizeOfData=size(obj.data);

            IS_TIME_TABLE=iscell(obj.data);

            for index=1:length(obj.ListItems)

                ind2SubStr=getIndexText(obj,sizeOfData,index);

                if IS_TIME_TABLE
                    itemFactory=starepository.factory.createSignalItemFactory([obj.name,ind2SubStr],obj.data{index});
                else
                    itemFactory=starepository.factory.createSignalItemFactory([obj.name,ind2SubStr],obj.data(index));
                end

                if~isempty(itemFactory)
                    item=itemFactory.createSignalItem();
                    if~isempty(item)
                        itemcounter=itemcounter+1;
                        obj.addListItem(item,itemcounter);
                    end
                end
            end
            if isempty(obj.ListItems)||isequal(itemcounter,0)
                ForEachItem=[];
            else
                listitems=obj.ListItems(1:itemcounter);
                ForEachItem=starepository.ioitem.ForEachSignal(listitems,obj.name);
                ForEachItem.UIProperties=starepository.ioitemproperty.BusUIProperties;


            end

        end


        function ForEachItem=createSignalItemWithoutChildren(obj)
            listitems=[];
            ForEachItem=starepository.ioitem.Bus(listitems,obj.name);
            ForEachItem.UIProperties=starepository.ioitemproperty.BusUIProperties;

        end


        function busproperty=buildProperties(obj)

            busproperty=starepository.ioitem.BusProperties(obj.name);

        end

        function ind2SubStr=getIndexText(obj,theSize,idx)%#ok<INUSL>
            nDims=length(theSize);

            if nDims==2&&any(theSize==1)
                ind2SubStr=['(',num2str(idx),')'];
                return;
            end

            evalStr='[';
            for dimK=1:nDims
                evalStr=[evalStr,['dim',num2str(dimK)],' '];
            end

            evalStr=[evalStr,'] = ind2sub(theSize,idx);'];
            eval(evalStr);
            ind2SubStr='( ';
            for dimK=1:nDims

                if dimK==nDims
                    ind2SubStr=[ind2SubStr,num2str(eval(['dim',num2str(dimK)])),' '];
                else
                    ind2SubStr=[ind2SubStr,num2str(eval(['dim',num2str(dimK)])),', '];
                end
            end

            ind2SubStr=[ind2SubStr,')'];

        end
    end



    methods(Static)


        function bool=isSupported(dataValue)

            bool=false;




            if(isa(dataValue,'timeseries')&&...
                ~isempty(dataValue)&&...
                ~isscalar(dataValue))||...
                (iscell(dataValue)&&...
                all(cellfun(@isSLTimeTable,dataValue)))
                bool=true;
            end
        end

    end

end

