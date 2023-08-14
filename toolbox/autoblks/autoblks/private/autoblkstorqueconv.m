function[varargout]=autoblkstorqueconv(varargin)



    block=varargin{1};
    callID=varargin{2};
    blkTyp=get_param(block,'TCType');
    maskSet=get_param(block,'MaskVisibilities');
    maskObj=Simulink.Mask.get(block);
    ClutchgroupObj=maskObj.getDialogControl('ClutchParams');
    ClutchLockUpgroupObj=maskObj.getDialogControl('ClutchLockUp');


    if callID==0||callID==3
        portConfigMaskRow=2;
    else
        portConfigMaskRow=1;
    end










    if callID==0

        ParamList={'Ji',[1,1],{'gt',0};...
        'bi',[1,1],{'gte',0};...
        'Jt',[1,1],{'gt',0};...
        'bt',[1,1],{'gte',0};...
        'omegai_o',[1,1],{};...
        'omegat_o',[1,1],{};...
        'maxAbsSpd',[1,1],{'gt',0};...
        'tauTC',[1,1],{'gte',0};...
        'Reff',[1,1],{'gt',0};...
        'muk',[1,1],{'gt',0};...
        'mus',[1,1],{'gt',0;'gt','muk'};...
        'philu',[1,1],{'gte',0;'lte',1};...
        'omegal',[1,1],{'gte',0};...
        'omegau',[1,1],{'gte',0};...
        'K_c',[1,1],{'gte',0};...
        'tauC',[1,1],{'gt',0};...
        };


        TableList={{'phi',[],{}},'psi',{'gt',0};...
        {'phi',[],{}},'zeta',{};...
        };
        autoblkscheckparams(block,'Torque Converter',ParamList,TableList);
        TCOptions=...
        {'autolibdrivetraincommon/Torque Converter Without Lock-up','Torque Converter Without Lock-up';
        'autolibdrivetraincommon/Torque Converter With Lock-up','Torque Converter With Lock-up';
        'autolibdrivetraincommon/Torque Converter With External Lock-up','Torque Converter With External Lock-up'};

        KType=get_param(block,'KType');
        ClutchLocked=get_param(block,'ClutchLocked');
        interpType=get_param(block,'InterpMethod');


        switch blkTyp
        case 'No lock-up'
            blkID=1;
        case 'Lock-up'
            blkID=2;
        case 'External lock-up input'
            blkID=3;
        otherwise
            error(message('autoblks:autoerrTrqConv:invalidType'));
        end

        autoblksreplaceblock(block,TCOptions,blkID);
        set_param([block,'/',TCOptions{blkID,2}],'KType',KType);
        set_param([block,'/',TCOptions{blkID,2}],'ClutchLocked',ClutchLocked);
        set_param([block,'/',TCOptions{blkID,2}],'InterpMethod',interpType);

        if blkID==3||blkID==5
            UnlockThreshold=get_param(block,'omegau');
            LockUpThreshold=get_param(block,'omegal');
            set_param([block,'/',TCOptions{blkID,2}],'LockUpThreshold',LockUpThreshold);
            set_param([block,'/',TCOptions{blkID,2}],'UnlockThreshold',UnlockThreshold);
        end

        varargout{1}={};

    end

    if callID<8
        switch blkTyp
        case 'No lock-up'
            if callID==1
                if~strcmp(get_param([block,'/Lock-up Type'],'LabelModeActiveChoice'),'3')
                    set_param([block,'/Lock-up Type'],'LabelModeActiveChoice','3');
                end
                if strcmp(get_param([block,'/Clutch Force'],'BlockType'),'Inport')
                    replace_block(block,'SearchDepth',1,'FollowLinks','on','BlockType','Inport','Name','Clutch Force','built-in/Constant','noprompt')
                    set_param([block,'/Clutch Force'],'Value','eps');
                end
            end

            autoblksenableparameters(block,[],[],[],'ClutchParams')

        case 'Lock-up'
            if callID==1
                if~strcmp(get_param([block,'/Lock-up Type'],'LabelModeActiveChoice'),'1')
                    set_param([block,'/Lock-up Type'],'LabelModeActiveChoice','1');
                end
                if strcmp(get_param([block,'/Clutch Force'],'BlockType'),'Inport')
                    replace_block(block,'SearchDepth',1,'FollowLinks','on','BlockType','Inport','Name','Clutch Force','built-in/Constant','noprompt')
                    set_param([block,'/Clutch Force'],'Value','eps');
                end
            end

            autoblksenableparameters(block,[],[],'ClutchParams')

        case 'External lock-up input'
            if callID==1
                if~strcmp(get_param([block,'/Lock-up Type'],'LabelModeActiveChoice'),'0')
                    set_param([block,'/Lock-up Type'],'LabelModeActiveChoice','0');
                end
                if strcmp(get_param([block,'/Clutch Force'],'BlockType'),'Constant')
                    replace_block(block,'SearchDepth',1,'FollowLinks','on','BlockType','Constant','Name','Clutch Force','built-in/Inport','noprompt')
                end
            end
            ClutchgroupObj.Enabled='on';
            ClutchgroupObj.Visible='on';
            autoblksenableparameters(block,[],[],'ClutchFrictionParams','ClutchLockUp');



        otherwise
            if callID==1
                set_param([block,'/Lock-up Type'],'LabelModeActiveChoice','0');
                if strcmp(get_param([block,'/Clutch Force'],'BlockType'),'Inport')
                    replace_block(block,'SearchDepth',1,'FollowLinks','on','BlockType','Inport','Name','Clutch Force','built-in/Constant','noprompt')
                    set_param([block,'/Clutch Force'],'Value','eps');
                end
            end
            maskSet(15:end-portConfigMaskRow)=cellstr('off');
            set_param(block,'MaskVisibilities',maskSet);
            set_param(block,'MaskEnables',maskSet);
            ClutchLockUpgroupObj.Visible='off';
            ClutchgroupObj.Visible='off';
            ClutchLockUpgroupObj.Enabled='off';
            ClutchgroupObj.Enabled='off';


        end

        varargout{1}={};
    end

    if callID==8
        varargout{1}=DrawCommands(block);
    end
end


function IconInfo=DrawCommands(BlkHdl)

    AliasNames={'Impeller Trq','TrqImp';'Turbine Trq','TrqTrb';'Impeller Spd','SpdImp';'Turbine Spd','SpdTrb'};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    IconInfo.ImageName='torque_converter.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,10,175,'white');
end