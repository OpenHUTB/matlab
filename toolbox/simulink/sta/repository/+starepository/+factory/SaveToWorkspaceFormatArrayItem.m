classdef SaveToWorkspaceFormatArrayItem<starepository.factory.ContainerItem









    properties


name

data
    end

    methods
        function obj=SaveToWorkspaceFormatArrayItem(name,data)

            if isStringScalar(name)
                name=char(name);
            end

            obj=obj@starepository.factory.ContainerItem;
            obj.data=data;
            obj.name=name;
        end

        function DataArrayItem=createSignalItemWithoutProperties(obj)
            dataArraySize=size(obj.data);
            UIProperties=starepository.ioitemproperty.SaveToWorkspaceFormatArrayUIProperties;
            columns=dataArraySize(2);
            rows=dataArraySize(1);










            if length(dataArraySize)>2||columns<2
                DataArrayItem=[];



            else
                if columns==2
                    obj.ListItems=cell(1,columns-1);
                    for index=2:columns
                        ts=createTimeSeries(obj.data(:,index),obj.data(:,1));
                        itemname=sprintf('%s(:,%d)',obj.name,index);
                        itemFactory=starepository.factory.createSignalItemFactory(itemname,ts);
                        item=itemFactory.createSignalItem();
                        obj.addListItem(item,index-1);
                        item.UIProperties.isDisplayParentName=false;
                        item.isDataArrayColumn=true;
                        item.DataArrayColNum=index-1;
                    end
                    DataArrayItem=starepository.ioitem.SaveToWorkspaceFormatArray(obj.ListItems,obj.name);
                    DataArrayItem.Data=obj.data;
                else
                    DataArrayItem=starepository.ioitem.DataArray([],obj.name,obj.data);
                end
                DataArrayItem.UIProperties=UIProperties;

            end

        end

        function DataArrayItem=createSignalItemWithoutChildren(obj)
            dataArraySize=size(obj.data);
            UIProperties=starepository.ioitemproperty.SaveToWorkspaceFormatArrayUIProperties;
            columns=dataArraySize(2);









            if length(dataArraySize)>2||columns<2
                DataArrayItem=[];



            else
                if columns==2
                    obj.ListItems=[];

                    DataArrayItem=starepository.ioitem.SaveToWorkspaceFormatArray(obj.ListItems,obj.name);
                else
                    DataArrayItem=starepository.ioitem.DataArray([],obj.name,obj.data);
                end
                DataArrayItem.UIProperties=UIProperties;

            end
        end

        function dataarrayproperty=buildProperties(obj)

            dataarrayproperty=starepository.ioitem.SaveToWorkspaceFormatArrayProperties(obj.name);

            dataarrayproperty.DataType=class(obj.data);
            if isequal(dataarrayproperty.DataType,'embedded.fi')
                var=obj.data;
                numericType=var.numerictype;
                dataarrayproperty.DataType=fixdt(numericType);

                if~license('test','Fixed_Point_Toolbox')
                    try



                        fi;
                    catch err
                        warning(message(err.identifier));
                    end
                end
            end
            if~isreal(obj.data)
                dataarrayproperty.SignalType=getString(message('sl_sta_general:common:Complex'));
            else
                dataarrayproperty.SignalType=getString(message('sl_sta_general:common:Real'));
            end


            dataarrayproperty.SampleTime=-1;



            theDims=size(obj.data);

            numColumnsThatAreData=theDims(2)-1;
            dataarrayproperty.Dimension=numColumnsThatAreData;

        end
    end












    methods(Static)


        function bool=isSupported(dataValue)

            bool=false;





            if ismatrix(dataValue)&&~iscell(dataValue)&&~ischar(dataValue)...
                &&~isempty(dataValue)&&~isstruct(dataValue)&&...
                (all(isnumeric(dataValue))||all(islogical(dataValue)))&&...
                ~iscolumn(dataValue)
                bool=true;
            end
        end

    end
end


