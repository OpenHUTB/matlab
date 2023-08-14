function gw=generateColumnVisibilityPopup(cbinfo)




    ed=Simulink.typeeditor.app.Editor.getInstance;
    cb=@(colName,arg)Simulink.typeeditor.actions.toggleColumnVisibility(colName,arg);

    if ed.isVisible
        gw=dig.GeneratedWidget(cbinfo.EventData.namespace,cbinfo.EventData.type);
        generatePropertyList;
    end

    function generatePropertyList
        lc=ed.getListComp;
        colConfig=lc.getColumnWidths;
        colNames={jsondecode(colConfig).columns.name};

        endChar='_';
        if slfeature('TypeEditorStudio')==0
            props=Simulink.typeeditor.app.Editor.getHeterogeneousColumns;
        else
            cv=ed.getColumnView;
            if strcmp(cv,'Simulink:busEditor:ColumnsDefaultView')
                props=Simulink.typeeditor.app.Editor.getPropertiesForDefaultView;
            else
                props=Simulink.typeeditor.app.Editor.getColumnsForView(cv);
            end
        end
        props=props(~strcmp(DAStudio.message('Simulink:busEditor:PropElementName'),props));
        listSepCtr=0;
        listHeaderCtr=0;
        for i=1:length(props)
            if isempty(props{i})
                listSepCtr=listSepCtr+1;
                itemName=sprintf('ListSeparator%d',listSepCtr);
                item=gw.Widget.addChild('PopupListSeparator',itemName);
                item.ActionId='';
            elseif startsWith(props{i},endChar)&&endsWith(props{i},endChar)
                listHeaderCtr=listHeaderCtr+1;
                itemName=sprintf('ListHeader%d',listHeaderCtr);
                item=gw.Widget.addChild('PopupListHeader',itemName);
                item.Label=props{i}(2:end-1);
            else
                itemName=sprintf('toggleColumnsItem%d',i);
                item=gw.Widget.addChild('ListItemWithCheckBox',itemName);
                actionName=sprintf('toggleColumnsAction%d',i);
                item.ActionId=[gw.Namespace,':',actionName];

                action=gw.createAction(actionName);
                action.enabled=true;
                viewName=props{i};
                action.text=viewName;
                action.closePopupOnClick=false;
                action.selected=any(strcmp(viewName,colNames));
                action.qabEligible=false;
                action.setCallbackFromArray(@(arg)cb(viewName,arg),dig.model.FunctionType.Action);
                action.eventDataType=dig.model.EventDataType.Any;
            end
        end
    end
end
