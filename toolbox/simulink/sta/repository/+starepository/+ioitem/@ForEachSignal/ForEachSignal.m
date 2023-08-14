classdef ForEachSignal<starepository.ioitem.Container&starepository.ioitem.DataSetChild




    properties
        isLogged=false
BlockPath
BlockPathType
SubPath
PortType
PortIndex
LoggedName
    end

    methods

        function obj=ForEachSignal(ListItems,SignalName)
            obj=obj@starepository.ioitem.Container(ListItems,SignalName);
            obj=obj@starepository.ioitem.DataSetChild;

        end


        function metaData_struct=getMetaData(obj)

            dataFormatStr='';

            if obj.isDataSetElement
                dataFormatStr='datasetElement:';
            end

            if obj.isLogged
                dataFormatStr=[dataFormatStr,'loggedsignal:foreachsubsys'];

                metaData_struct.dataformat=dataFormatStr;
                metaData_struct.Name=obj.Name;
                metaData_struct.BlockPathLength=length(obj.BlockPath);

                if~isempty(obj.BlockPath)
                    metaData_struct.BlockPath=obj.BlockPath{1};
                end
                metaData_struct.SubPath=obj.SubPath;
                metaData_struct.BlockDataProperties=obj.BlockDataProperties;


            else

                dataFormatStr=[dataFormatStr,'foreachsubsys'];

                metaData_struct.dataformat=dataFormatStr;
            end
            metaData_struct.ParentID=obj.RepoParentID;

        end


        function itemstruct=ioitem2Structure(obj)
            itemstruct=ioitem2Structure@starepository.ioitem.Container(obj);
            itemstruct{1}.Type='ForEachSubsystem';
            itemstruct{1}.Icon='foreach_16.png';
        end

    end

end

