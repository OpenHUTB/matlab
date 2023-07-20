classdef MulticoreSpreadsheet<multicoredesigner.internal.MulticoreDockableComponent





    properties
Columns
Menu
    end

    events
SpreadSheetCloseAction
    end

    methods

        function obj=MulticoreSpreadsheet(uiObj,compName)
            obj=obj@multicoredesigner.internal.MulticoreDockableComponent(uiObj,compName);
            enableHierarchicalView(obj.Component,true);
            obj.Component.onCloseClicked=@(~)obj.handleCloseClicked();
            obj.Component.setConfig('{"expandall":true, "disablepropertyinspectorupdate":true}');
        end

        function close(obj)
            if~isempty(obj.Component)&&isvalid(obj.Component)
                obj.hide();
            end
        end

        function delete(obj)

            if~isempty(obj.Menu)&&isvalid(obj.Menu)
                delete(obj.Menu);
            end

            obj.Menu=[];
        end



        function comp=getComponentType(~)
            comp='GLUE2:SpreadSheet';
        end

        function comp=createDockableComponent(obj)
            comp=GLUE2.SpreadSheetComponent(obj.Studio,obj.ComponentName);
        end

        function update(obj)
            if~isempty(obj.Component)&&isvalid(obj.Component)
                obj.Component.setConfig('{"expandall":true, "disablepropertyinspectorupdate":true}');
                update(obj.Component);
            end
        end



        function handleCloseClicked(obj)
            notify(obj,'SpreadSheetCloseAction');
        end


        function setDataSource(obj,dataSource,varargin)
            obj.Data=dataSource;
            [sortCol,sortDirection]=obj.Data.getSortColumn();
            setColumns(obj.Component,obj.Data.getColumns(),sortCol,obj.Data.getColumnGroup(),sortDirection);
            setSource(obj.Component,obj.Data);
            if nargin>2
                obj.Menu=varargin{1};
                setTitleViewSource(obj.Component,obj.Menu);
            end
        end

        function expand(obj)
            if~isempty(obj.Component)&&isvalid(obj.Component)
                drawnow;
                expandAll(obj.Component);
            end
        end

        function updateColumns(obj)
            [sortCol,sortDirection]=obj.Data.getSortColumn();
            setColumns(obj.Component,obj.Data.getColumns(),sortCol,obj.Data.getColumnGroup(),sortDirection);
            update(obj);
        end

        function setPlaceholderText(obj,text)
            if~isempty(obj.Component)&&isvalid(obj.Component)
                setEmptyListMessage(obj.Component,text);
            end
        end

    end
end


