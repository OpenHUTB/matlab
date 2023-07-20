function schema





    mlock;

    pk=findpackage('fpgaworkflowprops');
    c=schema.class(pk,'FDHDLCoder');

    defineEnumTypes;


    p=schema.prop(c,'FPGAWorkflow','FPGAWorkflowType');
    set(p,'FactoryValue','Project generation');

    p=schema.prop(c,'FPGAProjectGenOutput','FPGAProjectGenOutputType');
    set(p,'FactoryValue','ISE project');

    p=schema.prop(c,'CustomFilterOutput','CustomFilterOutputType');
    set(p,'FactoryValue','ISE project');


    p=schema.prop(c,'FPGAProjectType','ProjectAndTclType');
    set(p,'FactoryValue','Create new project');

    p=schema.prop(c,'ExistingFPGAProjectPath','string');
    set(p,'FactoryValue','');


    p=schema.prop(c,'TclOptions','ProjectAndTclType');
    set(p,'FactoryValue','Create new project');


    p=schema.prop(c,'USRPFPGASourceFolder','string');
    set(p,'FactoryValue','');


    p=schema.prop(c,'FPGAProjectName','string');
    set(p,'FactoryValue','untitled_proj');

    p=schema.prop(c,'FPGAProjectFolder','string');
    set(p,'FactoryValue','iseproject');

    p=schema.prop(c,'FPGAFamily','string');
    set(p,'FactoryValue','Virtex4');

    p=schema.prop(c,'FPGADevice','string');
    set(p,'FactoryValue','xc4vsx35');

    p=schema.prop(c,'FPGASpeed','string');
    set(p,'FactoryValue','-10');

    p=schema.prop(c,'FPGAPackage','string');
    set(p,'FactoryValue','ff668');

    p=schema.prop(c,'UserFPGASourceFiles','string');
    set(p,'FactoryValue','');

    p=schema.prop(c,'FPGAProjectPropTableSource','handle');
    set(p,'Visible','off');


    p=schema.prop(c,'FPGAProjectPropertyName','string');
    set(p,'FactoryValue','');

    p=schema.prop(c,'FPGAProjectPropertyValue','string');
    set(p,'FactoryValue','');

    p=schema.prop(c,'FPGAProjectPropertyProcess','string');
    set(p,'FactoryValue','');


    p=schema.prop(c,'GenClockModule','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'FPGAInputClockPeriod','string');
    set(p,'FactoryValue','10');

    p=schema.prop(c,'FPGASystemClockPeriod','string');
    set(p,'FactoryValue','10');


    function defineEnumTypes

        if isempty(findtype('FPGAWorkflowType'))
            schema.EnumType('FPGAWorkflowType',...
            {'Project generation','USRP2 filter customization'});
        end

        if isempty(findtype('FPGAProjectGenOutputType'))
            schema.EnumType('FPGAProjectGenOutputType',...
            {'ISE project','Tcl script'});
        end

        if isempty(findtype('ProjectAndTclType'))
            schema.EnumType('ProjectAndTclType',...
            {'Create new project','Add to existing project'});
        end

        if isempty(findtype('CustomFilterOutputType'))
            schema.EnumType('CustomFilterOutputType',...
            {'ISE project','FPGA bitstream'});
        end
