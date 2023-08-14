function[varargout]=vehdynlibdynamicsteering(varargin)
    varargout{1}=0;
    block=varargin{1};
    maskMode=varargin{2};
    maskObj=Simulink.Mask.get(block);
    StrgType=get_param(block,'StrgType');
    StrgRatioType=get_param(block,'StrgRatioType');
    PwrAst=get_param(block,'PwrAst');
    MaskParamsAng=maskObj.getWorkspaceVariables;


    switch maskMode

    case 'Init'
        Initialization;
    case 'PowerAssist'
        PowerAssist;
    otherwise
        varargout{1}=0;
    end

    function Initialization

        ParamList={...
        'TrckWdth',[1,1],{'gt',0};...
        'WhlBase',[1,1],{'gt',0};...
        'StrgRng',[1,1],{'gt',0};...
        'StrgRatio',[1,1],{'gt',0};...
        'StrgArmLngth',[1,1],{'gt',0};...
        'RckCsLngth',[1,1],{'gt',0};...
        'TieRodLngth',[1,1],{'gt',0};...
        'D',[1,1],{'gt',0};...
        'PnnRadius',[1,1],{'gt',0};...
        'RodLngth',[1,1],{'gt',0};...
        'J1',[1,1],{'gt',0};...
        'J2',[1,1],{'gt',0};...
        'beta_u',[1,1],{'gte',0};...
        'beta_l',[1,1],{'gte',0};...
        'b1',[1,1],{'gte',0};...
        'b2',[1,1],{'gte',0};...
        'b3',[1,1],{'gte',0};...
        'k1',[1,1],{'gte',0};...
        'omega_o',[1,1],{};...
        'theta_o',[1,1],{};...
        'FricTrq',[1,1],{};...
        'TrqLmt',[1,1],{'gte',0};...
        'PwrLmt',[1,1],{'gte',0};...
        'Eta',[1,1],{'gte',0;'lte',1};...
        'omega_c',[1,1],{'gte',0};...
        };
        StrgAngBpts={'StrgAngBpts',{}};
        AstTrqBpts={'TrqBpts',{},'VehSpdBpts',{}};
        LookupTblList={StrgAngBpts,'StrgRatioTbl',{'gt',0};...
        AstTrqBpts,'TrqTbl',{};...
        };
        autoblkscheckparams(block,'VDYNBLKSDYNAMICSTEERING',ParamList,LookupTblList);
        if strcmp(StrgType,'Rack and pinion')
            TrckWdth=MaskParamsAng(strcmp({MaskParamsAng.Name},'TrckWdth')).Value;
            StrgArmLngth=MaskParamsAng(strcmp({MaskParamsAng.Name},'StrgArmLngth')).Value;
            RckCsLngth=MaskParamsAng(strcmp({MaskParamsAng.Name},'RckCsLngth')).Value;
            TieRodLngth=MaskParamsAng(strcmp({MaskParamsAng.Name},'TieRodLngth')).Value;
            D=MaskParamsAng(strcmp({MaskParamsAng.Name},'D')).Value;

            vdyncheckrackpinion(TrckWdth,StrgArmLngth,RckCsLngth,TieRodLngth,D);
        end

        EffctOptions={'vehdynlibsteeringcommon/AckermanConstantRatio','AckermanConstantRatio';...
        'vehdynlibsteeringcommon/RackandPinConstantRatio','RackandPinConstantRatio';...
        'vehdynlibsteeringcommon/ParaArmConstRatio','ParaArmConstRatio';...
        'vehdynlibsteeringcommon/ParalConstRatio','ParalConstRatio';...
        'vehdynlibsteeringcommon/AckermanVariableRatio','AckermanVariableRatio';...
        'vehdynlibsteeringcommon/RackandPinVariableRatio','RackandPinVariableRatio';...
        'vehdynlibsteeringcommon/ParaArmVarRatio','ParaArmVarRatio';...
        'vehdynlibsteeringcommon/ParalVarRatio','ParalVarRatio'};
        Loc=get_param(block,'Loc');
        switch Loc
        case 'Front'
            set_param([block,'/TrqSwitch/index'],'Value','1');
            set_param([block,'/AngSwitch/index'],'Value','1');
            set_param([block,'/SpdSwitch/index'],'Value','1');
        case 'Rear'
            set_param([block,'/TrqSwitch/index'],'Value','0');
            set_param([block,'/AngSwitch/index'],'Value','0');
            set_param([block,'/SpdSwitch/index'],'Value','0');
        end
        switch StrgRatioType
        case 'Constant'
            switch StrgType
            case 'Ackerman'
                autoblksreplaceblock(block,EffctOptions,1);
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
                autoblksreplaceblock(block,EffctOptions,5);
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
        PwrAssitOptions={'vehdynlibsteeringcommon/PowerAssist','PowerAssist';...
        'vehdynlibsteeringcommon/NoAssist','NoAssist';...
        };
        PwrAssistPortOptions={'simulink/Sources/In1','VehSpd';...
        'simulink/Sources/Ground','Ground';...
        };
        switch PwrAst
        case 'on'
            autoblksreplaceblock(block,PwrAssitOptions,1);
            autoblksreplaceblock(block,PwrAssistPortOptions,1);
            set_param([block,'/',PwrAssistPortOptions{1,2}],'Port','4');
        case 'off'
            autoblksreplaceblock(block,PwrAssitOptions,2);
            autoblksreplaceblock(block,PwrAssistPortOptions,2);
        end

    end
    function PowerAssist
        parameterControl=maskObj.getDialogControl('ParameterGroupVar');
        PwrAstControl=parameterControl.getDialogControl('PwrAstParam');
        PwrAstControl.Enabled=PwrAst;
        PwrAstControl.Visible=PwrAst;
        maskObj.getParameter('TrqBpts').Visible=PwrAst;
        maskObj.getParameter('TrqBpts').Enabled=PwrAst;
        maskObj.getParameter('VehSpdBpts').Visible=PwrAst;
        maskObj.getParameter('VehSpdBpts').Enabled=PwrAst;
        maskObj.getParameter('TrqLmt').Visible=PwrAst;
        maskObj.getParameter('TrqLmt').Enabled=PwrAst;
        maskObj.getParameter('PwrLmt').Visible=PwrAst;
        maskObj.getParameter('PwrLmt').Enabled=PwrAst;
        maskObj.getParameter('Eta').Visible=PwrAst;
        maskObj.getParameter('Eta').Enabled=PwrAst;
        maskObj.getParameter('TrqTbl').Visible=PwrAst;
        maskObj.getParameter('TrqTbl').Enabled=PwrAst;
        maskObj.getParameter('omega_c').Visible=PwrAst;
        maskObj.getParameter('omega_c').Enabled=PwrAst;

    end
end