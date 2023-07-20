function schemas=getMenuInterface(whichMenu,cbinfo)

    schemas={};
    err={};
    try
        switch(whichMenu)
        case 'MenuBar'
            schemas=MenuBar(cbinfo);
        case 'ToolBars'
            schemas=ToolBars(cbinfo);
        case 'EditorContextMenu'
            schemas=EditorContextMenu(cbinfo);
        end
    catch Err
        err=Err;
    end

    if isempty(err)

        if isempty(schemas)&&strcmp(whichMenu,'MenuBar')
            msg=sprintf('%s produced an empty schema.',whichMenu);
            err=MException('Simulink:SchemaError',msg);
        end
    end


    if~isempty(err)
        error_gen=feval('studiotestprivate','dig_get_error_gen','container',err);
        schemas={error_gen};
    end
end

function schemas=MenuBar(cbinfo)
    schemas={@FileMenu};
end

function schema=FileMenu(cbinfo)
    schema=sl_container_schema;
    schema.label='File';
    schema.tag='FileMenu';
    schema.childrenFcns={@New};
end

function schema=New(cbinfo)
    schema=sl_action_schema;
    schema.label='New';
    schema.tag='NewMenuItem';

    schema.callback=@NewCB;
end

function NewCB(cbinfo)
    disp('New Called');
end

function schemas=ToolBars(cbinfo)
    schemas={};
end

function schemas=EditorContextMenu(cbinfo)
    schemas={@New};
end
