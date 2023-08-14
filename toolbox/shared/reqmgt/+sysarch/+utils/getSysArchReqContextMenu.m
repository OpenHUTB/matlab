



function menus=getSysArchReqContextMenu()


    curHlgtedComp=sysarch.getCurrentItem();

    callbackInfo.model=curHlgtedComp.ParentArchitecture;
    callbackInfo.userdata=false;
    callbackInfo.getSelection=curHlgtedComp;
    callbackInfo.uiObject=curHlgtedComp;
    rmiMenuActions.callbackInfo=callbackInfo;
    rmiMenuActions.map=containers.Map();

    schema=rmisl.menus_rmi_object(callbackInfo);
    if isequal(schema{end},'separator')

        schema(end)=[];
    end

    menus=cell(size(schema));

    for k=1:length(schema)
        item=schema{k};

        if isa(item,'function_handle')

            actionSchema=item(callbackInfo);
            rmiMenuActions.map(actionSchema.label)=actionSchema;
            menu.label=actionSchema.label;
            menu.state=actionSchema.state;
            menus{k}=menu;

        elseif iscell(item)&&~isempty(item)

            callbackInfo.userdata=item{2};
            actionSchema=item{1}(callbackInfo);
            rmiMenuActions.map(actionSchema.label)=actionSchema;
            menu.label=actionSchema.label;
            menu.state=actionSchema.state;
            menus{k}=menu;

        elseif isequal(item,'separator')
            menus{k}=item;

        else
            assert(false);
        end
    end
end

