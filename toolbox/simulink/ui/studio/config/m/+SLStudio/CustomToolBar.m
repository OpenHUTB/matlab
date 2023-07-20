function schemas=CustomToolBar(cbinfo)
    schemas={};

    isModel=strcmpi(cbinfo.model.BlockDiagramType,'model');
    isSubsystem=strcmpi(cbinfo.model.BlockDiagramType,'subsystem');

    children={};
    if isa(cbinfo.domain,'SLM3I.SLDomain')
        children=customMenuSchema(cbinfo,'Simulink','File');
        children=[children,customMenuSchema(cbinfo,'Simulink','Edit')];
        children=[children,customMenuSchema(cbinfo,'Simulink','View')];
        children=[children,customMenuSchema(cbinfo,'Simulink','Display')];
        children=[children,customMenuSchema(cbinfo,'Simulink','Diagram')];
        if isModel
            children=[children,customMenuSchema(cbinfo,'Simulink','Simulation')];
        end
        children=[children,customMenuSchema(cbinfo,'Simulink','Analysis')];
        if isModel
            children=[children,customMenuSchema(cbinfo,'Simulink','Code')];
        end
        if isModel||isSubsystem
            children=[children,customMenuSchema(cbinfo,'Simulink','Tools')];
        end
        children=[children,customMenuSchema(cbinfo,'Simulink','MenuBar')];
        children=[children,customMenuSchema(cbinfo,'Simulink','Help')];
    elseif isa(cbinfo.domain,'StateflowDI.SFDomain')
        children=customMenuSchema(cbinfo,'Stateflow','File');
        children=[children,customMenuSchema(cbinfo,'Stateflow','Edit')];
        children=[children,customMenuSchema(cbinfo,'Stateflow','View')];
        children=[children,customMenuSchema(cbinfo,'Simulink','Display')];
        children=[children,customMenuSchema(cbinfo,'Stateflow','Chart')];
        if isModel
            children=[children,customMenuSchema(cbinfo,'Stateflow','Simulation')];
        end
        children=[children,customMenuSchema(cbinfo,'Simulink','Analysis')];
        children=[children,customMenuSchema(cbinfo,'Simulink','Code')];
        if isModel||isSubsystem
            children=[children,customMenuSchema(cbinfo,'Stateflow','Tools')];
        end
        children=[children,customMenuSchema(cbinfo,'Stateflow','MenuBar')];
        children=[children,customMenuSchema(cbinfo,'Stateflow','Help')];
    end

    if~isempty(children)
        schemas={@(cbinfo)toolBarSchema(cbinfo,children)};
    end
end

function schemas=customMenuSchema(~,domain,menu)
    schemas={};
    if strcmpi(menu,'MenuBar')
        customSchemas=cm_get_custom_schemas([domain,':MenuBar']);
        if~isempty(customSchemas)
            schemas=cell(1,length(customSchemas));
            for index=1:length(customSchemas)
                if ischar(customSchemas{index})
                    schemas{index}=customSchemas{index};
                else
                    schemas{index}=@(cbinfo)convertMenuBarSchema(cbinfo,customSchemas{index});
                end
            end
        end
    else
        customSchemas=cm_get_custom_schemas([domain,':',menu,'Menu']);
        if strcmpi(menu,'Chart')
            customAddSchemas=cm_get_custom_schemas([domain,':AddMenu']);
            if~isempty(customAddSchemas)
                customSchemas=[customSchemas,customAddSchemas];
            end
        elseif strcmpi(menu,'Diagram')
            customFormatSchemas=cm_get_custom_schemas([domain,':FormatMenu']);
            if~isempty(customFormatSchemas)
                customSchemas=[customSchemas,customFormatSchemas];
            end
        end
        if~isempty(customSchemas)
            schemas={@(cbinfo)customMenuBarSchema(cbinfo,menu,customSchemas)};
        end
    end
end

function schema=toolBarSchema(~,children)
    assert(~isempty(children));
    schema=DAStudio.ContainerSchema();
    schema.tag='Simulink:CustomToolBar';
    schema.children=children;
    schema.autodisableWhen='Never';
end

function schema=customMenuBarSchema(~,menu,customSchemas)
    schema=DAStudio.ActionChoiceSchema;
    if strcmpi(menu,'Chart')||strcmpi(menu,'Add')
        schema.tag='Stateflow:ChartMenu';
        schema.label=DAStudio.message(['Stateflow:studio:',menu,'Menu']);
    elseif~strcmpi(menu,'MenuBar')
        schema.tag=['Simulink:',menu,'Menu'];
        schema.label=DAStudio.message(['Simulink:studio:',menu,'Menu']);
    end
    schema.generateFcn=@(cbinfo)generatorFcn(cbinfo,customSchemas);
    schema.autodisableWhen='Never';
end

function generated=generatorFcn(~,children)
    generated=children;
end

function schema=convertMenuBarSchema(cbinfo,generator)
    schema=DAStudio.ActionChoiceSchema();
    if iscell(generator)
        gen=generator{1};
        cbinfo.userdata=generator{2};
        customSchema=gen(cbinfo);
    else
        customSchema=generator(cbinfo);
    end
    schema.label=customSchema.label;
    if isempty(schema.label)
        schema.label=' ';
        schema.state='Hidden';
    else
        schema.label=customSchema.label;
        schema.state=customSchema.state;
    end
    schema.tag=customSchema.tag;
    schema.tooltip=customSchema.tooltip;
    schema.statustip=customSchema.statustip;
    schema.userdata=customSchema.userdata;
    schema.childrenFcns=customSchema.childrenFcns;
    schema.generateFcn=customSchema.generateFcn;
    schema.autodisableWhen=customSchema.autodisableWhen;
end