function schema=reqMove(userdata,~)
    schema=sl_action_schema;
    schema.icon='appendTransitionColumn';
    schema.autoDisableWhen='Locked';
    if strcmp(userdata,'up')
        schema.callback=@reqMoveUpCB;
    else
        schema.callback=@reqMoveDownCB;
    end
end


function reqMoveUpCB(cbinfo)
    dispatchToContextMenuFcn(cbinfo,'moveUpRowCB');
end
function reqMoveDownCB(cbinfo)
    dispatchToContextMenuFcn(cbinfo,'moveDownRowCB');
end