classdef SaveToWorkspaceFormatArray<starepository.ioitem.Container&starepository.ioitem.DataSetChild&starepository.ioitem.DataArrayDataDump



    properties
Data

    end

    methods
        function obj=SaveToWorkspaceFormatArray(ListItems,BusName)
            obj=obj@starepository.ioitem.Container(ListItems,BusName);
            obj=obj@starepository.ioitem.DataSetChild;

        end

    end

end

