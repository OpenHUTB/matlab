function[varargout]=autoblksoperlong(varargin)




    block=varargin{1};
    maskMode=varargin{2};

    cntrlType=get_param(block,'cntrlType');
    shftType=get_param(block,'shftType');
    simStopped=autoblkschecksimstopped(block);








    BlockNames={'Longitudinal Driver'};
    if maskMode==0
        blkID=1;
        autoblksoperlong(block,1);
        autoblksoperlong(block,2);
        BlockOptions=...
        {['autolibsharedcommon/',BlockNames{1}],BlockNames{1};...
        };

        if strcmp(get_param(block,'gearOut'),'on')
            SwitchPort(block,'GearCmd','Outport',[])
        else
            SwitchPort(block,'GearCmd','Terminator',[])
        end
        paramstruct=autoblkscheckparams(block,{'velUnits',[1,1],{'unit','m/s'}});
        set_param([block,'/VelFdbk'],'Unit',paramstruct.velUnits);
        set_param([block,'/Longitudinal Driver'],'errUnit',paramstruct.velUnits);


        switch cntrlType
        case 'PI'
            if simStopped
                set_param([block,'/',BlockOptions{blkID,2},'/Control'],'LabelModeActiveChoice','0');
            end
            CntrlParamList={...
            'Kff',[1,1],{};...
            'vnom',[1,1],{'gt',0};...
            'Kp',[1,1],{'gte',0};...
            'Ki',[1,1],{'gte',0};...
            'Kaw',[1,1],{'gte',0};...
            'Kg',[1,1],{'gte',0};...
            'tauerr',[1,1],{'gte',0};...
            };
            CntrlLookupTblList=[];
            paramstruct=autoblkscheckparams(block,'Longitudinal Driver Model',{'tauerr',[1,1],{'gte',0}});
            if simStopped
                if paramstruct.tauerr<=0
                    set_param([block,'/',BlockOptions{blkID,2},'/LPF'],'LabelModeActiveChoice','0');
                else
                    set_param([block,'/',BlockOptions{blkID,2},'/LPF'],'LabelModeActiveChoice','1');
                end
            end
        case 'Scheduled PI'
            if simStopped
                set_param([block,'/',BlockOptions{blkID,2},'/Control'],'LabelModeActiveChoice','1');
            end

            CntrlParamList={...
            'vnom',[1,1],{'gt',0};...
            'Kaw',[1,1],{'gte',0};...
            'tauerr',[1,1],{'gte',0};...
            };
            KffChecks={{'VehVelVec',{}},'KffVec',{}};
            KpChecks={{'VehVelVec',{}},'KpVec',{'gte',0}};
            KiChecks={{'VehVelVec',{}},'KiVec',{'gte',0}};
            KgChecks={{'VehVelVec',{}},'KgVec',{}};
            CntrlLookupTblList=[KffChecks;KpChecks;KiChecks;KgChecks];
            paramstruct=autoblkscheckparams(block,'Longitudinal Driver Model',{'tauerr',[1,1],{'gte',0}});
            if simStopped
                if paramstruct.tauerr<=0
                    set_param([block,'/',BlockOptions{blkID,2},'/LPF'],'LabelModeActiveChoice','0');
                else
                    set_param([block,'/',BlockOptions{blkID,2},'/LPF'],'LabelModeActiveChoice','1');
                end
            end
        case 'Predictive'
            if simStopped
                set_param([block,'/',BlockOptions{blkID,2},'/LPF'],'LabelModeActiveChoice','0');
                set_param([block,'/',BlockOptions{blkID,2},'/Control'],'LabelModeActiveChoice','2');
            end
            CntrlParamList={...
            'tau',[1,1],{'gt',0};...
            'Kpt',[1,1],{'gt',0};...
            'm',[1,1],{'gt',0};...
            'L',[1,1],{'gt',0};...
            'g',[1,1],{'gte',0};...
            'aR',[1,1],{};...
            'bR',[1,1],{};...
            'cR',[1,1],{};...
            };
            CntrlLookupTblList=[];
        end

        switch shftType
        case 'None'
            if simStopped
                set_param([block,'/',BlockOptions{blkID,2},'/Shift'],'LabelModeActiveChoice','0');
            end
            ShiftParamList=[];
            ShiftLookupTblList=[];
            SwitchPort(block,'ExtGear','Ground',[])
        case 'Reverse, Neutral, Drive'
            if simStopped
                set_param([block,'/',BlockOptions{blkID,2},'/Shift'],'LabelModeActiveChoice','1');
            end
            ShiftParamList={...
            'tShift',[1,1],{'gt',0};...
            'GearInit',[1,1],{'gte',-1;'lte',1;'int',0};...
            };
            ShiftLookupTblList=[];
            SwitchPort(block,'ExtGear','Ground',[])

        case 'Scheduled'

            if simStopped
                set_param([block,'/',BlockOptions{blkID,2},'/Shift'],'LabelModeActiveChoice','3');
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
            SwitchPort(block,'ExtGear','Ground',[])
        case 'External'
            if simStopped
                set_param([block,'/',BlockOptions{blkID,2},'/Shift'],'LabelModeActiveChoice','4');
            end
            ShiftParamList=[];
            ShiftLookupTblList=[];
            SwitchPort(block,'ExtGear','Inport',[])
        end


        ParamList=[CntrlParamList;ShiftParamList];
        LookupTblList=[CntrlLookupTblList;ShiftLookupTblList];

        if~isempty(LookupTblList)&&~isempty(ParamList)
            autoblkscheckparams(block,'Longitudinal Driver Model',ParamList,LookupTblList);
        elseif~isempty(ParamList)
            autoblkscheckparams(block,'Longitudinal Driver Model',ParamList);
        end


    end

    if maskMode==1
        if simStopped

            switch cntrlType
            case 'PI'
                autoblksenableparameters(block,{'vnom';'Kaw';'tauerr'},[],{'PIParam'},{'PISchedParam';'PredParam'});
            case 'Scheduled PI'
                autoblksenableparameters(block,{'vnom';'Kaw';'tauerr'},[],{'PISchedParam'},{'PIParam';'PredParam'});
            case 'Predictive'
                autoblksenableparameters(block,[],{'vnom';'Kaw';'tauerr'},{'PredParam'},{'PIParam';'PISchedParam'});
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
        varargout{1}=[];
    end

    if maskMode==2
        if simStopped

            labelList={'EnblAccelOvr';'AccelOvrCmd';'AccelHld';'AccelZero';'EnblDecelOvr';'DecelOvrCmd';'DecelHld';'DecelZero'};
            checkboxList={'extAccelOvr';'extAccelHld';'extAccelZero';'extDecelOvr';'extDecelHld';'extDecelZero'};
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
        end
    end
    if maskMode<4
        varargout{1}=[];
    end

    if maskMode==4
        varargout{1}=DrawCommands(block);
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

    InportNames={'VelRef';'EnblAccelOvr';'AccelOvrCmd';'AccelHld';'AccelZero';'EnblDecelOvr';'DecelOvrCmd';'DecelHld';'DecelZero';'ExtGear';'VelFdbk';'Grade'};
    OutportNames={'Info';'AccelCmd';'DecelCmd';'GearCmd'};
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
        IconInfo.ImageName='longitudinal_driver_pedals.png';
    else
        IconInfo.ImageName='longitudinal_driver_pedals_shifter.png';
    end
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,15,90,'white');
end