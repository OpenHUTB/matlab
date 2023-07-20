function[varargout]=vehdynpredictdrvr(varargin)


    block=varargin{1};
    maskMode=varargin{2};
    cntrlType=get_param(block,'cntrlType');
    shftType=get_param(block,'shftType');
    cntrlLatType=get_param(block,'cntrlTypeLat');
    driftType=get_param(block,'enableDrift');
    dynmode=get_param(block,'dynamMode');
    refType=get_param(block,'refType');
    simStopped=autoblkschecksimstopped(block);












    switch maskMode
    case 0
        vehdynpredictdrvr(block,1);
        vehdynpredictdrvr(block,4);
        vehdynpredictdrvr(block,5);
        vehdynpredictdrvr(block,7);
        vehdynpredictdrvr(block,9);
        if simStopped
            inputUnits=get_param(block,'velUnits');
            try
                if strcmp(inputUnits,'inherit')
                    error(message('autoblks_shared:autoerrDriver:invalidUnits'));
                else
                    [~]=autoblksunitconv(1,'m/s',inputUnits);
                    set_param([block,'/VelFdbk'],'Unit',inputUnits);
                    set_param([block,'/Routing/Error Metrics/error signal spec'],'Unit',inputUnits);
                end
            catch
                error(message('autoblks_shared:autoerrDriver:invalidUnits'));
            end
        end

        switch cntrlType
        case 'PI'
            CntrlParamList={...
            'Kff',[1,1],{};...
            'vnom',[1,1],{'gt',0};...
            'Kp',[1,1],{'gte',0};...
            'Ki',[1,1],{'gte',0};...
            'Kaw',[1,1],{'gte',0};...
            'Kg',[1,1],{'gte',0};...
            'tauerr',[1,1],{'gte',0};...
            'a',[1,1],{'gte',0};...
            'b',[1,1],{'gte',0};...
            'm',[1,1],{'gt',0};...
            'I',[1,1],{'gt',0};...
            'Cy_f',[1,1],{'gte',0};...
            'Cy_r',[1,1],{'gte',0};...
            'theta',[1,1],{'gt',0;'lte',pi};...
            'Ksteer',[1,1],{'gt',0};...
            'tau',[1,1],{'gt',0};...
            'L',[1,1],{'gt',0};...
            };
            CntrlLookupTblList=[];
            paramstruct=autoblkscheckparams(block,'Predictive Driver Model',{'tauerr',[1,1],{'gte',0}});
            if simStopped
                if paramstruct.tauerr<=0
                    set_param([block,'/Control/Decoupled/LPF'],'LabelModeActiveChoice','0');
                else
                    set_param([block,'/Control/Decoupled/LPF'],'LabelModeActiveChoice','1');
                end
            end
        case 'Scheduled PI'

            CntrlParamList={...
            'vnom',[1,1],{'gt',0};...
            'Kaw',[1,1],{'gte',0};...
            'tauerr',[1,1],{'gte',0};...
            'a',[1,1],{'gte',0};...
            'b',[1,1],{'gte',0};...
            'm',[1,1],{'gt',0};...
            'I',[1,1],{'gt',0};...
            'Cy_f',[1,1],{'gte',0};...
            'Cy_r',[1,1],{'gte',0};...
            'theta',[1,1],{'gt',0;'lte',pi};...
            'Ksteer',[1,1],{'gt',0};...
            'tau',[1,1],{'gt',0};...
            'L',[1,1],{'gt',0};...
            };
            KffChecks={{'VehVelVec',{}},'KffVec',{}};
            KpChecks={{'VehVelVec',{}},'KpVec',{'gte',0}};
            KiChecks={{'VehVelVec',{}},'KiVec',{'gte',0}};
            KgChecks={{'VehVelVec',{}},'KgVec',{}};
            CntrlLookupTblList=[KffChecks;KpChecks;KiChecks;KgChecks];
            paramstruct=autoblkscheckparams(block,'Longitudinal Driver Model',{'tauerr',[1,1],{'gte',0}});
            if simStopped
                if paramstruct.tauerr<=0
                    set_param([block,'/Control/Decoupled/LPF'],'LabelModeActiveChoice','0');
                else
                    set_param([block,'/Control/Decoupled/LPF'],'LabelModeActiveChoice','1');
                end
            end
        case 'Predictive'
            CntrlParamList={...
            'tau',[1,1],{'gt',0};...
            'Kpt',[1,1],{'gt',0};...
            'm',[1,1],{'gt',0};...
            'L',[1,1],{'gt',0};...
            'g',[1,1],{'gte',0};...
            'a',[1,1],{'gte',0};...
            'b',[1,1],{'gte',0};...
            'I',[1,1],{'gt',0};...
            'Cy_f',[1,1],{'gte',0};...
            'Cy_r',[1,1],{'gte',0};...
            'theta',[1,1],{'gt',0;'lte',pi};...
            'Ksteer',[1,1],{'gt',0};...
            'tau',[1,1],{'gt',0};...
            'L',[1,1],{'gt',0};...
            'aR',[1,1],{};...
            'bR',[1,1],{};...
            'cR',[1,1],{};...
            };
            CntrlLookupTblList=[];
        end

        DriftParamList={...
        'BetaRef',[1,1],{'gte',0};...
        'KpDrift',[1,1],{'gte',0};...
        'KdDrift',[1,1],{'gte',0};...
        'KpBeta',[1,1],{'gte',0};...
        'KpPsi',[1,1],{'gte',0};...
        'KOmega',[1,1],{'gte',0};...
        'tOmega',[1,1],{'gt',0};...
        'Idl',[1,1],{'gt',0};...
        'Re',[1,1],{'gt',0};...
        'lambda_mu',[1,1],{'gte',0};...
        };
        DriftLookupTblList=[];


        switch shftType
        case 'None'
            if simStopped
                set_param([block,'/Shift'],'LabelModeActiveChoice','0');
                SwitchPort(block,'ExtGear','Ground',[])
            end
            ShiftParamList=[];
            ShiftLookupTblList=[];
        case 'Reverse, Neutral, Drive'
            if simStopped
                set_param([block,'/Shift'],'LabelModeActiveChoice','1');
                SwitchPort(block,'ExtGear','Ground',[])
            end
            ShiftParamList={...
            'tShift',[1,1],{'gt',0};...
            'GearInit',[1,1],{'gte',-1;'lte',1;'int',0};...
            };
            ShiftLookupTblList=[];
        case 'Scheduled'
            if simStopped
                set_param([block,'/Shift'],'LabelModeActiveChoice','3');
                SwitchPort(block,'ExtGear','Ground',[])
            end
            ShiftParamList={...
            'GearInit',[1,1],{'int',0};...
            'tClutch',[1,1],{'gte',0};...
            'tRev',[1,1],{'gte',0};...
            'tPark',[1,1],{'gte',0};...
            };
            upShftTbl=autoblksgetmaskparms(block,{'upShftTbl'},true);
            [~,N]=size(upShftTbl{1});
            set_param(block,'UpGearVec',['[',num2str(0:N-1),']']);
            set_param(block,'DownGearVec',['[',num2str(1:N),']']);
            UpShiftTblBpt={'pdlVec',{'gte',0;'lte',1},'UpGearVec',{}};
            DwnShiftTblBpt={'pdlVec',{'gte',0;'lte',1},'DownGearVec',{}};
            UpShifTbl={UpShiftTblBpt,'upShftTbl',{}};
            DwnShiftTbl={DwnShiftTblBpt,'dwnShftTbl',{}};
            ShiftLookupTblList=[UpShifTbl;DwnShiftTbl];
        case 'External'

            if simStopped
                set_param([block,'/Shift'],'LabelModeActiveChoice','4');
                SwitchPort(block,'ExtGear','Inport',[])
            end
            ShiftParamList=[];
            ShiftLookupTblList=[];
        end
        if simStopped

            labelList={'EnblSteerOvr';'SteerOvrCmd';'SteerHld';'SteerZero';'EnblAccelOvr';'AccelOvrCmd';'AccelHld';'AccelZero';'EnblDecelOvr';'DecelOvrCmd';'DecelHld';'DecelZero'};
            checkboxList={'extSteerOvr';'extSteerHld';'extSteerZero';'extAccelOvr';'extAccelHld';'extAccelZero';'extDecelOvr';'extDecelHld';'extDecelZero'};
            idxx=1;
            for idx=1:length(checkboxList)
                if strcmp(get_param(block,checkboxList{idx}),'on')
                    SwitchPort(block,labelList{idxx},'Inport',[]);
                    if endsWith(checkboxList{idx},'Ovr')
                        idxx=idxx+1;
                        SwitchPort(block,labelList{idxx},'Inport',[]);

                    end
                else
                    SwitchPort(block,labelList{idxx},'Ground',[]);
                    if endsWith(checkboxList{idx},'Ovr')
                        idxx=idxx+1;
                        SwitchPort(block,labelList{idxx},'Ground',[]);

                    end

                end
                idxx=idxx+1;

            end
            if strcmp(get_param(block,'gearOut'),'on')
                SwitchPort(block,'GearCmd','Outport',[])
            else
                SwitchPort(block,'GearCmd','Terminator',[])
            end
        end


        if strcmp(cntrlLatType,'Predictive')
            if strcmp(driftType,'on')
                if strcmp(refType,'Reference pose')
                    inList={'LongRef';'LatRef';'YawRef';'LongFdbk';'LatFdbk';'LatVelFdbk';'YawFdbk';'YawVelFdbk'};
                    gndList={'RefPose';'CurrPose';'Curvature';'XYRef'};
                else
                    inList={'XYRef';'LongFdbk';'LatVelFdbk';'YawFdbk';'YawVelFdbk'};
                    gndList={'LongRef';'LatRef';'YawRef';'RefPose';'LongRef';'YawRef';'CurrPose';'Curvature'};
                end
            else
                if strcmp(refType,'Reference pose')
                    inList={'LatRef';'LatFdbk';'LatVelFdbk';'YawFdbk';'YawVelFdbk'};
                    gndList={'RefPose';'LongRef';'YawRef';'LongFdbk';'CurrPose';'Curvature';'XYRef'};
                else
                    inList={'XYRef';'LongFdbk';'LatVelFdbk';'YawFdbk';'YawVelFdbk'};
                    gndList={'LongRef';'LatRef';'YawRef';'RefPose';'LongRef';'YawRef';'CurrPose';'Curvature'};
                end
            end
            StanParamList=[];
        else

            if strcmp(get_param(block,'vecPose'),'on')
                if strcmp(refType,'Reference pose')
                    inList={'RefPose';'CurrPose'};
                    gndList={'LongRef';'LatRef';'YawRef';'LongFdbk';'LatFdbk';'LatVelFdbk';'YawFdbk';'XYRef'};
                else
                    inList={'XYRef';'CurrPose'};
                    gndList={'LongRef';'LatRef';'YawRef';'RefPose';'LongFdbk';'LatFdbk';'LatVelFdbk';'YawFdbk'};
                end
            else
                if strcmp(refType,'Reference pose')
                    inList={'LongRef';'LatRef';'YawRef';'LongFdbk';'LatFdbk';'YawFdbk'};
                    gndList={'RefPose';'CurrPose';'LatVelFdbk';'XYRef'};
                else
                    inList={'XYRef';'LongFdbk';'LatFdbk';'YawFdbk'};
                    gndList={'LongRef';'LatRef';'YawRef';'RefPose';'CurrPose';'LatVelFdbk'};
                end
            end

            if strcmp(dynmode,'on')
                inListDyn={'Curvature'};
                gndListDyn={};
                StanParamList={...
                'a',[1,1],{'gte',0};...
                'b',[1,1],{'gte',0};...
                'm',[1,1],{'gt',0};...
                'Cy_f',[1,1],{'gte',0};...
                'theta',[1,1],{'gt',0;'lte',pi};...
                'Ksteer',[1,1],{'gt',0};...
                'PositionGainF',[1,1],{'gte',0};...
                'PositionGainR',[1,1],{'gte',0};...
                'YawRateGain',[1,1],{'gte',0};...
                'DelayGain',[1,1],{'gte',0}...
                };
            else
                inListDyn={};
                gndListDyn={'Curvature'};
                StanParamList={...
                'a',[1,1],{'gte',0};...
                'b',[1,1],{'gte',0};...
                'theta',[1,1],{'gt',0;'lte',pi};...
                'Ksteer',[1,1],{'gt',0};...
                'PositionGainF',[1,1],{'gte',0};...
                'PositionGainR',[1,1],{'gte',0};...
                };
            end
            if simStopped
                for idx=1:length(inListDyn)
                    SwitchPort(block,inListDyn{idx},'Inport',[]);
                end
                for idx=1:length(gndListDyn)
                    SwitchPort(block,gndListDyn{idx},'Ground',[]);
                end
            end
        end
        if simStopped
            for idx=1:length(inList)
                SwitchPort(block,inList{idx},'Inport',[]);
            end
            for idx=1:length(gndList)
                SwitchPort(block,gndList{idx},'Ground',[]);
            end
            if strcmp(driftType,'on')
                SwitchPort(block,'Omega','Inport',[])
            else
                SwitchPort(block,'Omega','Ground',[])
            end
            if strcmp(driftType,'on')||strcmp(dynmode,'on')||strcmp(cntrlLatType,'Predictive')
                SwitchPort(block,'YawVelFdbk','Inport',[])
            else
                SwitchPort(block,'YawVelFdbk','Ground',[])
            end
        end


        ParamList=[CntrlParamList;ShiftParamList;StanParamList;DriftParamList];
        LookupTblList=[CntrlLookupTblList;ShiftLookupTblList;DriftLookupTblList];
        if~isempty(LookupTblList)&&~isempty(ParamList)
            autoblkscheckparams(block,'Predictive Driver Model',ParamList,LookupTblList);
        elseif~isempty(ParamList)
            autoblkscheckparams(block,'Predictive Driver Model',ParamList);
        end
        varargout{1}=0;
    case 1
        if simStopped
            switch cntrlType
            case 'PI'
                set_param([block,'/Control'],'LabelModeActiveChoice','0');
                set_param([block,'/Control/Decoupled/Longitudinal Control'],'LabelModeActiveChoice','0');
                if strcmp(cntrlLatType,'Predictive')
                    autoblksenableparameters(block,{'vnom','Kaw','tauerr','m','Cy_f','Cy_r','I'},[],{'LongGroup','LongPanel','PIParam','PredGroup'},{'StanGroup','PISchedParam'});
                    autoblksenableparameters(block,[],{'Kpt','aR','bR','cR','g'},{'VehGroup'},[],true);
                    set_param([block,'/Control/Decoupled/Lateral Control'],'LabelModeActiveChoice','0');
                else
                    autoblksenableparameters(block,[],[],{'StanGroup','LongGroup','LongPanel','PIParam'},{'PredGroup','PISchedParam'});
                    vehdynpredictdrvr(block,2);
                    vehdynpredictdrvr(block,3);
                    if strcmp(dynmode,'on')
                        set_param([block,'/Control/Decoupled/Lateral Control'],'LabelModeActiveChoice','2');
                    else
                        set_param([block,'/Control/Decoupled/Lateral Control'],'LabelModeActiveChoice','1');
                    end
                end
            case 'Scheduled PI'
                set_param([block,'/Control'],'LabelModeActiveChoice','0');
                set_param([block,'/Control/Decoupled/Longitudinal Control'],'LabelModeActiveChoice','1');
                if strcmp(cntrlLatType,'Predictive')
                    autoblksenableparameters(block,{'vnom','Kaw','tauerr','m','Cy_f','Cy_r','I'},[],{'LongGroup','LongPanel','PISchedParam','PredGroup'},{'StanGroup','PIParam'});
                    autoblksenableparameters(block,[],{'Kpt','aR','bR','cR','g'},{'VehGroup'},[],true);
                else
                    autoblksenableparameters(block,[],[],{'StanGroup','LongGroup','LongPanel','PISchedParam'},{'PredGroup','PIParam'});
                    vehdynpredictdrvr(block,2);
                    vehdynpredictdrvr(block,3);
                    if strcmp(dynmode,'on')
                        set_param([block,'/Control/Decoupled/Lateral Control'],'LabelModeActiveChoice','2');
                    else
                        set_param([block,'/Control/Decoupled/Lateral Control'],'LabelModeActiveChoice','1');
                    end
                end
            case 'Predictive'
                if strcmp(cntrlLatType,'Predictive')

                    autoblksenableparameters(block,{'m','Cy_f','Cy_r','I','g','Kpt'},[],{'PredGroup','VehGroup'},{'StanGroup','LongGroup'});
                    set_param(block,'vecPose','off');
                    set_param([block,'/Control'],'LabelModeActiveChoice','1');
                else
                    set_param([block,'/Control'],'LabelModeActiveChoice','0');
                    set_param([block,'/Control/Decoupled/Longitudinal Control'],'LabelModeActiveChoice','2');
                    autoblksenableparameters(block,[],[],{'StanGroup','PredGroup'},{'LongGroup'});
                    if strcmp(dynmode,'on')
                        set_param([block,'/Control/Decoupled/Lateral Control'],'LabelModeActiveChoice','2');
                    else
                        set_param([block,'/Control/Decoupled/Lateral Control'],'LabelModeActiveChoice','1');
                    end
                    vehdynpredictdrvr(block,2);
                    vehdynpredictdrvr(block,3);
                end
            end
            switch shftType
            case 'None'
                autoblksenableparameters(block,[],[],[],{'shiftParamGroup'});
            case 'Reverse, Neutral, Drive'
                autoblksenableparameters(block,[],[],{'shiftParamGroup'},[]);
                autoblksenableparameters(block,{'GearInit';'tShift'},{'pdlVec';'upShftTbl';'dwnShftTbl';'tClutch';'tRev';'tPark'},[],[]);
            case 'Scheduled'
                autoblksenableparameters(block,[],[],{'shiftParamGroup'},[]);
                autoblksenableparameters(block,{'GearInit';'pdlVec';'upShftTbl';'dwnShftTbl';'tClutch';'tRev';'tPark'},{'tShift'},[],[]);
            case 'External'
                autoblksenableparameters(block,[],[],[],{'shiftParamGroup'});
            end
        end
        vehdynpredictdrvr(block,6);
        varargout{1}=0;
    case 2
        if simStopped&&strcmp(refType,'Reference pose')
            if strcmp(get_param(block,'vecPose'),'on')
                set_param([block,'/Pose Routing'],'LabelModeActiveChoice','1');
            else
                set_param([block,'/Pose Routing'],'LabelModeActiveChoice','0');
            end
        end
        varargout{1}=0;
    case 3
        if simStopped
            if strcmp(cntrlLatType,'Stanley')
                if strcmp(dynmode,'on')
                    autoblksenableparameters(block,{'m','Cy_f','YawRateGain','DelayGain'},{'Cy_r','I'},[],[],true);

                else
                    autoblksenableparameters(block,[],{'m','Cy_f','I','YawRateGain','DelayGain','Cy_r'},[],[],true);

                end
            end
        end
        varargout{1}=0;
    case 4
        if simStopped
            inputUnits=get_param(block,'angUnits');
            try
                if strcmp(inputUnits,'inherit')
                    error(message('autoblks_shared:autoerrDriver:invalidAngUnits'));
                else
                    [~]=autoblksunitconv(1,'rad',inputUnits);
                    tempUnit=[inputUnits,'/s'];
                    set_param([block,'/Coordinates'],'yawRateUnit',tempUnit);
                    tempUnit=[inputUnits,'/m'];
                    set_param([block,'/Coordinates'],'curvUnit',tempUnit);
                end
            catch
                error(message('autoblks_shared:autoerrDriver:invalidAngUnits'));
            end
        end
        varargout{1}=0;
    case 5







        varargout{1}=0;
    case 6
        if strcmp(driftType,'on')
            autoblksenableparameters(block,{'Idl','Re','lambda_mu'},[],{'DriftGroup'},[],true);
            if simStopped
                set_param([block,'/Advanced Override'],'LabelModeActiveChoice','1');
            end
        else
            autoblksenableparameters(block,[],{'Idl','Re','lambda_mu'},[],{'DriftGroup'},true);
            if simStopped
                set_param([block,'/Advanced Override'],'LabelModeActiveChoice','0');
            end
        end
        varargout{1}=0;
    case 7
        if strcmp(get_param(block,'steerOut'),'on')
            inputUnits=get_param(block,'angUnits');
            autoblksenableparameters(block,{'Ksteer'},[],[],[]);
            set_param([block,'/Control/Combined/Routing/SteerUnit'],'Unit',inputUnits);
            set_param([block,'/Control/Combined/Routing/BaseUnit'],'Unit','rad');
            set_param([block,'/External Action Routing/SteerOvrCmd'],'Unit',inputUnits);

        else
            autoblksenableparameters(block,[],{'Ksteer'},[],[],'false');
            set_param([block,'/Control/Combined/Routing/SteerUnit'],'Unit','1');
            set_param([block,'/External Action Routing/SteerOvrCmd'],'Unit','1');
            set_param([block,'/Control/Combined/Routing/BaseUnit'],'Unit','1');
        end
        varargout{1}=0;
    case 8
        varargout{1}=DrawCommands(block);
    case 9
        if strcmp(refType,'Reference pose')

            vehdynpredictdrvr(block,2);
        else

            if simStopped
                set_param([block,'/Pose Routing'],'LabelModeActiveChoice','2');
            end
        end
        varargout{1}=0;
    end
