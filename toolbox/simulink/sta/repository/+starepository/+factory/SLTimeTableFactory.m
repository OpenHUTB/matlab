classdef SLTimeTableFactory<starepository.factory.ContainerItem




    properties

name
data
DefaultFactory
        SIGNAL_INDEX=1;
    end


    methods


        function obj=SLTimeTableFactory(name,data)

            if isStringScalar(name)
                name=char(name);
            end
            obj=obj@starepository.factory.ContainerItem;
            obj.data=data;
            obj.name=name;
            obj.DefaultFactory=starepository.factory.DefaultItem(obj.name);
        end


        function slTimeTableItem=createSignalItemWithoutProperties(obj)
            slTimeTableItem=starepository.ioitem.SLTimeTable();
            slTimeTableItem.Name=obj.name;
            slTimeTableItem.Data=obj.data;
            slTimeTableItem.isEnum=isenum(obj.data.(obj.data.Properties.VariableNames{1}));
            slTimeTableItem.Properties=obj.DefaultFactory.buildProperties();
            slTimeTableItem.UIProperties=starepository.ioitemproperty.SignalUIProperties;
        end


        function slTimeTableItem=createSignalItemWithoutChildren(obj)
            slTimeTableItem=starepository.ioitem.SLTimeTable();
            slTimeTableItem.Name=obj.name;
            slTimeTableItem.Data=obj.data;
            slTimeTableItem.Properties=obj.DefaultFactory.buildProperties();
            slTimeTableItem.UIProperties=starepository.ioitemproperty.SignalUIProperties;
        end


        function slTimeTableProperties=buildProperties(obj)

            slTimeTableProperties=obj.DefaultFactory.buildProperties();

            tableData=obj.data.(obj.data.Properties.VariableNames{obj.SIGNAL_INDEX});
            slTimeTableProperties.DataType=class(tableData);

            if isequal(slTimeTableProperties.DataType,'embedded.fi')
                var=tableData;
                numericType=var.numerictype;
                slTimeTableProperties.DataType=fixdt(numericType);

                if~license('test','Fixed_Point_Toolbox')
                    try



                        fi;
                    catch err %#ok<NASGU>
                        uiProperties=obj.Item.UIProperties;
                        uiProperties.State=starepository.ioitemproperty.ItemState.Error;
                    end
                end
            end

            if~isreal(tableData)&&~isstring(tableData)
                slTimeTableProperties.SignalType=getString(message('sl_sta_general:common:Complex'));
            else
                slTimeTableProperties.SignalType=getString(message('sl_sta_general:common:Real'));
            end


            slTimeTableProperties.SampleTime=-1;

            tssize=size(tableData);
            dataDim=tssize(2:end);
            slTimeTableProperties.Dimension=mat2str(dataDim);
        end
    end



    methods(Static)


        function bool=isSupported(dataValue)

            bool=false;

            if isSLTimeTable(dataValue)
                bool=true;
            end
        end

    end
end
