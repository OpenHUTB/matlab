function[varargout]=vehdyndynamicsteering(varargin)


    varargout{1}=0;
    block=varargin{1};
    maskMode=varargin{2};
    maskObj=Simulink.Mask.get(block);
    StrgType=get_param(block,'StrgType');
    StrgRatioType=get_param(block,'StrgRatioType');
    MaskParamsAng=maskObj.getWorkspaceVariables;



    switch maskMode
    case 'Main'
        Main;
    case 'Initilization'
        Initilization;
    case 'SteeringOptions'
        SteeringOptions;
    case 'DrawCommands'
        varargout{1}=DrawCommands(block);
    case 'DrawCommandsforStrSys'
        varargout{1}=DrawCommandsforStrSys(block);
    case 'Normalization'
        Normalization;
    case 'SteeringGearType'
        SteeringGearType;
    case 'PowerAssistance'
        PowerAssistance;
    case 'PowerAssistanceExt'
        PowerAssistanceExt;
    case 'AckermanSteering'
        AckermanSteering;
    case 'AckermanSteeringExt'
        AckermanSteeringExt;
    case 'SteeringInput'
        SteeringInput;
    case 'IntermediateShaft'
        IntermediateShaft;
    case 'SteerLocation'
        SteerLocation;
    case 'KingpinExt'
        KingpinExt;
    case 'RckParameterizedType'
        RckParameterizedType;
    case 'AckParameterizedType'
        AckParameterizedType;
    otherwise
        varargout{1}=0;
    end

    function SteeringGearType
        parameterControl=maskObj.getDialogControl('ParameterGroupVar');
        generalControl=parameterControl.getDialogControl('General');
        RPControl=parameterControl.getDialogControl('RackandPinion');
        WSControl=parameterControl.getDialogControl('WormandSector');
        turnoffAll({RPControl,WSControl});
        setGroupVisibleEnable(generalControl,'on');
        maskObj.getParameter('StrgRatioType').Visible='on';
        switch StrgType
        case 'Rack and pinion'
            setGroupVisibleEnable(RPControl,'on');
            RckParameterizedType;
        case 'Worm and sector'
            setGroupVisibleEnable(WSControl,'on');
        end
        KingpinExt;
    end

    function PowerAssistance
        parameterControl=maskObj.getDialogControl('ParameterGroupVar');
        PAControl=parameterControl.getDialogControl('PowerAssistance');
        PwrAst=get_param(block,'PwrAst');
        setGroupVisibleEnable(PAControl,'off');
        path=[block,'/Power Assistance'];
        if strcmp(PwrAst,'on')
            setGroupVisibleEnable(PAControl,'on');
            set_param(path,'OverrideUsingVariant','EPS');
        else
            set_param(path,'OverrideUsingVariant','NoPowerAssistance');
        end
    end

    function PowerAssistanceExt
        PwrAstOverride=get_param(block,'PwrAstOverride');
        path=[block,'/Power Assistance'];
        if strcmp(PwrAstOverride,'on')
            maskObj.getParameter('PwrAst').Enabled='off';
            maskObj.getParameter('PwrAst').Value='off';

            PowerAssistance;
            set_param(path,'OverrideUsingVariant','External');
        else
            maskObj.getParameter('PwrAst').Enabled='on';

            PowerAssistance;
        end
    end

    function AckermanSteering
        parameterControl=maskObj.getDialogControl('ParameterGroupVar');
        ACControl=parameterControl.getDialogControl('AckermanSteering');
        AckStr=get_param(block,'AckStr');
        setGroupVisibleEnable(ACControl,'off');









        if strcmp(AckStr,'on')
            setGroupVisibleEnable(ACControl,'on');





        end
        AckParameterizedType;
    end

    function AckermanSteeringExt
        AckStrOverride=get_param(block,'AckStrOverride');








        if strcmp(AckStrOverride,'on')
            maskObj.getParameter('AckStr').Enabled='off';
            maskObj.getParameter('AckStr').Value='off';
            maskObj.getParameter('AckParamType').Value='Constant';
            AckermanSteering;


        else
            maskObj.getParameter('AckStr').Enabled='on';


        end
    end

    function KingpinExt
        KingpinOverride=get_param(block,'KingpinOverride');
        path=[block,'/Kingpin Moments'];
        if strcmp(KingpinOverride,'on')
            SwitchInport(block,'CstrAng','Ground');
            SwitchInport(block,'WhlAngFdk','Ground');
            SwitchInport(block,'TireFdk','Ground');
            SwitchInport(block,'LftKpM','Inport');
            SwitchInport(block,'RghtKpM','Inport');
            set_param(path,'OverrideUsingVariant','ExtnalK');
            maskObj.getParameter('CstrAng').Visible='on';
            maskObj.getParameter('CstrAng').Enabled='on';
        else
            SwitchInport(block,'CstrAng','Inport');
            SwitchInport(block,'WhlAngFdk','Inport');
            SwitchInport(block,'TireFdk','Inport');
            SwitchInport(block,'LftKpM','Ground');
            SwitchInport(block,'RghtKpM','Ground');
            set_param(path,'OverrideUsingVariant','InternalK');
            maskObj.getParameter('CstrAng').Visible='off';
            maskObj.getParameter('CstrAng').Enabled='off';
        end
    end

    function SteeringInput
        SteeringInputType=get_param(block,'StrIn');
        if strcmp(SteeringInputType,'Angle')
            SwitchInport(block,'StrWhlAng','Inport');
            SwitchInport(block,'StrWhlTrq','Ground');
            SwitchInport(block,'SteerInputFlag','Constant','0');
        else
            SwitchInport(block,'StrWhlTrq','Inport');
            SwitchInport(block,'StrWhlAng','Ground');
            SwitchInport(block,'SteerInputFlag','Constant','1');
        end
    end

    function IntermediateShaft
        parameterControl=maskObj.getDialogControl('ParameterGroupVar');
        SingleCardanControl=parameterControl.getDialogControl('SingleCardanJoint');
        DoubleCardanControl=parameterControl.getDialogControl('DoubleCardanJoint');
        setGroupVisibleEnable(SingleCardanControl,'off');
        setGroupVisibleEnable(DoubleCardanControl,'off');
        path=[block,'/Steering System/Intermediate Shaft'];
        IntmdShaft=get_param(block,'IntmdShaftType');
        if strcmp(IntmdShaft,'Single Cardan joint')
            set_param(path,'OverrideUsingVariant','SingleCardanJoint');
            setGroupVisibleEnable(SingleCardanControl,'on');
        else
            set_param(path,'OverrideUsingVariant','DoubleCardanJoint');
            setGroupVisibleEnable(DoubleCardanControl,'on');
        end
    end

    function SteerLocation
        Loc=get_param(block,'Loc');
        if strcmp(Loc,'Front')
            SwitchInport(block,'LocFlag','Constant','1');
        else
            SwitchInport(block,'LocFlag','Constant','0');
        end
    end

    function RckParameterizedType
        RckParamType=get_param(block,'StrgRatioType');
        AckParamType=get_param(block,'AckParamType');
        path=[block,'/Rack Gain'];
        if strcmp(RckParamType,'Constant')
            if strcmp(AckParamType,'Constant')
                maskObj.getParameter('StrgAngBpts').Visible='off';
                maskObj.getParameter('StrgAngBpts').Enabled='off';
            end
            maskObj.getParameter('RckGnTbl').Visible='off';
            maskObj.getParameter('RckGnTbl').Enabled='off';
            maskObj.getParameter('RckGn').Visible='on';
            maskObj.getParameter('RckGn').Enabled='on';
            set_param(path,'OverrideUsingVariant','ConstantRackGain');
        else
            maskObj.getParameter('StrgAngBpts').Visible='on';
            maskObj.getParameter('StrgAngBpts').Enabled='on';
            maskObj.getParameter('RckGnTbl').Visible='on';
            maskObj.getParameter('RckGnTbl').Enabled='on';
            maskObj.getParameter('RckGn').Visible='off';
            maskObj.getParameter('RckGn').Enabled='off';
            set_param(path,'OverrideUsingVariant','VariableRackGain');
        end
    end

    function AckParameterizedType
        AckParamType=get_param(block,'AckParamType');
        RckParamType=get_param(block,'StrgRatioType');
        path=[block,'/Percent Ackerman'];
        if strcmp(AckParamType,'Constant')
            if strcmp(RckParamType,'Constant')
                maskObj.getParameter('StrgAngBpts').Visible='off';
                maskObj.getParameter('StrgAngBpts').Enabled='off';
            end
            maskObj.getParameter('PctAckTbl').Visible='off';
            maskObj.getParameter('PctAckTbl').Enabled='off';
            maskObj.getParameter('PctAck').Visible='on';
            maskObj.getParameter('PctAck').Enabled='on';
            set_param(path,'OverrideUsingVariant','ConstantPctAck');
        else
            maskObj.getParameter('StrgAngBpts').Visible='on';
            maskObj.getParameter('StrgAngBpts').Enabled='on';
            maskObj.getParameter('PctAckTbl').Visible='on';
            maskObj.getParameter('PctAckTbl').Enabled='on';
            maskObj.getParameter('PctAck').Visible='off';
            maskObj.getParameter('PctAck').Enabled='off';
            set_param(path,'OverrideUsingVariant','VariablePctAck');
        end
    end

    function Initilization
        SteeringGearType;

        IntermediateShaft;

        PowerAssistance;

        AckermanSteering;


        PwrAstOverride=get_param(block,'PwrAstOverride');
        path=[block,'/Power Assistance'];
        if strcmp(PwrAstOverride,'on')
            maskObj.getParameter('PwrAst').Enabled='off';
            maskObj.getParameter('PwrAst').Value='off';
            SwitchInport(block,'PwrAstTrq','Inport');
            PowerAssistance;
            set_param(path,'OverrideUsingVariant','External');
        else
            maskObj.getParameter('PwrAst').Enabled='on';
            SwitchInport(block,'PwrAstTrq','Ground');
            PowerAssistance;
        end


        parameterControl=maskObj.getDialogControl('ParameterGroupVar');
        ACControl=parameterControl.getDialogControl('AckermanSteering');
        AckStr=get_param(block,'AckStr');
        setGroupVisibleEnable(ACControl,'off');

        StrGear=get_param(block,'StrgType');
        switch StrGear
        case 'Rack and pinion'
            path=[block,'/Steering System/Lower Steernig (Linkages and Gears)/Rack and Pinion Constant'];
        case 'Worm and sector'
            path=[block,'/Steering System/Lower Steernig (Linkages and Gears)/Worm and Sector'];
        end

        if strcmp(AckStr,'on')
            SwitchInport(path,'AckermanFlag','Constant','0');
            SwitchInport(block,'PctAck','Constant','PctAck');
        else
            SwitchInport(path,'AckermanFlag','Constant','1');
            SwitchInport(block,'PctAck','Constant','100');
        end


        AckStrOverride=get_param(block,'AckStrOverride');
        StrGear=get_param(block,'StrgType');
        switch StrGear
        case 'Rack and pinion'
            path=[block,'/Steering System/Lower Steernig (Linkages and Gears)/Rack and Pinion Constant'];
        case 'Worm and sector'
            path=[block,'/Steering System/Lower Steernig (Linkages and Gears)/Worm and Sector'];
        end
        if strcmp(AckStrOverride,'on')
            maskObj.getParameter('AckStr').Enabled='off';
            maskObj.getParameter('AckStr').Value='off';
            AckermanSteering;
            SwitchInport(block,'PctAck','Inport');
            SwitchInport(path,'AckermanFlag','Constant','0');
        else
            maskObj.getParameter('AckStr').Enabled='on';
            AckermanSteering;
        end

        SteerLocation;

        SteeringInput;

        RckParameterizedType;
        AckParameterizedType;

        KingpinExt;

        ParamType=get_param(block,'StrgRatioType');
        if strcmp(ParamType,'Constant')
            SwitchInport(block,'RckGn','Constant','RckGn');
        else
            SwitchInport(block,'RckGn','Ground');
        end


        ParamList={...
        'TrckWdth',[1,1],{'gt',0};...
        'StrRng',[1,1],{'gt',0};...
        'StrWhlInert',[1,1],{'gt',0};...
        'StrColInert',[1,1],{'gt',0};...
        'KngpnOfst',[1,1],{'gt',0};...
        'Lambda',[1,1],{'gt',0};...
        'HbLead',[1,1],{'gt',0};...
        'StcLdRadius',[1,1],{'gt',0};...
        'CstrAng',[1,1],{'gte',0};...
        'OvrlStrRatio',[1,1],{'gt',0};...
        };
        StrgAngBpts={'StrgAngBpts',{}};

        LookupTblList={StrgAngBpts,'RckGnTbl',{'gt',0};...
        StrgAngBpts,'PctAckTbl',{'gt',0};};
        autoblkscheckparams(block,'VDYNBLKSKINEMATICSTEERING',ParamList,LookupTblList);

        if strcmp(StrgType,'Rack and pinion')
            TrckWdth=MaskParamsAng(strcmp({MaskParamsAng.Name},'TrckWdth')).Value;
            StrgArmLngth=MaskParamsAng(strcmp({MaskParamsAng.Name},'StrgArmLngth')).Value;
            RckCsLngth=MaskParamsAng(strcmp({MaskParamsAng.Name},'RckCsLngth')).Value;
            TieRodLngth=MaskParamsAng(strcmp({MaskParamsAng.Name},'TieRodLngth')).Value;
            Dst=MaskParamsAng(strcmp({MaskParamsAng.Name},'Dst')).Value;

            vdyncheckrackpinion(TrckWdth,StrgArmLngth,RckCsLngth,TieRodLngth,Dst);
        end

    end




    function Normalization

        set_param(block,'StrgRatioType','Constant');

        maskObj.getParameter('StrgAngBpts').Visible='off';
        maskObj.getParameter('StrgAngBpts').Enabled='off';

        TrckWdth=MaskParamsAng(strcmp({MaskParamsAng.Name},'TrckWdth')).Value;
        StrgArmLngth=MaskParamsAng(strcmp({MaskParamsAng.Name},'StrgArmLngth')).Value;
        RckCsLngth=MaskParamsAng(strcmp({MaskParamsAng.Name},'RckCsLngth')).Value;
        TieRodLngth=MaskParamsAng(strcmp({MaskParamsAng.Name},'TieRodLngth')).Value;
        D=MaskParamsAng(strcmp({MaskParamsAng.Name},'D')).Value;

        NFactor=evalin('base',get_param(block,'NrmlFctr'));
        if strcmp(StrgType,'Rack and pinion')
            maskObj.getParameter('PnnRadiusTbl').Visible='off';
            maskObj.getParameter('PnnRadiusTbl').Enabled='off';
            maskObj.getParameter('PnnRadius').Visible='on';
            maskObj.getParameter('PnnRadius').Enabled='on';
            [~,~,ratio]=vdynrackpinion(1,TrckWdth,StrgArmLngth,RckCsLngth,TieRodLngth,D,0.001);
            set_param(block,'PnnRadius',num2str(NFactor*ratio*0.001));
        else
            maskObj.getParameter('StrgRatioTbl').Visible='off';
            maskObj.getParameter('StrgRatioTbl').Enabled='off';
            maskObj.getParameter('StrgRatio').Visible='on';
            maskObj.getParameter('StrgRatio').Enabled='on';
            set_param(block,'StrgRatio',num2str(1./NFactor));
        end

    end

    function Main
        ParamList={...
        'TrckWdth',[1,1],{'gt',0};...
        'WhlBase',[1,1],{'gt',0};...
        'Db',[1,1],{'gte',0};...
        'StrgRng',[1,1],{'gt',0};...
        'StrgRatio',[1,1],{'gt',0};...
        'StrgArmLngth',[1,1],{'gt',0};...
        'RckCsLngth',[1,1],{'gt',0};...
        'TieRodLngth',[1,1],{'gt',0};...
        'D',[1,1],{'gt',0};...
        'PnnRadius',[1,1],{'gt',0};...
        'RodLngth',[1,1],{'gt',0};...
        'NrmlFctr',[1,1],{'gt',0};...
        };
        StrgAngBpts={'StrgAngBpts',{}};

        LookupTblList={StrgAngBpts,'StrgRatioTbl',{'gt',0};...
        StrgAngBpts,'PnnRadiusTbl',{'gt',0};};
        autoblkscheckparams(block,'VDYNBLKSKINEMATICSTEERING',ParamList,LookupTblList);
        if strcmp(StrgType,'Rack and pinion')
            TrckWdth=MaskParamsAng(strcmp({MaskParamsAng.Name},'TrckWdth')).Value;
            StrgArmLngth=MaskParamsAng(strcmp({MaskParamsAng.Name},'StrgArmLngth')).Value;
            RckCsLngth=MaskParamsAng(strcmp({MaskParamsAng.Name},'RckCsLngth')).Value;
            TieRodLngth=MaskParamsAng(strcmp({MaskParamsAng.Name},'TieRodLngth')).Value;
            D=MaskParamsAng(strcmp({MaskParamsAng.Name},'D')).Value;

            vdyncheckrackpinion(TrckWdth,StrgArmLngth,RckCsLngth,TieRodLngth,D);
        end
        set_param([block,'/AngInput'],'StrgType',StrgType);
        set_param([block,'/AngInput'],'StrgRatioType',StrgRatioType);
        Loc=get_param(block,'Loc');
        switch Loc
        case 'Front'
            set_param([block,'/index'],'Value','1');
        case 'Rear'
            set_param([block,'/index'],'Value','0');
        end
    end










































    function SteeringOptions
        parameterControl=maskObj.getDialogControl('ParameterGroupVar');

        generalControl=parameterControl.getDialogControl('General');
        RPControl=parameterControl.getDialogControl('RackandPinion');
        paraControl=parameterControl.getDialogControl('ParallelArm');
        turnoffAll({RPControl,paraControl});
        setGroupVisibleEnable(generalControl,'on');
        maskObj.getParameter('StrgRatioType').Visible='on';
        switch StrgType
        case{'Ackerman','Parallel'}

            maskObj.getParameter('PnnRadiusTbl').Visible='off';
            maskObj.getParameter('PnnRadiusTbl').Enabled='off';
            maskObj.getParameter('PnnRadius').Visible='off';
            maskObj.getParameter('PnnRadius').Enabled='off';
            if strcmp(StrgType,'Parallel')

                maskObj.getParameter('WhlBase').Visible='off';
                maskObj.getParameter('WhlBase').Enabled='off';
                maskObj.getParameter('TrckWdth').Visible='off';
                maskObj.getParameter('TrckWdth').Enabled='off';
            end
            switch StrgRatioType
            case 'Constant'
                maskObj.getParameter('StrgAngBpts').Visible='off';
                maskObj.getParameter('StrgRatioTbl').Visible='off';
                maskObj.getParameter('StrgAngBpts').Enabled='off';
                maskObj.getParameter('StrgRatioTbl').Enabled='off';
            case 'Lookup table'
                maskObj.getParameter('StrgRatio').Visible='off';
                maskObj.getParameter('StrgRatio').Enabled='off';
            end
        case 'Rack and pinion'
            setGroupVisibleEnable(RPControl,'on');
            maskObj.getParameter('StrgRatioTbl').Visible='off';
            maskObj.getParameter('StrgRatioTbl').Enabled='off';
            maskObj.getParameter('WhlBase').Visible='off';
            maskObj.getParameter('WhlBase').Enabled='off';
            maskObj.getParameter('StrgRatio').Visible='off';
            maskObj.getParameter('StrgRatio').Enabled='off';
            switch StrgRatioType
            case 'Constant'
                maskObj.getParameter('StrgAngBpts').Visible='off';
                maskObj.getParameter('StrgAngBpts').Enabled='off';
                maskObj.getParameter('PnnRadiusTbl').Visible='off';
                maskObj.getParameter('PnnRadiusTbl').Enabled='off';
            case 'Lookup table'
                maskObj.getParameter('PnnRadius').Visible='off';
                maskObj.getParameter('PnnRadius').Enabled='off';
            end
        case 'Parallel Arm'
            setGroupVisibleEnable(paraControl,'on');
            maskObj.getParameter('PnnRadiusTbl').Visible='off';
            maskObj.getParameter('PnnRadiusTbl').Enabled='off';
            maskObj.getParameter('PnnRadius').Visible='off';
            maskObj.getParameter('PnnRadius').Enabled='off';
            maskObj.getParameter('WhlBase').Visible='off';
            maskObj.getParameter('WhlBase').Enabled='off';
            maskObj.getParameter('TrckWidth').Visible='off';
            maskObj.getParameter('TrckWidth').Enabled='off';
            switch StrgRatioType
            case 'Constant'
                maskObj.getParameter('StrgAngBpts').Visible='off';
                maskObj.getParameter('StrgRatioTbl').Visible='off';
                maskObj.getParameter('StrgAngBpts').Enabled='off';
                maskObj.getParameter('StrgRatioTbl').Enabled='off';
            case 'Lookup table'
                maskObj.getParameter('StrgRatio').Visible='off';
                maskObj.getParameter('StrgRatio').Enabled='off';
            end
        end

    end

    function turnoffAll(objs)
        for i=1:length(objs)
            setGroupVisibleEnable(objs{i},'off');
        end
    end

    function setGroupVisibleEnable(obj,value)
        obj.Visible=value;
        obj.Enabled=value;
        vars=obj.DialogControls;
        for i=1:length(vars)
            maskObj.getParameter(vars(i).Name).Visible=value;
            maskObj.getParameter(vars(i).Name).Enabled=value;

        end
    end


    function IconInfo=DrawCommands(Block)

        AliasNames={};
        IconInfo=autoblksgetportlabels(Block,AliasNames);


        switch StrgType
        case 'Ackerman'
            IconInfo.ImageName='steeracker.png';
        case 'Rack and pinion'
            IconInfo.ImageName='steerrp.png';
        case 'Parallel'
            IconInfo.ImageName='steerpar.png';
        otherwise
            IconInfo.ImageName='strsys.png';
        end
        [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,50,'white');
    end

    function IconInfo=DrawCommandsforStrSys(Block)

        AliasNames={};
        IconInfo=autoblksgetportlabels(Block,AliasNames);


        IconInfo.ImageName='strsys.png';
        [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,50,'white');
    end


    function SwitchInport(Block,PortName,UsePort,Param)

        InportOption={'built-in/Constant',[PortName,'Constant'];...
        'built-in/Inport',PortName;...
        'simulink/Sinks/Terminator',[PortName,'Terminator'];...
        'simulink/Sinks/Out1',PortName;...
        'built-in/Ground',[PortName,'Ground']};
        switch UsePort
        case 'Constant'
            NewBlkHdl=autoblksreplaceblock(Block,InportOption,1);
            set_param(NewBlkHdl,'Value',Param);
        case 'Terminator'
            autoblksreplaceblock(Block,InportOption,3);
        case 'Outport'
            autoblksreplaceblock(Block,InportOption,4);
        case 'Inport'
            autoblksreplaceblock(Block,InportOption,2);
        case 'Ground'
            autoblksreplaceblock(Block,InportOption,5);
        end
    end














    if nargout==0
        clear varargout;
    end

end