end
function SwitchPort(Block,PortName,UsePort,Param)

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

    InportNames={'VelRef';'RefPose';'LongRef';'LatRef';'YawRef';'XYRef';'EnblSteerOvr';'SteerOvrCmd';'SteerHld';'SteerZero';'EnblAccelOvr';'AccelOvrCmd';'AccelHld';'AccelZero';'EnblDecelOvr';'DecelOvrCmd';'DecelHld';'DecelZero';'ExtGear';'Grade';'Curvature';'VelFdbk';'CurrPose';'LongFdbk';'LatFdbk';'LatVelFdbk';'YawFdbk';'YawVelFdbk';'Omega'};
    OutportNames={'Info';'SteerCmd';'AccelCmd';'DecelCmd';'GearCmd'};
    FoundInNames=get_param(find_system(Block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport'),'Name');
    [~,PortI]=intersect(InportNames,FoundInNames);
    FoundOutNames=get_param(find_system(Block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Outport'),'Name');
    [~,PortO]=intersect(OutportNames,FoundOutNames);
    PortI=sort(PortI);
    PortO=sort(PortO);
    for i=1:length(PortI)
        set_param([Block,'/',InportNames{PortI(i)}],'Port',num2str(i));
    end
    for i=1:length(PortO)
        set_param([Block,'/',OutportNames{PortO(i)}],'Port',num2str(i));
    end
end

function IconInfo=DrawCommands(BlkHdl)

    AliasNames={'Accel Cmd','AccelCmd';'Decel Cmd','DecelCmd';...
    'vref','VelRef';'v','VelFdbk';...
    'grade','Grade';...
    };
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    if strcmp(get_param(BlkHdl,'shftType'),'None')
        IconInfo.ImageName='driverlatlong.png';
    else
        IconInfo.ImageName='driverlatlongshift.png';
    end
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,90,100,'white');
end