classdef dynamicPopups

    methods(Static)
        function gw=filterValuePopupList(columnId,cbinfo)
            pm_assert(~isempty(cbinfo));
            pm_assert(~isempty(columnId));

            obj=cbinfo.Context.Object;
            [filterValues,selectedFilters]=simscape_variable_viewer_get_filter_values(...
            obj.ModelHandle,columnId);

            if~isKey(obj.ColumnToFilterMap,columnId)
                obj.ColumnToFilterMap(columnId)=selectedFilters;
            end

            gw=dig.GeneratedWidget(cbinfo.EventData.namespace,cbinfo.EventData.type);

















            for idx=1:numel(filterValues)
                itemId=['item',int2str(idx)];
                actionName=[itemId,'FilterValueAction'];
                action=gw.createAction(actionName);
                action.text=filterValues{idx};
                action.enabled=true;
                action.selected=any(strcmp(filterValues{idx},selectedFilters));
                action.closePopupOnClick=false;
                action.eventDataType=dig.model.EventDataType.Boolean;
                fcn=@(cbInfo)simscape.state.internal.toolstrip.columnFilterCallbacks(...
                cbInfo,columnId,filterValues,{},filterValues{idx},'');
                action.setCallbackFromArray(fcn,dig.model.FunctionType.Action);

                item=gw.Widget.addChild('ListItemWithCheckBox',itemId);
                item.ActionId=[gw.Namespace,':',actionName];
            end
            item=gw.Widget.addChild('PopupListHeader',[columnId,'ApplyHeader']);

            if strcmpi(columnId,simscape.state.internal.toolstrip.dynamicPopups.getMessage(...
                'physmod:common:dataservices:gui:app:ColumnNominalUnitsId'))
                displayTxt=simscape.state.internal.toolstrip.dynamicPopups.getMessage(...
                'physmod:common:dataservices:gui:app:ColumnNominalUnits');
            elseif strcmpi(columnId,simscape.state.internal.toolstrip.dynamicPopups.getMessage(...
                'physmod:common:dataservices:gui:app:ColumnNominalSourceId'))
                displayTxt=simscape.state.internal.toolstrip.dynamicPopups.getMessage(...
                'physmod:common:dataservices:gui:app:ColumnNominalSource');
            else
                displayTxt=columnId;
            end
            item.Label=simscape.state.internal.toolstrip.dynamicPopups.getMessage(...
            'physmod:common:dataservices:gui:app:ButtonApplyFiltersHeader',upper(displayTxt));
            actionName=[columnId,'ApplyFiltersAction'];
            action=gw.createAction(actionName);
            action.text=simscape.state.internal.toolstrip.dynamicPopups.getMessage(...
            'physmod:common:dataservices:gui:app:ButtonApply');
            action.enabled=true;
            action.closePopupOnClick=true;
            fcn=@(cbInfo)simscape.state.internal.toolstrip.columnFilterCallbacks(...
            cbInfo,columnId,{},selectedFilters,'','apply');
            action.setCallbackFromArray(fcn,dig.model.FunctionType.Action);
            item=gw.Widget.addChild('ListItem',[columnId,'ApplyListIttem']);
            item.ActionId=[gw.Namespace,':',actionName];
        end

        function gw=showColumnsPopupList(userData,cbInfo)



            pm_assert(~isempty(cbInfo));
            pm_assert(~isempty(userData));

            obj=cbInfo.Context.Object;
            gw=dig.GeneratedWidget(cbInfo.EventData.namespace,...
            cbInfo.EventData.type);

            [columnIds,columnNames,visibleColumnIds]=...
            simscape_variable_viewer_get_columns(obj.ModelHandle);

            pm_assert(length(columnIds)==length(columnNames));
            if isempty(obj.VisibleColumns)
                obj.VisibleColumns=visibleColumnIds;
            end
            for idx=1:numel(columnIds)
                actionName=[columnIds{idx},'ColumnAction'];
                action=gw.createAction(actionName);
                action.text=columnNames{idx};
                action.enabled=true;
                action.selected=any(strcmp(columnIds{idx},visibleColumnIds));


                if strcmpi(columnIds{idx},simscape.state.internal.toolstrip.dynamicPopups.getMessage(...
                    'physmod:common:dataservices:gui:app:ColumnNameId'))
                    action.enabled=false;
                    action.selected=true;
                end
                action.closePopupOnClick=false;
                action.eventDataType=dig.model.EventDataType.Boolean;

                fcn=@(cbInfo)simscape.state.internal.toolstrip.columnCallbacks(...
                cbInfo,userData,columnIds{idx});
                action.setCallbackFromArray(fcn,dig.model.FunctionType.Action);

                item=gw.Widget.addChild('ListItemWithCheckBox',[columnIds{idx},'CheckBox']);
                item.ActionId=[gw.Namespace,':',actionName];
            end
            item=gw.Widget.addChild('PopupListHeader',[userData,'ApplyHeader']);
            item.Label=simscape.state.internal.toolstrip.dynamicPopups.getMessage(...
            'physmod:common:dataservices:gui:app:ButtonShowColumnsApplyHeader');
            actionName=[userData,'ApplyFiltersAction'];
            action=gw.createAction(actionName);
            action.text=simscape.state.internal.toolstrip.dynamicPopups.getMessage(...
            'physmod:common:dataservices:gui:app:ButtonApply');
            action.enabled=true;
            action.closePopupOnClick=true;
            fcn=@(cbInfo)simscape.state.internal.toolstrip.columnCallbacks(...
            cbInfo,userData,columnIds{idx},'apply');
            action.setCallbackFromArray(fcn,dig.model.FunctionType.Action);
            item=gw.Widget.addChild('ListItem',[userData,'ApplyListIttem']);
            item.ActionId=[gw.Namespace,':',actionName];
        end

        function gw=filterColumnsPopupList(userData,cbInfo)



            pm_assert(~isempty(cbInfo));
            pm_assert(~isempty(userData));

            obj=cbInfo.Context.Object;
            gw=dig.GeneratedWidget(cbInfo.EventData.namespace,...
            cbInfo.EventData.type);

            [columnIds,columnNames,visibleColumnIds]=...
            simscape_variable_viewer_get_filterable_columns(obj.ModelHandle);

            pm_assert(length(columnIds)==length(columnNames));
            for idx=1:numel(columnIds)
                if any(strcmp(columnIds{idx},visibleColumnIds)==1)
                    actionName=[columnIds{idx},'FilterAction'];
                    action=gw.createAction(actionName);
                    action.text=columnNames{idx};
                    action.enabled=true;
                    action.closePopupOnClick=false;

                    fcn=@(cbInfo)simscape.state.internal.toolstrip.columnCallbacks(...
                    cbInfo,userData,columnIds{idx});
                    action.setCallbackFromArray(fcn,dig.model.FunctionType.Action);

                    item=gw.Widget.addChild('ListItemWithPopup',[columnIds{idx},'ListItem']);
                    item.ActionId=[gw.Namespace,':',actionName];
                    item.PopupName=[columnIds{idx},'ListItemPopup'];
                end
            end
        end
    end


    methods(Static,Access=private)
        function msg=getMessage(msgId,in)
            if nargin==2
                msg=message(msgId,in).getString();
            else
                msg=message(msgId).getString();
            end
        end

























    end
end