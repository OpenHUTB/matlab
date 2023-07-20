


function schema=handlescopemenu(fcnName,cbinfo)
    fcn=str2func(fcnName);
    schema=fcn(cbinfo);
end


function schema=Pan(cbinfo)%#ok<DEFNU>

    baseSchema=sl_action_schema;
    schema=locCreateBaseSchema(baseSchema,cbinfo,'Simulink:HMI:ScopePan');
    if~strcmpi(schema.state,'hidden')
        schema.label=DAStudio.message('SDI:toolStrip:DefaultCursorLabel');
        curVal=locGetScopeWidgetValue(cbinfo,'NormalMode');
        if curVal
            schema.icon='Simulink:HMI:Scope:CheckMark';
        end
        schema.userdata.action='NormalMode';
        schema.callback=@simulink.hmi.handleScopeMenuItem;
    end
end


function schema=Zoom(cbinfo)%#ok<DEFNU>

    baseSchema=sl_action_schema;
    schema=locCreateBaseSchema(baseSchema,cbinfo,'Simulink:HMI:ScopeZoom');
    if~strcmpi(schema.state,'hidden')
        schema.label=DAStudio.message('SDI:toolStrip:ZoomMarqueeLabel');
        curVal=locGetScopeWidgetValue(cbinfo,'ZoomMarquee');
        if curVal
            schema.icon='Simulink:HMI:Scope:CheckMark';
        end
        schema.userdata.action='ZoomMarquee';
        schema.callback=@simulink.hmi.handleScopeMenuItem;
    end
end


function schema=ZoomT(cbinfo)%#ok<DEFNU>

    baseSchema=sl_action_schema;
    schema=locCreateBaseSchema(baseSchema,cbinfo,'Simulink:HMI:ScopeZoomT');
    if~strcmpi(schema.state,'hidden')
        schema.label=DAStudio.message('SDI:toolStrip:ZoomInTLabel');
        curVal=locGetScopeWidgetValue(cbinfo,'ZoomT');
        if curVal
            schema.icon='Simulink:HMI:Scope:CheckMark';
        end
        schema.userdata.action='ZoomT';
        schema.callback=@simulink.hmi.handleScopeMenuItem;
    end
end


function schema=ZoomY(cbinfo)%#ok<DEFNU>

    baseSchema=sl_action_schema;
    schema=locCreateBaseSchema(baseSchema,cbinfo,'Simulink:HMI:ScopeZoomY');
    if~strcmpi(schema.state,'hidden')
        schema.label=DAStudio.message('SDI:toolStrip:ZoomInYLabel');
        curVal=locGetScopeWidgetValue(cbinfo,'ZoomY');
        if curVal
            schema.icon='Simulink:HMI:Scope:CheckMark';
        end
        schema.userdata.action='ZoomY';
        schema.callback=@simulink.hmi.handleScopeMenuItem;
    end
end


function schema=ZoomOut(cbinfo)%#ok<DEFNU>

    baseSchema=sl_action_schema;
    schema=locCreateBaseSchema(baseSchema,cbinfo,'Simulink:HMI:ScopeZoomOut');
    if~strcmpi(schema.state,'hidden')
        schema.label=DAStudio.message('SDI:toolStrip:ZoomOutLabel');
        schema.icon='Simulink:HMI:Scope:ZoomOut';
        schema.userdata.action='ZoomOut';
        schema.callback=@simulink.hmi.handleScopeMenuItem;
    end
end


function schema=FitToView(cbinfo)%#ok<DEFNU>

    baseSchema=sl_action_schema;
    schema=locCreateBaseSchema(baseSchema,cbinfo,'Simulink:HMI:ScopeFitToView');
    if~strcmpi(schema.state,'hidden')
        schema.label=DAStudio.message('SDI:toolStrip:FitWindowLabel');
        schema.icon='Simulink:HMI:Scope:FitToView';
        schema.userdata.action='FitToView';
        schema.callback=@simulink.hmi.handleScopeMenuItem;
    end
end


function schema=FitToViewInTime(cbinfo)%#ok<DEFNU>

    baseSchema=sl_action_schema;
    schema=locCreateBaseSchema(baseSchema,cbinfo,'Simulink:HMI:ScopeFitToViewInTime');
    if~strcmpi(schema.state,'hidden')
        schema.label=DAStudio.message('SDI:toolStrip:FitInTLabel');
        schema.userdata.action='FitToViewInTime';
        schema.callback=@simulink.hmi.handleScopeMenuItem;
    end
end


