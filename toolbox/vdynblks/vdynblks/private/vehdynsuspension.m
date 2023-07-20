function[varargout]=vehdynsuspension(varargin)



    block=varargin{1};
    context=varargin{2};

    varargout{1}={[]};

    switch context
    case 'init'
        InitSuspension(block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(block);
    case 'NumAxles'
        SuspNumAxlesSpinboxCallback(block);
    case 'NumTracks'
        SuspNumTracksCallback(block);
    case 'SuspTypeEn'
        SuspTypeEnCallback(block);
    case 'IdealParms'
        SuspIdealParmsCallback(block);
    case 'KandCParms'
        SuspKandCParmsCallback(block);
    case 'KandCInternalParmsCalc'
        varargout{1}=CalcInternalKandCParmeters(block);
    case 'MappedParms'
        SuspMappedParmsCallback(block);
    case 'SuspAxlesUsedOn'
        SuspAxlesUsedOnCallback(block);
    case 'SteeredAxleEnables'
        SuspSteeredAxleEnablesCallback(block);
    case 'SuspActiveSuspEnableCallback'
        SuspActiveSuspEnableCallback(block);
    case 'AntiSwayParms'
        SuspAntiSwayCallback(block);
    case 'AntiSwayEnables'
        SuspAntiSwayEnablesCallback(block);
    case 'SolidAxleParms'
        SuspSolidAxleParmsCallback(block);
    case 'SuspTypeCallback'
        SuspTypeCallback(block);
    case 'ShockTypeCallback'
        ShockTypeCallback(block);
    case 'DrivetrainTypeCallback'
        DrivetrainTypeCallback(block);
    case 'WheelRatesCallback'
        WheelRatesCallback(block);
    otherwise
    end

end

function InitSuspension(block)


    autoblksgetmaskparms(block,{'NumAxl','NumWhlsByAxl','StrgEnByAxl'},true);


    autoblksgetmaskparms(block,{'SuspImage'},true);

    if strcmp(SuspImage,'suspkandc.png')||strcmp(SuspImage,'suspkandctwist.png')
        if(NumAxl==2)&&isequal(NumWhlsByAxl,[2,2])
            autoblksenableparameters(block,{'SuspType'},[],[],[],true);
        else
            set_param(block,'SuspType','Linear');
            autoblksenableparameters(block,[],{'SuspType'},[],[],true);
        end
    end


    if strcmp(get_param(block,'IdealSuspEn'),'on')
        set_param(block,'IdealSuspAxles',['[',num2str(1:NumAxl),']']);
    end

    if strcmp(get_param(block,'MappedSuspEn'),'on')
        set_param(block,'MappedSuspAxles',['[',num2str(1:NumAxl),']']);
    end

    SuspAxlesUsedOnCallback(block);

    if strcmp(get_param(block,'IdealSuspEn'),'on')
        if strcmp(SuspImage,'suspkandc.png')||strcmp(SuspImage,'suspkandctwist.png')
            if strcmp(get_param(block,'SuspType'),'Linear')
                SuspIdealParmsCallback(block);
            else
                SuspKandCParmsCallback(block);
            end
        else
            SuspIdealParmsCallback(block);
        end
    end

    if strcmp(get_param(block,'MappedSuspEn'),'on')
        SuspMappedParmsCallback(block);
    end

    SuspNumAxlesSpinboxCallback(block);
    SuspNumTracksCallback(block);

    SuspSteeredAxleEnablesCallback(block);

    autoblksgetmaskparms(block,{'StrgEnByAxl'},true);

    if sum(StrgEnByAxl)>0
        SwitchInport(block,'StrgAng',true);
    else
        SwitchInport(block,'StrgAng',false);
    end

    if strcmp(SuspImage,'suspkandc.png')||strcmp(SuspImage,'suspkandctwist.png')

        if strcmp(get_param(block,'SuspType'),'Independent front and rear')||strcmp(get_param(block,'SuspType'),'Independent front and twist-beam rear')

            SwitchInport(block,'Phi',true);

            SwitchInport(block,'TrckWdth',true);

            if autoblkschecksimstopped(block)


                autoblksgetmaskparms(block,{'BumpSteer','BumpCamber','BumpCaster','LatWhlCtrDisp','LngWhlCtrDisp','NrmlWhlRates','LatSteerCompl','LatCambCompl','LatWhlCtrComplLat','LngSteerCompl','LngCambCompl','LngCastCompl','LngWhlCtrCompl','LatWhlCtrComplLngBrk','RollCamber','RollSteer','RollCaster','ShckFrcVsCompRate','MotRatios','CambVsSteerAng','CastVsSteerAng','AlgnTrqCambCompl','AlgnTrqSteerCompl','LatLdTrnsfr'},true);

                if isstruct(BumpSteer)
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Steer Kinematic and Compliance Effects/Bump Steer'],'LabelModeActiveChoice','2');
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Steer Kinematic and Compliance Effects/Bump Steer'],'LabelModeActiveChoice','1');
                end

                if isstruct(BumpCamber)
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Camber Kinematic and Compliance Effects/Bump Camber'],'LabelModeActiveChoice','2');
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Camber Kinematic and Compliance Effects/Bump Camber'],'LabelModeActiveChoice','1');
                end

                if isstruct(BumpCaster)
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Caster Kinematic and Compliance Effects/Bump Caster'],'LabelModeActiveChoice','2');
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Caster Kinematic and Compliance Effects/Bump Caster'],'LabelModeActiveChoice','1');
                end

                if strcmp(get_param(block,'SuspType'),'Independent front and rear')

                    if isstruct(LatWhlCtrDisp)
                        set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Lateral Wheel Center Displacement Effects/Bump Lateral Wheel Displacement'],'LabelModeActiveChoice','2');

                        if isstruct(BumpCamber)&&isstruct(BumpCaster)&&isstruct(LngWhlCtrDisp)
                            set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic/Kinematics and Compliance Suspension/Constrained spring damper combination for K&C/Lateral Vertical Load Transfer Effects'],'LabelModeActiveChoice','2');
                        else
                            set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic/Kinematics and Compliance Suspension/Constrained spring damper combination for K&C/Lateral Vertical Load Transfer Effects'],'LabelModeActiveChoice','1');
                        end

                    else

                        set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Lateral Wheel Center Displacement Effects/Bump Lateral Wheel Displacement'],'LabelModeActiveChoice','1');
                        set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic/Kinematics and Compliance Suspension/Constrained spring damper combination for K&C/Lateral Vertical Load Transfer Effects'],'LabelModeActiveChoice','1');

                    end

                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic/Kinematics and Compliance Suspension/Constrained spring damper combination for K&C/Anti-roll Bar Force/Select ARB Front and Rear Stiffnesses/Arb Roll Stiffness'],'LabelModeActiveChoice','1');

                elseif strcmp(get_param(block,'SuspType'),'Independent front and twist-beam rear')

                    if isstruct(LatWhlCtrDisp)
                        set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Lateral Wheel Center Displacement Effects/Bump Lateral Wheel Displacement'],'LabelModeActiveChoice','2');
                    else
                        set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Lateral Wheel Center Displacement Effects/Bump Lateral Wheel Displacement'],'LabelModeActiveChoice','1');
                    end

                    if~isstruct(LatLdTrnsfr)&&isstruct(LatWhlCtrDisp)&&isstruct(BumpCamber)&&isstruct(BumpCaster)&&isstruct(LngWhlCtrDisp)
                        set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic/Kinematics and Compliance Suspension/Constrained spring damper combination for K&C/Lateral Vertical Load Transfer Effects'],'LabelModeActiveChoice','3');
                    elseif isstruct(LatLdTrnsfr)&&isstruct(LatWhlCtrDisp)&&isstruct(BumpCamber)&&isstruct(BumpCaster)&&isstruct(LngWhlCtrDisp)
                        set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic/Kinematics and Compliance Suspension/Constrained spring damper combination for K&C/Lateral Vertical Load Transfer Effects'],'LabelModeActiveChoice','4');
                    elseif~isstruct(LatLdTrnsfr)
                        set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic/Kinematics and Compliance Suspension/Constrained spring damper combination for K&C/Lateral Vertical Load Transfer Effects'],'LabelModeActiveChoice','5');
                    elseif isstruct(LatLdTrnsfr)
                        set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic/Kinematics and Compliance Suspension/Constrained spring damper combination for K&C/Lateral Vertical Load Transfer Effects'],'LabelModeActiveChoice','6');
                    else
                        set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Lateral Wheel Center Displacement Effects/Bump Lateral Wheel Displacement'],'LabelModeActiveChoice','1');
                    end

                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic/Kinematics and Compliance Suspension/Constrained spring damper combination for K&C/Anti-roll Bar Force/Select ARB Front and Rear Stiffnesses/Arb Roll Stiffness'],'LabelModeActiveChoice','2');

                end

                if isstruct(LngWhlCtrDisp)
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Longitudinal Wheel Center Displacement Effects/Bump Longitudinal Wheel Displacement'],'LabelModeActiveChoice','2');
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Longitudinal Wheel Center Displacement Effects/Bump Longitudinal Wheel Displacement'],'LabelModeActiveChoice','1');
                end

                if isstruct(NrmlWhlRates)
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic/Kinematics and Compliance Suspension/Constrained spring damper combination for K&C/Wheel Rate'],'LabelModeActiveChoice','1');
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic/Kinematics and Compliance Suspension/Constrained spring damper combination for K&C/Wheel Rate'],'LabelModeActiveChoice','0');
                end

                if isstruct(LatCambCompl)
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Camber Kinematic and Compliance Effects/Lateral Camber Compliance'],'LabelModeActiveChoice','2');
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Camber Kinematic and Compliance Effects/Lateral Camber Compliance'],'LabelModeActiveChoice','1');
                end

                if isstruct(LatSteerCompl)
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Steer Kinematic and Compliance Effects/Lateral Steer Compliance'],'LabelModeActiveChoice','2');
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Steer Kinematic and Compliance Effects/Lateral Steer Compliance'],'LabelModeActiveChoice','1');
                end

                if isstruct(LatWhlCtrComplLat)
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Lateral Wheel Center Displacement Effects/Lateral Wheel Compliance'],'LabelModeActiveChoice','2');
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Lateral Wheel Center Displacement Effects/Lateral Wheel Compliance'],'LabelModeActiveChoice','1');
                end

                if isstruct(LngSteerCompl)
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Steer Kinematic and Compliance Effects/Longitudinal Steer Compliance'],'LabelModeActiveChoice','2');
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Steer Kinematic and Compliance Effects/Longitudinal Steer Compliance'],'LabelModeActiveChoice','1');
                end

                if isstruct(LngCambCompl)
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Camber Kinematic and Compliance Effects/Longitudinal Camber Compliance'],'LabelModeActiveChoice','2');
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Camber Kinematic and Compliance Effects/Longitudinal Camber Compliance'],'LabelModeActiveChoice','1');
                end

                if isstruct(LngCastCompl)
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Caster Kinematic and Compliance Effects/Longitudinal Caster Compliance'],'LabelModeActiveChoice','2');
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Caster Kinematic and Compliance Effects/Longitudinal Caster Compliance'],'LabelModeActiveChoice','1');
                end

                if isstruct(LngWhlCtrCompl)
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Longitudinal Wheel Center Displacement Effects/Longitudinal Wheel Compliance'],'LabelModeActiveChoice','2');
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Longitudinal Wheel Center Displacement Effects/Longitudinal Wheel Compliance'],'LabelModeActiveChoice','1');
                end

                if isstruct(LatWhlCtrComplLngBrk)
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Lateral Wheel Center Displacement Effects/Lateral Wheel Compliance from Fx'],'LabelModeActiveChoice','2');
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Lateral Wheel Center Displacement Effects/Lateral Wheel Compliance from Fx'],'LabelModeActiveChoice','1');
                end

                if strcmp(get_param(block,'RollParamEn'),'on')
                    if isstruct(RollCamber)
                        set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Camber Kinematic and Compliance Effects/Roll Camber'],'LabelModeActiveChoice','2');
                    else
                        set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Camber Kinematic and Compliance Effects/Roll Camber'],'LabelModeActiveChoice','1');
                    end


                    if isstruct(RollSteer)
                        set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Steer Kinematic and Compliance Effects/Roll Steer'],'LabelModeActiveChoice','2');
                    else
                        set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Steer Kinematic and Compliance Effects/Roll Steer'],'LabelModeActiveChoice','1');
                    end

                    if isstruct(RollCaster)
                        set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Caster Kinematic and Compliance Effects/Roll Caster'],'LabelModeActiveChoice','2');
                    else
                        set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Caster Kinematic and Compliance Effects/Roll Caster'],'LabelModeActiveChoice','1');
                    end
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Camber Kinematic and Compliance Effects/Roll Camber'],'LabelModeActiveChoice','0');
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Steer Kinematic and Compliance Effects/Roll Steer'],'LabelModeActiveChoice','0');
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Caster Kinematic and Compliance Effects/Roll Caster'],'LabelModeActiveChoice','0');
                end


                if strcmp(get_param(block,'ShockType'),'Constant')

                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic/Kinematics and Compliance Suspension/Constrained spring damper combination for K&C/Shock Force'],'LabelModeActiveChoice','2');
                elseif strcmp(get_param(block,'ShockType'),'Table-based individual')

                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic/Kinematics and Compliance Suspension/Constrained spring damper combination for K&C/Shock Force'],'LabelModeActiveChoice','1');
                else

                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic/Kinematics and Compliance Suspension/Constrained spring damper combination for K&C/Shock Force'],'LabelModeActiveChoice','0');
                end

                if isstruct(CambVsSteerAng)
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Camber Kinematic and Compliance Effects/Steer Camber'],'LabelModeActiveChoice','2');
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Camber Kinematic and Compliance Effects/Steer Camber'],'LabelModeActiveChoice','1');
                end

                if isstruct(CastVsSteerAng)
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Caster Kinematic and Compliance Effects/Steer Caster'],'LabelModeActiveChoice','2');
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Caster Kinematic and Compliance Effects/Steer Caster'],'LabelModeActiveChoice','1');
                end

                if isstruct(AlgnTrqCambCompl)
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Camber Kinematic and Compliance Effects/Aligning Torque Camber Compliance'],'LabelModeActiveChoice','2');
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Camber Kinematic and Compliance Effects/Aligning Torque Camber Compliance'],'LabelModeActiveChoice','1');
                end

                if isstruct(AlgnTrqSteerCompl)
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Steer Kinematic and Compliance Effects/Aligning Torque Steer Compliance'],'LabelModeActiveChoice','2');
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations/Kinematics and Compliance Steering Enabled/Steer Kinematic and Compliance Effects/Aligning Torque Steer Compliance'],'LabelModeActiveChoice','1');
                end

                if isstruct(LatWhlCtrDisp)&&isstruct(BumpCamber)&&isstruct(BumpCaster)&&isstruct(LngWhlCtrDisp)
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic/Kinematics and Compliance Suspension/Constrained spring damper combination for K&C/Longitudinal Side View Swing Arm Anti-Effects'],'LabelModeActiveChoice','2');
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic/Kinematics and Compliance Suspension/Constrained spring damper combination for K&C/Longitudinal Side View Swing Arm Anti-Effects'],'LabelModeActiveChoice','0');
                end

            end

        else
            SwitchInport(block,'Phi',false);
            SwitchInport(block,'TrckWdth',false);
        end
    end

    if~strcmp(SuspImage,'suspindmap.png')&&~strcmp(SuspImage,'suspsacoil.png')&&~strcmp(SuspImage,'suspsa.png')&&~strcmp(SuspImage,'suspsacoil.png')&&~strcmp(SuspImage,'suspsaleaf.png')&&~strcmp(SuspImage,'suspsamap.png')

        SuspActiveSuspEnableCallback(block);
        ActiveDampEn=get_param(block,'ActiveDampEn');

        if strcmp(ActiveDampEn,'on')
            SwitchInport(block,'ActSuspDutyCycle',true);
        else
            SwitchInport(block,'ActSuspDutyCycle',false);
        end

    end

    if~strcmp(SuspImage,'suspsa.png')&&~strcmp(SuspImage,'suspsacoil.png')&&~strcmp(SuspImage,'suspsaleaf.png')&&~strcmp(SuspImage,'suspsamap.png')

        SuspAntiSwayEnablesCallback(block);

        autoblksgetmaskparms(block,{'AntiSwayEnByAxl'},true);

        if sum(AntiSwayEnByAxl)>0
            SuspAntiSwayCallback(block);
        end

    end

    if strcmp(SuspImage,'suspsa.png')||strcmp(SuspImage,'suspsacoil.png')||strcmp(SuspImage,'suspsaleaf.png')||strcmp(SuspImage,'suspsamap.png')
        SuspSolidAxleParmsCallback(block);
    end



    k=1;
    for i=1:NumAxl

        NumTracks=NumWhlsByAxl(i);
        for j=1:NumTracks
            WhlNumVec(1,k)=j;
            AxleNumVec(1,k)=i;
            k=k+1;
        end

    end

    set_param(block,'AxleNumVec',['[',num2str(AxleNumVec),']']);
    set_param(block,'WhlNumVec',['[',num2str(WhlNumVec),']']);



end



function SuspTypeEnCallback(block)

    Containers={'IdealSusp','MappedSusp'};

    OnContainerInds=[];
    if strcmp(get_param(block,'IdealSuspEn'),'on')
        OnContainerInds=[OnContainerInds,1];
    end

    if strcmp(get_param(block,'MappedSuspEn'),'on')
        OnContainerInds=[OnContainerInds,2];
    end

    OnContainer=Containers(OnContainerInds);
    OffContainers=setdiff(Containers,OnContainer);

    autoblksenableparameters(block,[],[],OnContainer,OffContainers);

    autoblksgetmaskparms(block,{'SuspImage'},true);

    if~strcmp(SuspImage,'suspindmap.png')&&~strcmp(SuspImage,'suspsacoil.png')&&~strcmp(SuspImage,'suspsa.png')&&~strcmp(SuspImage,'suspsacoil.png')&&~strcmp(SuspImage,'suspsaleaf.png')&&~strcmp(SuspImage,'suspsamap.png')
        ActiveDampEn=get_param(block,'ActiveDampEn');
    else
        ActiveDampEn='off';
    end

    if strcmp(get_param(block,'IdealSuspEn'),'on')&&strcmp(ActiveDampEn,'off')
        if autoblkschecksimstopped(block)
            set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic'],'LabelModeActiveChoice','IdealSuspension');
        end
    elseif strcmp(get_param(block,'IdealSuspEn'),'on')&&strcmp(ActiveDampEn,'on')
        if autoblkschecksimstopped(block)
            set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic'],'LabelModeActiveChoice','IdealActiveSuspension');
        end
    end

    if strcmp(get_param(block,'MappedSuspEn'),'on')
        if autoblkschecksimstopped(block)
            set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic'],'LabelModeActiveChoice','MappedSuspension');
        end
    end

end

function SuspNumAxlesSpinboxCallback(block)

    ParamList={'NumAxl',[1,1],{'gte',1;'int',0;'lte',100}};
    autoblkscheckparams(block,'Suspension',ParamList,{});

end


function SuspNumTracksCallback(block)

    autoblksgetmaskparms(block,{'NumAxl'},true);
    ParamList={'NumWhlsByAxl',[1,NumAxl],{'gte',1;'int',0;'lte',100}};
    autoblkscheckparams(block,'Suspension',ParamList,{});

end


function SuspActiveSuspEnableCallback(block)

    autoblksgetmaskparms(block,{'SuspImage'},true);

    if~strcmp(SuspImage,'suspindmap.png')&&~strcmp(SuspImage,'suspsacoil.png')&&~strcmp(SuspImage,'suspsa.png')&&~strcmp(SuspImage,'suspsacoil.png')&&~strcmp(SuspImage,'suspsaleaf.png')&&~strcmp(SuspImage,'suspsamap.png')

        if strcmp(SuspImage,'suspkandc.png')||strcmp(SuspImage,'suspkandctwist.png')
            if strcmp(get_param(block,'SuspType'),'Independent front and rear')
                set_param(block,'ActiveDampEn','off');
            end
        end

        ActiveDampEn=strcmp(get_param(block,'ActiveDampEn'),'on');

        ContainersActive={'f_act_susp_cz','f_act_susp_duty_bpt','f_act_susp_zdot_bpt','ActiveParms'};
        ContainersPassive={'Cz'};

        if ActiveDampEn>0
            autoblksenableparameters(block,[],[],ContainersActive,ContainersPassive);
        else
            autoblksenableparameters(block,[],[],ContainersPassive,ContainersActive);
        end

    end

end


function SuspSteeredAxleEnablesCallback(block)

    autoblksgetmaskparms(block,{'NumAxl'},true);
    ParamList={'StrgEnByAxl',[1,NumAxl],{'gte',0;'int',0;'lte',1}};
    autoblkscheckparams(block,'Suspension',ParamList,{});

    autoblksgetmaskparms(block,{'StrgEnByAxl'},true);

    Containers={'SuspSteering','StrgHgtSlp','CamberStrgSlp','CasterStrgSlp','ToeStrgSlp'};
    if sum(StrgEnByAxl)>0
        autoblksenableparameters(block,[],[],Containers,[]);
    else
        autoblksenableparameters(block,[],[],[],Containers);
    end

end


function SuspAntiSwayEnablesCallback(block)
    SrcBlock=get_param(block,'Name');
    autoblksgetmaskparms(block,{'NumAxl','NumWhlsByAxl'},true);

    ParamList={'AntiSwayEnByAxl',[1,NumAxl],{'gte',0;'int',0;'lte',1}};
    autoblkscheckparams(block,'Suspension',ParamList,{});

    autoblksgetmaskparms(block,{'AntiSwayEnByAxl'},true);

    if any((AntiSwayEnByAxl==1)&(NumWhlsByAxl~=2))
        error(message('autoblks_shared:autoblkSuspension:invalidNumTracksForAntiSway',SrcBlock,'AntiSwayEnByAxl'));
    end

    Container={'AntiSway'};

    autoblksgetmaskparms(block,{'SuspImage'},true);

    if strcmp(SuspImage,'suspkandc.png')||strcmp(SuspImage,'suspkandctwist.png')
        if strcmp(get_param(block,'SuspType'),'Linear')
            EnableAntiSwayCheck=true;
        else
            EnableAntiSwayCheck=false;
        end
    else
        EnableAntiSwayCheck=true;
    end

    if(sum(AntiSwayEnByAxl)>0)&&EnableAntiSwayCheck
        autoblksenableparameters(block,[],[],Container,[]);
        if autoblkschecksimstopped(block)
            set_param([block,'/Anti-Sway Force'],'LabelModeActiveChoice','AntiSway');
        end
    else
        autoblksenableparameters(block,[],[],[],Container);
        if autoblkschecksimstopped(block)
            set_param([block,'/Anti-Sway Force'],'LabelModeActiveChoice','NoOp');
        end
    end

end


function SuspAntiSwayCallback(block)



    autoblksgetmaskparms(block,{'SuspImage'},true);

    if strcmp(SuspImage,'suspkandc.png')||strcmp(SuspImage,'suspkandctwist.png')

        if strcmp(get_param(block,'SuspType'),'Linear')
            CheckAntiSwayParms=true;
        else
            CheckAntiSwayParms=false;
        end

    else
        CheckAntiSwayParms=true;
    end

    if CheckAntiSwayParms==true

        autoblksgetmaskparms(block,{'AntiSwayEnByAxl'},true);
        NumAntiSwayParms=sum(AntiSwayEnByAxl);

        ParamList={'AntiSwayR',[1,GetIdealSuspParmLenReq(block,'AntiSwayR',NumAntiSwayParms)],{'gte',0;'lte',1};...
        'AntiSwayNtrlAng',[1,GetIdealSuspParmLenReq(block,'AntiSwayNtrlAng',NumAntiSwayParms)],{'gte',-pi/2;'lte',pi/2};...
        'AntiSwayTrsK',[1,GetIdealSuspParmLenReq(block,'AntiSwayTrsK',NumAntiSwayParms)],{'gte',0.;'lte',1.e6}};

        autoblkscheckparams(block,'Suspension',ParamList,{});

    end


end


function SuspAxlesUsedOnCallback(block)

    SrcBlock=get_param(block,'Name');


    autoblksgetmaskparms(block,{'StrgEnByAxl'},true);



    AllSuspAxles=[];
    AllSuspAxleTypes=[];
    if strcmp(get_param(block,'IdealSuspEn'),'on')
        IdealSuspAxles=[];
        autoblksgetmaskparms(block,{'IdealSuspAxles'},true);
        AllSuspAxles=[AllSuspAxles;IdealSuspAxles(:)];
        AllSuspAxleTypes=[AllSuspAxleTypes;1*ones(length(IdealSuspAxles),1)];

        autoblksgetmaskparms(block,{'SuspImage'},true);

        if~strcmp(SuspImage,'suspindmap.png')&&~strcmp(SuspImage,'suspsacoil.png')&&~strcmp(SuspImage,'suspsa.png')&&~strcmp(SuspImage,'suspsacoil.png')&&~strcmp(SuspImage,'suspsaleaf.png')&&~strcmp(SuspImage,'suspsamap.png')
            ActiveDampEn=get_param(block,'ActiveDampEn');
        else
            ActiveDampEn='off';
        end


        if autoblkschecksimstopped(block)
            autoblksgetmaskparms(block,{'SuspImage'},true);
            if strcmp(ActiveDampEn,'off')
                if strcmp(SuspImage,'suspkandc.png')||strcmp(SuspImage,'suspkandctwist.png')
                    SuspTypeCallback(block);
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic'],'LabelModeActiveChoice','IdealSuspension');
                end

            else
                if strcmp(SuspImage,'suspkandc.png')||strcmp(SuspImage,'suspkandctwist.png')
                    set_param(block,'SuspType','Linear');
                    SuspTypeCallback(block);
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic'],'LabelModeActiveChoice','IdealActiveSuspension');
                end
            end
            if sum(StrgEnByAxl)>0
                autoblksgetmaskparms(block,{'SuspImage'},true);
                if strcmp(SuspImage,'suspkandc.png')||strcmp(SuspImage,'suspkandctwist.png')
                    SuspTypeCallback(block);
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations'],'LabelModeActiveChoice','IdealSteeringEnabled');
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic/Ideal Suspension/Steering Height Slope'],'LabelModeActiveChoice','SteeringEnabled');
                end
            else
                autoblksgetmaskparms(block,{'SuspImage'},true);
                if strcmp(SuspImage,'suspkandc.png')||strcmp(SuspImage,'suspkandctwist.png')
                    SuspTypeCallback(block);
                else
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations'],'LabelModeActiveChoice','IdealSteeringDisabled');
                    set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic/Ideal Suspension/Steering Height Slope'],'LabelModeActiveChoice','SteeringDisabled');
                end
            end
        end
    end

    if strcmp(get_param(block,'MappedSuspEn'),'on')
        MappedSuspAxles=[];
        autoblksgetmaskparms(block,{'MappedSuspAxles'},true);
        AllSuspAxles=[AllSuspAxles;MappedSuspAxles(:)];
        AllSuspAxleTypes=[AllSuspAxleTypes;2*ones(length(MappedSuspAxles),1)];
        if autoblkschecksimstopped(block)
            set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic'],'LabelModeActiveChoice','MappedSuspension');
            set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations'],'LabelModeActiveChoice','MappedSteeringEnabled');
        end
    end


    if length(unique(AllSuspAxles))~=length(AllSuspAxles)

        if strcmp(get_param(block,'IdealSuspEn'),'on')&&strcmp(get_param(block,'MappedSuspEn'),'on')
            error(message('autoblks_shared:autoblkSuspension:invalidSuspAxleAssign',SrcBlock,'MappedSuspAxles and IdealSuspAxles combined'));
        elseif strcmp(get_param(block,'IdealSuspEn'),'on')
            error(message('autoblks_shared:autoblkSuspension:invalidSuspAxleAssign',SrcBlock,'IdealSuspAxles'));
        elseif strcmp(get_param(block,'MappedSuspEn'),'on')
            error(message('autoblks_shared:autoblkSuspension:invalidSuspAxleAssign',SrcBlock,'MappedSuspAxles'));
        end

    elseif~isempty(AllSuspAxles)&&((sum(diff(sort(AllSuspAxles)))~=(length(AllSuspAxles)-1))||(min(AllSuspAxles)~=1))

        if strcmp(get_param(block,'IdealSuspEn'),'on')&&strcmp(get_param(block,'MappedSuspEn'),'on')
            error(message('autoblks_shared:autoblkSuspension:invalidSuspAxleIndices',SrcBlock,'MappedSuspAxles and IdealSuspAxles'));
        elseif strcmp(get_param(block,'IdealSuspEn'),'on')
            error(message('autoblks_shared:autoblkSuspension:invalidSuspAxleIndices',SrcBlock,'IdealSuspAxles'));
        elseif strcmp(get_param(block,'MappedSuspEn'),'on')
            error(message('autoblks_shared:autoblkSuspension:invalidSuspAxleIndices',SrcBlock,'MappedSuspAxles'));
        end

    else

        [~,axlesortind]=sort(AllSuspAxles,'ascend');
        SuspTypesByAxle=AllSuspAxleTypes(axlesortind);
        set_param(block,'SuspTypesByAxle',['[',num2str(SuspTypesByAxle(:)'),']']);
    end


    if strcmp(get_param(block,'IdealSuspEn'),'on')
        if(length(IdealSuspAxles)>1)&&min(diff(IdealSuspAxles))<0
            error(message('autoblks_shared:autoblkSuspension:invalidSuspNonMonoAxleIndices',SrcBlock,'IdealSuspAxles'));
        end
    end

    if strcmp(get_param(block,'MappedSuspEn'),'on')
        if(length(MappedSuspAxles)>1)&&min(diff(MappedSuspAxles))<0
            error(message('autoblks_shared:autoblkSuspension:invalidSuspNonMonoAxleIndices',SrcBlock,'MappedSuspAxles'));
        end
    end

end


function SuspIdealParmsCallback(block)




    autoblksgetmaskparms(block,{'IdealSuspAxles','StrgEnByAxl'},true);
    NumIdealSuspAxles=length(IdealSuspAxles);

    autoblksgetmaskparms(block,{'SuspImage'},true);

    if~strcmp(SuspImage,'suspindmap.png')&&~strcmp(SuspImage,'suspsacoil.png')&&~strcmp(SuspImage,'suspsa.png')&&~strcmp(SuspImage,'suspsacoil.png')&&~strcmp(SuspImage,'suspsaleaf.png')&&~strcmp(SuspImage,'suspsamap.png')
        ActiveDampEn=get_param(block,'ActiveDampEn');
    else
        ActiveDampEn='off';
    end

    if sum(StrgEnByAxl)>0

        ParamList={'IdealSuspAxles',[1,max(1,NumIdealSuspAxles)],{'gte',1;'lte',100};...
        'Kz',[1,GetIdealSuspParmLenReq(block,'Kz',NumIdealSuspAxles)],{'gte',1;'lte',1e10};...
        'F0z',[1,GetIdealSuspParmLenReq(block,'F0z',NumIdealSuspAxles)],{'gte',0.;'lte',1e7};...
        'Hmax',[1,GetIdealSuspParmLenReq(block,'Hmax',NumIdealSuspAxles)],{'gte',0.01;'lte',10};...
        'Camber',[1,GetIdealSuspParmLenReq(block,'Camber',NumIdealSuspAxles)],{'gte',-pi/2;'lte',pi/2};...
        'Caster',[1,GetIdealSuspParmLenReq(block,'Caster',NumIdealSuspAxles)],{'gte',-pi/2;'lte',pi/2};...
        'Toe',[1,GetIdealSuspParmLenReq(block,'Toe',NumIdealSuspAxles)],{'gte',-pi/2;'lte',pi/2};...
        'CamberHslp',[1,GetIdealSuspParmLenReq(block,'CamberHslp',NumIdealSuspAxles)],{'gte',-1e6;'lte',1e6};...
        'CasterHslp',[1,GetIdealSuspParmLenReq(block,'CamberHslp',NumIdealSuspAxles)],{'gte',-1e6;'lte',1e6};...
        'RollStrgSlp',[1,GetIdealSuspParmLenReq(block,'RollStrgSlp',NumIdealSuspAxles)],{'gte',-1e6;'lte',1e6};...
        'StrgHgtSlp',[1,GetIdealSuspParmLenReq(block,'StrgHgtSlp',max(sum(StrgEnByAxl),1))],{'gte',-1e6;'lte',1e6};...
        'CasterStrgSlp',[1,GetIdealSuspParmLenReq(block,'CasterStrgSlp',max(sum(StrgEnByAxl),1))],{'gte',-1e6;'lte',1e6};...
        'CamberStrgSlp',[1,GetIdealSuspParmLenReq(block,'CamberStrgSlp',max(sum(StrgEnByAxl),1))],{'gte',-1e6;'lte',1e6};...
        'ToeStrgSlp',[1,GetIdealSuspParmLenReq(block,'ToeStrgSlp',max(sum(StrgEnByAxl),1))],{'gte',-1e6;'lte',1e6}};
    else

        ParamList={'IdealSuspAxles',[1,max(1,NumIdealSuspAxles)],{'gte',1;'lte',100};...
        'Kz',[1,GetIdealSuspParmLenReq(block,'Kz',NumIdealSuspAxles)],{'gte',1;'lte',1e10};...
        'F0z',[1,GetIdealSuspParmLenReq(block,'F0z',NumIdealSuspAxles)],{'gte',0.;'lte',1e7};...
        'Hmax',[1,GetIdealSuspParmLenReq(block,'Hmax',NumIdealSuspAxles)],{'gte',0.01;'lte',10};...
        'Camber',[1,GetIdealSuspParmLenReq(block,'Camber',NumIdealSuspAxles)],{'gte',-pi/2;'lte',pi/2};...
        'Caster',[1,GetIdealSuspParmLenReq(block,'Caster',NumIdealSuspAxles)],{'gte',-pi/2;'lte',pi/2};...
        'Toe',[1,GetIdealSuspParmLenReq(block,'Toe',NumIdealSuspAxles)],{'gte',-pi/2;'lte',pi/2};...
        'CamberHslp',[1,GetIdealSuspParmLenReq(block,'CamberHslp',NumIdealSuspAxles)],{'gte',-1e6;'lte',1e6};...
        'CasterHslp',[1,GetIdealSuspParmLenReq(block,'CamberHslp',NumIdealSuspAxles)],{'gte',-1e6;'lte',1e6};...
        'RollStrgSlp',[1,GetIdealSuspParmLenReq(block,'RollStrgSlp',NumIdealSuspAxles)],{'gte',-1e6;'lte',1e6}};

    end

    if strcmp(ActiveDampEn,'off')
        ParamList(end+1,:)={'Cz',[1,GetIdealSuspParmLenReq(block,'Cz',NumIdealSuspAxles)],{'gte',0;'lte',1e6}};
        LookupTblList={};
    else
        autoblksgetmaskparms(block,{'f_act_susp_duty_bpt','f_act_susp_zdot_bpt'},true);
        ActSuspCzBpts={'f_act_susp_duty_bpt',{'gte',0;'lte',1},'f_act_susp_zdot_bpt',{'gte',-1e6;'lte',1e6}};
        LookupTblList={ActSuspCzBpts,'f_act_susp_cz',{'gte',0;'lte',1e6}};
    end

    autoblkscheckparams(block,'Suspension',ParamList,LookupTblList);

end


function SuspKandCParmsCallback(block)

    ParamChecks={'BumpSteer',[1,4],{'gte',-90.;'lte',90.};...
    'BumpCamber',[1,4],{'gte',-90.;'lte',90.};...
    'BumpCaster',[1,4],{'gte',-360.;'lte',360.};...
    'LatWhlCtrDisp',[1,4],{'gte',-1.;'lte',1.};...
    'LngWhlCtrDisp',[1,4],{'gte',-1.;'lte',1.};...
    'NrmlWhlRates',[1,4],{'gte',-1.e6;'lte',1.e6};...
    'CambVsSteerAng',[1,4],{'gte',-10.;'lte',10.};...
    'CastVsSteerAng',[1,4],{'gte',-10.;'lte',10.};...
    'LngSteerCompl',[2,4],{'gte',-90.;'lte',90.};...
    'LngCambCompl',[2,4],{'gte',-90.;'lte',90.};...
    'LngCastCompl',[2,4],{'gte',-360.;'lte',360.};...
    'LngWhlCtrCompl',[2,4],{'gte',-1.e6;'lte',1.e6};...
    'LatWhlCtrComplLngBrk',[2,4],{'gte',-1.e6;'lte',1.e6};...
    'LatSteerCompl',[1,4],{'gte',-360.;'lte',360.};...
    'LatCambCompl',[1,4],{'gte',-90.;'lte',90.};...
    'LatWhlCtrComplLat',[1,4],{'gte',-1.e6;'lte',1.e6};...
    'AlgnTrqSteerCompl',[1,4],{'gte',-360.;'lte',360.};...
    'AlgnTrqCambCompl',[1,4],{'gte',-90.;'lte',90.};...
    'StatToe',[1,4],{'gte',-90.;'lte',90.};...
    'StatCamber',[1,4],{'gte',-90.;'lte',90.};...
    'StatCaster',[1,4],{'gte',-360.;'lte',360.};...
    'ShckFrcVsCompRate',[1,4],{'gte',-1.e6;'lte',1.e6};...
    'MotRatios',[1,2],{'gte',-100.;'lte',100.};...
    'StatLdWhlR',[1,4],{'gte',0.;'lte',10.};...
    'NrmlWhlFrcOff',[1,4],{'gte',-1.e6;'lte',1.e6}};


    if strcmp(get_param(block,'SuspType'),'Independent front and rear')
        ParamChecks(end+1,:)={'RollStiffArb',[1,2],{'gte',-1.e6;'lte',1.e6}};
        ParamChecks(end+1,:)={'RollStiffNoArb',[1,2],{'gte',-1.e6;'lte',1.e6}};
    elseif strcmp(get_param(block,'SuspType'),'Independent front and twist-beam rear')
        ParamChecks(end+1,:)={'RollStiffArbFrnt',[1,1],{'gte',-1.e6;'lte',1.e6}};
        ParamChecks(end+1,:)={'RollStiffNoArbFrnt',[1,1],{'gte',-1.e6;'lte',1.e6}};
        ParamChecks(end+1,:)={'RollStiffNoTwstRear',[1,1],{'gte',-1.e6;'lte',1.e6}};
        ParamChecks(end+1,:)={'RollSteer',[1,2],{'gte',-10.;'lte',10.}};
        ParamChecks(end+1,:)={'RollCamber',[1,2],{'gte',-10.;'lte',10.}};
        ParamChecks(end+1,:)={'RollCaster',[1,2],{'gte',-100.;'lte',100.}};
        ParamChecks(end+1,:)={'LatLdTrnsfr',[1,4],{'gte',-1.e6;'lte',1.e6}};
    end

    ParamNameList=ParamChecks(:,1);

    for i=1:length(ParamNameList)
        if strcmp(ParamNameList(i),'RollStiffArbFrnt')||strcmp(ParamNameList(i),'RollStiffNoArbFrnt')||strcmp(ParamNameList(i),'RollStiffNoTwstRear')||strcmp(ParamNameList(i),'RollStiffArb')||strcmp(ParamNameList(i),'RollStiffNoArb')||strcmp(ParamNameList(i),'NrmlWhlFrcOff')||strcmp(ParamNameList(i),'StatLdWhlR')
            ParmIsArray(i)=true;
        else
            parm=autoblksgetmaskparms(block,ParamNameList(i),false);
            if isstruct(parm{1})
                ParmIsArray(i)=false;
            elseif isempty(parm{1})
                ParmIsArray(i)=false;
            elseif isnumeric(parm{1})
                ParmIsArray(i)=true;
            else
                ParmIsArray(i)=false;
            end
        end
    end

    TableParamsToCheck=ParamNameList(~ParmIsArray);

    ShockParms=autoblksgetmaskparms(block,{'ShckFrcVsCompRate','MotRatios'},false);

    if strcmp(get_param(block,'ShockType'),'Constant')&&~isnumeric(ShockParms{1})
        error(message('autoblks_shared:autoerrCheckParams:invalidDims',block,'ShckFrcVsCompRate','1','4'));
    elseif strcmp(get_param(block,'ShockType'),'Constant')&&~isnumeric(ShockParms{2})
        error(message('autoblks_shared:autoerrCheckParams:invalidDims',block,'MotRatios','1','2'));
    elseif strcmp(get_param(block,'ShockType'),'Table-based')&&~isstruct(ShockParms{1})
        error(message('autoblks_shared:autoerrCheckParams:invalidTableStructureFieldFormat',block,'ShckFrcVsCompRate'));
    elseif strcmp(get_param(block,'ShockType'),'Table-based')&&~isnumeric(ShockParms{2})
        error(message('autoblks_shared:autoerrCheckParams:invalidDims',block,'MotRatios','1','2'));
    elseif strcmp(get_param(block,'ShockType'),'Table-based')
        if~isfield(ShockParms{1},'F')||~isfield(ShockParms{1},'R')
            error(message('autoblks_shared:autoerrCheckParams:invalidTableStructureFieldFormat',block,'ShckFrcVsCompRate'));
        end
    elseif~isstruct(ShockParms{1})&&strcmp(get_param(block,'ShockType'),'Table-based individual')
        error(message('autoblks_shared:autoerrCheckParams:invalidTableStructureFieldFormat',block,'ShckFrcVsCompRate'));
    elseif~isstruct(ShockParms{2})&&strcmp(get_param(block,'ShockType'),'Table-based individual')
        error(message('autoblks_shared:autoerrCheckParams:invalidTableStructureFieldFormat',block,'MotRatios'));
    elseif strcmp(get_param(block,'ShockType'),'Table-based individual')
        if~isfield(ShockParms{1},'FL')||~isfield(ShockParms{1},'FR')||~isfield(ShockParms{1},'RL')||~isfield(ShockParms{1},'RR')
            error(message('autoblks_shared:autoerrCheckParams:invalidTableStructureFieldFormat',block,'ShckFrcVsCompRate'));
        end

        if~isfield(ShockParms{2},'FL')||~isfield(ShockParms{2},'FR')||~isfield(ShockParms{2},'RL')||~isfield(ShockParms{2},'RR')
            error(message('autoblks_shared:autoerrCheckParams:invalidTableStructureFieldFormat',block,'MotRatios'));
        end
    end

    ParamChecks=ParamChecks(ParmIsArray,:);

    if~isempty(ParamChecks)
        autoblkscheckparams(block,'Suspension',ParamChecks,{});
    end


    TableChecks={'BumpSteer',1,{'gte',-10.;'lte',10.},{'gte',-90.;'lte',90.};...
    'BumpCamber',1,{'gte',-10.;'lte',10.},{'gte',-90.;'lte',90.};...
    'BumpCaster',1,{'gte',-10.;'lte',10.},{'gte',-90.;'lte',90.};...
    'LatWhlCtrDisp',1,{'gte',-1000.;'lte',1000.},{'gte',-1000.;'lte',1000.};...
    'LngWhlCtrDisp',1,{'gte',-1000.;'lte',1000.},{'gte',-1000.;'lte',1000.};...
    'NrmlWhlRates',1,{'gte',-1000.;'lte',1000.},{'gte',-1.e5;'lte',1.e5};...
    'RollSteer',4,{'gte',-90.;'lte',90.},{'gte',-90.;'lte',90.};...
    'RollCamber',4,{'gte',-90.;'lte',90.},{'gte',-90.;'lte',90.};...
    'RollCaster',4,{'gte',-90.;'lte',90.},{'gte',-180.;'lte',180.};...
    'CambVsSteerAng',1,{'gte',-3600.;'lte',3600.},{'gte',-90.;'lte',90.};...
    'CastVsSteerAng',1,{'gte',-3600.;'lte',3600.},{'gte',-180.;'lte',180.};...
    'LngSteerCompl',2,{'gte',-10000.;'lte',10000.},{'gte',-360.;'lte',360.};...
    'LngCambCompl',2,{'gte',-100.;'lte',100.},{'gte',-90.;'lte',90.};...
    'LngCastCompl',2,{'gte',-100.;'lte',100.},{'gte',-180.;'lte',180.};...
    'LngWhlCtrCompl',2,{'gte',-100.;'lte',100.},{'gte',-1000.;'lte',1000.};...
    'LatWhlCtrComplLngBrk',2,{'gte',-100.;'lte',100.},{'gte',-1000.;'lte',1000.};...
    'LatSteerCompl',1,{'gte',-100.;'lte',100.},{'gte',-360.;'lte',360.};...
    'LatCambCompl',1,{'gte',-100.;'lte',100.},{'gte',-90.;'lte',90.};...
    'LatWhlCtrComplLat',1,{'gte',-100.;'lte',100.},{'gte',-1000.;'lte',1000.};...
    'AlgnTrqSteerCompl',1,{'gte',-10000.;'lte',10000.},{'gte',-360.;'lte',360.};...
    'AlgnTrqCambCompl',1,{'gte',-100.;'lte',100.},{'gte',-90.;'lte',90.};...
    'ShckFrcVsCompRate',[1,3],{'gte',-10000.;'lte',10000.},{'gte',-10000.;'lte',10000.};...
    'MotRatios',1,{'gte',-1.;'lte',1.},{'gte',-10.;'lte',10.};...
    'LatLdTrnsfr',1,{'gte',-100.;'lte',100.},{'gte',-1.e6;'lte',1.e6}};

    if strcmp(get_param(block,'ShockType'),'Constant')
        [~,TableCheckInds]=setdiff(TableChecks(:,1),{'ShckFrcVsCompRate','MotRatios'},'stable');
        TableChecks=TableChecks(TableCheckInds,:);
    elseif strcmp(get_param(block,'ShockType'),'Table-based')
        [~,TableCheckInds]=setdiff(TableChecks(:,1),'MotRatios','stable');
        TableChecks=TableChecks(TableCheckInds,:);
    end

    [~,IParamList]=intersect(TableChecks(:,1),TableParamsToCheck,'stable');

    [TableList,WsVars]=CheckWheelXYTable(block,TableChecks(IParamList,:));

    if~isempty(TableList)
        autoblkscheckparams(block,'Suspension',[],TableList,WsVars);
    end

end

function SuspMappedParmsCallback(block)

    autoblksgetmaskparms(block,{'MappedSuspAxles'},true);
    NumMappedSuspAxles=length(MappedSuspAxles);

    TblBpt_fmz={'f_susp_dz_bp',{'gte',-1e6;'lte',1e6},'f_susp_dzdot_bp',{'gte',-1e6;'lte',1e6},'f_susp_strgdelta_bp',{'gte',-pi/2;'lte',pi/2},'f_susp_axl_bp',{'gte',1;'lte',100},'NDFLookupOutType',{'gte',1;'lte',4}};
    TblBpt_geom={'f_susp_dz_bp',{'gte',-1e6;'lte',1e6},'f_susp_strgdelta_bp',{'gte',-pi/2;'lte',pi/2},'f_susp_axl_bp',{'gte',1;'lte',100},'NDGLookupOutType',{'gte',1;'lte',3}};

    LookupTblList={TblBpt_fmz,'f_susp_fmz',{'gte',-1e8;'lte',1e8};...
    TblBpt_geom,'f_susp_geom',{'gte',-1e6;'lte',1e6}};

    ParamList={'MappedSuspAxles',[1,max(1,NumMappedSuspAxles)],{'gte',1;'lte',100}};









    autoblkscheckparams(block,'Suspension',ParamList,LookupTblList);

end

function SuspSolidAxleParmsCallback(block)

    autoblksgetmaskparms(block,{'NumAxl','NumWhlsByAxl'},true);

    ParamList={'AxlIxx',[1,GetIdealSuspParmLenReq(block,'AxlIxx',NumAxl)],{'gte',0.01;'lte',1e6};...
    'AxlM',[1,GetIdealSuspParmLenReq(block,'AxlM',NumAxl)],{'gte',0.01;'lte',1e6};...
    'TrackCoords',[3,sum(NumWhlsByAxl)],{'gte',-20.;'lte',20.};...
    'SuspCoords',[3,sum(NumWhlsByAxl)],{'gte',-20.;'lte',20.};...
    'KzWhlAxl',[1,1],{'gte',0.;'lte',1.e10};...
    'F0zWhlAxl',[1,1],{'gte',0.;'lte',1.e7};...
    'CzWhlAxl',[1,1],{'gte',0.;'lte',1.e6}};

    autoblkscheckparams(block,'Suspension',ParamList,{});

end

function SuspTypeCallback(block)

    MO=get_param(block,'MaskObject');

    KandCContainer={'KnCSuspParms'};
    LinearSuspContainer={'IdealSusp'};

    if strcmp(get_param(block,'SuspType'),'Independent front and rear')||strcmp(get_param(block,'SuspType'),'Independent front and twist-beam rear')
        set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic'],'LabelModeActiveChoice','KinematicsAndComplianceSuspension');
        set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations'],'LabelModeActiveChoice','KinematicsAndComplianceSteeringEnabled');

        LinearSusp=MO.getDialogControl(LinearSuspContainer{1});
        LinearSusp.Visible='off';
        set_param(block,'ActiveDampEn','off');
        autoblksenableparameters(block,{},{'ActiveDampEn'},KandCContainer,{});
        autoblksenableparameters(block,{'tanTheta_FL','tanTheta_FR','tanTheta_RL','tanTheta_RR'},{},{},{},true);




        if strcmp(get_param(block,'SuspType'),'Independent front and twist-beam rear')
            set_param(block,'RollParamEn','on');
            set_param(block,'SuspImage','suspkandctwist.png');
        else
            set_param(block,'RollParamEn','off');
            set_param(block,'SuspImage','suspkandc.png');
        end

        if strcmp(get_param(block,'RollParamEn'),'off')
            autoblksenableparameters(block,{'RollStiffArb','RollStiffNoArb'},{'RollSteer','RollCamber','RollCaster','RollStiffArbFrnt','RollStiffNoArbFrnt','RollStiffNoTwstRear'},{},{'ParLatFrcCmplTest'},false);
        else
            autoblksenableparameters(block,{'RollSteer','RollCamber','RollCaster','RollStiffArbFrnt','RollStiffNoArbFrnt','RollStiffNoTwstRear'},{'RollStiffArb','RollStiffNoArb'},{'ParLatFrcCmplTest'},{},false);
        end

    else
        set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Z axis suspension characteristic'],'LabelModeActiveChoice','IdealSuspension');
        set_param([block,'/For each track and axle combination calculate suspension forces and moments/Suspension/Suspension Angle Calculations'],'LabelModeActiveChoice','IdealSteeringEnabled');
        autoblksenableparameters(block,{'ActiveDampEn'},{},{},KandCContainer);
        autoblksenableparameters(block,{},{'tanTheta_FL','tanTheta_FR','tanTheta_RL','tanTheta_RR'},{},{},true);
        LinearSusp=MO.getDialogControl(LinearSuspContainer{1});
        LinearSusp.Visible='on';
    end

    SuspAntiSwayEnablesCallback(block);

end


function WheelRatesCallback(block)

    autoblksgetmaskparms(block,{'NrmlWhlRates'},true);

    if isnumeric(NrmlWhlRates)
        autoblksenableparameters(block,{'NrmlWhlFrcOff'},{},{},{},false);
    else
        autoblksenableparameters(block,{},{'NrmlWhlFrcOff'},{},{},false);
    end

end


function ShockTypeCallback(block)

end

function DrivetrainTypeCallback(block)

end


function ParmLenReq=GetIdealSuspParmLenReq(block,ParmName,NumSuspAxles)
    autoblksgetmaskparms(block,{ParmName},true);
    ParmVal=eval(ParmName);
    if length(ParmVal)==1
        ParmLenReq=1;
    else
        ParmLenReq=NumSuspAxles;
    end
end






function[TableList,WsVars]=CheckWheelXYTable(block,TableChecks)

    TableList={};
    WsVars=[];

    k=1;

    for i=1:size(TableChecks,1)

        TableName=TableChecks{i,1};
        TableType=TableChecks{i,2};
        XCheck=TableChecks{i,3};
        YCheck=TableChecks{i,4};

        TableValue=autoblksgetmaskparms(block,{TableName},false);
        TableValue=TableValue{1};

        StructureType=[];

        if isfield(TableValue,'FL')&&isfield(TableValue,'FR')&&isfield(TableValue,'RL')&&isfield(TableValue,'RR')

            StructureType=1;

        elseif isfield(TableValue,'PosFx')&&isfield(TableValue,'NegFx')

            if isfield(TableValue.PosFx,'FL')&&isfield(TableValue.PosFx,'FR')&&isfield(TableValue.PosFx,'RL')&&isfield(TableValue.PosFx,'RR')

                if isfield(TableValue.NegFx,'FL')&&isfield(TableValue.NegFx,'FR')&&isfield(TableValue.NegFx,'RL')&&isfield(TableValue.NegFx,'RR')
                    StructureType=2;
                end

            end

        elseif isfield(TableValue,'F')&&isfield(TableValue,'R')
            StructureType=3;
        elseif isfield(TableValue,'RL')&&isfield(TableValue,'RR')
            StructureType=4;
        end

        if isempty(StructureType)||~any(TableType==StructureType)
            error(message('autoblks_shared:autoerrCheckParams:invalidTableStructureFieldFormat',block,TableName));
        end

        if(StructureType==1)||(StructureType==2)

            Corners={'FL','FR','RL','RR'};

            for j=1:length(Corners)

                if StructureType==1

                    CornerValue=getfield(TableValue,Corners{j});

                    XName=[TableName,'.',Corners{j},'(:,1)'];
                    XValue=CornerValue(:,1);

                    YName=[TableName,'.',Corners{j},'(:,2)'];
                    YValue=CornerValue(:,2);

                    TableList(k,:)={{XName,XCheck},YName,YCheck};

                    WsVars(2*(k-1)+1).Name=XName;
                    WsVars(2*(k-1)+1).Value=XValue;
                    WsVars(2*(k-1)+2).Name=YName;
                    WsVars(2*(k-1)+2).Value=YValue;

                    k=k+1;

                else

                    CornerValue1=getfield(TableValue.NegFx,Corners{j});

                    XName1=[TableName,'.NegFx.',Corners{j},'(:,1)'];
                    XValue1=CornerValue1(:,1);

                    YName1=[TableName,'.NegFx.',Corners{j},'(:,2)'];
                    YValue1=CornerValue1(:,2);

                    TableList(k,:)={{XName1,XCheck},YName1,YCheck};

                    WsVars(2*(k-1)+1).Name=XName1;
                    WsVars(2*(k-1)+1).Value=XValue1;
                    WsVars(2*(k-1)+2).Name=YName1;
                    WsVars(2*(k-1)+2).Value=YValue1;

                    k=k+1;

                    CornerValue2=getfield(TableValue.PosFx,Corners{j});

                    XName2=[TableName,'.PosFx.',Corners{j},'(:,1)'];
                    XValue2=CornerValue2(:,1);

                    YName2=[TableName,'.PosFx.',Corners{j},'(:,2)'];
                    YValue2=CornerValue2(:,2);

                    TableList(k,:)={{XName2,XCheck},YName2,YCheck};

                    WsVars(2*(k-1)+1).Name=XName2;
                    WsVars(2*(k-1)+1).Value=XValue2;
                    WsVars(2*(k-1)+2).Name=YName2;
                    WsVars(2*(k-1)+2).Value=YValue2;

                    k=k+1;

                end

            end

        elseif StructureType==4

            Corners={'RL','RR'};

            for j=1:length(Corners)

                CornerValue=getfield(TableValue,Corners{j});

                XName=[TableName,'.',Corners{j},'(:,1)'];
                XValue=CornerValue(:,1);

                YName=[TableName,'.',Corners{j},'(:,2)'];
                YValue=CornerValue(:,2);

                TableList(k,:)={{XName,XCheck},YName,YCheck};

                WsVars(2*(k-1)+1).Name=XName;
                WsVars(2*(k-1)+1).Value=XValue;
                WsVars(2*(k-1)+2).Name=YName;
                WsVars(2*(k-1)+2).Value=YValue;

                k=k+1;

            end

        else

            Axles={'F','R'};

            for j=1:length(Axles)

                AxleValue=getfield(TableValue,Axles{j});

                XName=[TableName,'.',Axles{j},'(:,1)'];
                XValue=AxleValue(:,1);

                YName=[TableName,'.',Axles{j},'(:,2)'];
                YValue=AxleValue(:,2);

                TableList(k,:)={{XName,XCheck},YName,YCheck};

                WsVars(2*(k-1)+1).Name=XName;
                WsVars(2*(k-1)+1).Value=XValue;
                WsVars(2*(k-1)+2).Name=YName;
                WsVars(2*(k-1)+2).Value=YValue;

                k=k+1;

            end

        end

    end

end



function out=CalcInternalKandCParmeters(block)

    tanTheta_FL=[0,0,0];
    tanTheta_FR=[0,0,0];
    tanTheta_RL=[0,0,0];
    tanTheta_RR=[0,0,0];

    SteerSign=1;
    LongitudinalSign=1;
    LateralSign=1;
    VerticalSign=1;
    WhlMzSign=1;

    tanTheta_SVSA_WC_FL=nan;
    tanTheta_SVSA_WC_FR=nan;
    tanTheta_SVSA_WC_RL=nan;
    tanTheta_SVSA_WC_RR=nan;
    tanTheta_SVSA_CP_FL=nan;
    tanTheta_SVSA_CP_FR=nan;
    tanTheta_SVSA_CP_RL=nan;
    tanTheta_SVSA_CP_RR=nan;

    if strcmp(get_param(block,'SuspType'),'Independent front and rear')||strcmp(get_param(block,'SuspType'),'Independent front and twist-beam rear')


        if strcmp(get_param(block,'StrPlusDirection'),'Left')
            SteerSign=-1;
        else
            SteerSign=1;
        end

        if strcmp(get_param(block,'XPlusDirection'),'Rear')
            LongitudinalSign=-1;
        else
            LongitudinalSign=1;
        end

        if strcmp(get_param(block,'YPlusDirection'),'Left')
            LateralSign=-1;
        else
            LateralSign=1;
        end

        if strcmp(get_param(block,'ZPlusDirection'),'Down')
            VerticalSign=-1;
        else
            VerticalSign=1;
        end

        if strcmp(get_param(block,'WhlMzDirection'),'Clockwise')
            WhlMzSign=-1;
        else
            WhlMzSign=1;
        end

        autoblksgetmaskparms(block,{'BumpCamber','StatToe','StatCamber','StatCaster','LatWhlCtrDisp','StatLdWhlR','BumpCaster','LngWhlCtrDisp'},true);

        DrivetrainType=get_param(block,'DrivetrainType');

        if isstruct(LatWhlCtrDisp)&&isstruct(BumpCamber)&&isstruct(BumpCaster)&&isstruct(LngWhlCtrDisp)

            WCy_FL=LatWhlCtrDisp.FL(:,2);
            WCz_FL=LatWhlCtrDisp.FL(:,1);
            WCy_FR=LatWhlCtrDisp.FR(:,2);
            WCz_FR=LatWhlCtrDisp.FR(:,1);
            WCy_RL=LatWhlCtrDisp.RL(:,2);
            WCz_RL=LatWhlCtrDisp.RL(:,1);
            WCy_RR=LatWhlCtrDisp.RR(:,2);
            WCz_RR=LatWhlCtrDisp.RR(:,1);

            BumpCamber_FL=BumpCamber.FL(:,2);
            BumpCamber_FR=BumpCamber.FR(:,2);
            BumpCamber_RL=BumpCamber.RL(:,2);
            BumpCamber_RR=BumpCamber.RR(:,2);

            WCx_FL=LngWhlCtrDisp.FL(:,2);
            WCx_FR=LngWhlCtrDisp.FR(:,2);
            WCx_RL=LngWhlCtrDisp.RL(:,2);
            WCx_RR=LngWhlCtrDisp.RR(:,2);

            BumpCaster_FL=BumpCaster.FL(:,2);
            BumpCaster_FR=BumpCaster.FR(:,2);
            BumpCaster_RL=BumpCaster.RL(:,2);
            BumpCaster_RR=BumpCaster.RR(:,2);

            CPy_FL=zeros(length(WCy_FL),1);
            CPz_FL=zeros(length(WCz_FL),1);

            for i=1:length(WCy_FL)
                CPy_FL(i)=(WCy_FL(i))+1000.*StatLdWhlR(1)*sind(StatCamber(1)+BumpCamber_FL(i));
                CPz_FL(i)=(WCz_FL(i))-1000.*StatLdWhlR(1)*cosd(StatCamber(1)+BumpCamber_FL(i));
            end


            dzdy_FL=gradient(CPz_FL(:))./gradient(CPy_FL(:));


            tanTheta_FL=-1./dzdy_FL;

            CPy_FR=zeros(length(WCy_FR),1);
            CPz_FR=zeros(length(WCz_FR),1);

            for i=1:length(WCy_FR)
                CPy_FR(i)=(WCy_FR(i))-1000.*StatLdWhlR(2)*sind(StatCamber(2)+BumpCamber_FR(i));
                CPz_FR(i)=(WCz_FR(i))-1000.*StatLdWhlR(2)*cosd(StatCamber(2)+BumpCamber_FR(i));
            end


            dzdy_FR=gradient(CPz_FR(:))./gradient(CPy_FR(:));


            tanTheta_FR=-1./dzdy_FR;

            CPy_RL=zeros(length(WCy_RL),1);
            CPz_RL=zeros(length(WCz_RL),1);
            for i=1:length(WCy_RL)
                CPy_RL(i)=(WCy_RL(i))+1000.*StatLdWhlR(3)*sind(StatCamber(3)+BumpCamber_RL(i));
                CPz_RL(i)=(WCz_RL(i))-1000.*StatLdWhlR(3)*cosd(StatCamber(3)+BumpCamber_RL(i));
            end


            dzdy_RL=gradient(CPz_RL(:))./gradient(CPy_RL(:));


            tanTheta_RL=-1./dzdy_RL;

            CPy_RR=zeros(length(WCy_RR),1);
            CPz_RR=zeros(length(WCz_RR),1);

            for i=1:length(WCy_RR)
                CPy_RR(i)=(WCy_RR(i))-1000.*StatLdWhlR(4)*sind(StatCamber(4)+BumpCamber_RR(i));
                CPz_RR(i)=(WCz_RR(i))-1000.*StatLdWhlR(4)*cosd(StatCamber(4)+BumpCamber_RR(i));
            end


            dzdy_RR=gradient(CPz_RR(:))./gradient(CPy_RR(:));


            tanTheta_RR=-1./dzdy_RR;







            dzdx_SVSA_WC_FL=gradient(WCz_FL(:))./gradient(WCx_FL(:));
            dzdx_SVSA_WC_FR=gradient(WCz_FR(:))./gradient(WCx_FR(:));
            dzdx_SVSA_WC_RL=gradient(WCz_RL(:))./gradient(WCx_RL(:));
            dzdx_SVSA_WC_RR=gradient(WCz_RR(:))./gradient(WCx_RR(:));


            switch DrivetrainType
            case 'FWD'
                tanTheta_SVSA_WC_FL=-1./dzdx_SVSA_WC_FL;
                tanTheta_SVSA_WC_FR=-1./dzdx_SVSA_WC_FR;
                tanTheta_SVSA_WC_RL=(-1./dzdx_SVSA_WC_RL).*0;
                tanTheta_SVSA_WC_RR=(-1./dzdx_SVSA_WC_RR).*0;
            case 'RWD'
                tanTheta_SVSA_WC_FL=(-1./dzdx_SVSA_WC_FL).*0;
                tanTheta_SVSA_WC_FR=(-1./dzdx_SVSA_WC_FR).*0;
                tanTheta_SVSA_WC_RL=-1./dzdx_SVSA_WC_RL;
                tanTheta_SVSA_WC_RR=-1./dzdx_SVSA_WC_RR;
            case 'AWD'
                tanTheta_SVSA_WC_FL=-1./dzdx_SVSA_WC_FL;
                tanTheta_SVSA_WC_FR=-1./dzdx_SVSA_WC_FR;
                tanTheta_SVSA_WC_RL=-1./dzdx_SVSA_WC_RL;
                tanTheta_SVSA_WC_RR=-1./dzdx_SVSA_WC_RR;
            end




            CPx_FL=zeros(length(WCx_FL),1);
            for i=1:length(WCx_FL)
                CPx_FL(i)=(WCx_FL(i))+1000.*StatLdWhlR(1)*sind(BumpCaster_FL(i));
            end

            dzdx_SVSA_CP_FL=gradient(CPz_FL(:))./gradient(CPx_FL(:));

            tanTheta_SVSA_CP_FL=-1./dzdx_SVSA_CP_FL;

            CPx_FR=zeros(length(WCx_FR),1);
            for i=1:length(WCx_FR)
                CPx_FR(i)=(WCx_FR(i))+1000.*StatLdWhlR(2)*sind(BumpCaster_FR(i));
            end

            dzdx_SVSA_CP_FR=gradient(CPz_FR(:))./gradient(CPx_FR(:));

            tanTheta_SVSA_CP_FR=-1./dzdx_SVSA_CP_FR;

            CPx_RL=zeros(length(WCx_RL),1);
            for i=1:length(WCx_RL)
                CPx_RL(i)=(WCx_RL(i))+1000.*StatLdWhlR(3)*sind(BumpCaster_RL(i));
            end

            dzdx_SVSA_CP_RL=gradient(CPz_RL(:))./gradient(CPx_RL(:));

            tanTheta_SVSA_CP_RL=-1./dzdx_SVSA_CP_RL;

            CPx_RR=zeros(length(WCx_RR),1);
            for i=1:length(WCx_RR)
                CPx_RR(i)=(WCx_RR(i))+1000.*StatLdWhlR(4)*sind(BumpCaster_RR(i));
            end

            dzdx_SVSA_CP_RR=gradient(CPz_RR(:))./gradient(CPx_RR(:));

            tanTheta_SVSA_CP_RR=-1./dzdx_SVSA_CP_RR;

        end

    end

    out={tanTheta_FL,tanTheta_FR,tanTheta_RL,tanTheta_RR,SteerSign,LongitudinalSign,LateralSign,VerticalSign,WhlMzSign,tanTheta_SVSA_WC_FL,tanTheta_SVSA_WC_FR,tanTheta_SVSA_WC_RL,tanTheta_SVSA_WC_RR,tanTheta_SVSA_CP_FL,tanTheta_SVSA_CP_FR,tanTheta_SVSA_CP_RL,tanTheta_SVSA_CP_RR};

end


function SwitchInport(Block,PortName,UsePort)

    InportOption={'built-in/Ground',[PortName,' Ground'];...
    'built-in/Inport',PortName};
    if~UsePort
        NewBlkHdl=autoblksreplaceblock(Block,InportOption,1);
        set_param(NewBlkHdl,'ShowName','off');
    else
        autoblksreplaceblock(Block,InportOption,2);
    end

end


function SwitchOutport(Block,PortName,UsePort)

    OutPortOption={'built-in/Terminator',[PortName,' Terminator'];...
    'built-in/Outport',PortName};
    if~UsePort
        NewBlkHdl=autoblksreplaceblock(Block,OutPortOption,1);
        set_param(NewBlkHdl,'ShowName','off');
    else
        autoblksreplaceblock(Block,OutPortOption,2);
    end

end



function IconInfo=DrawCommands(block)

    IconInfo=autoblksgetportlabels(block);


    IconInfo.ImageName=get_param(block,'SuspImage');

    if strcmp(IconInfo.ImageName,'suspkandc.png')||strcmp(IconInfo.ImageName,'suspkandctwist.png')
        [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1);
    else
        [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,100,90,'white');
    end

end