classdef DataTipMixin<matlab.graphics.mixin.Mixin













    properties(Access=protected,Dependent)
DataTipVariables
    end

    properties(Access=protected,Constant)
        MAX_OPTIONS=10
    end

    properties(AffectsObject,Access=protected)

        DataTipConfigurationMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(AffectsObject,Access=private)

        DataTipConfiguration_I string=string.empty(0,1)
    end

    properties(Transient,NonCopyable,Access=protected)


        ContextMenu=matlab.graphics.GraphicsPlaceholder.empty(0,0)
    end

    properties(Dependent,Abstract)
SourceTable
    end

    properties(Transient,NonCopyable,Access=protected)


DataTipsDialog
    end

    methods(Abstract,Access=protected)


        getDefaultDataTipConfiguration(obj)
    end

    methods(Hidden)

        function var=getDataTipVariables(obj)
            var=obj.getDataTipConfiguration();
        end
    end

    methods(Access=protected)



        function showContextMenu(obj,evd)

            if evd.Button==3
                if isempty(obj.ContextMenu)
                    obj.initializeContextMenu();
                end
                hMenu=obj.ContextMenu;


                addTableOptions(obj,hMenu.Children(2));


                hFig=ancestor(obj,'figure','node');

                figPoint=hFig.CurrentPoint;
                figPoint=hgconvertunits(hFig,[figPoint,0,0],hFig.Units,'pixels',hFig);
                figPoint=figPoint(1:2);
                hMenu.Position=figPoint;

                hgfeval(hMenu.Callback,hMenu,[]);
                hMenu.Visible='on';
            end
        end

        function dtConfig=getDataTipConfiguration(obj)
            dtConfig=obj.DataTipConfiguration_I;
        end

        function setDataTipConfiguration(obj,dtConf)
            obj.DataTipConfiguration_I=dtConf;
            obj.DataTipConfigurationMode='manual';
            obj.updateDialogIfNeeded();
        end

        function delete(obj)
            delete(obj.ContextMenu);
            delete(obj.DataTipsDialog);
        end






        function initializeContextMenu(obj)
            hFig=ancestor(obj,'figure','node');
            hMenu=uicontextmenu(hFig);
            uimenu(hMenu,'Text',getString(message('MATLAB:graphics:datatip:ModifyOption')),...
            'Tag','ModifyDataTipOption');
            uimenu(hMenu,'Text',getString(message('MATLAB:graphics:datatip:ResetOption')),...
            'Tag','ResetDataTip',...
            'MenuSelectedFcn',@(e,d)obj.resetDataTipConfiguration());
            obj.ContextMenu=hMenu;
        end

        function resetDataTipConfiguration(obj)
            obj.setDataTipConfiguration(obj.getDefaultDataTipConfiguration());
            obj.DataTipConfigurationMode='auto';
        end



        function validateAndSetDataTipConfiguration(obj,dtConf)
            tbl=obj.SourceTable;
            for i=1:numel(dtConf)
                [dtConf{i},~,err]=...
                matlab.graphics.chart.internal.validateTableSubscript(...
                tbl,dtConf{i},'DataTipConfiguration');
                if~isempty(err)&&~strcmpi(dtConf{i},tb1.Properties.DimensionNames{1})
                    throwAsCaller(err);
                end
            end
            obj.DataTipConfiguration_I=dtConf;
        end

        function clearDataTipConfiguration(obj)
            obj.DataTipConfiguration_I=[];
        end

        function initializeDataTipConfiguration(obj)
            if strcmp(obj.DataTipConfigurationMode,'auto')
                obj.DataTipConfiguration_I=obj.getDefaultDataTipConfiguration();
                obj.updateDialogIfNeeded();
            end
        end

    end

    methods(Access=protected)



        function addTableOptions(obj,parentMenu)
            delete(parentMenu.Children);
            tbl=obj.SourceTable;
            totalOptions=[tbl.Properties.VariableNames,tbl.Properties.DimensionNames{1}];
            selectedOptions=obj.getDataTipVariables();

            unSelectedOptions=setdiff(totalOptions,selectedOptions);

            for i=1:obj.MAX_OPTIONS
                if numel(selectedOptions)<i
                    break;
                end
                uimenu(parentMenu,'Text',selectedOptions{i},...
                'Tag',selectedOptions{i},...
                'MenuSelectedFcn',@(e,d)updateDataTipConfiguration(obj,d),...
                'Checked','on');
            end

            for j=1:(obj.MAX_OPTIONS-i+1)
                if numel(unSelectedOptions)<j
                    break;
                end

                u=uimenu(parentMenu,'Text',unSelectedOptions{j},...
                'Tag',unSelectedOptions{j},...
                'MenuSelectedFcn',@(e,d)updateDataTipConfiguration(obj,d));
                if j==1
                    u.Separator='on';
                end
            end


            uimenu(parentMenu,'Text',getString(message('MATLAB:graphics:datatip:MoreOption')),...
            'ForegroundColor','blue',...
            'Tag','MoreOption',...
            'Separator','on',...
            'MenuSelectedFcn',@(e,d)openDialogToEdit(obj));
        end



        function updateDataTipConfiguration(obj,eventobj)
            obj.DataTipConfigurationMode='manual';
            dtConfig=obj.DataTipConfiguration_I;
            if strcmpi(eventobj.Source.Checked,'off')
                dtConfig{end+1}=eventobj.Source.Text;
                eventobj.Source.Checked='on';
            else
                dtConfig(ismember(dtConfig,eventobj.Source.Text))=[];
                eventobj.Source.Checked='off';
            end
            obj.setDataTipConfiguration(dtConfig);
        end


        function openDialogToEdit(obj)
            if isempty(obj.DataTipsDialog)||~isvalid(obj.DataTipsDialog)
                obj.DataTipsDialog=matlab.graphics.datatip.internal.mixin.dialogs.DataTipsDialog(obj);
            end
            obj.DataTipsDialog.bringToFront();
        end

        function updateDialogIfNeeded(obj)
            if~isempty(obj.DataTipsDialog)&&isvalid(obj.DataTipsDialog)
                obj.DataTipsDialog.updateOptions();
            end
        end
    end

    methods(Access={?matlab.graphics.datatip.internal.mixin.dialogs.AggregatedDataTipsDialog,...
        ?matlab.graphics.datatip.internal.mixin.dialogs.DataTipsDialog})

        function dtConfig=getConfiguration(obj)
            dtConfig=obj.getDataTipConfiguration();
        end

        function setConfiguration(obj,dtConf)
            obj.setDataTipConfiguration(dtConf);
        end
    end

    methods(Access=?tDataTip)
        function hDialog=getDataTipDialog(obj)
            hDialog=obj.DataTipsDialog;
        end
    end
end