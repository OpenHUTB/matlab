function gw=generateGotoPopup(cbinfo)




    gw=dig.GeneratedWidget(cbinfo.EventData.namespace,cbinfo.EventData.type);




    headerFcn=gw.Widget.addChild('PopupListHeader','slmleGotoFunctions');
    headerFcn.Label='FUNCTIONS';

    mgr=slmle.internal.slmlemgr.getInstance;
    saEd=cbinfo.studio.App.getActiveEditor;
    editor=mgr.getMLFBEditorByStudioAdapter(saEd);

    if~isempty(editor)
        fncList=editor.functionList;
    end

    for i=1:numel(fncList)
        loc_createFncListItems(gw,fncList(i),i);
    end




    headerLine=gw.Widget.addChild('PopupListHeader','slmleGotoLine');
    headerLine.Label='LINE';

    itemName='slmleGotoLinePopupListItem';
    item=gw.Widget.addChild('ListItem',itemName);
    item.ActionId='slmleGotoLinePopupAction';
end

function loc_createFncListItems(gw,fnc,idx)

    actionName=['slmleGotoFxnAction_',num2str(idx)];
    action=gw.createAction(actionName);
    fnc=fnc.x_data;
    action.text=fnc.name;
    action.setCallbackFromArray(@(cbinfo)loc_gotoFunction(cbinfo,fnc.startLine),dig.model.FunctionType.Action);
    action.enabled=true;
    action.optOutLocked=true;
    action.optOutBusy=true;



    itemName=['slmleGotoFxnListItem_',num2str(idx)];
    item=gw.Widget.addChild('ListItem',itemName);
    item.ActionId=[gw.Namespace,':',actionName];
end

function loc_gotoFunction(cbinfo,startLine)


    slmle.internal.toolstrip.Callbacks.goto('goto_functions',cbinfo,startLine)
end
