function schema





    hCreateInPackage=findpackage('xpctarget');


    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'CustomTargetCC');


    h=schema.class(hCreateInPackage,'xpcTargetCC',hDeriveFromClass);


    if isempty(findtype('xPCExecutionModeEnum'))
        schema.EnumType('xPCExecutionModeEnum',{'Real-Time','Freerun'});
    end
    p=add_prop(h,'RL32ModeModifier','xPCExecutionModeEnum');
    p.FactoryValue='Real-Time';

    p=add_prop(h,'ExtMode','on/off');
    p.FactoryValue='on';

    p=add_prop(h,'ExtModeMexFile','ustring');
    p.FactoryValue='ext_xpc';

    p=add_prop(h,'ExtModeIntrfLevel','ustring');
    p.FactoryValue='Level2 - Open';

    p=add_prop(h,'ExtModeMexArgs','ustring');
    p.FactoryValue='';

    p=add_prop(h,'ExtModeArmWhenConnect','on/off');
    p.FactoryValue='off';

    p=add_prop(h,'RL32LogTETModifier','on/off');
    p.FactoryValue='on';

    p=add_prop(h,'RL32LogBufSizeModifier','string');
    p.FactoryValue='100000';

    p=add_prop(h,'xPCTaskExecutionProfile','on/off');
    p.FactoryValue='off';

    p=add_prop(h,'xPCRL32EventNumber','string');
    p.FactoryValue='5000';

    if isempty(findtype('xPCIRQChoicesEnum'))
        schema.EnumType('xPCIRQChoicesEnum',...
        {'Timer','Auto (PCI only)',...
        '3','4','5','6','7','8','9','10',...
        '11','12','13','14','15'});
    end
    p=add_prop(h,'RL32IRQSourceModifier','xPCIRQChoicesEnum');
    p.FactoryValue='Timer';


    t=findtype('xPCIRQSourceBoardEnum');
    if isempty(t)
        t=schema.EnumType('xPCIRQSourceBoardEnum',getioirqhookstruct);
    end
    p=add_prop(h,'xPCIRQSourceBoard','xPCIRQSourceBoardEnum');
    p.FactoryValue='None/other';

    p=add_prop(h,'xPCIOIRQSlot','string');
    p.FactoryValue='-1';


    p=add_prop(h,'xpcDblBuff','on/off');
    p.FactoryValue='off';

    p=add_prop(h,'xpcObjCom','on/off');
    p.FactoryValue='off';

    p=add_prop(h,'xPCGenerateASAP2','on/off');
    p.FactoryValue='off';

    p=add_prop(h,'xPCGenerateXML','on/off');
    p.FactoryValue='off';

    p=add_prop(h,'RL32ObjectName','string');
    p.FactoryValue='tg';



    p=add_prop(h,'xPCisDownloadable','on/off');
    p.FactoryValue='on';

    p=add_prop(h,'xPCisDefaultEnv','on/off');
    p.FactoryValue='on';

    p=add_prop(h,'xPCTargetPCEnvName','string');
    p.FactoryValue='';

    p=add_prop(h,'xPCisModelTimeout','on/off');
    p.FactoryValue='on';

    p=add_prop(h,'xPCModelTimeoutSecs','string');
    p.FactoryValue='5';

    p=add_prop(h,'xPCLoadParamSetFile','on/off');
    p.FactoryValue='off';

    p=add_prop(h,'xPCOnTgtParamSetFileName','string');
    p.FactoryValue='';

    p=add_prop(h,'xPCConcurrentTasks','on/off');
    p.FactoryValue='off';

    p=add_prop(h,'xPCEnableSFAnimation','on/off');
    p.FactoryValue='off';

    hPreSetListener=handle.listener(h,h.Properties,'PropertyPreSet',...
    @preSetFcn_Prop);
    add_prop(p,'PreSetListener','handle');
    p.PreSetListener=hPreSetListener;


    hPostSetListener=handle.listener(h,h.Properties,'PropertyPostSet',...
    @postSetFcn_Prop);
    add_prop(p,'PostSetListener','handle');
    p.PostSetListener=hPostSetListener;



    m=schema.method(h,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(h,'getStringFormat');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

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




    function preSetFcn_Prop(hProp,eventData,x)

        hObj=eventData.AffectedObject;
        if~isequal(get(hObj,hProp.Name),eventData.NewVal)
            hObj.dirtyHostBD;
        end
        if strcmp(hProp.Name,'xPCisDefaultEnv')



        end

        function postSetFcn_Prop(hProp,eventData)
            hObj=eventData.AffectedObject;
            if~isequal(get(hObj,hProp.Name),eventData.NewVal)
                hObj.dirtyHostBD;
            end
            if strcmp(hProp.Name,'xPCConcurrentTasks')
                if(~isempty(hObj.getParent))
                    cs=hObj.getParent.getConfigSet;
                    set_param(cs,'ConcurrentTasks',eventData.NewVal);
                end
            end


            function p=add_prop(h,name,type)

                p=Simulink.TargetCCProperty(h,name,type);
                p.TargetCCPropertyAttributes.set_prop_attrib('CODEGEN_CODE');

