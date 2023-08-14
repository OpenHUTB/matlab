classdef Container<starepository.ioitem.Item&starepository.ioitem.DataDump






    properties


ListItems

    end

    events
ListItemsChanged
    end





    methods


        function jsonStruct=initializeRepository(obj,fileName,onFileIndex,runID,parentSigID,...
            runTimeRange)

            obj.isEnum=false;
            obj.isBool=false;


            [~,dataSourceName,ext]=fileparts(fileName);

            obj.FileName=[dataSourceName,ext];
            obj.LastKnownFullFile=fileName;
            obj.OnFileIndex=onFileIndex;


            jsonStruct=ioitem2Structure(obj);


            [sigID,~,runTimeRange]=staCreateSignal(obj,...
            runID,parentSigID,runTimeRange);
            jsonStruct{1}.ID=sigID;

            if parentSigID~=0
                jsonStruct{1}.ParentID=parentSigID;
            end

            if~isempty(obj.ListItems)




                for k=1:length(obj.ListItems)
                    obj.ListItems{k}.FileModifiedDate=obj.FileModifiedDate;

                    childStruct=initializeRepository(obj.ListItems{k},...
                    fileName,k,runID,jsonStruct{1}.ID,...
                    runTimeRange);


                    sibOrder=sta.ChildOrder();
                    sibOrder.ParentID=sigID;
                    if isfield(childStruct{1},'ComplexID')
                        sibOrder.ChildID=childStruct{1}.ComplexID;
                    else
                        sibOrder.ChildID=childStruct{1}.ID;
                    end
                    sibOrder.SignalOrder=k;


                    jsonStruct=[jsonStruct,childStruct];
                end


            end


            for k=1:length(jsonStruct)

                jsonStruct{k}.TreeOrder=k;
            end


        end

    end

    methods
        function obj=Container(ListItems,BusName)
            obj=obj@starepository.ioitem.Item;
            obj.setName(BusName);


            obj.ListItems=cell(size(ListItems));
            ItemNames=cell(size(ListItems));
            counter=1;
            for k=1:length(ListItems)
                ItemNames{counter}=ListItems{k}.Name;
                obj.ListItems{counter}=ListItems{k};
                ListItems{k}.setParentID(obj.getID());
                counter=counter+1;
            end

            obj.setParentNameOfChildren();
        end

        function isequalflag=isItemEqual(obj,aItem)
            isequalflag=true;
            if~aItem.isBus()
                isequalflag=false;
                return;
            end

            if~isequal(class(obj),class(aItem))
                isequalflag=false;
                return;
            end
            list1=obj.ListItems;
            list2=aItem.ListItems;

            if~isequal(size(list1),size(list2))
                isequalflag=false;
                return;
            end

            if~isequal(obj.Name,aItem.Name)
                isequalflag=false;
                return;
            end
            for i=1:length(list1)

                isequalflag=list1{i}.isItemEqual(list2{i});
                if~isequalflag
                    isequalflag=false;
                    return;
                end
            end

        end

        function flag=isBus(obj)
            flag=true;
        end



    end

    methods


        function setName(obj,Name)
            setName@starepository.ioitem.Item(obj,Name);
            obj.setParentNameOfChildren();
        end

        function setParentName(obj,ParentName)
            setParentName@starepository.ioitem.Item(obj,ParentName);
            obj.setParentNameOfChildren();
        end
    end


    methods(Access='private')

        function setParentNameOfChildren(obj)
            for k=1:length(obj.ListItems)
                obj.setParentNameOfChild(k);
            end
        end

        function setParentNameOfChild(obj,index)
            FullName=obj.getFullName();

            if~isempty(obj.ListItems{index}.UIProperties)&&...
                ~obj.ListItems{index}.UIProperties.isDisplayParentName



                obj.ListItems{index}.setParentName(obj.ParentName);

            else

                obj.ListItems{index}.setParentName(FullName);
            end

        end

    end

end


