function schema





    hCreateInPackage=findpackage('slrealtime');


    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'GRTTargetCC');


    h=schema.class(hCreateInPackage,'SimulinkRealTimeTargetCC',hDeriveFromClass);


    if isempty(findtype('SLRTLogLevelEnum'))
        schema.EnumType('SLRTLogLevelEnum',...
        {'trace','debug','info','warning','error','fatal'});
    end

    p=add_prop(h,'SLRTLogLevel','SLRTLogLevelEnum');
    p.FactoryValue='info';

    p=add_prop(h,'SLRTForcePollingMode','slbool');
    p.FactoryValue='off';

    p=add_prop(h,'SLRTFileLogMaxRuns','slint');
    p.FactoryValue=1;

    p=add_prop(h,'xPCEnableSFAnimation','slbool');
    p.FactoryValue='on';
    p.Visible='off';

    p=add_prop(h,'UseGCCFastMath','slbool');
    p.FactoryValue='off';


    hPreSetListener=handle.listener(h,h.Properties,'PropertyPreSet',...
    @preSetFcn_Prop);
    add_prop(p,'PreSetListener','handle');
    p.PreSetListener=hPreSetListener;



    m=schema.method(h,'update');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};

    m=schema.method(h,'getMdlRefComplianceTable');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','Sl_MdlRefTarget_EnumType'};
    s.OutputTypes={'MATLAB array'};

    m=schema.method(h,'upgrade');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

end


function preSetFcn_Prop(hProp,eventData)

    hObj=eventData.AffectedObject;
    if~isequal(get(hObj,hProp.Name),eventData.NewVal)
        hObj.dirtyHostBD;
    end
end


function p=add_prop(h,name,type)

    p=Simulink.TargetCCProperty(h,name,type);
    p.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');
end
