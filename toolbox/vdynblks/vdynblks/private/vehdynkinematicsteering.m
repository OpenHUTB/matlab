function[varargout]=vehdynkinematicsteering(varargin)


    varargout{1}=0;
    block=varargin{1};
    maskMode=varargin{2};
    maskObj=Simulink.Mask.get(block);
    StrgType=get_param(block,'StrgType');
    StrgRatioType=get_param(block,'StrgRatioType');
    PctAckIn=get_param(block,'PctAckIn');
    MaskParamsAng=maskObj.getWorkspaceVariables;


    switch maskMode
    case 'Main'
        Main;
    case 'Init'
        Initialization;
    case 'SteeringOptions'
        SteeringOptions;
    case 'DrawCommands'
        varargout{1}=DrawCommands(block);
    case 'Normalization'
        Normalization;
    otherwise
        varargout{1}=0;
    end
    function Normalization






        TrckWdth=MaskParamsAng(strcmp({MaskParamsAng.Name},'TrckWdth')).Value;
        StrgArmLngth=MaskParamsAng(strcmp({MaskParamsAng.Name},'StrgArmLngth')).Value;
        RckCsLngth=MaskParamsAng(strcmp({MaskParamsAng.Name},'RckCsLngth')).Value;
        TieRodLngth=MaskParamsAng(strcmp({MaskParamsAng.Name},'TieRodLngth')).Value;
        D=MaskParamsAng(strcmp({MaskParamsAng.Name},'D')).Value;

        NFactor=evalin('base',get_param(block,'NrmlFctr'));
        if strcmp(StrgType,'Rack and pinion')




            [~,~,ratio]=vdynrackpinion(1,TrckWdth,StrgArmLngth,RckCsLngth,TieRodLngth,D,0.001);
            if strcmp(StrgRatioType,'Constant')
                set_param(block,'PnnRadius',num2str(NFactor*ratio*0.001));
            else
                PnnRadiusTblOrignial=evalin("base",get_param(block,'PnnRadiusTbl'));
                AugPnnRadius=NFactor.*ratio.*0.001;
                [~,I]=min(abs(PnnRadiusTblOrignial-AugPnnRadius));
                NormFact=PnnRadiusTblOrignial(I);
                tbl_value=PnnRadiusTblOrignial.*AugPnnRadius./NormFact;
                set_param(block,'PnnRadiusTbl',append('[',num2str(tbl_value),']'));
            end
        else




            if strcmp(StrgRatioType,'Constant')
                set_param(block,'StrgRatio',num2str(1./NFactor));
            else
                StrgRatioTblOrignial=evalin("base",get_param(block,'StrgRatioTbl'));
                tbl_value=StrgRatioTblOrignial./NFactor;
                set_param(block,'StrgRatioTbl',append('[',num2str(tbl_value),']'));
            end
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
        set_param([block,'/AngInput'],'PctAckIn',PctAckIn);
        Loc=get_param(block,'Loc');
        switch Loc
        case 'Front'
            set_param([block,'/index'],'Value','1');
        case 'Rear'
            set_param([block,'/index'],'Value','0');
        end

        ExternalPctAck=get_param(block,'PctAckIn');
        if strcmp(StrgType,'Ackerman')

            if strcmp(ExternalPctAck,'on')
                SwitchInport(block,'PerAckIn','Inport');
            else
                SwitchInport(block,'PerAckIn','Constant','1');
            end
        else
            SwitchInport(block,'PerAckIn','Constant','1');
        end
    end
    function Initialization

        EffctOptions={'vehdynlibsteeringcommon/PercentAckermanConstantRatio','PercentAckermanConstantRatio';...
        'vehdynlibsteeringcommon/RackandPinConstantRatio','RackandPinConstantRatio';...
        'vehdynlibsteeringcommon/ParaArmConstRatio','ParaArmConstRatio';...
        'vehdynlibsteeringcommon/ParalConstRatio','ParalConstRatio';...
        'vehdynlibsteeringcommon/PercentAckermanVariableRatio','PercentAckermanVariableRatio';...
        'vehdynlibsteeringcommon/RackandPinVariableRatio','RackandPinVariableRatio';...
        'vehdynlibsteeringcommon/ParaArmVarRatio','ParaArmVarRatio';...
        'vehdynlibsteeringcommon/ParalVarRatio','ParalVarRatio';...
        'vehdynlibsteeringcommon/PercentAckermanExternalRatio','PercentAckermanExternalRatio'};

        switch StrgRatioType
        case 'Constant'
            switch StrgType
            case 'Ackerman'
                ExternalPctAck=get_param(block,'PctAckIn');
                if strcmp(ExternalPctAck,'on')
                    autoblksreplaceblock(block,EffctOptions,9);
                else
                    autoblksreplaceblock(block,EffctOptions,1);
                end
            case 'Rack and pinion'
                autoblksreplaceblock(block,EffctOptions,2);
            case 'Parallel Arm'
                autoblksreplaceblock(block,EffctOptions,3);
            case 'Parallel'
                autoblksreplaceblock(block,EffctOptions,4);
            otherwise
                error([StrgType,'is not recognized']);
            end
        case 'Lookup table'
            switch StrgType
            case 'Ackerman'
                ExternalPctAck=get_param(block,'PctAckIn');
                if strcmp(ExternalPctAck,'on')
                    autoblksreplaceblock(block,EffctOptions,9);
                else
                    autoblksreplaceblock(block,EffctOptions,5);
                end
            case 'Rack and pinion'
                autoblksreplaceblock(block,EffctOptions,6);
            case 'Parallel Arm'
                autoblksreplaceblock(block,EffctOptions,7);
            case 'Parallel'
                autoblksreplaceblock(block,EffctOptions,8);
            otherwise
                error([StrgType,'is not recognized']);
            end

        end
    end
    function SteeringOptions
        parameterControl=maskObj.getDialogControl('ParameterGroupVar');

        generalControl=parameterControl.getDialogControl('General');
        ackControl=parameterControl.getDialogControl('AckermannSteering');
        RPControl=parameterControl.getDialogControl('RackandPinion');
        paraControl=parameterControl.getDialogControl('ParallelArm');
        turnoffAll({RPControl,paraControl});
        setGroupVisibleEnable(generalControl,'on');
        setGroupVisibleEnable(ackControl,'off');
        maskObj.getParameter('StrgRatioType').Visible='on';
        switch StrgType
        case{'Ackerman','Parallel'}
            if strcmp(StrgType,'Ackerman')
                setGroupVisibleEnable(ackControl,'on');
                ExternalPctAck=get_param(block,'PctAckIn');
            end

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
                maskObj.getParameter('PctAckTbl').Visible='off';
                maskObj.getParameter('PctAckTbl').Enabled='off';
                if strcmp(StrgType,'Ackerman')
                    if strcmp(ExternalPctAck,'on')
                        maskObj.getParameter('PctAck').Enabled='off';
                    else
                        maskObj.getParameter('PctAck').Enabled='on';
                    end
                end
            case 'Lookup table'
                maskObj.getParameter('StrgRatio').Visible='off';
                maskObj.getParameter('StrgRatio').Enabled='off';
                maskObj.getParameter('PctAck').Visible='off';
                maskObj.getParameter('PctAck').Enabled='off';
                if strcmp(StrgType,'Ackerman')
                    if strcmp(ExternalPctAck,'on')
                        maskObj.getParameter('PctAckTbl').Enabled='off';
                    else
                        maskObj.getParameter('PctAckTbl').Enabled='on';
                    end
                end
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

        end
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
