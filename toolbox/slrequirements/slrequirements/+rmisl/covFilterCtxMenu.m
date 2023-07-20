function schema=covFilterCtxMenu(callbackInfo)


    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:TraceabilityFilters';
    schema.label='Exclude from Analysis ...';
    schema.userdata{1}=callbackInfo.userdata{1};
    schema.userdata{2}=callbackInfo.userdata{2};
    schema.generateFcn=@createFiltersSchema;
    schema.autoDisableWhen='Busy';
end

function filter_schemas=createFiltersSchema(callbackInfo)
    obj=callbackInfo.userdata{1};
    objFullName=strrep(getStringName(obj),char(10),' ');
    filter_schemas{1}={@CreatePathFilterSchema,{objFullName}};
    filter_schemas{2}={@CreateTypeFilterSchema,{obj}};
    if isa(obj,'Simulink.SubSystem')
        objName=rmi.objname(obj);
        filter_schemas{end+1}={@CreatePathFilterSchema,{[obj.parent,'/',objName,'/*']}};
    end
    inLibrary=callbackInfo.userdata{2}||...
    (isa(obj,'Simulink.Object')&&~isempty(obj.ReferenceBlock));
    if inLibrary
        libName=strtok(obj.ReferenceBlock,'/');
        if~isempty(libName)
            filter_schemas{end+1}={@CreatePathFilterSchema,{libName}};
        end
    end
    if(isa(obj,'Simulink.SubSystem')||isa(obj,'Simulink.Block'))...
        &&obj.isMasked&&~isempty(obj.MaskType)
        filter_schemas{end+1}={@CreateMaskFilterSchema,{obj}};
    end
end

function schema=CreateTypeFilterSchema(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label='all Objects of this Type';
    schema.tag='Simulink:TraceabilityFilterType';
    schema.userdata=callbackInfo.userdata{1};
    schema.callback=@CreateTypeFilterSchema_callback;
    schema.autoDisableWhen='Busy';
end
function CreateTypeFilterSchema_callback(callbackInfo)
    obj=callbackInfo.userdata;
    if isa(obj,'double')
        objType=class(get_param(obj,'Object'));
    else
        objType=class(obj);
    end
    disp(['Filter callback called for type ',objType]);
    filter_callback('type',objType);
end

function schema=CreateMaskFilterSchema(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label='all Masks of this Type';
    schema.tag='Simulink:TraceabilityFilterMask';
    obj=callbackInfo.userdata{1};
    maskName=obj.MaskType;
    schema.userdata={obj,maskName};
    schema.callback=@CreateMaskFilterSchema_callback;
    schema.autoDisableWhen='Busy';
end
function CreateMaskFilterSchema_callback(callbackInfo)

    maskName=callbackInfo.userdata{2};
    disp(['Filter callback called for mask ',maskName]);
    filter_callback('mask',maskName);
end

function schema=CreatePathFilterSchema(callbackInfo)
    schema=DAStudio.ActionSchema;
    obj=callbackInfo.userdata{1};
    if~any(obj=='/')
        schema.label='all References from same Library';
        schema.tag='Simulink:TraceabilityFilterPath';
        schema.userdata{1}=[obj,'/*'];
    elseif obj(end)=='*'
        schema.label='all Ojbects below';
        schema.tag='Simulink:TraceabilityFilterChild';
        schema.userdata{1}=obj;
    else
        schema.label='this Object';
        schema.tag='Simulink:TraceabilityFilterThis';
        schema.userdata{1}=obj;
    end
    schema.callback=@CreatePathFilterSchema_callback;
    schema.autoDisableWhen='Busy';
end
function CreatePathFilterSchema_callback(callbackInfo)
    obj=callbackInfo.userdata{1};
    disp(['Filter path: ',obj]);
    filter_callback('path',obj);
end

function filter_callback(type,value)
    coverageSettings=rmi.settings_mgr('get','coverageSettings');
    switch type
    case 'mask'
        currentFilter=coverageSettings.maskTypeFilters;
        if any(strcmp(currentFilter,value))
            return;
        end
        coverageSettings.maskTypeFilters=unique([currentFilter,value]);
    case 'type'
        currentFilter=coverageSettings.objTypeFilters;
        if any(strcmp(currentFilter,value))
            return;
        end
        coverageSettings.objTypeFilters=unique([currentFilter,value]);
    case 'path'
        currentFilter=coverageSettings.objPathFilters;
        if any(strcmp(currentFilter,value))
            return;
        end
        coverageSettings.objPathFilters=unique([currentFilter,value]);
    otherwise
    end
    rmi.settings_mgr('set','coverageSettings',coverageSettings);

    dlg=rmi_settings_dlg('get');
    if~isempty(dlg)
        try dlg.refresh();
        catch ME %#ok<NASGU>
        end
    end
end

function stringName=getStringName(obj)
    if isa(obj,'Stateflow.Object')
        stringName=[obj.Path,'/',obj.LabelString];
    elseif isa(obj,'Simulink.Object')
        stringName=[obj.Parent,'/',obj.Name];
    else
        stringName=getfullname(obj);
    end
end
