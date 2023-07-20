function schema=reqMoveColumn(userdata,~)
    schema=sl_action_schema;
    schema.icon='appendTransitionColumn';
    schema.autoDisableWhen='Locked';
    if strcmp(userdata,'right')
        schema.callback=@reqMoveRightCB;
    else
        schema.callback=@reqMoveLeftCB;
    end
end


function reqMoveRightCB(cbinfo)
    dispatchToContextMenuFcn(cbinfo,'moveColumnRightCB');
end
function reqMoveLeftCB(cbinfo)
    dispatchToContextMenuFcn(cbinfo,'moveColumnLeftCB');
end