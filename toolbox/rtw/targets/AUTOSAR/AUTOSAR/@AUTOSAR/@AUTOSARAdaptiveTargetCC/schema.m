function schema()





    hCreateInPackage=findpackage('AUTOSAR');


    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'ERTTargetCC');


    hThisClass=schema.class(hCreateInPackage,'AUTOSARAdaptiveTargetCC',hDeriveFromClass);




    if isempty(findtype('AUTOSAR_SCHEMA_VERSION_ENUM'))
        schema.EnumType('AUTOSAR_SCHEMA_VERSION_ENUM',...
        [getOldStyleSchemaVersions(),'R18-03'...
        ,arxml.getSupportedAdaptiveSchemas()]);
    end

    if isempty(findtype('ADAPTIVE_AUTOSAR_XCP_SLAVE_TRANSPORT_LAYER_ENUM'))
        schema.EnumType('ADAPTIVE_AUTOSAR_XCP_SLAVE_TRANSPORT_LAYER_ENUM',...
        {'None','XCPOnTCPIP'});
    end

    p=add_cc_prop(hThisClass,'AutosarSchemaVersion','AUTOSAR_SCHEMA_VERSION_ENUM');
    p.FactoryValue=arxml.getAdaptiveDefaultSchema();
    p.SetFunction=@setFcn_AutosarSchemaVersion;

    p=add_cc_prop(hThisClass,'AutosarMaxShortNameLength','slint');
    p.FactoryValue='128';

    p=add_cc_prop(hThisClass,'AdaptiveAutosarXCPSlaveTransportLayer','ADAPTIVE_AUTOSAR_XCP_SLAVE_TRANSPORT_LAYER_ENUM');
    p.FactoryValue='None';

    p=add_cc_prop(hThisClass,'AdaptiveAutosarXCPSlaveTCPIPAddress','ustring');
    p.FactoryValue='127.0.0.1';

    p=add_cc_prop(hThisClass,'AdaptiveAutosarXCPSlavePort','ustring');
    p.FactoryValue='17725';

    p=add_cc_prop(hThisClass,'AdaptiveAutosarXCPSlaveVerbosity','slbool');
    p.FactoryValue='off';

    p=add_cc_prop(hThisClass,'AdaptiveAutosarUseCustomXCPSlave','slbool');
    p.FactoryValue='off';



    p=schema.prop(hThisClass,'propListener','handle.listener vector');
    p.Visible='off';
    p.FactoryValue=[];
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Serialize='off';


    m=schema.method(hThisClass,'update');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};
end

function p=add_cc_prop(h,name,type)
    p=Simulink.TargetCCProperty(h,name,type);
    p.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
end

function newVal=setFcn_AutosarSchemaVersion(hObj,userVal)

    newVal=arxml.convertSchemaToRelease(userVal);

    if strcmp(hObj.InMdlLoading,'off')



        if~any(strcmp(newVal,arxml.getSupportedAdaptiveSchemas()))||...
            (strcmp(newVal,'R20-11')&&~slfeature('AutosarAdaptiveR2011'))

            DAStudio.error('autosarstandard:validation:invalidAdaptiveSchema',...
            newVal,strjoin(arxml.getSupportedAdaptiveSchemas,''','''));
        elseif any(strcmp(userVal,getOldStyleSchemaVersions()))


            DAStudio.warning('autosarstandard:validation:oldStyleAdaptiveSchema',...
            userVal,newVal);
        end
    end
end

function oldStyleVersions=getOldStyleSchemaVersions()
    oldStyleVersions={'00045','00046','00047','00048','00049'};
end