function schema=FitToViewInY(cbinfo)%#ok<DEFNU>

    baseSchema=sl_action_schema;
    schema=locCreateBaseSchema(baseSchema,cbinfo,'Simulink:HMI:ScopeFitToViewInY');
    if~strcmpi(schema.state,'hidden')
        schema.label=DAStudio.message('SDI:toolStrip:FitInYLabel');
        schema.userdata.action='FitToViewInY';
        schema.callback=@simulink.hmi.handleScopeMenuItem;
    end
end


function schema=DataCursors(cbinfo)%#ok<DEFNU>

    baseSchema=sl_action_schema;
    baseSchema=locCreateBaseSchema(baseSchema,cbinfo,'Simulink:HMI:ScopeDataCursors');
    if~strcmpi(baseSchema.state,'hidden')
        schema=sl_container_schema;
        schema.tag='ScopeDataCursors';
        schema.label=DAStudio.message('SDI:toolStrip:DataCursors');
        im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
        schema.childrenFcns={...
        im.getAction('Simulink:HMI:Scope:DataCursors:1'),...
        im.getAction('Simulink:HMI:Scope:DataCursors:2'),...
        im.getAction('Simulink:HMI:Scope:DataCursors:None')...
        };
    else
        schema=baseSchema;
    end
end


function schema=DataCursorsOne(cbinfo)%#ok<DEFNU>

    schema=sl_action_schema;
    schema.tag='Simulink:HMI:ScopeDataCursorsOne';
    schema.label=DAStudio.message('SDI:toolStrip:ShowOneCursor');
    curVal=locGetScopeWidgetValue(cbinfo,'DataCursors');
    if curVal==1
        schema.icon='Simulink:HMI:Scope:CheckMark';
    end
    schema.userdata.action='DataCursorOne';
    schema.callback=@simulink.hmi.handleScopeMenuItem;
end


function schema=DataCursorsTwo(cbinfo)%#ok<DEFNU>

    schema=sl_action_schema;
    schema.tag='Simulink:HMI:ScopeDataCursorsTwo';
    schema.label=DAStudio.message('SDI:toolStrip:ShowTwoCursors');
    curVal=locGetScopeWidgetValue(cbinfo,'DataCursors');
    if curVal==2
        schema.icon='Simulink:HMI:Scope:CheckMark';
    end
    schema.userdata.action='DataCursorTwo';
    schema.callback=@simulink.hmi.handleScopeMenuItem;
end


function schema=DataCursorsNone(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:HMI:ScopeDataCursorsNone';
    schema.label=DAStudio.message('SDI:toolStrip:HideAllCursors');
    curVal=locGetScopeWidgetValue(cbinfo,'DataCursors');
    if curVal==0
        schema.icon='Simulink:HMI:Scope:CheckMark';
    end
    schema.userdata.action='DataCursorNone';
    schema.callback=@simulink.hmi.handleScopeMenuItem;
end


function schema=locCreateBaseSchema(schema,cbinfo,tag)

    schema.tag=tag;
    if~locIsHMIScopeBlock(cbinfo)
        schema.state='hidden';
    end
end


function ret=locIsHMIScopeBlock(cbinfo)

    ret=false;
    btype=get_param(cbinfo.target.handle,'blockType');
    if strcmp(btype,'DashboardScope')
        ret=true;
    elseif strcmp(btype,'SubSystem')&&strcmp(get_param(cbinfo.target.handle,'isWebBlock'),'on')
        try
            webBlockType=get(cbinfo.target.handle,'webBlockType');
            ret=strcmp(webBlockType,'sdiscope');
        catch me %#ok<NASGU>
            ret=false;
        end
    end
end


function widget=locGetScopeWidget(cbinfo)

    blkH=cbinfo.target.handle;
    instanceId=utils.getInstanceId(get_param(blkH,'object'));
    isLibWidget=utils.getIsLibWidget(get_param(blkH,'object'));
    widget=utils.getWidget(cbinfo.model.Name,instanceId,isLibWidget);
end


function ret=locGetScopeWidgetValue(cbinfo,prop)
    btype=get_param(cbinfo.target.handle,'blockType');
    if strcmp(btype,'SubSystem')
        widget=locGetScopeWidget(cbinfo);
        ret=widget.getProperty(prop);
        return
    end

    switch prop
    case{'NormalMode','ZoomMarquee','ZoomT','ZoomY'}
        curMode=get_param(cbinfo.target.handle,'ZoomMode');
        ret=strcmpi(curMode,prop);
    case 'DataCursors'
        ret=str2double(get_param(cbinfo.target.handle,'CursorMode'));
    otherwise
        assert(0);
    end
end