


function out=GetSqf(fid,key,method,varargin)


















    try
        function_revision=5;
        function_name='GetSqf';




        out=[];


        if nargin<3
            disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
            return;
        end


        correct_code='tzsvq27h';
        switch key
        case correct_code
        otherwise
            disp(sprintf('ERROR [ %s ] Call is illegal.',function_name));
            return;
        end


        switch method
        case 'SystemInfo'
            rtn=GetSqfSystemInfo(fid);
        case 'PatientInfo'
            rtn=GetSqfPatientInfo(fid);
        case 'Channel'
            rtn=GetSqfChannel(fid,varargin{:});
        case 'FLL'
            rtn=GetSqfFLL(fid);
        case 'Calibration'
            rtn=GetSqfCalibration(fid,varargin{:});
        case 'AFA'
            rtn=GetSqfAFA(fid);
        case 'AcqCondition'
            rtn=GetSqfAcqCondition(fid);
        case 'Data'
            rtn=GetSqfData(fid,varargin{:});
        case 'MrImage'
            rtn=GetSqfMrImage(fid);
        case 'Matching'
            rtn=GetSqfMatching(fid);
        case 'TriggerEvent'
            rtn=GetSqfTriggerEvent(fid,varargin{:});
        case 'DigitizerInfo'
            rtn=GetSqfDigitizerInfo(fid,varargin{:});
        case 'DigitizationPoint'
            rtn=GetSqfDigitizationPoint(fid);
        case 'Bookmark'
            rtn=GetSqfBookmark(fid,varargin{:});
        case 'SourceInfo'
            rtn=GetSqfSource(fid,varargin{:});
        case 'Data2str'
            rtn=GetSqfData2str(varargin{:});
        otherwise
            disp(sprintf('ERROR [ %s ] Specified method is illegal.',function_name));
            return;
        end


        out=rtn;

    catch





        str_error_message=sprintf('Exception : Sorry, reading error was occurred. (sqf)');

        disp(str_error_message);
        return;
    end










    function out=GetSqfConstantsDirectory(varargin)












        try
            function_revision=0;
            function_name='GetSqfConstantsDirectory';


            out=[];


            out.SqfDirectorySlot=0*16;
            out.SqfSystemInfoSlot=1*16;
            out.SqfPatientInfoSlot=2*16;
            out.SqfHistorySlot=3*16;
            out.SqfChannelSlot=4*16;
            out.SqfCalibrationSlot=5*16;
            out.SqfFLLSlot=6*16;
            out.SqfAFASlot=7*16;
            out.SqfAcqConditionSlot=8*16;
            out.SqfRawDataSlot=9*16;
            out.SqfAveDataSlot=10*16;
            out.SqfMrImageSlot=11*16;
            out.SqfMatchingSlot=12*16;
            out.SqfSourceSlot=13*16;
            out.SqfTriggerEventSlot=14*16;
            out.SqfBookmarkSlot=15*16;
            out.SqfUserLabelSlot=16*16;
            out.SqfReferenceWeightSlot=17*16;
            out.SqfEEGElectrodeNameSlot=18*16;
            out.SqfEEGPatternSlot=19*16;
            out.SqfEEGColorCodeSlot=20*16;
            out.SqfEEGAcqConditionSlot=21*16;
            out.SqfEEGOriginalFileSlot=22*16;
            out.SqfEEGVideoFileSlot=23*16;

            out.SqfDigitizerSlot=25*16;
            out.SqfDigitizationPointSlot=26*16;





























        catch





            str_error_message=sprintf('Exception : Sorry, reading error was occurred. (constants)');
            disp(str_error_message);
            return;
        end











        function direc=GetSqfDirectory(fid,SqfSlot,function_name)
















            try
                function_revision=0;
                function_name='GetSqfDirectory';




                if nargin~=3
                    disp(sprintf('ERROR [ %s ] Argument is illegal.',function_name));
                    return;
                end


                fseek(fid,0,'bof');


                tmp.offset=fread(fid,1,'uint32');
                tmp.size=fread(fid,1,'int32');
                tmp.max_count=fread(fid,1,'int32');
                tmp.count=fread(fid,1,'int32');

                if isempty([tmp.size])|[tmp.size]~=(32+32+32+32)/8

                    direc=[];
                    return;
                end


                fseek(fid,SqfSlot,'bof');


                direc.offset=fread(fid,1,'uint32');
                direc.size=fread(fid,1,'int32');
                direc.max_count=fread(fid,1,'int32');
                direc.count=fread(fid,1,'int32');
            catch





                str_error_message=sprintf('Exception : Sorry, reading error was occurred. (directory)');
                disp(str_error_message);
                return;
            end











            function out=GetSqfSystemInfo(fid)















































                try
                    function_revision=0;
                    function_name='GetSqfSystemInfo';



                    out=[];


                    if nargin~=1
                        disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                        return;
                    end


                    sqf_slot=GetSqfConstantsDirectory;
                    if isempty(sqf_slot)
                        return;
                    end


                    MaxFileNameLength=256;
                    MaxSystemNameLength=128;
                    MaxModelNameLength=128;
                    MaxCommentLength=256;

                    NoWakeupOnLAN=0;

                    SizeOfSystemInfo1=272;
                    SizeOfSystemInfo2=536;
                    SizeOfSystemInfo3=700;
                    SizeOfSystemInfo4=732;
                    SizeOfSystemInfo=1248;


                    direc=GetSqfDirectory(fid,sqf_slot.SqfSystemInfoSlot,function_name);
                    if isempty(direc)
                        disp(['ERROR ( ',function_name,' ): This file is not Meg160 format!!']);
                        return;
                    end







                    fseek(fid,direc.offset,'bof');


                    switch direc.size
                    case SizeOfSystemInfo1
                        meg160_version=0;
                        meg160_revision=119;
                        system_id=fread(fid,1,'int32');
                        system_name=fread(fid,MaxSystemNameLength,'uchar');index=min(find(system_name==0));system_name=deblank(GetSqfData2str(system_name(1:index)));
                        model_name=fread(fid,MaxModelNameLength,'uchar');index=min(find(model_name==0));model_name=deblank(GetSqfData2str(model_name(1:index)));
                        channel_count=fread(fid,1,'int32');
                        comment='';
                        create_time=fread(fid,1,'int32');
                        last_modified_time=fread(fid,1,'int32');
                        slave_count=floor((channel_count+31)/32);
                        board_in_slave=0;if(channel_count>16);board_in_slave=2;else;board_in_slave=1;end;
                        channel_in_board=16;
                        dewar_style=GetDewarStyle(system_id);
                        dewar_parameter(1)=0;
                        dewar_parameter(2)=0;
                        dewar_parameter(3)=0;
                        fll_type=GetHangerType(system_id);
                        fll_parameter(1)=0;
                        fll_parameter(2)=0;
                        fll_parameter(3)=0;
                        triggerbox_type=GetTriggerBoxType(system_id);
                        triggerbox_parameter(1)=0;
                        triggerbox_parameter(2)=0;
                        triggerbox_parameter(3)=0;
                        adboard_type=GetAdBoardType(system_id);
                        adboard_parameter(1)=0;
                        adboard_parameter(2)=0;
                        adboard_parameter(3)=0;
                        kansipanel_type=GetKansiPanelType(system_id);
                        kansipanel_parameter(1)=0;
                        kansipanel_parameter(2)=0;
                        kansipanel_parameter(3)=0;
                        powerline_frequency=GetPowerLineFrequency(system_id);
                        monitor_assign='';
                        wakeuponlan_type=NoWakeupOnLAN;
                        wakeuponlan_parameter(1)=0;
                        wakeuponlan_parameter(2)=0;
                        wakeuponlan_parameter(3)=0;
                        adc_range=10;
                        adc_polarity=0;
                        adc_allocated=16;
                        adc_stored=12;
                        original_megfile='';
                        original_eegfile='';
                    case SizeOfSystemInfo2
                        meg160_version=fread(fid,1,'int32');
                        meg160_revision=fread(fid,1,'int32');
                        system_id=fread(fid,1,'int32');
                        system_name=fread(fid,MaxSystemNameLength,'uchar');index=min(find(system_name==0));system_name=deblank(GetSqfData2str(system_name(1:index)));
                        model_name=fread(fid,MaxModelNameLength,'uchar');index=min(find(model_name==0));model_name=deblank(GetSqfData2str(model_name(1:index)));
                        channel_count=fread(fid,1,'int32');
                        comment=fread(fid,MaxCommentLength,'uchar');index=min(find(comment==0));comment=GetSqfData2str(comment(1:index));
                        create_time=fread(fid,1,'int32');
                        last_modified_time=fread(fid,1,'int32');
                        slave_count=floor((channel_count+31)/32);
                        board_in_slave=0;if(channel_count>16);board_in_slave=2;else;board_in_slave=1;end;
                        channel_in_board=16;
                        dewar_style=GetDewarStyle(system_id);
                        dewar_parameter(1)=0;
                        dewar_parameter(2)=0;
                        dewar_parameter(3)=0;
                        fll_type=GetHangerType(system_id);
                        fll_parameter(1)=0;
                        fll_parameter(2)=0;
                        fll_parameter(3)=0;
                        triggerbox_type=GetTriggerBoxType(system_id);
                        triggerbox_parameter(1)=0;
                        triggerbox_parameter(2)=0;
                        triggerbox_parameter(3)=0;
                        adboard_type=GetAdBoardType(system_id);
                        adboard_parameter(1)=0;
                        adboard_parameter(2)=0;
                        adboard_parameter(3)=0;
                        kansipanel_type=GetKansiPanelType(system_id);
                        kansipanel_parameter(1)=0;
                        kansipanel_parameter(2)=0;
                        kansipanel_parameter(3)=0;
                        powerline_frequency=GetPowerLineFrequency(system_id);
                        monitor_assign='';
                        wakeuponlan_type=NoWakeupOnLAN;
                        wakeuponlan_parameter(1)=0;
                        wakeuponlan_parameter(2)=0;
                        wakeuponlan_parameter(3)=0;
                        adc_range=10;
                        adc_polarity=0;
                        adc_allocated=16;
                        adc_stored=12;
                        original_megfile='';
                        original_eegfile='';
                    case SizeOfSystemInfo3
                        meg160_version=fread(fid,1,'int32');
                        meg160_revision=fread(fid,1,'int32');
                        system_id=fread(fid,1,'int32');
                        system_name=fread(fid,MaxSystemNameLength,'uchar');index=min(find(system_name==0));system_name=deblank(GetSqfData2str(system_name(1:index)));
                        model_name=fread(fid,MaxModelNameLength,'uchar');index=min(find(model_name==0));model_name=deblank(GetSqfData2str(model_name(1:index)));
                        channel_count=fread(fid,1,'int32');
                        comment=fread(fid,MaxCommentLength,'uchar');index=min(find(comment==0));comment=GetSqfData2str(comment(1:index));
                        create_time=fread(fid,1,'int32');
                        last_modified_time=fread(fid,1,'int32');
                        slave_count=fread(fid,1,'int32');
                        board_in_slave=fread(fid,1,'int32');
                        channel_in_board=fread(fid,1,'int32');
                        dewar_style=fread(fid,1,'int32');
                        dewar_parameter(1)=fread(fid,1,'int32');
                        dewar_parameter(2)=fread(fid,1,'int32');
                        dewar_parameter(3)=fread(fid,1,'int32');
                        fll_type=fread(fid,1,'int32');
                        fll_parameter(1)=fread(fid,1,'int32');
                        fll_parameter(2)=fread(fid,1,'int32');
                        fll_parameter(3)=fread(fid,1,'int32');
                        triggerbox_type=fread(fid,1,'int32');
                        triggerbox_parameter(1)=fread(fid,1,'int32');
                        triggerbox_parameter(2)=fread(fid,1,'int32');
                        triggerbox_parameter(3)=fread(fid,1,'int32');
                        adboard_type=fread(fid,1,'int32');
                        adboard_parameter(1)=fread(fid,1,'int32');
                        adboard_parameter(2)=fread(fid,1,'int32');
                        adboard_parameter(3)=fread(fid,1,'int32');
                        kansipanel_type=fread(fid,1,'int32');
                        kansipanel_parameter(1)=fread(fid,1,'int32');
                        kansipanel_parameter(2)=fread(fid,1,'int32');
                        kansipanel_parameter(3)=fread(fid,1,'int32');
                        powerline_frequency=fread(fid,1,'double');
                        monitor_assign=fread(fid,64,'uchar');index=min(find(monitor_assign==0));monitor_assign=GetSqfData2str(monitor_assign(1:index));
                        wakeuponlan_type=NoWakeupOnLAN;
                        wakeuponlan_parameter(1)=0;
                        wakeuponlan_parameter(2)=0;
                        wakeuponlan_parameter(3)=0;
                        adc_range=10;
                        adc_polarity=0;
                        adc_allocated=16;
                        adc_stored=12;
                        original_megfile='';
                        original_eegfile='';
                    case SizeOfSystemInfo4
                        meg160_version=fread(fid,1,'int32');
                        meg160_revision=fread(fid,1,'int32');
                        system_id=fread(fid,1,'int32');
                        system_name=fread(fid,MaxSystemNameLength,'uchar');index=min(find(system_name==0));system_name=deblank(GetSqfData2str(system_name(1:index)));
                        model_name=fread(fid,MaxModelNameLength,'uchar');index=min(find(model_name==0));model_name=deblank(GetSqfData2str(model_name(1:index)));
                        channel_count=fread(fid,1,'int32');
                        comment=fread(fid,MaxCommentLength,'uchar');index=min(find(comment==0));comment=GetSqfData2str(comment(1:index));
                        create_time=fread(fid,1,'int32');
                        last_modified_time=fread(fid,1,'int32');
                        slave_count=fread(fid,1,'int32');
                        board_in_slave=fread(fid,1,'int32');
                        channel_in_board=fread(fid,1,'int32');
                        dewar_style=fread(fid,1,'int32');
                        dewar_parameter(1)=fread(fid,1,'int32');
                        dewar_parameter(2)=fread(fid,1,'int32');
                        dewar_parameter(3)=fread(fid,1,'int32');
                        fll_type=fread(fid,1,'int32');
                        fll_parameter(1)=fread(fid,1,'int32');
                        fll_parameter(2)=fread(fid,1,'int32');
                        fll_parameter(3)=fread(fid,1,'int32');
                        triggerbox_type=fread(fid,1,'int32');
                        triggerbox_parameter(1)=fread(fid,1,'int32');
                        triggerbox_parameter(2)=fread(fid,1,'int32');
                        triggerbox_parameter(3)=fread(fid,1,'int32');
                        adboard_type=fread(fid,1,'int32');
                        adboard_parameter(1)=fread(fid,1,'int32');
                        adboard_parameter(2)=fread(fid,1,'int32');
                        adboard_parameter(3)=fread(fid,1,'int32');
                        kansipanel_type=fread(fid,1,'int32');
                        kansipanel_parameter(1)=fread(fid,1,'int32');
                        kansipanel_parameter(2)=fread(fid,1,'int32');
                        kansipanel_parameter(3)=fread(fid,1,'int32');
                        powerline_frequency=fread(fid,1,'double');
                        monitor_assign=fread(fid,64,'uchar');index=min(find(monitor_assign==0));monitor_assign=GetSqfData2str(monitor_assign(1:index));
                        wakeuponlan_type=fread(fid,1,'int32');
                        wakeuponlan_parameter(1)=fread(fid,1,'int32');
                        wakeuponlan_parameter(2)=fread(fid,1,'int32');
                        wakeuponlan_parameter(3)=fread(fid,1,'int32');
                        adc_range=fread(fid,1,'int32');
                        adc_polarity=fread(fid,1,'int32');
                        adc_allocated=fread(fid,1,'int32');
                        adc_stored=fread(fid,1,'int32');
                        original_megfile='';
                        original_eegfile='';
                    case SizeOfSystemInfo
                        meg160_version=fread(fid,1,'int32');
                        meg160_revision=fread(fid,1,'int32');
                        system_id=fread(fid,1,'int32');
                        system_name=fread(fid,MaxSystemNameLength,'uchar');index=min(find(system_name==0));system_name=deblank(GetSqfData2str(system_name(1:index)));
                        model_name=fread(fid,MaxModelNameLength,'uchar');index=min(find(model_name==0));model_name=deblank(GetSqfData2str(model_name(1:index)));
                        channel_count=fread(fid,1,'int32');
                        comment=fread(fid,MaxCommentLength,'uchar');index=min(find(comment==0));comment=GetSqfData2str(comment(1:index));
                        create_time=fread(fid,1,'int32');
                        last_modified_time=fread(fid,1,'int32');
                        slave_count=fread(fid,1,'int32');
                        board_in_slave=fread(fid,1,'int32');
                        channel_in_board=fread(fid,1,'int32');
                        dewar_style=fread(fid,1,'int32');
                        dewar_parameter(1)=fread(fid,1,'int32');
                        dewar_parameter(2)=fread(fid,1,'int32');
                        dewar_parameter(3)=fread(fid,1,'int32');
                        fll_type=fread(fid,1,'int32');
                        fll_parameter(1)=fread(fid,1,'int32');
                        fll_parameter(2)=fread(fid,1,'int32');
                        fll_parameter(3)=fread(fid,1,'int32');
                        triggerbox_type=fread(fid,1,'int32');
                        triggerbox_parameter(1)=fread(fid,1,'int32');
                        triggerbox_parameter(2)=fread(fid,1,'int32');
                        triggerbox_parameter(3)=fread(fid,1,'int32');
                        adboard_type=fread(fid,1,'int32');
                        adboard_parameter(1)=fread(fid,1,'int32');
                        adboard_parameter(2)=fread(fid,1,'int32');
                        adboard_parameter(3)=fread(fid,1,'int32');
                        kansipanel_type=fread(fid,1,'int32');
                        kansipanel_parameter(1)=fread(fid,1,'int32');
                        kansipanel_parameter(2)=fread(fid,1,'int32');
                        kansipanel_parameter(3)=fread(fid,1,'int32');
                        powerline_frequency=fread(fid,1,'double');
                        monitor_assign=fread(fid,64,'uchar');index=min(find(monitor_assign==0));monitor_assign=GetSqfData2str(monitor_assign(1:index));
                        wakeuponlan_type=fread(fid,1,'int32');
                        wakeuponlan_parameter(1)=fread(fid,1,'int32');
                        wakeuponlan_parameter(2)=fread(fid,1,'int32');
                        wakeuponlan_parameter(3)=fread(fid,1,'int32');
                        adc_range=fread(fid,1,'double');
                        adc_polarity=fread(fid,1,'int32');
                        adc_allocated=fread(fid,1,'int32');
                        adc_stored=fread(fid,1,'int32');
                        original_megfile=fread(fid,MaxFileNameLength,'uchar');index=min(find(original_megfile==0));original_megfile=GetSqfData2str(original_megfile(1:index));
                        original_eegfile=fread(fid,MaxFileNameLength,'uchar');index=min(find(original_eegfile==0));original_eegfile=GetSqfData2str(original_eegfile(1:index));
                    otherwise
                        disp(['ERROR ( ',function_name,' ): System information is illegal !!']);
                        return;
                    end


                    fseek(fid,0,'bof');


                    out.version=meg160_version;
                    out.revision=meg160_revision;
                    out.system_id=system_id;
                    out.system_name=system_name;
                    out.model_name=model_name;
                    out.channel_count=channel_count;
                    out.comment=comment;
                    out.create_time=create_time;
                    out.last_modified_time=last_modified_time;
                    out.slave_count=slave_count;
                    out.board_in_slave=board_in_slave;
                    out.channel_in_board=channel_in_board;
                    out.dewar_style=dewar_style;
                    out.dewar_parameter=dewar_parameter;
                    out.fll_type=fll_type;
                    out.fll_parameter=fll_parameter;
                    out.triggerbox_type=triggerbox_type;
                    out.triggerbox_parameter=triggerbox_parameter;
                    out.adboard_type=adboard_type;
                    out.adboard_parameter=adboard_parameter;
                    out.kansipanel_type=kansipanel_type;
                    out.kansipanel_parameter=kansipanel_parameter;
                    out.powerline_frequency=powerline_frequency;
                    out.monitor_assign=monitor_assign;
                    out.wakeuponlan_type=wakeuponlan_type;
                    out.wakeuponlan_parameter=wakeuponlan_parameter;
                    out.adc_range=adc_range;
                    out.adc_polarity=adc_polarity;
                    out.adc_allocated=adc_allocated;
                    out.adc_stored=adc_stored;
                    out.original_megfile=original_megfile;
                    out.original_eegfile=original_eegfile;

                catch





                    str_error_message=sprintf('Exception : Sorry, reading error was occurred. (system information)');
                    disp(str_error_message);
                    return;
                end






























                function dewar_style=GetDewarStyle(system_id)






                    dewar_style=[];


                    if nargin~=1
                        disp(['ERROR : Arguments is illegal !!']);
                        return;
                    end


                    UnknownDewarType=-1;
                    PlannerDewar=0;
                    WholeHeadDewar180=1;
                    WholeHeadDewar270=2;

                    dewar_type=[...
                    WholeHeadDewar180,
                    WholeHeadDewar180,
                    WholeHeadDewar180,
                    WholeHeadDewar180,
                    WholeHeadDewar180,
                    WholeHeadDewar270,
                    0,
                    0,
                    0,
                    0,
                    WholeHeadDewar180,
                    WholeHeadDewar180,
                    WholeHeadDewar270,
                    0,
                    WholeHeadDewar180,
                    PlannerDewar,
                    WholeHeadDewar180,
                    PlannerDewar,
                    WholeHeadDewar270,
                    WholeHeadDewar270,
                    WholeHeadDewar270,
                    PlannerDewar,
                    WholeHeadDewar270,
                    PlannerDewar,
                    WholeHeadDewar180,
                    WholeHeadDewar270,
                    PlannerDewar,
                    WholeHeadDewar180,
                    WholeHeadDewar270,
                    WholeHeadDewar270,
WholeHeadDewar270
                    ];

                    if system_id<=30
                        dewar_style=dewar_type(system_id);
                    elseif IsKeioSystem(system_id)
                        dewar_style=WholeHeadDewar180;
                    elseif IsAmaike080BSystem(system_id)
                        dewar_style=WholeHeadDewar180;
                    elseif IsAmaike160System(system_id)
                        dewar_style=WholeHeadDewar180;
                    elseif IsKoreaMCGSystem(system_id)
                        dewar_style=PlannerDewar;
                    else

                        dewar_style=WholeHeadDewar270;
                    end


                    function fll_type=GetHangerType(system_id)



















                        fll_type=[];


                        if nargin~=1
                            disp(['ERROR : Arguments is illegal !!']);
                            return;
                        end


                        UnknownHangerType=-1;
                        StandardHangerType=0;
                        FLLASPSeparateHangerType=1;
                        PCI1StandardHangerType=10;
                        PCI2StandardHangerType=20;
                        PCI1RevisedHangerType=50;
                        PCI2RevisedHangerType=60;
                        PCI1LowHPFHangerType=51;
                        PCI2LowHPFHangerType=61;
                        USBLowBandKapperType=100;
                        USBHighBandKapperType=200;
                        USBLowBandKapperWithTrueDcType=101;
                        USBHighBandKapperWithTrueDcType=201;
                        PRDPhase1FLLASPSystem=300;

                        if IsOsakaSystem(system_id)||IsKeioSystem(system_id)
                            fll_type=StandardHangerType;
                        elseif IsMITSystem(system_id)||IsMarylandSystem(system_id)||IsAcademiaSinicaSystem(system_id)
                            fll_type=PCI1StandardHangerType;
                        elseif IsPTBSystem(system_id)
                            fll_type=FLLASPSeparateHangerType;
                        elseif IsFujimotoSystem(system_id)||IsEpilepsyCenterSystem(system_id)||IsTokyoKomabaSystem(system_id)||IsHokutoSystem(system_id)
                            fll_type=PCI1StandardHangerType;
                        elseif IsISICOSystem(system_id)||IsMattoHISSystem(system_id)||IsAmaike160System(system_id)||IsTokyo440System(system_id)
                            fll_type=USBLowBandKapperType;
                        elseif IsTMDUSystem(system_id)||IsTMDU75System(system_id)
                            fll_type=PCI1StandardHangerType;
                        elseif IsKoreaMCGSystem(system_id)
                            fll_type=PCI1StandardHangerType;
                        elseif IsJointLaboratorySystem(system_id)
                            fll_type=UnknownHangerType;
                        else
                            fll_type=USBLowBandKapperType;
                        end


                        function triggerbox_type=GetTriggerBoxType(system_id)









                            triggerbox_type=[];


                            if nargin~=1
                                disp(['ERROR : Arguments is illegal !!']);
                                return;
                            end


                            UnknownTriggerBoxType=-1;
                            SingleTriggerTriggerBoxType=0;
                            MultiTriggerTriggerBoxType=1;
                            PCI1MultiTriggerTriggerBoxType=11;
                            PCI2MultiTriggerTriggerBoxType=21;
                            FBIDIOMultiTriggerTriggerBoxType=51;
                            PRDPhase1TriggerBoxType=101;

                            if IsOsakaSystem(system_id)||IsKeioSystem(system_id)
                                triggerbox_type=MultiTriggerTriggerBoxType;
                            elseif IsMITSystem(system_id)||IsMarylandSystem(system_id)||IsAcademiaSinicaSystem(system_id)
                                triggerbox_type=PCI2MultiTriggerTriggerBoxType;
                            elseif IsPTBSystem(system_id)
                                triggerbox_type=MultiTriggerTriggerBoxType;
                            elseif IsFujimotoSystem(system_id)||IsEpilepsyCenterSystem(system_id)||IsTokyoKomabaSystem(system_id)||IsHokutoSystem(system_id)
                                triggerbox_type=PCI2MultiTriggerTriggerBoxType;
                            elseif IsISICOSystem(system_id)||IsMattoHISSystem(system_id)||IsAmaike160System(system_id)||IsTokyo440System(system_id)
                                triggerbox_type=PCI1MultiTriggerTriggerBoxType;
                            elseif IsKoreaMCGSystem(system_id)
                                triggerbox_type=PCI2MultiTriggerTriggerBoxType;
                            elseif IsJointLaboratorySystem(system_id)
                                triggerbox_type=UnknownTriggerBoxType;
                            else
                                triggerbox_type=PCI1MultiTriggerTriggerBoxType;
                            end


                            function adboard_type=GetAdBoardType(system_id)





































                                adboard_type=[];


                                if nargin~=1
                                    disp(['ERROR : Arguments is illegal !!']);
                                    return;
                                end


                                UnknownAdBoardType=-1;
                                ATMIO16E2withoutETS=0;
                                ATMIO16E2withETS=1;
                                ATMIO16E2withETS2=2;
                                PCIMIO16E1withoutETS=10;
                                PCIMIO16E1withETS=11;
                                PCIMIO16E1withETS2=12;
                                PCI6071EwithoutETS=20;
                                PCI6071EwithETS=21;
                                PCI6071EwithETS2=22;
                                PCI6071EDiffwithoutETS=25;
                                PCI6071EDiffwithETS=26;
                                PCI6071EDiffwithETS2=27;
                                PCI6071EWBwithoutETS=30;
                                PCI6071EWBwithETS=31;
                                PCI6071EWBwithETS2=32;
                                PCI6071EWBDiffwithoutETS=35;
                                PCI6071EWBDiffwithETS=36;
                                PCI6071EWBDiffwithETS2=37;

                                PCI6254withoutETS=100;
                                PCI6254withETS=101;
                                PCI6254withETS2=102;
                                PCI6254DiffwithoutETS=105;
                                PCI6254DiffwithETS=106;
                                PCI6254DiffwithETS2=107;

                                USB6259withoutETS=110;
                                USB6259withETS=111;
                                USB6259withETS2=112;
                                USB6259DiffwithoutETS=115;
                                USB6259DiffwithETS=116;
                                USB6259DiffwithETS2=117;

                                PRDPhase1DAQSystem=200;


                                if IsOsakaSystem(system_id)||IsKeioSystem(system_id)
                                    adboard_type=ATMIO16E2withETS2;
                                elseif IsAmaike160System(system_id)
                                    adboard_type=ATMIO16E2withoutETS;
                                elseif IsPTBSystem(system_id)
                                    adboard_type=PCIMIO16E1withETS2;
                                elseif IsFujimotoSystem(system_id)||IsEpilepsyCenterSystem(system_id)||IsTokyoKomabaSystem(system_id)||IsHokutoSystem(system_id)
                                    adboard_type=PCIMIO16E1withETS2;
                                elseif IsISICOSystem(system_id)||IsMattoHISSystem(system_id)||IsTokyo440System(system_id)
                                    adboard_type=PCI6071EDiffwithETS2;
                                elseif IsAcademiaSinicaSystem(system_id)
                                    adboard_type=PCI6071EDiffwithETS2;
                                elseif IsKoreaMCGSystem(system_id)
                                    adboard_type=PCIMIO16E1withETS2;
                                elseif IsJointLaboratorySystem(system_id)
                                    adboard_type=UnknownAdBoardType;
                                else
                                    adboard_type=PCI6071EDiffwithETS2;
                                end


                                function kansipanel_type=GetKansiPanelType(system_id)







                                    kansipanel_type=[];


                                    if nargin~=1
                                        disp(['ERROR : Arguments is illegal !!']);
                                        return;
                                    end


                                    UnknownKansiPanelType=-1;
                                    NoKansiPanel=0;
                                    PCIDASKKansiPanelType=1;
                                    FBIDIOKansiPanelType=2;
                                    PRDPhase1KansiPanelType=3;

                                    if IsFujimotoSystem(system_id)||IsTokyoKomabaSystem(system_id)
                                        kansipanel_type=PCIDASKKansiPanelType;
                                    elseif IsEpilepsyCenterSystem(system_id)
                                        kansipanel_type=FBIDIOKansiPanelType;
                                    else
                                        kansipanel_type=NoKansiPanel;
                                    end


                                    function powerline_frequency=GetPowerLineFrequency(system_id)

                                        powerline_frequency=[];


                                        if nargin~=1
                                            disp(['ERROR : Arguments is illegal !!']);
                                            return;
                                        end

                                        if IsKeioSystem(system_id)
                                            powerline_frequency=50.0;
                                        elseif IsPTBSystem(system_id)
                                            powerline_frequency=50.0;
                                        elseif IsTMDUSystem(system_id)||IsTMDU75System(system_id)
                                            powerline_frequency=50.0;
                                        elseif IsTokyo440System(system_id)||IsTokyoKomabaSystem(system_id)||IsHokutoSystem(system_id)
                                            powerline_frequency=50.0;
                                        elseif system_id==999

                                            powerline_frequency=50.0;
                                        else

                                            powerline_frequency=60.0;
                                        end


                                        function torf=IsOsakaSystem(system_id)

                                            torf=false;


                                            if nargin~=1
                                                disp(['ERROR : Arguments is illegal !!']);
                                                return;
                                            end

                                            if IsOsaka180System(system_id)
                                                torf=true;
                                            elseif IsOsaka270System(system_id)
                                                torf=true;
                                            else
                                                torf=false;
                                            end


                                            function torf=IsOsaka180System(system_id)

                                                torf=false;


                                                if nargin~=1
                                                    disp(['ERROR : Arguments is illegal !!']);
                                                    return;
                                                end

                                                if system_id==2
                                                    torf=true;
                                                elseif system_id==4
                                                    torf=true;
                                                elseif system_id==10
                                                    torf=true;
                                                else
                                                    torf=false;
                                                end


                                                function torf=IsOsaka270System(system_id)



                                                    torf=false;


                                                    if nargin~=1
                                                        disp(['ERROR : Arguments is illegal !!']);
                                                        return;
                                                    end


                                                    SystemIdOsakaCUmin=80;
                                                    SystemIdOsakaCUmax=89;

                                                    if system_id==18
                                                        torf=true;
                                                    elseif system_id==20
                                                        torf=true;
                                                    elseif system_id==22
                                                        torf=true;
                                                    elseif system_id==25
                                                        torf=true;
                                                    elseif(system_id>=SystemIdOsakaCUmin)&(system_id<=SystemIdOsakaCUmax)
                                                        torf=true;
                                                    else
                                                        torf=false;
                                                    end


                                                    function torf=IsKeioSystem(system_id)



                                                        torf=false;


                                                        if nargin~=1
                                                            disp(['ERROR : Arguments is illegal !!']);
                                                            return;
                                                        end


                                                        SystemIdKeioRPmin=70;
                                                        SystemIdKeioRPmax=79;

                                                        if system_id==3
                                                            torf=true;
                                                        elseif system_id==11
                                                            torf=true;
                                                        elseif system_id==16
                                                            torf=true;
                                                        elseif system_id==24
                                                            torf=true;
                                                        elseif system_id==27
                                                            torf=true;
                                                        elseif(system_id>=SystemIdKeioRPmin)&(system_id<=SystemIdKeioRPmax)
                                                            torf=true;
                                                        else
                                                            torf=false;
                                                        end


                                                        function torf=IsAmaike080BSystem(system_id)


                                                            torf=false;


                                                            if nargin~=1
                                                                disp(['ERROR : Arguments is illegal !!']);
                                                                return;
                                                            end


                                                            SystemIdAmaike080B=40;

                                                            if system_id==SystemIdAmaike080B
                                                                torf=true;
                                                            else
                                                                torf=false;
                                                            end


                                                            function torf=IsAmaike160System(system_id)



                                                                torf=false;


                                                                if nargin~=1
                                                                    disp(['ERROR : Arguments is illegal !!']);
                                                                    return;
                                                                end


                                                                SystemIdAmaike160min=41;
                                                                SystemIdAmaike160max=49;

                                                                if(system_id>=SystemIdAmaike160min)&(system_id<=SystemIdAmaike160max)
                                                                    torf=true;
                                                                else
                                                                    torf=false;
                                                                end


                                                                function torf=IsKoreaMCGSystem(system_id)



                                                                    torf=false;


                                                                    if nargin~=1
                                                                        disp(['ERROR : Arguments is illegal !!']);
                                                                        return;
                                                                    end


                                                                    SystemIdKoreaMCGmin=800;
                                                                    SystemIdKoreaMCGmax=819;

                                                                    if(system_id>=SystemIdKoreaMCGmin)&(system_id<=SystemIdKoreaMCGmax)
                                                                        torf=true;
                                                                    else
                                                                        torf=false;
                                                                    end


                                                                    function torf=IsMITSystem(system_id)



                                                                        torf=false;


                                                                        if nargin~=1
                                                                            disp(['ERROR : Arguments is illegal !!']);
                                                                            return;
                                                                        end


                                                                        SystemIdMITmin=30;
                                                                        SystemIdMITmax=39;

                                                                        if system_id==5
                                                                            torf=true;
                                                                        elseif system_id==12
                                                                            torf=true;
                                                                        elseif(system_id>=28)&(system_id<=30)
                                                                            torf=true;
                                                                        elseif(system_id>=SystemIdMITmin)&(system_id<=SystemIdMITmax)
                                                                            torf=true;
                                                                        else
                                                                            torf=false;
                                                                        end


                                                                        function torf=IsMarylandSystem(system_id)



                                                                            torf=false;


                                                                            if nargin~=1
                                                                                disp(['ERROR : Arguments is illegal !!']);
                                                                                return;
                                                                            end


                                                                            SystemIdUMDmin=50;
                                                                            SystemIdUMDmax=59;

                                                                            if(system_id>=SystemIdUMDmin)&(system_id<=SystemIdUMDmax)
                                                                                torf=true;
                                                                            else
                                                                                torf=false;
                                                                            end


                                                                            function torf=IsAcademiaSinicaSystem(system_id)



                                                                                torf=false;


                                                                                if nargin~=1
                                                                                    disp(['ERROR : Arguments is illegal !!']);
                                                                                    return;
                                                                                end


                                                                                SystemIdAcademiaSinicamin=260;
                                                                                SystemIdAcademiaSinicamax=279;

                                                                                if(system_id>=SystemIdAcademiaSinicamin)&(system_id<=SystemIdAcademiaSinicamax)
                                                                                    torf=true;
                                                                                else
                                                                                    torf=false;
                                                                                end


                                                                                function torf=IsPTBSystem(system_id)



                                                                                    torf=false;


                                                                                    if nargin~=1
                                                                                        disp(['ERROR : Arguments is illegal !!']);
                                                                                        return;
                                                                                    end


                                                                                    SystemIdPTBmin=120;
                                                                                    SystemIdPTBmax=139;

                                                                                    if(system_id>=SystemIdPTBmin)&(system_id<=SystemIdPTBmax)
                                                                                        torf=true;
                                                                                    else
                                                                                        torf=false;
                                                                                    end


                                                                                    function torf=IsFujimotoSystem(system_id)



                                                                                        torf=false;


                                                                                        if nargin~=1
                                                                                            disp(['ERROR : Arguments is illegal !!']);
                                                                                            return;
                                                                                        end


                                                                                        SystemIdFujimotomin=140;
                                                                                        SystemIdFujimotomax=159;

                                                                                        if(system_id>=SystemIdFujimotomin)&(system_id<=SystemIdFujimotomax)
                                                                                            torf=true;
                                                                                        else
                                                                                            torf=false;
                                                                                        end


                                                                                        function torf=IsEpilepsyCenterSystem(system_id)




                                                                                            torf=false;


                                                                                            if nargin~=1
                                                                                                disp(['ERROR : Arguments is illegal !!']);
                                                                                                return;
                                                                                            end


                                                                                            SystemIdEpilepsyCentermin=200;
                                                                                            SystemIdEpilepsyCentermax=219;

                                                                                            if(system_id>=SystemIdEpilepsyCentermin)&(system_id<=SystemIdEpilepsyCentermax)
                                                                                                torf=true;
                                                                                            else
                                                                                                torf=false;
                                                                                            end


                                                                                            function torf=IsTokyoKomabaSystem(system_id)




                                                                                                torf=false;


                                                                                                if nargin~=1
                                                                                                    disp(['ERROR : Arguments is illegal !!']);
                                                                                                    return;
                                                                                                end


                                                                                                SystemIdTokyoKomabamin=220;
                                                                                                SystemIdTokyoKomabamax=239;

                                                                                                if(system_id>=SystemIdTokyoKomabamin)&(system_id<=SystemIdTokyoKomabamax)
                                                                                                    torf=true;
                                                                                                else
                                                                                                    torf=false;
                                                                                                end


                                                                                                function torf=IsHokutoSystem(system_id)




                                                                                                    torf=false;


                                                                                                    if nargin~=1
                                                                                                        disp(['ERROR : Arguments is illegal !!']);
                                                                                                        return;
                                                                                                    end


                                                                                                    SystemIdHokutomin=240;
                                                                                                    SystemIdHokutomax=259;

                                                                                                    if(system_id>=SystemIdHokutomin)&(system_id<=SystemIdHokutomax)
                                                                                                        torf=true;
                                                                                                    else
                                                                                                        torf=false;
                                                                                                    end


                                                                                                    function torf=IsISICOSystem(system_id)




                                                                                                        torf=false;


                                                                                                        if nargin~=1
                                                                                                            disp(['ERROR : Arguments is illegal !!']);
                                                                                                            return;
                                                                                                        end


                                                                                                        SystemIdISICOmin=160;
                                                                                                        SystemIdISICOmax=179;

                                                                                                        if(system_id>=SystemIdISICOmin)&(system_id<=SystemIdISICOmax)
                                                                                                            torf=true;
                                                                                                        else
                                                                                                            torf=false;
                                                                                                        end


                                                                                                        function torf=IsMattoHISSystem(system_id)




                                                                                                            torf=false;


                                                                                                            if nargin~=1
                                                                                                                disp(['ERROR : Arguments is illegal !!']);
                                                                                                                return;
                                                                                                            end


                                                                                                            SystemIdMattoHISmin=60;
                                                                                                            SystemIdMattoHISmax=69;

                                                                                                            if(system_id>=SystemIdMattoHISmin)&(system_id<=SystemIdMattoHISmax)
                                                                                                                torf=true;
                                                                                                            else
                                                                                                                torf=false;
                                                                                                            end


                                                                                                            function torf=IsTokyo440System(system_id)




                                                                                                                torf=false;


                                                                                                                if nargin~=1
                                                                                                                    disp(['ERROR : Arguments is illegal !!']);
                                                                                                                    return;
                                                                                                                end


                                                                                                                SystemIdTokyo440min=180;
                                                                                                                SystemIdTokyo440max=199;

                                                                                                                if(system_id>=SystemIdTokyo440min)&(system_id<=SystemIdTokyo440max)
                                                                                                                    torf=true;
                                                                                                                else
                                                                                                                    torf=false;
                                                                                                                end


                                                                                                                function torf=IsTMDUSystem(system_id)






                                                                                                                    torf=false;


                                                                                                                    if nargin~=1
                                                                                                                        disp(['ERROR : Arguments is illegal !!']);
                                                                                                                        return;
                                                                                                                    end


                                                                                                                    SystemIdTMDU=21;
                                                                                                                    SystemIdTMDU2=26;
                                                                                                                    SystemIdTMDUmin=700;
                                                                                                                    SystemIdTMDUmax=719;

                                                                                                                    if system_id==SystemIdTMDU
                                                                                                                        torf=true;
                                                                                                                    elseif system_id==SystemIdTMDU2
                                                                                                                        torf=true;
                                                                                                                    elseif(system_id>=SystemIdTMDUmin)&(system_id<=SystemIdTMDUmax)
                                                                                                                        torf=true;
                                                                                                                    else
                                                                                                                        torf=false;
                                                                                                                    end


                                                                                                                    function torf=IsTMDU75System(system_id)




                                                                                                                        torf=false;


                                                                                                                        if nargin~=1
                                                                                                                            disp(['ERROR : Arguments is illegal !!']);
                                                                                                                            return;
                                                                                                                        end


                                                                                                                        SystemIdTMDU75min=280;
                                                                                                                        SystemIdTMDU75max=299;

                                                                                                                        if(system_id>=SystemIdTMDU75min)&(system_id<=SystemIdTMDU75max)
                                                                                                                            torf=true;
                                                                                                                        else
                                                                                                                            torf=false;
                                                                                                                        end


                                                                                                                        function torf=IsJointLaboratorySystem(system_id)



                                                                                                                            torf=false;


                                                                                                                            if nargin~=1
                                                                                                                                disp(['ERROR : Arguments is illegal !!']);
                                                                                                                                return;
                                                                                                                            end


                                                                                                                            SystemIdCommercialSystem=100;

                                                                                                                            if system_id<SystemIdCommercialSystem
                                                                                                                                torf=true;
                                                                                                                            else
                                                                                                                                torf=false;
                                                                                                                            end












                                                                                                                            function out=GetSqfPatientInfo(varargin)

















                                                                                                                                try
                                                                                                                                    function_revision=0;
                                                                                                                                    function_name='GetSqfPatientInfo';




                                                                                                                                    out=[];


                                                                                                                                    if nargin==1
                                                                                                                                        fid=varargin{1};
                                                                                                                                    else
                                                                                                                                        disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                        return;
                                                                                                                                    end


                                                                                                                                    sqf_slot=GetSqfConstantsDirectory;
                                                                                                                                    if isempty(sqf_slot)
                                                                                                                                        return;
                                                                                                                                    end














                                                                                                                                    PatientInfoPatientIDCode=hex2dec('00001');
                                                                                                                                    PatientInfoPatientIDSubcode=hex2dec('00001');
                                                                                                                                    PatientInfoPatientNameCode=hex2dec('00002');
                                                                                                                                    PatientInfoPatientNameSubcode=hex2dec('00001');
                                                                                                                                    PatientInfoPatientBirthdayCode=hex2dec('00003');
                                                                                                                                    PatientInfoPatientBirthdaySubcode=hex2dec('00001');
                                                                                                                                    PatientInfoPatientSexCode=hex2dec('00004');
                                                                                                                                    PatientInfoPatientSexSubcode=hex2dec('00001');
                                                                                                                                    PatientInfoPatientHandedCode=hex2dec('00005');
                                                                                                                                    PatientInfoPatientHandedSubcode=hex2dec('00001');

                                                                                                                                    MaxPatientIDLength=128;
                                                                                                                                    MaxPatientNameLength=128;
                                                                                                                                    MaxPatientBirthdayLength=64;
                                                                                                                                    MaxPatientSexLength=16;
                                                                                                                                    MaxPatientHandedLength=16;


                                                                                                                                    direc=GetSqfDirectory(fid,sqf_slot.SqfPatientInfoSlot,function_name);
                                                                                                                                    if isempty(direc)
                                                                                                                                        disp(['ERROR ( ',function_name,' ): This file is not Meg160 format!!']);
                                                                                                                                        return;
                                                                                                                                    end


                                                                                                                                    patient_id=[];
                                                                                                                                    patient_name=[];
                                                                                                                                    patient_birthday=[];
                                                                                                                                    patient_sex=[];
                                                                                                                                    patient_handed=[];


                                                                                                                                    fseek(fid,direc.offset,'bof');



                                                                                                                                    fseek(fid,direc.offset,'bof');
                                                                                                                                    start_fid=ftell(fid);
                                                                                                                                    total_info_size=direc.size*direc.count;
                                                                                                                                    while(ftell(fid)<start_fid+total_info_size)
                                                                                                                                        info_size=fread(fid,1,'int32');
                                                                                                                                        info_code=fread(fid,1,'int32');
                                                                                                                                        info_subcode=fread(fid,1,'int32');
                                                                                                                                        if info_code==PatientInfoPatientIDCode&info_subcode==PatientInfoPatientIDSubcode
                                                                                                                                            tmp=fread(fid,MaxPatientIDLength,'uchar');
                                                                                                                                            index=min(find(tmp==0));
                                                                                                                                            patient_id=GetSqfData2str(tmp(1:index));
                                                                                                                                        elseif info_code==PatientInfoPatientNameCode&info_subcode==PatientInfoPatientNameSubcode
                                                                                                                                            tmp=fread(fid,MaxPatientNameLength,'uchar');
                                                                                                                                            index=min(find(tmp==0));
                                                                                                                                            patient_name=GetSqfData2str(tmp(1:index));
                                                                                                                                        elseif info_code==PatientInfoPatientBirthdayCode&info_subcode==PatientInfoPatientBirthdaySubcode
                                                                                                                                            tmp=fread(fid,MaxPatientBirthdayLength,'uchar');
                                                                                                                                            index=min(find(tmp==0));
                                                                                                                                            patient_birthday=GetSqfData2str(tmp(1:index));
                                                                                                                                        elseif info_code==PatientInfoPatientSexCode&info_subcode==PatientInfoPatientSexSubcode
                                                                                                                                            tmp=fread(fid,MaxPatientSexLength,'uchar');
                                                                                                                                            index=min(find(tmp==0));
                                                                                                                                            patient_sex=GetSqfData2str(tmp(1:index));
                                                                                                                                        elseif info_code==PatientInfoPatientHandedCode&info_subcode==PatientInfoPatientHandedSubcode
                                                                                                                                            tmp=fread(fid,MaxPatientHandedLength,'uchar');
                                                                                                                                            index=min(find(tmp==0));
                                                                                                                                            patient_handed=GetSqfData2str(tmp(1:index));
                                                                                                                                        end
                                                                                                                                    end
                                                                                                                                    patient_info.id=patient_id;
                                                                                                                                    patient_info.name=patient_name;
                                                                                                                                    patient_info.birthday=patient_birthday;
                                                                                                                                    patient_info.sex=patient_sex;
                                                                                                                                    patient_info.handed=patient_handed;


                                                                                                                                    fseek(fid,0,'bof');


                                                                                                                                    out=patient_info;

                                                                                                                                catch





                                                                                                                                    str_error_message=sprintf('Exception : Sorry, reading error was occurred. ()');
                                                                                                                                    disp(str_error_message);
                                                                                                                                    return;
                                                                                                                                end





















                                                                                                                                function out=GetSqfChannel(varargin)






































                                                                                                                                    try
                                                                                                                                        function_revision=2;
                                                                                                                                        function_name='GetSqfChannel';



                                                                                                                                        out=[];


                                                                                                                                        if nargin>=4
                                                                                                                                            disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                            return;
                                                                                                                                        end
                                                                                                                                        if nargin>=1
                                                                                                                                            fid=varargin{1};
                                                                                                                                        else
                                                                                                                                            disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                            return;
                                                                                                                                        end
                                                                                                                                        if nargin>=2
                                                                                                                                            sqf_sysinfo=varargin{2};

                                                                                                                                            if~(isfield(sqf_sysinfo,'version')&isfield(sqf_sysinfo,'revision')&isfield(sqf_sysinfo,'channel_count')&isfield(sqf_sysinfo,'system_id'))
                                                                                                                                                sqf_sysinfo=GetSqfSystemInfo(fid);
                                                                                                                                            end
                                                                                                                                        else
                                                                                                                                            sqf_sysinfo=GetSqfSystemInfo(fid);
                                                                                                                                        end
                                                                                                                                        if nargin>=3
                                                                                                                                            SmallAnimalsMCGSys=varargin{3};
                                                                                                                                        else
                                                                                                                                            SmallAnimalsMCGSys=false;
                                                                                                                                        end


                                                                                                                                        sqf_slot=GetSqfConstantsDirectory;
                                                                                                                                        if isempty(sqf_slot)
                                                                                                                                            return;
                                                                                                                                        end


                                                                                                                                        NullChannel=0;
                                                                                                                                        MagnetoMeter=1;
                                                                                                                                        AxialGradioMeter=2;
                                                                                                                                        PlannerGradioMeter=3;
                                                                                                                                        ReferenceChannelMark=hex2dec('0100');
                                                                                                                                        ReferenceMagnetoMeter=bitor(ReferenceChannelMark,MagnetoMeter);
                                                                                                                                        ReferenceAxialGradioMeter=bitor(ReferenceChannelMark,AxialGradioMeter);
                                                                                                                                        ReferencePlannerGradioMeter=bitor(ReferenceChannelMark,PlannerGradioMeter);
                                                                                                                                        TriggerChannel=-1;
                                                                                                                                        EegChannel=-2;
                                                                                                                                        EcgChannel=-3;
                                                                                                                                        EtcChannel=-4;

                                                                                                                                        MegChannelNameLength=6;
                                                                                                                                        NonMegChannelNameLength=32;



                                                                                                                                        NKCEegChannelType=1;
                                                                                                                                        NKCEegChannelNameLength=8;











                                                                                                                                        if SmallAnimalsMCGSys
                                                                                                                                            DefaultMagnetometerSize=(2.5/1000.0);
                                                                                                                                        else
                                                                                                                                            DefaultMagnetometerSize=(4.0/1000.0);
                                                                                                                                        end
                                                                                                                                        DefaultAxialGradioMeterSize=(15.5/1000.0);
                                                                                                                                        DefaultPlannerGradioMeterSize=(12.0/1000.0);


                                                                                                                                        direc=GetSqfDirectory(fid,sqf_slot.SqfChannelSlot,function_name);
                                                                                                                                        if isempty(direc)
                                                                                                                                            disp(['ERROR ( ',function_name,' ): This file is not Meg160 format!!']);
                                                                                                                                            return;
                                                                                                                                        end








                                                                                                                                        sqf_channel=[];

                                                                                                                                        for ch=1:direc.count

                                                                                                                                            fseek(fid,direc.offset+direc.size*(ch-1),'bof');


                                                                                                                                            channel_type=fread(fid,1,'int32');


                                                                                                                                            inner_UData=[];


                                                                                                                                            switch channel_type
                                                                                                                                            case MagnetoMeter
                                                                                                                                                inner_UData.x=fread(fid,1,'double');
                                                                                                                                                inner_UData.y=fread(fid,1,'double');
                                                                                                                                                inner_UData.z=fread(fid,1,'double');
                                                                                                                                                inner_UData.zdir=fread(fid,1,'double');
                                                                                                                                                inner_UData.xdir=fread(fid,1,'double');
                                                                                                                                                inner_UData.size=fread(fid,1,'double');
                                                                                                                                                inner_UData.spare=fread(fid,8,'uchar');index=min(find(inner_UData.spare==0));inner_UData.spare=deblank(GetSqfData2str(inner_UData.spare(1:index)));
                                                                                                                                                inner_UData.name=fread(fid,MegChannelNameLength,'uchar');index=min(find(inner_UData.name==0));inner_UData.name=deblank(GetSqfData2str(inner_UData.name(1:index)));
                                                                                                                                                inner_UData.order=fread(fid,1,'int16');
                                                                                                                                                inner_UData.color_enable=fread(fid,1,'int32');
                                                                                                                                                inner_UData.color=fread(fid,1,'uint32');inner_UData.color=Colorref2RGB(inner_UData.color);
                                                                                                                                                if SmallAnimalsMCGSys
                                                                                                                                                    if(inner_UData.size<=0.0)||(DefaultMagnetometerSize*20<=inner_UData.size)
                                                                                                                                                        inner_UData.size=DefaultMagnetometerSize;
                                                                                                                                                    end
                                                                                                                                                else
                                                                                                                                                    inner_UData.size=DefaultMagnetometerSize;
                                                                                                                                                end
                                                                                                                                            case AxialGradioMeter
                                                                                                                                                inner_UData.x=fread(fid,1,'double');
                                                                                                                                                inner_UData.y=fread(fid,1,'double');
                                                                                                                                                inner_UData.z=fread(fid,1,'double');
                                                                                                                                                inner_UData.zdir=fread(fid,1,'double');
                                                                                                                                                inner_UData.xdir=fread(fid,1,'double');
                                                                                                                                                inner_UData.baseline=fread(fid,1,'double');
                                                                                                                                                inner_UData.size=fread(fid,1,'double');inner_UData.size=DefaultAxialGradioMeterSize;
                                                                                                                                                inner_UData.name=fread(fid,MegChannelNameLength,'uchar');index=min(find(inner_UData.name==0));inner_UData.name=deblank(GetSqfData2str(inner_UData.name(1:index)));
                                                                                                                                                inner_UData.order=fread(fid,1,'int16');
                                                                                                                                                inner_UData.color_enable=fread(fid,1,'int32');
                                                                                                                                                inner_UData.color=fread(fid,1,'uint32');inner_UData.color=Colorref2RGB(inner_UData.color);
                                                                                                                                            case PlannerGradioMeter
                                                                                                                                                inner_UData.x=fread(fid,1,'double');
                                                                                                                                                inner_UData.y=fread(fid,1,'double');
                                                                                                                                                inner_UData.z=fread(fid,1,'double');
                                                                                                                                                inner_UData.zdir1=fread(fid,1,'double');
                                                                                                                                                inner_UData.xdir1=fread(fid,1,'double');
                                                                                                                                                inner_UData.zdir2=fread(fid,1,'double');
                                                                                                                                                inner_UData.xdir2=fread(fid,1,'double');
                                                                                                                                                inner_UData.baseline=fread(fid,1,'double');
                                                                                                                                                inner_UData.size=fread(fid,1,'double');inner_UData.size=DefaultPlannerGradioMeterSize;
                                                                                                                                            case ReferenceMagnetoMeter
                                                                                                                                                inner_UData.x=fread(fid,1,'double');
                                                                                                                                                inner_UData.y=fread(fid,1,'double');
                                                                                                                                                inner_UData.z=fread(fid,1,'double');
                                                                                                                                                inner_UData.zdir=fread(fid,1,'double');
                                                                                                                                                inner_UData.xdir=fread(fid,1,'double');
                                                                                                                                                inner_UData.size=fread(fid,1,'double');
                                                                                                                                                inner_UData.spare=fread(fid,8,'uchar');index=min(find(inner_UData.spare==0));inner_UData.spare=deblank(GetSqfData2str(inner_UData.spare(1:index)));
                                                                                                                                                inner_UData.name=fread(fid,MegChannelNameLength,'uchar');index=min(find(inner_UData.name==0));inner_UData.name=deblank(GetSqfData2str(inner_UData.name(1:index)));
                                                                                                                                                inner_UData.order=fread(fid,1,'int16');
                                                                                                                                                inner_UData.color_enable=fread(fid,1,'int32');
                                                                                                                                                inner_UData.color=fread(fid,1,'uint32');inner_UData.color=Colorref2RGB(inner_UData.color);
                                                                                                                                                if SmallAnimalsMCGSys
                                                                                                                                                    if(inner_UData.size<=0.0)||(DefaultMagnetometerSize*20<=inner_UData.size)
                                                                                                                                                        inner_UData.size=DefaultMagnetometerSize;
                                                                                                                                                    end
                                                                                                                                                else
                                                                                                                                                    inner_UData.size=DefaultMagnetometerSize;
                                                                                                                                                end
                                                                                                                                            case ReferenceAxialGradioMeter
                                                                                                                                                inner_UData.x=fread(fid,1,'double');
                                                                                                                                                inner_UData.y=fread(fid,1,'double');
                                                                                                                                                inner_UData.z=fread(fid,1,'double');
                                                                                                                                                inner_UData.zdir=fread(fid,1,'double');
                                                                                                                                                inner_UData.xdir=fread(fid,1,'double');
                                                                                                                                                inner_UData.baseline=fread(fid,1,'double');
                                                                                                                                                inner_UData.size=fread(fid,1,'double');inner_UData.size=DefaultAxialGradioMeterSize;
                                                                                                                                                inner_UData.name=fread(fid,MegChannelNameLength,'uchar');index=min(find(inner_UData.name==0));inner_UData.name=deblank(GetSqfData2str(inner_UData.name(1:index)));
                                                                                                                                                inner_UData.order=fread(fid,1,'int16');
                                                                                                                                                inner_UData.color_enable=fread(fid,1,'int32');
                                                                                                                                                inner_UData.color=fread(fid,1,'uint32');inner_UData.color=Colorref2RGB(inner_UData.color);
                                                                                                                                            case ReferencePlannerGradioMeter
                                                                                                                                                inner_UData.x=fread(fid,1,'double');
                                                                                                                                                inner_UData.y=fread(fid,1,'double');
                                                                                                                                                inner_UData.z=fread(fid,1,'double');
                                                                                                                                                inner_UData.zdir1=fread(fid,1,'double');
                                                                                                                                                inner_UData.xdir1=fread(fid,1,'double');
                                                                                                                                                inner_UData.zdir2=fread(fid,1,'double');
                                                                                                                                                inner_UData.xdir2=fread(fid,1,'double');
                                                                                                                                                inner_UData.baseline=fread(fid,1,'double');
                                                                                                                                                inner_UData.size=fread(fid,1,'double');inner_UData.size=DefaultPlannerGradioMeterSize;
                                                                                                                                            case TriggerChannel
                                                                                                                                                inner_UData.type=fread(fid,1,'int32');
                                                                                                                                                inner_UData.id=fread(fid,1,'int32');
                                                                                                                                                inner_UData.name=fread(fid,NonMegChannelNameLength,'uchar');index=min(find(inner_UData.name==0));inner_UData.name=deblank(GetSqfData2str(inner_UData.name(1:index)));
                                                                                                                                                inner_UData.spare=fread(fid,22,'uchar');index=min(find(inner_UData.spare==0));inner_UData.spare=deblank(GetSqfData2str(inner_UData.spare(1:index)));
                                                                                                                                                inner_UData.order=fread(fid,1,'int16');
                                                                                                                                                inner_UData.color_enable=fread(fid,1,'int32');
                                                                                                                                                inner_UData.color=fread(fid,1,'uint32');inner_UData.color=Colorref2RGB(inner_UData.color);
                                                                                                                                            case EegChannel
                                                                                                                                                inner_UData.type=fread(fid,1,'int32');
                                                                                                                                                if inner_UData.type==NKCEegChannelType














                                                                                                                                                    inner_UData.id=fread(fid,1,'int32');
                                                                                                                                                    inner_UData.name=fread(fid,NKCEegChannelNameLength,'uchar');index=min(find(inner_UData.name==0));inner_UData.name=deblank(GetSqfData2str(inner_UData.name(1:index)));
                                                                                                                                                    inner_UData.storage=fread(fid,1,'uchar');
                                                                                                                                                    inner_UData.average=fread(fid,1,'uchar');
                                                                                                                                                    inner_UData.offset=fread(fid,1,'int32');
                                                                                                                                                    inner_UData.gain=fread(fid,1,'double');
                                                                                                                                                    inner_UData.spare=fread(fid,42,'uchar');index=min(find(inner_UData.spare==0));inner_UData.spare=deblank(GetSqfData2str(inner_UData.spare(1:index)));
                                                                                                                                                else
















                                                                                                                                                    inner_UData.id=fread(fid,1,'int32');
                                                                                                                                                    inner_UData.name=fread(fid,NonMegChannelNameLength,'uchar');index=min(find(inner_UData.name==0));inner_UData.name=deblank(GetSqfData2str(inner_UData.name(1:index)));
                                                                                                                                                    inner_UData.derivation_type=fread(fid,1,'int32');
                                                                                                                                                    inner_UData.derivation_parameter=fread(fid,1,'int32');
                                                                                                                                                    inner_UData.gain=fread(fid,1,'double');
                                                                                                                                                    inner_UData.spare=fread(fid,6,'uchar');index=min(find(inner_UData.spare==0));inner_UData.spare=deblank(GetSqfData2str(inner_UData.spare(1:index)));
                                                                                                                                                    inner_UData.order=fread(fid,1,'int16');
                                                                                                                                                    inner_UData.color_enable=fread(fid,1,'int32');
                                                                                                                                                    inner_UData.color=fread(fid,1,'uint32');inner_UData.color=Colorref2RGB(inner_UData.color);
                                                                                                                                                end
                                                                                                                                            case EcgChannel
                                                                                                                                                inner_UData.type=fread(fid,1,'int32');
                                                                                                                                                inner_UData.id=fread(fid,1,'int32');
                                                                                                                                                inner_UData.name=fread(fid,NonMegChannelNameLength,'uchar');index=min(find(inner_UData.name==0));inner_UData.name=deblank(GetSqfData2str(inner_UData.name(1:index)));
                                                                                                                                                inner_UData.leadsystem_type=fread(fid,1,'int32');
                                                                                                                                                inner_UData.leadsystem_parameter=fread(fid,1,'int32');
                                                                                                                                                inner_UData.gain=fread(fid,1,'double');
                                                                                                                                                inner_UData.spare=fread(fid,6,'uchar');index=min(find(inner_UData.spare==0));inner_UData.spare=deblank(GetSqfData2str(inner_UData.spare(1:index)));
                                                                                                                                                inner_UData.order=fread(fid,1,'int16');
                                                                                                                                                inner_UData.color_enable=fread(fid,1,'int32');
                                                                                                                                                inner_UData.color=fread(fid,1,'uint32');inner_UData.color=Colorref2RGB(inner_UData.color);
                                                                                                                                            case EtcChannel
                                                                                                                                                inner_UData.type=fread(fid,1,'int32');
                                                                                                                                                inner_UData.id=fread(fid,1,'int32');
                                                                                                                                                inner_UData.name=fread(fid,NonMegChannelNameLength,'uchar');index=min(find(inner_UData.name==0));inner_UData.name=deblank(GetSqfData2str(inner_UData.name(1:index)));
                                                                                                                                                inner_UData.spare=fread(fid,22,'uchar');index=min(find(inner_UData.spare==0));inner_UData.spare=deblank(GetSqfData2str(inner_UData.spare(1:index)));
                                                                                                                                                inner_UData.order=fread(fid,1,'int16');
                                                                                                                                                inner_UData.color_enable=fread(fid,1,'int32');
                                                                                                                                                inner_UData.color=fread(fid,1,'uint32');inner_UData.color=Colorref2RGB(inner_UData.color);
                                                                                                                                            case NullChannel


                                                                                                                                            otherwise
                                                                                                                                                disp(['ERROR ( ',function_name,' ): Channel information is illegal !!']);
                                                                                                                                                return;
                                                                                                                                            end


                                                                                                                                            sqf_channel(ch).type=channel_type;
                                                                                                                                            sqf_channel(ch).data=inner_UData;

                                                                                                                                        end


                                                                                                                                        fseek(fid,0,'bof');




                                                                                                                                        if(sqf_sysinfo.version<=0)&(sqf_sysinfo.revision<122)
                                                                                                                                            sqf_channel=CleanUpChannelInfo(sqf_sysinfo.channel_count,sqf_channel,true);
                                                                                                                                        elseif sqf_sysinfo.version<=1
                                                                                                                                            sqf_channel=CleanUpChannelInfo(sqf_sysinfo.channel_count,sqf_channel,false);
                                                                                                                                        end


                                                                                                                                        eeg_gain=-1.0;
                                                                                                                                        ecg_gain=-1.0;
                                                                                                                                        filepath_eeg_gain='C:\\Meg160\\AppInfo\\EegGain.txt';
                                                                                                                                        filepath_ecg_gain='C:\\Meg160\\AppInfo\\EcgGain.txt';
                                                                                                                                        flag_proper=1;
                                                                                                                                        for ch=1:sqf_sysinfo.channel_count
                                                                                                                                            switch sqf_channel(ch).type
                                                                                                                                            case EegChannel
                                                                                                                                                if sqf_channel(ch).data.gain<=0&&sqf_channel(ch).data.type~=1
                                                                                                                                                    if exist(filepath_eeg_gain)
                                                                                                                                                        eeg_gain=load('-ascii',filepath_eeg_gain);
                                                                                                                                                        if length(eeg_gain)>1
                                                                                                                                                            eeg_gain=eeg_gain(1,1);
                                                                                                                                                            flag_proper=-1;
                                                                                                                                                        end
                                                                                                                                                    end
                                                                                                                                                    if eeg_gain<=0
                                                                                                                                                        eeg_gain=1.0;
                                                                                                                                                    end
                                                                                                                                                    sqf_channel(ch).data.gain=eeg_gain;
                                                                                                                                                end
                                                                                                                                            case EcgChannel
                                                                                                                                                if sqf_channel(ch).data.gain<=0
                                                                                                                                                    if exist(filepath_ecg_gain)
                                                                                                                                                        ecg_gain=load('-ascii',filepath_ecg_gain);
                                                                                                                                                        if length(ecg_gain)>1
                                                                                                                                                            ecg_gain=ecg_gain(1,1);
                                                                                                                                                            flag_proper=-2;
                                                                                                                                                        end
                                                                                                                                                    end
                                                                                                                                                    if ecg_gain<=0
                                                                                                                                                        ecg_gain=1.0;
                                                                                                                                                    end
                                                                                                                                                    sqf_channel(ch).data.gain=ecg_gain;
                                                                                                                                                end
                                                                                                                                            end
                                                                                                                                        end
                                                                                                                                        if flag_proper<0
                                                                                                                                            switch flag_proper
                                                                                                                                            case-1
                                                                                                                                                disp(sprintf('WARNING (%s) : Format of EegGain.txt is illegal.',function_name));
                                                                                                                                            case-2
                                                                                                                                                disp(sprintf('WARNING (%s) : Format of EcgGain.txt is illegal.',function_name));
                                                                                                                                            end
                                                                                                                                        end










                                                                                                                                        if sqf_sysinfo.system_id==71
                                                                                                                                            sqf_channel(118).data.x=-0.014740;
                                                                                                                                            sqf_channel(118).data.y=-0.114533;
                                                                                                                                            sqf_channel(118).data.z=0.002429;
                                                                                                                                            sqf_channel(118).data.zdir=88.551562;
                                                                                                                                            sqf_channel(118).data.xdir=265.972661;
                                                                                                                                        end


                                                                                                                                        out=sqf_channel;

                                                                                                                                    catch





                                                                                                                                        str_error_message=sprintf('Exception : Sorry, reading error was occurred. (channel)');
                                                                                                                                        disp(str_error_message);
                                                                                                                                        return;
                                                                                                                                    end



                                                                                                                                    function sqf_channel=CleanUpChannelInfo(channel_count,sqf_channel,init_name)




                                                                                                                                        NullChannel=0;
                                                                                                                                        MagnetoMeter=1;
                                                                                                                                        AxialGradioMeter=2;
                                                                                                                                        PlannerGradioMeter=3;
                                                                                                                                        ReferenceChannelMark=hex2dec('0100');
                                                                                                                                        ReferenceMagnetoMeter=bitor(ReferenceChannelMark,MagnetoMeter);
                                                                                                                                        ReferenceAxialGradioMeter=bitor(ReferenceChannelMark,AxialGradioMeter);
                                                                                                                                        ReferencePlannerGradioMeter=bitor(ReferenceChannelMark,PlannerGradioMeter);
                                                                                                                                        TriggerChannel=-1;
                                                                                                                                        EegChannel=-2;
                                                                                                                                        EcgChannel=-3;
                                                                                                                                        EtcChannel=-4;

                                                                                                                                        for ch=1:channel_count
                                                                                                                                            switch sqf_channel(ch).type
                                                                                                                                            case MagnetoMeter
                                                                                                                                                if init_name
                                                                                                                                                    sqf_channel(ch).data.name='';
                                                                                                                                                end
                                                                                                                                                sqf_channel(ch).data.order=0;
                                                                                                                                                sqf_channel(ch).data.color_enable=false;
                                                                                                                                                sqf_channel(ch).data.color=[0,0,0];
                                                                                                                                                sqf_channel(ch).data.spare='';
                                                                                                                                            case AxialGradioMeter
                                                                                                                                                if init_name
                                                                                                                                                    sqf_channel(ch).data.name='';
                                                                                                                                                end
                                                                                                                                                sqf_channel(ch).data.order=0;
                                                                                                                                                sqf_channel(ch).data.color_enable=false;
                                                                                                                                                sqf_channel(ch).data.color=[0,0,0];
                                                                                                                                            case PlannerGradioMeter

                                                                                                                                            case ReferenceMagnetoMeter
                                                                                                                                                if init_name
                                                                                                                                                    sqf_channel(ch).data.name='';
                                                                                                                                                end
                                                                                                                                                sqf_channel(ch).data.order=0;
                                                                                                                                                sqf_channel(ch).data.color_enable=false;
                                                                                                                                                sqf_channel(ch).data.color=[0,0,0];
                                                                                                                                                sqf_channel(ch).data.spare='';
                                                                                                                                            case ReferenceAxialGradioMeter
                                                                                                                                                if init_name
                                                                                                                                                    sqf_channel(ch).data.name='';
                                                                                                                                                end
                                                                                                                                                sqf_channel(ch).data.order=0;
                                                                                                                                                sqf_channel(ch).data.color_enable=false;
                                                                                                                                                sqf_channel(ch).data.color=[0,0,0];
                                                                                                                                            case ReferencePlannerGradioMeter

                                                                                                                                            case TriggerChannel
                                                                                                                                                if init_name
                                                                                                                                                    sqf_channel(ch).data.name='';
                                                                                                                                                end
                                                                                                                                                sqf_channel(ch).data.order=0;
                                                                                                                                                sqf_channel(ch).data.color_enable=false;
                                                                                                                                                sqf_channel(ch).data.color=[0,0,0];
                                                                                                                                                sqf_channel(ch).data.spare='';
                                                                                                                                            case EegChannel
                                                                                                                                                if init_name
                                                                                                                                                    sqf_channel(ch).data.name='';
                                                                                                                                                end
                                                                                                                                                sqf_channel(ch).data.derivation_type=0;
                                                                                                                                                sqf_channel(ch).data.derivation_parameter=0;
                                                                                                                                                sqf_channel(ch).data.gain=0.0;
                                                                                                                                                sqf_channel(ch).data.order=0;
                                                                                                                                                sqf_channel(ch).data.color_enable=false;
                                                                                                                                                sqf_channel(ch).data.color=[0,0,0];
                                                                                                                                                sqf_channel(ch).data.spare='';
                                                                                                                                            case EcgChannel
                                                                                                                                                if init_name
                                                                                                                                                    sqf_channel(ch).data.name='';
                                                                                                                                                end
                                                                                                                                                sqf_channel(ch).data.leadsystem_type=0;
                                                                                                                                                sqf_channel(ch).data.leadsystem_parameter=0;
                                                                                                                                                sqf_channel(ch).data.gain=0.0;
                                                                                                                                                sqf_channel(ch).data.order=0;
                                                                                                                                                sqf_channel(ch).data.color_enable=false;
                                                                                                                                                sqf_channel(ch).data.color=[0,0,0];
                                                                                                                                                sqf_channel(ch).data.spare='';
                                                                                                                                            case EtcChannel
                                                                                                                                                if init_name
                                                                                                                                                    sqf_channel(ch).data.name='';
                                                                                                                                                end
                                                                                                                                                sqf_channel(ch).data.order=0;
                                                                                                                                                sqf_channel(ch).data.color_enable=false;
                                                                                                                                                sqf_channel(ch).data.color=[0,0,0];
                                                                                                                                                sqf_channel(ch).data.spare='';
                                                                                                                                            case NullChannel
                                                                                                                                                sqf_channel(ch).type=NullChannel;
                                                                                                                                            otherwise
                                                                                                                                                sqf_channel(ch).type=NullChannel;
                                                                                                                                            end
                                                                                                                                        end


                                                                                                                                        function rgb=Colorref2RGB(colorref)















                                                                                                                                            n=2;
                                                                                                                                            bit_count=24;

                                                                                                                                            if colorref==0
                                                                                                                                                rgb=[0,0,0];
                                                                                                                                                return;
                                                                                                                                            end

                                                                                                                                            remainder=zeros(1,bit_count);

                                                                                                                                            ii=1;
                                                                                                                                            while colorref~=0

                                                                                                                                                remainder(ii)=mod(colorref,n);

                                                                                                                                                colorref=floor(colorref/n);

                                                                                                                                                ii=ii+1;
                                                                                                                                            end
                                                                                                                                            remainder=fliplr(remainder);
                                                                                                                                            rgb(1)=remainder(1:8)*2.^([7:-1:0].');
                                                                                                                                            rgb(2)=remainder(9:16)*2.^([7:-1:0].');
                                                                                                                                            rgb(3)=remainder(17:24)*2.^([7:-1:0].');


                                                                                                                                            rgb=rgb./255;












                                                                                                                                            function out=GetSqfCalibration(varargin)




























                                                                                                                                                try
                                                                                                                                                    function_revision=3;
                                                                                                                                                    function_name='GetSqfCalibration';



                                                                                                                                                    out=[];


                                                                                                                                                    if nargin>=6
                                                                                                                                                        disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                                        return;
                                                                                                                                                    end
                                                                                                                                                    if nargin>=1
                                                                                                                                                        fid=varargin{1};
                                                                                                                                                    else
                                                                                                                                                        disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                                        return;
                                                                                                                                                    end
                                                                                                                                                    if nargin>=2
                                                                                                                                                        sqf_sysinfo=varargin{2};
                                                                                                                                                        if~(isfield(sqf_sysinfo,'system_id')&isfield(sqf_sysinfo,'channel_count'))
                                                                                                                                                            sqf_sysinfo=GetSqfSystemInfo(fid);
                                                                                                                                                        end
                                                                                                                                                    else
                                                                                                                                                        sqf_sysinfo=GetSqfSystemInfo(fid);
                                                                                                                                                    end
                                                                                                                                                    if nargin>=3
                                                                                                                                                        sqf_channel=varargin{3};
                                                                                                                                                        if~(isfield(sqf_channel,'type')&isfield(sqf_channel,'data'))
                                                                                                                                                            sqf_channel=GetSqfChannel(fid,sqf_sysinfo);
                                                                                                                                                        end
                                                                                                                                                    else
                                                                                                                                                        sqf_channel=GetSqfChannel(fid,sqf_sysinfo);
                                                                                                                                                    end
                                                                                                                                                    if nargin>=4
                                                                                                                                                        sqf_fll=varargin{4};
                                                                                                                                                        if~isfield(sqf_fll,'mode2')
                                                                                                                                                            sqf_fll=GetSqfFLL(fid);
                                                                                                                                                        end
                                                                                                                                                    else
                                                                                                                                                        sqf_fll=GetSqfFLL(fid);
                                                                                                                                                    end
                                                                                                                                                    if nargin>=5
                                                                                                                                                        sqf_afa=varargin{5};
                                                                                                                                                        if isempty(sqf_afa)
                                                                                                                                                            sqf_afa=GetSqfAFA(fid);
                                                                                                                                                        end
                                                                                                                                                    else
                                                                                                                                                        sqf_afa=GetSqfAFA(fid);
                                                                                                                                                    end


                                                                                                                                                    sqf_slot=GetSqfConstantsDirectory;
                                                                                                                                                    if isempty(sqf_slot)
                                                                                                                                                        return;
                                                                                                                                                    end


                                                                                                                                                    HangerSleepMode=hex2dec('0001');
                                                                                                                                                    PRDPhase1FLLASPSystem=300;
                                                                                                                                                    MaxChannelInHangerUnit=16;

                                                                                                                                                    NullChannel=0;
                                                                                                                                                    MagnetoMeter=1;
                                                                                                                                                    AxialGradioMeter=2;
                                                                                                                                                    PlannerGradioMeter=3;
                                                                                                                                                    RefferenceChannelMark=hex2dec('0100');
                                                                                                                                                    RefferenceMagnetoMeter=bitor(RefferenceChannelMark,MagnetoMeter);
                                                                                                                                                    RefferenceAxialGradioMeter=bitor(RefferenceChannelMark,AxialGradioMeter);
                                                                                                                                                    RefferencePlannerGradioMeter=bitor(RefferenceChannelMark,PlannerGradioMeter);
                                                                                                                                                    TriggerChannel=-1;
                                                                                                                                                    EegChannel=-2;
                                                                                                                                                    EcgChannel=-3;
                                                                                                                                                    EtcChannel=-4;


                                                                                                                                                    direc=GetSqfDirectory(fid,sqf_slot.SqfCalibrationSlot,function_name);
                                                                                                                                                    if isempty(direc)
                                                                                                                                                        disp(['ERROR ( ',function_name,' ): This file is not Meg160 format!!']);
                                                                                                                                                        return;
                                                                                                                                                    end







                                                                                                                                                    sqf_calib=[];

                                                                                                                                                    for ch=1:direc.count

                                                                                                                                                        fseek(fid,direc.offset+direc.size*(ch-1),'bof');


                                                                                                                                                        sqf_calib(ch).offset=fread(fid,1,'double');
                                                                                                                                                        sqf_calib(ch).gain=fread(fid,1,'double');
                                                                                                                                                    end


                                                                                                                                                    fseek(fid,0,'bof');










                                                                                                                                                    if sqf_sysinfo.system_id==71
                                                                                                                                                        sqf_calib(118).gain=5.549384e-10;
                                                                                                                                                    end


                                                                                                                                                    setup_calib=SetupCalibrationData(sqf_sysinfo,sqf_channel,sqf_fll,sqf_afa,sqf_calib);


                                                                                                                                                    out=setup_calib;

                                                                                                                                                catch





                                                                                                                                                    str_error_message=sprintf('Exception : Sorry, reading error was occurred. (calibration)');
                                                                                                                                                    disp(str_error_message);
                                                                                                                                                    return;
                                                                                                                                                end



                                                                                                                                                function out=SetupCalibrationData(sqf_sysinfo,sqf_channel,sqf_fll,sqf_afa,sqf_calib)


                                                                                                                                                    out=[];
























































                                                                                                                                                    MaxSlaveCount=16;
                                                                                                                                                    MaxBoardInSlave=2;
                                                                                                                                                    MaxChannelInBoard=32;
                                                                                                                                                    MaxChannelInSlave=MaxChannelInBoard*MaxBoardInSlave;
                                                                                                                                                    MaxChannelCount=MaxChannelInBoard*MaxBoardInSlave*MaxSlaveCount;
                                                                                                                                                    MaxMaxChannelCount=1024;





                                                                                                                                                    MaxHangerUnitCount=40;
                                                                                                                                                    MaxChannelInHangerUnit=16;
                                                                                                                                                    MaxHangerUnitInSlave=MaxChannelInSlave/MaxChannelInHangerUnit;



















                                                                                                                                                    UnknownHangerType=-1;
                                                                                                                                                    StandardHangerType=0;
                                                                                                                                                    FLLASPSeparateHangerType=1;
                                                                                                                                                    PCI1StandardHangerType=10;
                                                                                                                                                    PCI2StandardHangerType=20;
                                                                                                                                                    PCI1RevisedHangerType=50;
                                                                                                                                                    PCI2RevisedHangerType=60;
                                                                                                                                                    PCI1LowHPFHangerType=51;
                                                                                                                                                    PCI2LowHPFHangerType=61;
                                                                                                                                                    USBLowBandKapperType=100;
                                                                                                                                                    USBHighBandKapperType=200;
                                                                                                                                                    USBLowBandKapperWithTrueDcType=101;
                                                                                                                                                    USBHighBandKapperWithTrueDcType=201;
                                                                                                                                                    PRDPhase1FLLASPSystem=300;

                                                                                                                                                    DefaultCalibrationGain=0.6e-9;
                                                                                                                                                    DefaultCalibrationOffset=0.0;
                                                                                                                                                    DeltaValue=1.0e-30;

                                                                                                                                                    ReferenceChannelMark=hex2dec('0100');
                                                                                                                                                    HangerSleepMode=hex2dec('0001');








                                                                                                                                                    for ch=1:sqf_sysinfo.channel_count
                                                                                                                                                        if(sqf_channel(ch).type<=0)||(abs(sqf_calib(ch).gain)<DeltaValue)
                                                                                                                                                            sqf_calib(ch).gain=DefaultCalibrationGain;
                                                                                                                                                            sqf_calib(ch).offset=DefaultCalibrationOffset;
                                                                                                                                                        end
                                                                                                                                                    end


                                                                                                                                                    for ch=1:sqf_sysinfo.channel_count
                                                                                                                                                        sqf_calib(ch).offset=DefaultCalibrationOffset;
                                                                                                                                                    end



                                                                                                                                                    calib_data=sqf_calib;


                                                                                                                                                    afa_gain=0.0;
                                                                                                                                                    afa_count=0;
                                                                                                                                                    fll_unit_count=sqf_afa.FllUnitCount;

                                                                                                                                                    for k=0:fll_unit_count*MaxChannelInHangerUnit-1
                                                                                                                                                        ch=k+1;
                                                                                                                                                        if sqf_channel(ch).type>0
                                                                                                                                                            afa=sqf_afa.afa_list(floor(k/MaxChannelInHangerUnit)+1);
                                                                                                                                                            if FllIsUSBKapperType(sqf_sysinfo.fll_type)
                                                                                                                                                                gain=DecodeKapperGain1(afa)*DecodeKapperGain2(afa)*DecodeKapperGain3(afa);
                                                                                                                                                            elseif sqf_sysinfo.fll_type==PRDPhase1FLLASPSystem
                                                                                                                                                                gain=DecodePRDPhase1FLLASPGain1(afa)*DecodePRDPhase1FLLASPGain2(afa)*DecodePRDPhase1FLLASPGain3(afa);
                                                                                                                                                            else
                                                                                                                                                                gain=DecodeInputGain(afa)*DecodeOutputGain(afa);
                                                                                                                                                            end
                                                                                                                                                            calib_data(ch).gain=calib_data(ch).gain/gain;
                                                                                                                                                            afa_gain=afa_gain+gain;
                                                                                                                                                            afa_count=afa_count+1;
                                                                                                                                                        end
                                                                                                                                                        if ch>=sqf_sysinfo.channel_count
                                                                                                                                                            break;
                                                                                                                                                        end
                                                                                                                                                    end
                                                                                                                                                    if afa_count>0
                                                                                                                                                        afa_gain=afa_gain/afa_count;
                                                                                                                                                    else
                                                                                                                                                        afa_gain=1.0;
                                                                                                                                                    end


                                                                                                                                                    for ii=1:fll_unit_count
                                                                                                                                                        afa=sqf_afa.afa_list(ii);
                                                                                                                                                        if FllIsUSBKapperType(sqf_sysinfo.fll_type)
                                                                                                                                                            gain=DecodeKapperGain1(afa)*DecodeKapperGain2(afa)*DecodeKapperGain3(afa);
                                                                                                                                                        elseif sqf_sysinfo.fll_type==PRDPhase1FLLASPSystem
                                                                                                                                                            gain=DecodePRDPhase1FLLASPGain1(afa)*DecodePRDPhase1FLLASPGain2(afa)*DecodePRDPhase1FLLASPGain3(afa);
                                                                                                                                                        else
                                                                                                                                                            gain=DecodeInputGain(afa)*DecodeOutputGain(afa);
                                                                                                                                                        end
                                                                                                                                                        fllasp(ii).gain=gain;
                                                                                                                                                    end


                                                                                                                                                    for ch=1:sqf_sysinfo.channel_count
                                                                                                                                                        if(sqf_channel(ch).type<=0)||(abs(sqf_calib(ch).gain)<DeltaValue)
                                                                                                                                                            calib_data(ch).gain=DefaultCalibrationGain./afa_gain;
                                                                                                                                                            calib_data(ch).offset=DefaultCalibrationOffset;
                                                                                                                                                        end
                                                                                                                                                    end


                                                                                                                                                    out.calib_list=sqf_calib;
                                                                                                                                                    out.calib_data=calib_data;
                                                                                                                                                    out.fllasp=fllasp;














                                                                                                                                                    function out=GetSqfFLL(fid)

















                                                                                                                                                        try
                                                                                                                                                            function_revision=0;
                                                                                                                                                            function_name='GetSqfFLL';



                                                                                                                                                            out=[];


                                                                                                                                                            if nargin~=1
                                                                                                                                                                disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                                                return;
                                                                                                                                                            end


                                                                                                                                                            sqf_slot=GetSqfConstantsDirectory;
                                                                                                                                                            if isempty(sqf_slot)
                                                                                                                                                                return;
                                                                                                                                                            end




                                                                                                                                                            HangerSleepMode=hex2dec('0001');



                                                                                                                                                            direc=GetSqfDirectory(fid,sqf_slot.SqfFLLSlot,function_name);
                                                                                                                                                            if isempty(direc)
                                                                                                                                                                disp(['ERROR ( ',function_name,' ): This file is not Meg160 format!!']);
                                                                                                                                                                return;
                                                                                                                                                            end


                                                                                                                                                            sqf_fll=[];


                                                                                                                                                            fseek(fid,direc.offset,'bof');



                                                                                                                                                            for ch=1:direc.count

                                                                                                                                                                fseek(fid,direc.offset+direc.size*(ch-1),'bof');


                                                                                                                                                                sqf_fll(ch).mode2=fread(fid,1,'uchar');
                                                                                                                                                                sqf_fll(ch).reference=fread(fid,1,'uchar');
                                                                                                                                                                sqf_fll(ch).control=fread(fid,1,'int16');
                                                                                                                                                                sqf_fll(ch).Voffset=fread(fid,1,'int32');

                                                                                                                                                                sqf_fll(ch).Ibias=fread(fid,1,'int32');
                                                                                                                                                            end


                                                                                                                                                            fseek(fid,0,'bof');


                                                                                                                                                            out=sqf_fll;
                                                                                                                                                        catch





                                                                                                                                                            str_error_message=sprintf('Exception : Sorry, reading error was occurred. (fll)');
                                                                                                                                                            disp(str_error_message);
                                                                                                                                                            return;
                                                                                                                                                        end














                                                                                                                                                        function out=GetSqfAFA(varargin)



















                                                                                                                                                            try
                                                                                                                                                                function_revision=1;
                                                                                                                                                                function_name='GetSqfAFA';



                                                                                                                                                                out=[];


                                                                                                                                                                if nargin>=5
                                                                                                                                                                    disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                                                    return;
                                                                                                                                                                end
                                                                                                                                                                if nargin>=1
                                                                                                                                                                    fid=varargin{1};
                                                                                                                                                                else
                                                                                                                                                                    disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                                                    return;
                                                                                                                                                                end
                                                                                                                                                                if nargin>=2
                                                                                                                                                                    sqf_sysinfo=varargin{2};
                                                                                                                                                                    if~(isfield(sqf_sysinfo,'system_id')&isfield(sqf_sysinfo,'channel_count'))
                                                                                                                                                                        sqf_sysinfo=GetSqfSystemInfo(fid);
                                                                                                                                                                    end
                                                                                                                                                                else
                                                                                                                                                                    sqf_sysinfo=GetSqfSystemInfo(fid);
                                                                                                                                                                end
                                                                                                                                                                if nargin>=3
                                                                                                                                                                    sqf_channel=varargin{3};
                                                                                                                                                                    if~(isfield(sqf_channel,'type')&isfield(sqf_channel,'data'))
                                                                                                                                                                        sqf_channel=GetSqfChannel(fid,sqf_sysinfo);
                                                                                                                                                                    end
                                                                                                                                                                else
                                                                                                                                                                    sqf_channel=GetSqfChannel(fid,sqf_sysinfo);
                                                                                                                                                                end
                                                                                                                                                                if nargin>=4
                                                                                                                                                                    sqf_fll=varargin{4};
                                                                                                                                                                    if~isfield(sqf_fll,'mode2')
                                                                                                                                                                        sqf_fll=GetSqfFLL(fid);
                                                                                                                                                                    end
                                                                                                                                                                else
                                                                                                                                                                    sqf_fll=GetSqfFLL(fid);
                                                                                                                                                                end


                                                                                                                                                                sqf_slot=GetSqfConstantsDirectory;
                                                                                                                                                                if isempty(sqf_slot)
                                                                                                                                                                    return;
                                                                                                                                                                end


                                                                                                                                                                direc=GetSqfDirectory(fid,sqf_slot.SqfAFASlot,function_name);
                                                                                                                                                                if isempty(direc)
                                                                                                                                                                    disp(['ERROR ( ',function_name,' ): This file is not Meg160 format!!']);
                                                                                                                                                                    return;
                                                                                                                                                                end



                                                                                                                                                                fseek(fid,direc.offset,'bof');


                                                                                                                                                                for no=1:direc.count
                                                                                                                                                                    fseek(fid,direc.offset+direc.size*(no-1),'bof');
                                                                                                                                                                    afa_list(no)=fread(fid,1,'int32');
                                                                                                                                                                end


                                                                                                                                                                fseek(fid,0,'bof');


                                                                                                                                                                out.afa_list=afa_list;
                                                                                                                                                                out.FllUnitCount=direc.count;

                                                                                                                                                            catch





                                                                                                                                                                str_error_message=sprintf('Exception : Sorry, reading error was occurred. (amp gain)');
                                                                                                                                                                disp(str_error_message);
                                                                                                                                                                return;
                                                                                                                                                            end


                                                                                                                                                            function torf=FllIsUSBKapperType(fll_type)

                                                                                                                                                                torf=false;


                                                                                                                                                                if nargin~=1
                                                                                                                                                                    disp(['ERROR : Arguments is illegal !!']);
                                                                                                                                                                    return;
                                                                                                                                                                end

                                                                                                                                                                if(fll_type>=100)&&(fll_type<=299)
                                                                                                                                                                    torf=true;
                                                                                                                                                                end


                                                                                                                                                                function gain=DecodeKapperGain1(afa)








                                                                                                                                                                    gain=[];


                                                                                                                                                                    if nargin~=1
                                                                                                                                                                        disp(['ERROR : Arguments is illegal !!']);
                                                                                                                                                                        return;
                                                                                                                                                                    end

                                                                                                                                                                    KapperGain1Bit=12;
                                                                                                                                                                    KapperGain1Mask=hex2dec('00007000');

                                                                                                                                                                    gain_table=[1.0,2.0,5.0,10.0,20.0,50.0,100.0,200.0];
                                                                                                                                                                    gain=gain_table(bitshift(bitand(afa,KapperGain1Mask),-KapperGain1Bit)+1);


                                                                                                                                                                    function gain=DecodeKapperGain2(afa)








                                                                                                                                                                        gain=[];


                                                                                                                                                                        if nargin~=1
                                                                                                                                                                            disp(['ERROR : Arguments is illegal !!']);
                                                                                                                                                                            return;
                                                                                                                                                                        end

                                                                                                                                                                        KapperGain2Bit=28;
                                                                                                                                                                        KapperGain2Mask=hex2dec('70000000');

                                                                                                                                                                        gain_table=[1.0,2.0,5.0,10.0,20.0,50.0,100.0,200.0];
                                                                                                                                                                        gain=gain_table(bitshift(bitand(afa,KapperGain2Mask),-KapperGain2Bit)+1);


                                                                                                                                                                        function gain=DecodeKapperGain3(afa)








                                                                                                                                                                            gain=[];


                                                                                                                                                                            if nargin~=1
                                                                                                                                                                                disp(['ERROR : Arguments is illegal !!']);
                                                                                                                                                                                return;
                                                                                                                                                                            end

                                                                                                                                                                            KapperGain3Bit=24;
                                                                                                                                                                            KapperGain3Mask=hex2dec('07000000');

                                                                                                                                                                            gain_table=[1.0,2.0,5.0,10.0,20.0,50.0,100.0,200.0];
                                                                                                                                                                            gain=gain_table(bitshift(bitand(afa,KapperGain3Mask),-KapperGain3Bit)+1);


                                                                                                                                                                            function gain=DecodePRDPhase1FLLASPGain1(afa)








                                                                                                                                                                                gain=[];


                                                                                                                                                                                if nargin~=1
                                                                                                                                                                                    disp(['ERROR : Arguments is illegal !!']);
                                                                                                                                                                                    return;
                                                                                                                                                                                end

                                                                                                                                                                                KapperGain1Bit=12;
                                                                                                                                                                                KapperGain1Mask=hex2dec('00007000');

                                                                                                                                                                                gain_table=[1.0,2.0,5.0,10.0,20.0,50.0,100.0,200.0];
                                                                                                                                                                                gain=gain_table(bitshift(bitand(afa,KapperGain1Mask),-KapperGain1Bit)+1);


                                                                                                                                                                                function gain=DecodePRDPhase1FLLASPGain2(afa)








                                                                                                                                                                                    gain=[];


                                                                                                                                                                                    if nargin~=1
                                                                                                                                                                                        disp(['ERROR : Arguments is illegal !!']);
                                                                                                                                                                                        return;
                                                                                                                                                                                    end

                                                                                                                                                                                    KapperGain2Bit=28;
                                                                                                                                                                                    KapperGain2Mask=hex2dec('70000000');

                                                                                                                                                                                    gain_table=[1.0,2.0,5.0,10.0,20.0,50.0,100.0,200.0];
                                                                                                                                                                                    gain=gain_table(bitshift(bitand(afa,KapperGain2Mask),-KapperGain2Bit)+1);


                                                                                                                                                                                    function gain=DecodePRDPhase1FLLASPGain3(afa)








                                                                                                                                                                                        gain=[];


                                                                                                                                                                                        if nargin~=1
                                                                                                                                                                                            disp(['ERROR : Arguments is illegal !!']);
                                                                                                                                                                                            return;
                                                                                                                                                                                        end

                                                                                                                                                                                        KapperGain3Bit=24;
                                                                                                                                                                                        KapperGain3Mask=hex2dec('07000000');

                                                                                                                                                                                        gain_table=[1.0,2.0,5.0,10.0,20.0,50.0,100.0,200.0];
                                                                                                                                                                                        gain=gain_table(bitshift(bitand(afa,KapperGain3Mask),-KapperGain3Bit)+1);


                                                                                                                                                                                        function gain=DecodeInputGain(afa)








                                                                                                                                                                                            gain=[];


                                                                                                                                                                                            if nargin~=1
                                                                                                                                                                                                disp(['ERROR : Arguments is illegal !!']);
                                                                                                                                                                                                return;
                                                                                                                                                                                            end

                                                                                                                                                                                            HangerIgainBit=11;
                                                                                                                                                                                            HangerIgainMask=hex2dec('1800');

                                                                                                                                                                                            gain_table=[1.0,2.0,5.0,10.0];
                                                                                                                                                                                            gain=gain_table(bitshift(bitand(afa,HangerIgainMask),-HangerIgainBit)+1);


                                                                                                                                                                                            function gain=DecodeOutputGain(afa)








                                                                                                                                                                                                gain=[];


                                                                                                                                                                                                if nargin~=1
                                                                                                                                                                                                    disp(['ERROR : Arguments is illegal !!']);
                                                                                                                                                                                                    return;
                                                                                                                                                                                                end

                                                                                                                                                                                                HangerOgainBit=0;
                                                                                                                                                                                                HangerOgainMask=hex2dec('0007');

                                                                                                                                                                                                gain_table=[1.0,2.0,5.0,10.0,20.0,50.0,100.0,200.0];
                                                                                                                                                                                                gain=gain_table(bitshift(bitand(afa,HangerOgainMask),-HangerOgainBit)+1);












                                                                                                                                                                                                function out=GetSqfAcqCondition(varargin)



































































                                                                                                                                                                                                    try
                                                                                                                                                                                                        function_revision=0;
                                                                                                                                                                                                        function_name='GetSqfAcqCondition';




                                                                                                                                                                                                        flag_branch_by_sizeof=true;



                                                                                                                                                                                                        out=[];


                                                                                                                                                                                                        if nargin>=4
                                                                                                                                                                                                            disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                                                                                            return;
                                                                                                                                                                                                        end
                                                                                                                                                                                                        if nargin>=1
                                                                                                                                                                                                            fid=varargin{1};
                                                                                                                                                                                                        else
                                                                                                                                                                                                            disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                                                                                            return;
                                                                                                                                                                                                        end
                                                                                                                                                                                                        if nargin>=2
                                                                                                                                                                                                            sqf_sysinfo=varargin{2};
                                                                                                                                                                                                            if~(isfield(sqf_sysinfo,'system_id')&isfield(sqf_sysinfo,'channel_count'))
                                                                                                                                                                                                                sqf_sysinfo=GetSqfSystemInfo(fid);
                                                                                                                                                                                                            end
                                                                                                                                                                                                        else
                                                                                                                                                                                                            sqf_sysinfo=GetSqfSystemInfo(fid);
                                                                                                                                                                                                        end
                                                                                                                                                                                                        if nargin>=3
                                                                                                                                                                                                            sqf_channel=varargin{3};
                                                                                                                                                                                                            if~(isfield(sqf_channel,'type')&isfield(sqf_channel,'data'))
                                                                                                                                                                                                                sqf_channel=GetSqfChannel(fid,sqf_sysinfo);
                                                                                                                                                                                                            end
                                                                                                                                                                                                        else
                                                                                                                                                                                                            sqf_channel=GetSqfChannel(fid,sqf_sysinfo);
                                                                                                                                                                                                        end


                                                                                                                                                                                                        sqf_slot=GetSqfConstantsDirectory;
                                                                                                                                                                                                        if isempty(sqf_slot)
                                                                                                                                                                                                            return;
                                                                                                                                                                                                        end
















































                                                                                                                                                                                                        ContinuousRawDataAcquisition=1;
                                                                                                                                                                                                        EvokedAverageDataAcquisition=2;
                                                                                                                                                                                                        EvokedRawDataAcquisition=3;
                                                                                                                                                                                                        VarianceDataAcquisition=8;
                                                                                                                                                                                                        MarkerDataAcquisition=9;
                                                                                                                                                                                                        EvokedBothDataAcquisition=10;
                                                                                                                                                                                                        MarkerDataShotAcquisition=19;
                                                                                                                                                                                                        AllDataAcquisition=999;
                                                                                                                                                                                                        NoDataAcquisition=-1;








                                                                                                                                                                                                        MagneticFieldUnitData=0;
                                                                                                                                                                                                        NoUnitData=-1;


                                                                                                                                                                                                        SizeOfSqfAcqCondition1=76;
                                                                                                                                                                                                        SizeOfSqfAcqCondition2=21580;
                                                                                                                                                                                                        SizeOfSqfAcqCondition3=35408;
                                                                                                                                                                                                        SizeOfSqfAcqCondition4=35420;
                                                                                                                                                                                                        SizeOfSqfAcqCondition5=35428;
                                                                                                                                                                                                        SizeOfSqfAcqCondition=35428;

                                                                                                                                                                                                        SizeOfSystemInfo1=272;
                                                                                                                                                                                                        SizeOfSystemInfo2=536;
                                                                                                                                                                                                        SizeOfSystemInfo3=700;
                                                                                                                                                                                                        SizeOfSystemInfo4=732;
                                                                                                                                                                                                        SizeOfSystemInfo=1248;


                                                                                                                                                                                                        direc=GetSqfDirectory(fid,sqf_slot.SqfAcqConditionSlot,function_name);
                                                                                                                                                                                                        if isempty(direc)
                                                                                                                                                                                                            disp(['ERROR ( ',function_name,' ): This file is not Meg160 format!!']);
                                                                                                                                                                                                            return;
                                                                                                                                                                                                        end
                                                                                                                                                                                                        sysinfo_direc=GetSqfDirectory(fid,sqf_slot.SqfSystemInfoSlot,function_name);







                                                                                                                                                                                                        fseek(fid,direc.offset,'bof');


                                                                                                                                                                                                        acq_type=fread(fid,1,'int16');
                                                                                                                                                                                                        acq_unit=fread(fid,1,'int16');


                                                                                                                                                                                                        switch acq_type
                                                                                                                                                                                                        case ContinuousRawDataAcquisition


                                                                                                                                                                                                        case EvokedAverageDataAcquisition


                                                                                                                                                                                                        case EvokedRawDataAcquisition


                                                                                                                                                                                                        otherwise

                                                                                                                                                                                                            disp(['ERROR ( ',function_name,' ): Unknown acq type.']);
                                                                                                                                                                                                            return;
                                                                                                                                                                                                        end
                                                                                                                                                                                                        switch acq_unit
                                                                                                                                                                                                        case MagneticFieldUnitData

                                                                                                                                                                                                        case NoUnitData

                                                                                                                                                                                                        otherwise

                                                                                                                                                                                                            disp(['ERROR ( ',function_name,' ): Unknown acq unit.']);
                                                                                                                                                                                                            return;
                                                                                                                                                                                                        end

                                                                                                                                                                                                        if~flag_branch_by_sizeof



                                                                                                                                                                                                            if(sqf_sysinfo.version==0)&&(sqf_sysinfo.revision<=119)
                                                                                                                                                                                                                if acq_type==ContinuousRawDataAcquisition
                                                                                                                                                                                                                    rtn=GetSqfRawAcqCondition1(fid);
                                                                                                                                                                                                                elseif(acq_type==EvokedAverageDataAcquisition)||(acq_type==EvokedRawDataAcquisition)
                                                                                                                                                                                                                    rtn=GetSqfAveAcqCondition1(fid);
                                                                                                                                                                                                                end
                                                                                                                                                                                                            elseif(sqf_sysinfo.version==0)&&(sqf_sysinfo.revision<=126)
                                                                                                                                                                                                                if acq_type==ContinuousRawDataAcquisition
                                                                                                                                                                                                                    rtn=GetSqfRawAcqCondition1(fid);
                                                                                                                                                                                                                elseif(acq_type==EvokedAverageDataAcquisition)||(acq_type==EvokedRawDataAcquisition)
                                                                                                                                                                                                                    rtn=GetSqfAveAcqCondition2(fid);
                                                                                                                                                                                                                end
                                                                                                                                                                                                            elseif(sqf_sysinfo.version==0&&sqf_sysinfo.revision<=127)||(sqf_sysinfo.version==1&&sqf_sysinfo.revision<=3)
                                                                                                                                                                                                                if acq_type==ContinuousRawDataAcquisition
                                                                                                                                                                                                                    rtn=GetSqfRawAcqCondition1(fid);
                                                                                                                                                                                                                elseif(acq_type==EvokedAverageDataAcquisition)||(acq_type==EvokedRawDataAcquisition)
                                                                                                                                                                                                                    rtn=GetSqfAveAcqCondition3(fid);
                                                                                                                                                                                                                end
                                                                                                                                                                                                            elseif(sqf_sysinfo.version==1&&sqf_sysinfo.revision<=7)||(sqf_sysinfo.version==2&&sqf_sysinfo.revision<=3)
                                                                                                                                                                                                                if acq_type==ContinuousRawDataAcquisition
                                                                                                                                                                                                                    rtn=GetSqfRawAcqCondition1(fid);
                                                                                                                                                                                                                elseif(acq_type==EvokedAverageDataAcquisition)||(acq_type==EvokedRawDataAcquisition)
                                                                                                                                                                                                                    rtn=GetSqfAveAcqCondition4(fid);
                                                                                                                                                                                                                end
                                                                                                                                                                                                            else

                                                                                                                                                                                                                if acq_type==ContinuousRawDataAcquisition
                                                                                                                                                                                                                    rtn=GetSqfRawAcqCondition(fid);
                                                                                                                                                                                                                elseif(acq_type==EvokedAverageDataAcquisition)||(acq_type==EvokedRawDataAcquisition)
                                                                                                                                                                                                                    rtn=GetSqfAveAcqCondition(fid);
                                                                                                                                                                                                                end
                                                                                                                                                                                                            end

                                                                                                                                                                                                        else

                                                                                                                                                                                                            switch direc.size
                                                                                                                                                                                                            case SizeOfSqfAcqCondition1
                                                                                                                                                                                                                if acq_type==ContinuousRawDataAcquisition
                                                                                                                                                                                                                    rtn=GetSqfRawAcqCondition1(fid);
                                                                                                                                                                                                                elseif(acq_type==EvokedAverageDataAcquisition)||(acq_type==EvokedRawDataAcquisition)
                                                                                                                                                                                                                    rtn=GetSqfAveAcqCondition1(fid);
                                                                                                                                                                                                                end
                                                                                                                                                                                                            case SizeOfSqfAcqCondition2
                                                                                                                                                                                                                if acq_type==ContinuousRawDataAcquisition
                                                                                                                                                                                                                    rtn=GetSqfRawAcqCondition1(fid);
                                                                                                                                                                                                                elseif(acq_type==EvokedAverageDataAcquisition)||(acq_type==EvokedRawDataAcquisition)
                                                                                                                                                                                                                    rtn=GetSqfAveAcqCondition2(fid);
                                                                                                                                                                                                                end
                                                                                                                                                                                                            case SizeOfSqfAcqCondition3
                                                                                                                                                                                                                if acq_type==ContinuousRawDataAcquisition
                                                                                                                                                                                                                    rtn=GetSqfRawAcqCondition1(fid);
                                                                                                                                                                                                                elseif(acq_type==EvokedAverageDataAcquisition)||(acq_type==EvokedRawDataAcquisition)
                                                                                                                                                                                                                    rtn=GetSqfAveAcqCondition3(fid);
                                                                                                                                                                                                                end
                                                                                                                                                                                                            case SizeOfSqfAcqCondition4
                                                                                                                                                                                                                if acq_type==ContinuousRawDataAcquisition
                                                                                                                                                                                                                    rtn=GetSqfRawAcqCondition1(fid);
                                                                                                                                                                                                                elseif(acq_type==EvokedAverageDataAcquisition)||(acq_type==EvokedRawDataAcquisition)
                                                                                                                                                                                                                    rtn=GetSqfAveAcqCondition4(fid);
                                                                                                                                                                                                                end
                                                                                                                                                                                                            case SizeOfSqfAcqCondition
                                                                                                                                                                                                                if acq_type==ContinuousRawDataAcquisition
                                                                                                                                                                                                                    switch sysinfo_direc.size
                                                                                                                                                                                                                    case SizeOfSystemInfo4
                                                                                                                                                                                                                        rtn=GetSqfRawAcqCondition2(fid);
                                                                                                                                                                                                                    case SizeOfSystemInfo
                                                                                                                                                                                                                        rtn=GetSqfRawAcqCondition(fid);
                                                                                                                                                                                                                    otherwise

                                                                                                                                                                                                                        disp(['ERROR ( ',function_name,' ): Unknown acq condition and system info size.']);
                                                                                                                                                                                                                        return;
                                                                                                                                                                                                                    end
                                                                                                                                                                                                                elseif(acq_type==EvokedAverageDataAcquisition)||(acq_type==EvokedRawDataAcquisition)
                                                                                                                                                                                                                    rtn=GetSqfAveAcqCondition(fid);
                                                                                                                                                                                                                end
                                                                                                                                                                                                            otherwise

                                                                                                                                                                                                                disp(['ERROR ( ',function_name,' ): Unknown acq condition size.']);
                                                                                                                                                                                                                return;
                                                                                                                                                                                                            end
                                                                                                                                                                                                        end


                                                                                                                                                                                                        fseek(fid,0,'bof');


                                                                                                                                                                                                        out=rtn;

                                                                                                                                                                                                        out.acq_type=acq_type;
                                                                                                                                                                                                        out.acq_unit=acq_unit;

                                                                                                                                                                                                    catch





                                                                                                                                                                                                        str_error_message=sprintf('Exception : Sorry, reading error was occurred. (acq conditon)');
                                                                                                                                                                                                        disp(str_error_message);
                                                                                                                                                                                                        return;
                                                                                                                                                                                                    end



                                                                                                                                                                                                    function rtn=GetSqfRawAcqCondition(fid)



















































































                                                                                                                                                                                                        rtn=[];
                                                                                                                                                                                                        if nargin~=1
                                                                                                                                                                                                            disp(['ERROR Arguments is illegal !!']);
                                                                                                                                                                                                            return;
                                                                                                                                                                                                        end

                                                                                                                                                                                                        rtn.sample_rate=fread(fid,1,'double');
                                                                                                                                                                                                        rtn.sample_count=fread(fid,1,'int32');
                                                                                                                                                                                                        rtn.actual_count=fread(fid,1,'int32');
                                                                                                                                                                                                        rtn.trigger_mode=fread(fid,1,'int32');
                                                                                                                                                                                                        rtn.internal_trigger_interval=fread(fid,1,'double');
                                                                                                                                                                                                        rtn.internal_trigger_random=fread(fid,1,'double');
                                                                                                                                                                                                        rtn.multi_trigger=fread(fid,1,'int32');
                                                                                                                                                                                                        rtn.multi_trigger_count=fread(fid,1,'int32');
                                                                                                                                                                                                        rtn.multi_trigger_list=GetSqfMultiTrigger(fid);


                                                                                                                                                                                                        function rtn=GetSqfRawAcqCondition2(fid)














                                                                                                                                                                                                            rtn=[];
                                                                                                                                                                                                            if nargin~=1
                                                                                                                                                                                                                disp(['ERROR Arguments is illegal !!']);
                                                                                                                                                                                                                return;
                                                                                                                                                                                                            end



                                                                                                                                                                                                            NoTriggerMode=0;
                                                                                                                                                                                                            InternalTriggerMode=1;
                                                                                                                                                                                                            ExternalTriggerMode=2;
                                                                                                                                                                                                            AnalogChannelTriggerMode=3;
                                                                                                                                                                                                            MarkerTriggerMode=4;









                                                                                                                                                                                                            MaxMaxChannelCount=1024;
                                                                                                                                                                                                            MaxMultiTriggerCount=256;
                                                                                                                                                                                                            ActualMultiTriggerCount=64;
                                                                                                                                                                                                            MaxMultiTriggerSignalNameLength=32;
                                                                                                                                                                                                            MultiTriggerAttributeRare=hex2dec('00000003');


                                                                                                                                                                                                            tmp.sample_rate=fread(fid,1,'double');
                                                                                                                                                                                                            tmp.sample_count=fread(fid,1,'int32');
                                                                                                                                                                                                            tmp.actual_count=fread(fid,1,'int32');
                                                                                                                                                                                                            tmp.trigger_mode=fread(fid,1,'int32');
                                                                                                                                                                                                            tmp.internal_trigger_interval=fread(fid,1,'double');
                                                                                                                                                                                                            tmp.internal_trigger_random=fread(fid,1,'double');


                                                                                                                                                                                                            rtn.sample_rate=tmp.sample_rate;
                                                                                                                                                                                                            rtn.sample_count=tmp.sample_count;
                                                                                                                                                                                                            rtn.actual_count=tmp.actual_count;
                                                                                                                                                                                                            rtn.trigger_mode=tmp.trigger_mode;
                                                                                                                                                                                                            rtn.internal_trigger_interval=tmp.internal_trigger_interval;
                                                                                                                                                                                                            rtn.internal_trigger_random=tmp.internal_trigger_random;
                                                                                                                                                                                                            rtn.multi_trigger=false;
                                                                                                                                                                                                            rtn.multi_trigger_count=0;
                                                                                                                                                                                                            for ii=1:MaxMultiTriggerCount
                                                                                                                                                                                                                rtn.multi_trigger_list(ii).enable=0;
                                                                                                                                                                                                                rtn.multi_trigger_list(ii).attrib=0;
                                                                                                                                                                                                                rtn.multi_trigger_list(ii).status=0;
                                                                                                                                                                                                                rtn.multi_trigger_list(ii).event_code=0;
                                                                                                                                                                                                                rtn.multi_trigger_list(ii).name='';
                                                                                                                                                                                                                rtn.multi_trigger_list(ii).average_count=0;
                                                                                                                                                                                                                rtn.multi_trigger_list(ii).actual_count=0;
                                                                                                                                                                                                            end


                                                                                                                                                                                                            function rtn=GetSqfRawAcqCondition1(fid)











                                                                                                                                                                                                                rtn=[];
                                                                                                                                                                                                                if nargin~=1
                                                                                                                                                                                                                    disp(['ERROR Arguments is illegal !!']);
                                                                                                                                                                                                                    return;
                                                                                                                                                                                                                end



                                                                                                                                                                                                                NoTriggerMode=0;
                                                                                                                                                                                                                InternalTriggerMode=1;
                                                                                                                                                                                                                ExternalTriggerMode=2;
                                                                                                                                                                                                                AnalogChannelTriggerMode=3;
                                                                                                                                                                                                                MarkerTriggerMode=4;









                                                                                                                                                                                                                MaxMaxChannelCount=1024;
                                                                                                                                                                                                                MaxMultiTriggerCount=256;
                                                                                                                                                                                                                ActualMultiTriggerCount=64;
                                                                                                                                                                                                                MaxMultiTriggerSignalNameLength=32;
                                                                                                                                                                                                                MultiTriggerAttributeRare=hex2dec('00000003');


                                                                                                                                                                                                                tmp.sample_rate=fread(fid,1,'double');
                                                                                                                                                                                                                tmp.sample_count=fread(fid,1,'int32');
                                                                                                                                                                                                                tmp.actual_count=fread(fid,1,'int32');


                                                                                                                                                                                                                rtn.sample_rate=tmp.sample_rate;
                                                                                                                                                                                                                rtn.sample_count=tmp.sample_count;
                                                                                                                                                                                                                rtn.actual_count=tmp.actual_count;
                                                                                                                                                                                                                rtn.trigger_mode=NoTriggerMode;
                                                                                                                                                                                                                rtn.internal_trigger_interval=1.0;
                                                                                                                                                                                                                rtn.internal_trigger_random=0.0;
                                                                                                                                                                                                                rtn.multi_trigger=false;
                                                                                                                                                                                                                rtn.multi_trigger_count=0;
                                                                                                                                                                                                                for ii=1:MaxMultiTriggerCount
                                                                                                                                                                                                                    rtn.multi_trigger_list(ii).enable=0;
                                                                                                                                                                                                                    rtn.multi_trigger_list(ii).attrib=0;
                                                                                                                                                                                                                    rtn.multi_trigger_list(ii).status=0;
                                                                                                                                                                                                                    rtn.multi_trigger_list(ii).event_code=0;
                                                                                                                                                                                                                    rtn.multi_trigger_list(ii).name='';
                                                                                                                                                                                                                    rtn.multi_trigger_list(ii).average_count=0;
                                                                                                                                                                                                                    rtn.multi_trigger_list(ii).actual_count=0;
                                                                                                                                                                                                                end


                                                                                                                                                                                                                function rtn=GetSqfAveAcqCondition(fid)






















































































































































































                                                                                                                                                                                                                    rtn=[];
                                                                                                                                                                                                                    if nargin~=1
                                                                                                                                                                                                                        disp(['ERROR Arguments is illegal !!']);
                                                                                                                                                                                                                        return;
                                                                                                                                                                                                                    end

                                                                                                                                                                                                                    rtn.sample_rate=fread(fid,1,'double');
                                                                                                                                                                                                                    rtn.frame_length=fread(fid,1,'int32');
                                                                                                                                                                                                                    rtn.pretrigger_length=fread(fid,1,'int32');
                                                                                                                                                                                                                    rtn.average_count=fread(fid,1,'int32');
                                                                                                                                                                                                                    rtn.actual_count=fread(fid,1,'int32');
                                                                                                                                                                                                                    rtn.reject_count=fread(fid,1,'int32');
                                                                                                                                                                                                                    rtn.level_rejection=fread(fid,1,'int32');
                                                                                                                                                                                                                    rtn.level_rejection_level=GetSqfLevelRejection(fid);
                                                                                                                                                                                                                    rtn.level_rejection_void=fread(fid,1,'int32');
                                                                                                                                                                                                                    rtn.level_rejection_void_start=fread(fid,1,'int32');
                                                                                                                                                                                                                    rtn.level_rejection_void_end=fread(fid,1,'int32');
                                                                                                                                                                                                                    rtn.trigger_mode=fread(fid,1,'int32');
                                                                                                                                                                                                                    rtn.internal_trigger_interval=fread(fid,1,'double');
                                                                                                                                                                                                                    rtn.internal_trigger_random=fread(fid,1,'double');
                                                                                                                                                                                                                    rtn.multi_trigger=fread(fid,1,'int32');
                                                                                                                                                                                                                    rtn.multi_trigger_count=fread(fid,1,'int32');
                                                                                                                                                                                                                    rtn.multi_trigger_list=GetSqfMultiTrigger(fid);
                                                                                                                                                                                                                    rtn.analog_trigger_channel=fread(fid,1,'int32');
                                                                                                                                                                                                                    rtn.analog_trigger_level=fread(fid,1,'double');
                                                                                                                                                                                                                    rtn.analog_trigger_hysteresis=fread(fid,1,'double');
                                                                                                                                                                                                                    rtn.analog_trigger_slope=fread(fid,1,'int32');


                                                                                                                                                                                                                    function rtn=GetSqfAveAcqCondition4(fid)





























                                                                                                                                                                                                                        rtn=[];
                                                                                                                                                                                                                        if nargin~=1
                                                                                                                                                                                                                            disp(['ERROR Arguments is illegal !!']);
                                                                                                                                                                                                                            return;
                                                                                                                                                                                                                        end




                                                                                                                                                                                                                        MaxMaxChannelCount=1024;





                                                                                                                                                                                                                        MaxMultiTriggerCount=256;
                                                                                                                                                                                                                        ActualMultiTriggerCount=64;
                                                                                                                                                                                                                        MaxMultiTriggerSignalNameLength=32;
                                                                                                                                                                                                                        MultiTriggerAttributeRare=hex2dec('00000003');


                                                                                                                                                                                                                        rtn.sample_rate=fread(fid,1,'double');
                                                                                                                                                                                                                        rtn.frame_length=fread(fid,1,'int32');
                                                                                                                                                                                                                        rtn.pretrigger_length=fread(fid,1,'int32');
                                                                                                                                                                                                                        rtn.average_count=fread(fid,1,'int32');
                                                                                                                                                                                                                        rtn.actual_count=fread(fid,1,'int32');
                                                                                                                                                                                                                        rtn.reject_count=fread(fid,1,'int32');
                                                                                                                                                                                                                        rtn.level_rejection=fread(fid,1,'int32');
                                                                                                                                                                                                                        rtn.level_rejection_level=GetSqfLevelRejection(fid);
                                                                                                                                                                                                                        rtn.level_rejection_void=fread(fid,1,'int32');
                                                                                                                                                                                                                        rtn.level_rejection_void_start=fread(fid,1,'int32');
                                                                                                                                                                                                                        rtn.level_rejection_void_end=fread(fid,1,'int32');
                                                                                                                                                                                                                        rtn.trigger_mode=fread(fid,1,'int32');
                                                                                                                                                                                                                        rtn.internal_trigger_interval=fread(fid,1,'double');
                                                                                                                                                                                                                        rtn.internal_trigger_random=fread(fid,1,'double');
                                                                                                                                                                                                                        rtn.multi_trigger=fread(fid,1,'int32');
                                                                                                                                                                                                                        rtn.multi_trigger_count=fread(fid,1,'int32');
                                                                                                                                                                                                                        rtn.multi_trigger_list=GetSqfMultiTrigger(fid);
                                                                                                                                                                                                                        rtn.analog_trigger_channel=fread(fid,1,'int32');
                                                                                                                                                                                                                        rtn.analog_trigger_level=fread(fid,1,'double');
                                                                                                                                                                                                                        rtn.analog_trigger_hysteresis=0.0;
                                                                                                                                                                                                                        rtn.analog_trigger_slope=fread(fid,1,'int32');


                                                                                                                                                                                                                        function rtn=GetSqfAveAcqCondition3(fid)

                                                                                                                                                                                                                            rtn=[];
                                                                                                                                                                                                                            if nargin~=1
                                                                                                                                                                                                                                disp(['ERROR Arguments is illegal !!']);
                                                                                                                                                                                                                                return;
                                                                                                                                                                                                                            end




                                                                                                                                                                                                                            MaxMaxChannelCount=1024;





                                                                                                                                                                                                                            MaxMultiTriggerCount=256;
                                                                                                                                                                                                                            ActualMultiTriggerCount=64;
                                                                                                                                                                                                                            MaxMultiTriggerSignalNameLength=32;
                                                                                                                                                                                                                            MultiTriggerAttributeRare=hex2dec('00000003');


                                                                                                                                                                                                                            tmp.sample_rate=fread(fid,1,'double');
                                                                                                                                                                                                                            tmp.frame_length=fread(fid,1,'int32');
                                                                                                                                                                                                                            tmp.pretrigger_length=fread(fid,1,'int32');
                                                                                                                                                                                                                            tmp.average_count=fread(fid,1,'int32');
                                                                                                                                                                                                                            tmp.actual_count=fread(fid,1,'int32');
                                                                                                                                                                                                                            tmp.reject_count=fread(fid,1,'int32');
                                                                                                                                                                                                                            tmp.level_rejection=fread(fid,1,'int32');
                                                                                                                                                                                                                            tmp.level_rejection_level=GetSqfLevelRejection(fid);
                                                                                                                                                                                                                            tmp.trigger_mode=fread(fid,1,'int32');
                                                                                                                                                                                                                            tmp.internal_trigger_interval=fread(fid,1,'double');
                                                                                                                                                                                                                            tmp.internal_trigger_random=fread(fid,1,'double');
                                                                                                                                                                                                                            tmp.multi_trigger=fread(fid,1,'int32');
                                                                                                                                                                                                                            tmp.multi_trigger_count=fread(fid,1,'int32');
                                                                                                                                                                                                                            tmp.multi_trigger_list=GetSqfMultiTrigger(fid);
                                                                                                                                                                                                                            tmp.analog_trigger_channel=fread(fid,1,'int32');
                                                                                                                                                                                                                            tmp.analog_trigger_level=fread(fid,1,'double');
                                                                                                                                                                                                                            tmp.analog_trigger_slope=fread(fid,1,'int32');


                                                                                                                                                                                                                            rtn.sample_rate=tmp.sample_rate;
                                                                                                                                                                                                                            rtn.frame_length=tmp.frame_length;
                                                                                                                                                                                                                            rtn.pretrigger_length=tmp.pretrigger_length;
                                                                                                                                                                                                                            rtn.average_count=tmp.average_count;
                                                                                                                                                                                                                            rtn.actual_count=tmp.actual_count;
                                                                                                                                                                                                                            rtn.reject_count=tmp.reject_count;
                                                                                                                                                                                                                            rtn.level_rejection=tmp.level_rejection;
                                                                                                                                                                                                                            rtn.level_rejection_level=tmp.level_rejection_level;
                                                                                                                                                                                                                            rtn.level_rejection_void=false;
                                                                                                                                                                                                                            rtn.level_rejection_void_start=0;
                                                                                                                                                                                                                            rtn.level_rejection_void_end=0;
                                                                                                                                                                                                                            rtn.trigger_mode=tmp.trigger_mode;
                                                                                                                                                                                                                            rtn.internal_trigger_interval=tmp.internal_trigger_interval;
                                                                                                                                                                                                                            rtn.internal_trigger_random=tmp.internal_trigger_random;
                                                                                                                                                                                                                            rtn.multi_trigger=tmp.multi_trigger;
                                                                                                                                                                                                                            rtn.multi_trigger_count=tmp.multi_trigger_count;
                                                                                                                                                                                                                            rtn.multi_trigger_list=tmp.multi_trigger_list;
                                                                                                                                                                                                                            rtn.analog_trigger_channel=tmp.analog_trigger_channel;
                                                                                                                                                                                                                            rtn.analog_trigger_level=tmp.analog_trigger_level;
                                                                                                                                                                                                                            rtn.analog_trigger_hysteresis=0.0;
                                                                                                                                                                                                                            rtn.analog_trigger_slope=tmp.analog_trigger_slope;



                                                                                                                                                                                                                            function rtn=GetSqfAveAcqCondition2(fid)
























                                                                                                                                                                                                                                rtn=[];
                                                                                                                                                                                                                                if nargin~=1
                                                                                                                                                                                                                                    disp(['ERROR Arguments is illegal !!']);
                                                                                                                                                                                                                                    return;
                                                                                                                                                                                                                                end





                                                                                                                                                                                                                                MaxMaxChannelCount=1024;





                                                                                                                                                                                                                                MaxMultiTriggerCount=256;
                                                                                                                                                                                                                                ActualMultiTriggerCount=64;
                                                                                                                                                                                                                                MaxMultiTriggerSignalNameLength=32;
                                                                                                                                                                                                                                MultiTriggerAttributeRare=hex2dec('00000003');


                                                                                                                                                                                                                                tmp.sample_rate=fread(fid,1,'double');
                                                                                                                                                                                                                                tmp.frame_length=fread(fid,1,'int32');
                                                                                                                                                                                                                                tmp.pretrigger_length=fread(fid,1,'int32');
                                                                                                                                                                                                                                tmp.average_count=fread(fid,1,'int32');
                                                                                                                                                                                                                                tmp.actual_count=fread(fid,1,'int32');
                                                                                                                                                                                                                                tmp.reject_count=fread(fid,1,'int32');
                                                                                                                                                                                                                                tmp.level_rejection=fread(fid,1,'int32');
                                                                                                                                                                                                                                tmp.level_rejection_level=GetSqfLevelRejection(fid);
                                                                                                                                                                                                                                tmp.trigger_mode=fread(fid,1,'int32');
                                                                                                                                                                                                                                tmp.internal_trigger_interval=fread(fid,1,'double');
                                                                                                                                                                                                                                tmp.internal_trigger_random=fread(fid,1,'double');
                                                                                                                                                                                                                                tmp.multi_trigger_count=fread(fid,1,'int32');
                                                                                                                                                                                                                                for ii=1:MaxMultiTriggerCount
                                                                                                                                                                                                                                    tmp.multi_trigger_list(ii)=fread(fid,1,'int32');
                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                tmp.analog_trigger_channel=fread(fid,1,'int32');
                                                                                                                                                                                                                                tmp.analog_trigger_level=fread(fid,1,'double');
                                                                                                                                                                                                                                tmp.analog_trigger_slope=fread(fid,1,'int32');


                                                                                                                                                                                                                                rtn.sample_rate=tmp.sample_rate;
                                                                                                                                                                                                                                rtn.frame_length=tmp.frame_length;
                                                                                                                                                                                                                                rtn.pretrigger_length=tmp.pretrigger_length;
                                                                                                                                                                                                                                rtn.average_count=tmp.average_count;
                                                                                                                                                                                                                                rtn.actual_count=tmp.actual_count;
                                                                                                                                                                                                                                rtn.reject_count=tmp.reject_count;
                                                                                                                                                                                                                                rtn.level_rejection=tmp.level_rejection;
                                                                                                                                                                                                                                rtn.level_rejection_level=tmp.level_rejection_level;
                                                                                                                                                                                                                                rtn.level_rejection_void=false;
                                                                                                                                                                                                                                rtn.level_rejection_void_start=0;
                                                                                                                                                                                                                                rtn.level_rejection_void_end=0;
                                                                                                                                                                                                                                rtn.trigger_mode=tmp.trigger_mode;
                                                                                                                                                                                                                                rtn.internal_trigger_interval=tmp.internal_trigger_interval;
                                                                                                                                                                                                                                rtn.internal_trigger_random=tmp.internal_trigger_random;
                                                                                                                                                                                                                                rtn.multi_trigger=false;
                                                                                                                                                                                                                                rtn.multi_trigger_count=0;
                                                                                                                                                                                                                                for ii=1:MaxMultiTriggerCount
                                                                                                                                                                                                                                    rtn.multi_trigger_list(ii).enable=0;
                                                                                                                                                                                                                                    rtn.multi_trigger_list(ii).attrib=tmp.multi_trigger_list(ii);
                                                                                                                                                                                                                                    rtn.multi_trigger_list(ii).status=0;
                                                                                                                                                                                                                                    rtn.multi_trigger_list(ii).event_code=0;
                                                                                                                                                                                                                                    rtn.multi_trigger_list(ii).name='';
                                                                                                                                                                                                                                    rtn.multi_trigger_list(ii).average_count=0;
                                                                                                                                                                                                                                    rtn.multi_trigger_list(ii).actual_count=0;
                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                rtn.analog_trigger_channel=tmp.analog_trigger_channel;
                                                                                                                                                                                                                                rtn.analog_trigger_level=tmp.analog_trigger_level;
                                                                                                                                                                                                                                rtn.analog_trigger_hysteresis=0.0;
                                                                                                                                                                                                                                rtn.analog_trigger_slope=tmp.analog_trigger_slope;


                                                                                                                                                                                                                                function rtn=GetSqfAveAcqCondition1(fid)





















                                                                                                                                                                                                                                    rtn=[];
                                                                                                                                                                                                                                    if nargin~=1
                                                                                                                                                                                                                                        disp(['ERROR Arguments is illegal !!']);
                                                                                                                                                                                                                                        return;
                                                                                                                                                                                                                                    end





                                                                                                                                                                                                                                    MaxMaxChannelCount=1024;





                                                                                                                                                                                                                                    MaxMultiTriggerCount=256;
                                                                                                                                                                                                                                    ActualMultiTriggerCount=64;
                                                                                                                                                                                                                                    MaxMultiTriggerSignalNameLength=32;
                                                                                                                                                                                                                                    MultiTriggerAttributeRare=hex2dec('00000003');


                                                                                                                                                                                                                                    tmp.sample_rate=fread(fid,1,'double');
                                                                                                                                                                                                                                    tmp.frame_length=fread(fid,1,'int32');
                                                                                                                                                                                                                                    tmp.pretrigger_length=fread(fid,1,'int32');
                                                                                                                                                                                                                                    tmp.average_count=fread(fid,1,'int32');
                                                                                                                                                                                                                                    tmp.actual_count=fread(fid,1,'int32');
                                                                                                                                                                                                                                    tmp.reject_count=fread(fid,1,'int32');
                                                                                                                                                                                                                                    tmp.level_rejection=fread(fid,1,'double');
                                                                                                                                                                                                                                    tmp.trigger_mode=fread(fid,1,'int32');
                                                                                                                                                                                                                                    tmp.trigger_channel=fread(fid,1,'int32');
                                                                                                                                                                                                                                    tmp.trigger_level=fread(fid,1,'double');
                                                                                                                                                                                                                                    tmp.trigger_slope=fread(fid,1,'int32');
                                                                                                                                                                                                                                    tmp.trigger_interval=fread(fid,1,'double');
                                                                                                                                                                                                                                    tmp.trigger_random=fread(fid,1,'double');


                                                                                                                                                                                                                                    rtn.sample_rate=tmp.sample_rate;
                                                                                                                                                                                                                                    rtn.frame_length=tmp.frame_length;
                                                                                                                                                                                                                                    rtn.pretrigger_length=tmp.pretrigger_length;
                                                                                                                                                                                                                                    rtn.average_count=tmp.average_count;
                                                                                                                                                                                                                                    rtn.actual_count=tmp.actual_count;
                                                                                                                                                                                                                                    rtn.reject_count=tmp.reject_count;
                                                                                                                                                                                                                                    rtn.level_rejection=true;
                                                                                                                                                                                                                                    for ii=1:MaxMaxChannelCount
                                                                                                                                                                                                                                        rtn.level_rejection_level(ii).enable=true;
                                                                                                                                                                                                                                        rtn.level_rejection_level(ii).low_limit=-tmp.level_rejection;
                                                                                                                                                                                                                                        rtn.level_rejection_level(ii).high_limit=tmp.level_rejection;
                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                    rtn.level_rejection_void=false;
                                                                                                                                                                                                                                    rtn.level_rejection_void_start=0;
                                                                                                                                                                                                                                    rtn.level_rejection_void_end=0;

                                                                                                                                                                                                                                    rtn.trigger_mode=tmp.trigger_mode;
                                                                                                                                                                                                                                    rtn.internal_trigger_interval=tmp.trigger_interval;
                                                                                                                                                                                                                                    rtn.internal_trigger_random=tmp.trigger_random;
                                                                                                                                                                                                                                    rtn.multi_trigger=false;
                                                                                                                                                                                                                                    rtn.multi_trigger_count=0;
                                                                                                                                                                                                                                    for ii=1:MaxMultiTriggerCount
                                                                                                                                                                                                                                        rtn.multi_trigger_list(ii).enable=0;
                                                                                                                                                                                                                                        rtn.multi_trigger_list(ii).attrib=0;
                                                                                                                                                                                                                                        rtn.multi_trigger_list(ii).status=0;
                                                                                                                                                                                                                                        rtn.multi_trigger_list(ii).event_code=0;
                                                                                                                                                                                                                                        rtn.multi_trigger_list(ii).name='';
                                                                                                                                                                                                                                        rtn.multi_trigger_list(ii).average_count=0;
                                                                                                                                                                                                                                        rtn.multi_trigger_list(ii).actual_count=0;
                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                    rtn.analog_trigger_channel=tmp.trigger_channel;
                                                                                                                                                                                                                                    rtn.analog_trigger_level=tmp.trigger_level;
                                                                                                                                                                                                                                    rtn.analog_trigger_hysteresis=0.0;
                                                                                                                                                                                                                                    rtn.analog_trigger_slope=tmp.trigger_slope;


                                                                                                                                                                                                                                    function rtn=GetSqfMultiTrigger(fid)

















































                                                                                                                                                                                                                                        rtn=[];
                                                                                                                                                                                                                                        if nargin~=1
                                                                                                                                                                                                                                            disp(['ERROR Arguments is illegal !!']);
                                                                                                                                                                                                                                            return;
                                                                                                                                                                                                                                        end










                                                                                                                                                                                                                                        MaxMultiTriggerCount=256;
                                                                                                                                                                                                                                        ActualMultiTriggerCount=64;
                                                                                                                                                                                                                                        MaxMultiTriggerSignalNameLength=32;
                                                                                                                                                                                                                                        MultiTriggerAttributeRare=hex2dec('00000003');
                                                                                                                                                                                                                                        TriggerEventCodeMask=hex2dec('0000ffff');

                                                                                                                                                                                                                                        for ii=1:MaxMultiTriggerCount
                                                                                                                                                                                                                                            rtn(ii).enable=fread(fid,1,'int32');
                                                                                                                                                                                                                                            rtn(ii).attrib=fread(fid,1,'int32');
                                                                                                                                                                                                                                            rtn(ii).status=fread(fid,1,'int32');

                                                                                                                                                                                                                                            temp=fread(fid,1,'int32');
                                                                                                                                                                                                                                            if temp>=0
                                                                                                                                                                                                                                                rtn(ii).event_code=bitand(temp,TriggerEventCodeMask)+1;
                                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                                rtn(ii).event_code=temp;
                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                            rtn(ii).name=fread(fid,MaxMultiTriggerSignalNameLength+2,'uchar');index=min(find(rtn(ii).name==0));rtn(ii).name=deblank(GetSqfData2str(rtn(ii).name(1:index)));
                                                                                                                                                                                                                                            rtn(ii).average_count=fread(fid,1,'int32');
                                                                                                                                                                                                                                            rtn(ii).actual_count=fread(fid,1,'int32');
                                                                                                                                                                                                                                        end


                                                                                                                                                                                                                                        function rtn=GetSqfLevelRejection(fid)
























                                                                                                                                                                                                                                            rtn=[];
                                                                                                                                                                                                                                            if nargin~=1
                                                                                                                                                                                                                                                disp(['ERROR Arguments is illegal !!']);
                                                                                                                                                                                                                                                return;
                                                                                                                                                                                                                                            end



                                                                                                                                                                                                                                            MaxMaxChannelCount=1024;

                                                                                                                                                                                                                                            for ii=1:MaxMaxChannelCount
                                                                                                                                                                                                                                                rtn(ii).enable=fread(fid,1,'int32');
                                                                                                                                                                                                                                                rtn(ii).low_limit=fread(fid,1,'double');
                                                                                                                                                                                                                                                rtn(ii).high_limit=fread(fid,1,'double');
                                                                                                                                                                                                                                            end













                                                                                                                                                                                                                                            function out=GetSqfData(varargin)



































                                                                                                                                                                                                                                                try
                                                                                                                                                                                                                                                    function_revision=0;
                                                                                                                                                                                                                                                    function_name='GetSqfData';




                                                                                                                                                                                                                                                    out=[];



                                                                                                                                                                                                                                                    ContinuousRawDataAcquisition=1;
                                                                                                                                                                                                                                                    EvokedAverageDataAcquisition=2;
                                                                                                                                                                                                                                                    EvokedRawDataAcquisition=3;
                                                                                                                                                                                                                                                    VarianceDataAcquisition=8;
                                                                                                                                                                                                                                                    MarkerDataAcquisition=9;
                                                                                                                                                                                                                                                    EvokedBothDataAcquisition=10;
                                                                                                                                                                                                                                                    MarkerDataShotAcquisition=19;
                                                                                                                                                                                                                                                    AllDataAcquisition=999;
                                                                                                                                                                                                                                                    NoDataAcquisition=-1;


                                                                                                                                                                                                                                                    if nargin>=7
                                                                                                                                                                                                                                                        disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                                                                                                                                        return;
                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                    if nargin>=1
                                                                                                                                                                                                                                                        fid=varargin{1};
                                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                                        disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                                                                                                                                        return;
                                                                                                                                                                                                                                                    end


                                                                                                                                                                                                                                                    if nargin>=4
                                                                                                                                                                                                                                                        sqf_sysinfo=varargin{4};
                                                                                                                                                                                                                                                        if~(isfield(sqf_sysinfo,'system_id')&isfield(sqf_sysinfo,'channel_count'))
                                                                                                                                                                                                                                                            sqf_sysinfo=GetSqfSystemInfo(fid);
                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                                        sqf_sysinfo=GetSqfSystemInfo(fid);
                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                    if nargin>=5
                                                                                                                                                                                                                                                        sqf_channel=varargin{5};
                                                                                                                                                                                                                                                        if~(isfield(sqf_channel,'type')&isfield(sqf_channel,'data'))
                                                                                                                                                                                                                                                            sqf_channel=GetSqfChannel(fid,sqf_sysinfo);
                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                                        sqf_channel=GetSqfChannel(fid,sqf_sysinfo);
                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                    if nargin>=6
                                                                                                                                                                                                                                                        sqf_acqcond=varargin{6};
                                                                                                                                                                                                                                                        if~isfield(sqf_acqcond,'acq_type')
                                                                                                                                                                                                                                                            sqf_acqcond=GetSqfAcqCondition(fid,sqf_sysinfo,sqf_channel);
                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                                        sqf_acqcond=GetSqfAcqCondition(fid,sqf_sysinfo,sqf_channel);
                                                                                                                                                                                                                                                    end

                                                                                                                                                                                                                                                    if nargin>=3

                                                                                                                                                                                                                                                        start_sample=varargin{2};
                                                                                                                                                                                                                                                        sample_length=varargin{3};

                                                                                                                                                                                                                                                        if sample_length==Inf

                                                                                                                                                                                                                                                            switch sqf_acqcond.acq_type
                                                                                                                                                                                                                                                            case ContinuousRawDataAcquisition
                                                                                                                                                                                                                                                                sample_length=sqf_acqcond.actual_count-start_sample;
                                                                                                                                                                                                                                                            case EvokedRawDataAcquisition
                                                                                                                                                                                                                                                                sample_length=sqf_acqcond.actual_count-start_sample+1;
                                                                                                                                                                                                                                                            case EvokedAverageDataAcquisition
                                                                                                                                                                                                                                                                sample_length=sqf_acqcond.frame_length-start_sample;
                                                                                                                                                                                                                                                            otherwise

                                                                                                                                                                                                                                                                disp(['ERROR ( ',function_name,' ): Unknown acq type.']);
                                                                                                                                                                                                                                                                return;
                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                    elseif nargin==2

                                                                                                                                                                                                                                                        switch sqf_acqcond.acq_type
                                                                                                                                                                                                                                                        case ContinuousRawDataAcquisition
                                                                                                                                                                                                                                                            sample_length=sqf_acqcond.actual_count-start_sample;
                                                                                                                                                                                                                                                        case EvokedRawDataAcquisition
                                                                                                                                                                                                                                                            sample_length=sqf_acqcond.actual_count-start_sample+1;
                                                                                                                                                                                                                                                        case EvokedAverageDataAcquisition
                                                                                                                                                                                                                                                            sample_length=sqf_acqcond.frame_length-start_sample;
                                                                                                                                                                                                                                                        otherwise

                                                                                                                                                                                                                                                            disp(['ERROR ( ',function_name,' ): Unknown acq type.']);
                                                                                                                                                                                                                                                            return;
                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                    elseif nargin==1

                                                                                                                                                                                                                                                        switch sqf_acqcond.acq_type
                                                                                                                                                                                                                                                        case ContinuousRawDataAcquisition
                                                                                                                                                                                                                                                            start_sample=0;
                                                                                                                                                                                                                                                            sample_length=sqf_acqcond.actual_count;
                                                                                                                                                                                                                                                        case EvokedRawDataAcquisition
                                                                                                                                                                                                                                                            start_sample=1;
                                                                                                                                                                                                                                                            sample_length=sqf_acqcond.actual_count;
                                                                                                                                                                                                                                                        case EvokedAverageDataAcquisition
                                                                                                                                                                                                                                                            start_sample=0;
                                                                                                                                                                                                                                                            sample_length=sqf_acqcond.frame_length;
                                                                                                                                                                                                                                                        otherwise

                                                                                                                                                                                                                                                            disp(['ERROR ( ',function_name,' ): Unknown acq type.']);
                                                                                                                                                                                                                                                            return;
                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                    end


                                                                                                                                                                                                                                                    flag_input_error=false;
                                                                                                                                                                                                                                                    switch sqf_acqcond.acq_type
                                                                                                                                                                                                                                                    case ContinuousRawDataAcquisition
                                                                                                                                                                                                                                                        if start_sample<0||start_sample>sqf_acqcond.actual_count-1
                                                                                                                                                                                                                                                            flag_input_error=true;
                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                        if sample_length<0||start_sample+sample_length-1>sqf_acqcond.actual_count-1
                                                                                                                                                                                                                                                            flag_input_error=true;
                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                    case EvokedRawDataAcquisition
                                                                                                                                                                                                                                                        if start_sample<1||start_sample>sqf_acqcond.actual_count
                                                                                                                                                                                                                                                            flag_input_error=true;
                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                        if sample_length<1||start_sample+sample_length-1>sqf_acqcond.actual_count
                                                                                                                                                                                                                                                            flag_input_error=true;
                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                    case EvokedAverageDataAcquisition
                                                                                                                                                                                                                                                        if start_sample<0||start_sample>sqf_acqcond.frame_length-1
                                                                                                                                                                                                                                                            flag_input_error=true;
                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                        if sample_length<0||start_sample+sample_length-1>sqf_acqcond.frame_length-1
                                                                                                                                                                                                                                                            flag_input_error=true;
                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                    otherwise

                                                                                                                                                                                                                                                        disp(['ERROR ( ',function_name,' ): Unknown acq type.']);
                                                                                                                                                                                                                                                        return;
                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                    if flag_input_error
                                                                                                                                                                                                                                                        disp(['ERROR ( ',function_name,' ): Specified range is not proper !!']);
                                                                                                                                                                                                                                                        return;
                                                                                                                                                                                                                                                    end


                                                                                                                                                                                                                                                    sqf_slot=GetSqfConstantsDirectory;
                                                                                                                                                                                                                                                    if isempty(sqf_slot)
                                                                                                                                                                                                                                                        return;
                                                                                                                                                                                                                                                    end


                                                                                                                                                                                                                                                    if sqf_acqcond.acq_type==ContinuousRawDataAcquisition||sqf_acqcond.acq_type==EvokedRawDataAcquisition
                                                                                                                                                                                                                                                        direc=GetSqfDirectory(fid,sqf_slot.SqfRawDataSlot,function_name);
                                                                                                                                                                                                                                                    elseif sqf_acqcond.acq_type==EvokedAverageDataAcquisition
                                                                                                                                                                                                                                                        direc=GetSqfDirectory(fid,sqf_slot.SqfAveDataSlot,function_name);
                                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                                        disp(['ERROR ( ',function_name,' ): Unknown acq type.']);
                                                                                                                                                                                                                                                        return;
                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                    if isempty(direc)
                                                                                                                                                                                                                                                        disp(['ERROR ( ',function_name,' ): This file is not Meg160 format!!']);
                                                                                                                                                                                                                                                        return;
                                                                                                                                                                                                                                                    end




                                                                                                                                                                                                                                                    bOpenOrgFile=false;
                                                                                                                                                                                                                                                    if(((sqf_sysinfo.version==2)&&(sqf_sysinfo.revision>=4))||(sqf_sysinfo.version>2))

                                                                                                                                                                                                                                                        if(direc.offset==0&&direc.size==0&&direc.max_count==0&&direc.count==0)

                                                                                                                                                                                                                                                            if isempty(sqf_sysinfo.original_megfile)
                                                                                                                                                                                                                                                                disp(['ERROR ( ',function_name,' ): Original file was not specified.']);
                                                                                                                                                                                                                                                                return;
                                                                                                                                                                                                                                                            end

                                                                                                                                                                                                                                                            if exist(sqf_sysinfo.original_megfile)~=2
                                                                                                                                                                                                                                                                disp(['ERROR ( ',function_name,' ): Original file was not exist.']);
                                                                                                                                                                                                                                                                return;
                                                                                                                                                                                                                                                            end

                                                                                                                                                                                                                                                            fid_backup=fid;
                                                                                                                                                                                                                                                            fid=fopen(sqf_sysinfo.original_megfile,'rb','ieee-le');
                                                                                                                                                                                                                                                            if(fid==-1)
                                                                                                                                                                                                                                                                disp(['ERROR ( ',function_name,' ): Original file cannot be opened.']);
                                                                                                                                                                                                                                                                return;
                                                                                                                                                                                                                                                            end

                                                                                                                                                                                                                                                            bOpenOrgFile=true;



                                                                                                                                                                                                                                                            if sqf_acqcond.acq_type==ContinuousRawDataAcquisition||sqf_acqcond.acq_type==EvokedRawDataAcquisition
                                                                                                                                                                                                                                                                direc=GetSqfDirectory(fid,sqf_slot.SqfRawDataSlot,function_name);
                                                                                                                                                                                                                                                            elseif sqf_acqcond.acq_type==EvokedAverageDataAcquisition
                                                                                                                                                                                                                                                                direc=GetSqfDirectory(fid,sqf_slot.SqfAveDataSlot,function_name);
                                                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                                                disp(['ERROR ( ',function_name,' ): Unknown acq type.']);
                                                                                                                                                                                                                                                                return;
                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                            if isempty(direc)
                                                                                                                                                                                                                                                                disp(['ERROR ( ',function_name,' ): This file is not Meg160 format!!']);
                                                                                                                                                                                                                                                                return;
                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                    end



                                                                                                                                                                                                                                                    switch sqf_acqcond.acq_type
                                                                                                                                                                                                                                                    case ContinuousRawDataAcquisition
                                                                                                                                                                                                                                                        fseek(fid,direc.offset+direc.size*sqf_sysinfo.channel_count*start_sample,'bof');
                                                                                                                                                                                                                                                        data=fread(fid,[sqf_sysinfo.channel_count,sample_length],'int16');
                                                                                                                                                                                                                                                    case EvokedRawDataAcquisition
                                                                                                                                                                                                                                                        fseek(fid,direc.offset+direc.size*sqf_sysinfo.channel_count*sqf_acqcond.frame_length*(start_sample-1),'bof');
                                                                                                                                                                                                                                                        data=fread(fid,[sqf_sysinfo.channel_count,sqf_acqcond.frame_length*sample_length],'int16');
                                                                                                                                                                                                                                                    case EvokedAverageDataAcquisition
                                                                                                                                                                                                                                                        fseek(fid,direc.offset+direc.size*sqf_sysinfo.channel_count*start_sample,'bof');
                                                                                                                                                                                                                                                        data=fread(fid,[sqf_sysinfo.channel_count,sample_length],'double');
                                                                                                                                                                                                                                                    otherwise

                                                                                                                                                                                                                                                        disp(['ERROR ( ',function_name,' ): Unknown acq type.']);
                                                                                                                                                                                                                                                        return;
                                                                                                                                                                                                                                                    end


                                                                                                                                                                                                                                                    if bOpenOrgFile
                                                                                                                                                                                                                                                        fclose(fid);
                                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                                        fseek(fid,0,'bof');
                                                                                                                                                                                                                                                    end


                                                                                                                                                                                                                                                    out=data;

                                                                                                                                                                                                                                                catch

                                                                                                                                                                                                                                                    if exist('bOpenOrgFile')&&bOpenOrgFile&&fid~=-1
                                                                                                                                                                                                                                                        try
                                                                                                                                                                                                                                                            fclose(fid);
                                                                                                                                                                                                                                                        catch

                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                    end

                                                                                                                                                                                                                                                    last_error=lasterror;



                                                                                                                                                                                                                                                    switch last_error.identifier
                                                                                                                                                                                                                                                    case 'MATLAB:nomem'
                                                                                                                                                                                                                                                        str_error_message=sprintf('Exception : Sorry, not enough memory. (data)');
                                                                                                                                                                                                                                                    otherwise
                                                                                                                                                                                                                                                        str_error_message=sprintf('Exception : Sorry, reading error was occurred. (data)');
                                                                                                                                                                                                                                                    end


                                                                                                                                                                                                                                                    disp(str_error_message);

                                                                                                                                                                                                                                                    return;
                                                                                                                                                                                                                                                end














                                                                                                                                                                                                                                                function out=GetSqfMrImage(varargin)






























                                                                                                                                                                                                                                                    try
                                                                                                                                                                                                                                                        function_revision=0;
                                                                                                                                                                                                                                                        function_name='GetSqfMrImage';




                                                                                                                                                                                                                                                        out=[];


                                                                                                                                                                                                                                                        if nargin>=3
                                                                                                                                                                                                                                                            disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                                                                                                                                            return;
                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                        if nargin>=1
                                                                                                                                                                                                                                                            fid=varargin{1};
                                                                                                                                                                                                                                                        else
                                                                                                                                                                                                                                                            disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                                                                                                                                            return;
                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                        if nargin>=2
                                                                                                                                                                                                                                                            sqf_sysinfo=varargin{2};
                                                                                                                                                                                                                                                            if~(isfield(sqf_sysinfo,'version')&isfield(sqf_sysinfo,'revision'))
                                                                                                                                                                                                                                                                sqf_sysinfo=GetSqfSystemInfo(fid);
                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                        else
                                                                                                                                                                                                                                                            sqf_sysinfo=GetSqfSystemInfo(fid);
                                                                                                                                                                                                                                                        end


                                                                                                                                                                                                                                                        sqf_slot=GetSqfConstantsDirectory;
                                                                                                                                                                                                                                                        if isempty(sqf_slot)
                                                                                                                                                                                                                                                            return;
                                                                                                                                                                                                                                                        end



                                                                                                                                                                                                                                                        MaxFileNameLength=256;






                                                                                                                                                                                                                                                        NoMriFile=0;
                                                                                                                                                                                                                                                        NormalMriFile=1;
                                                                                                                                                                                                                                                        VirtualMriFile=2;









                                                                                                                                                                                                                                                        NO_MODEL=0;
                                                                                                                                                                                                                                                        SPHERICAL_MODEL=1;
                                                                                                                                                                                                                                                        LAYERED_MODEL=2;
                                                                                                                                                                                                                                                        ELLIPTIC_MODEL=3;
                                                                                                                                                                                                                                                        MULTILAYER_SPHERICAL_MODEL=4;


                                                                                                                                                                                                                                                        direc=GetSqfDirectory(fid,sqf_slot.SqfMrImageSlot,function_name);
                                                                                                                                                                                                                                                        if isempty(direc)
                                                                                                                                                                                                                                                            disp(['ERROR ( ',function_name,' ): This file is not Meg160 format!!']);
                                                                                                                                                                                                                                                            return;
                                                                                                                                                                                                                                                        end




                                                                                                                                                                                                                                                        fseek(fid,direc.offset,'bof');


                                                                                                                                                                                                                                                        if(sqf_sysinfo.version==0)||(sqf_sysinfo.version==1&&sqf_sysinfo.revision<=6)
                                                                                                                                                                                                                                                            mri_file=fread(fid,MaxFileNameLength,'uchar');index=min(find(mri_file==0));mri_file=GetSqfData2str(mri_file(1:index));
                                                                                                                                                                                                                                                            if isempty(mri_file)
                                                                                                                                                                                                                                                                mri_type=NoMriFile;
                                                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                                                mri_type=NormalMriFile;
                                                                                                                                                                                                                                                            end

                                                                                                                                                                                                                                                        else
                                                                                                                                                                                                                                                            mri_type=fread(fid,1,'int32');
                                                                                                                                                                                                                                                            mri_file=fread(fid,MaxFileNameLength,'uchar');index=min(find(mri_file==0));mri_file=GetSqfData2str(mri_file(1:index));
                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                        model_type=fread(fid,1,'int32');

                                                                                                                                                                                                                                                        out.mri_type=mri_type;
                                                                                                                                                                                                                                                        out.mri_file=mri_file;
                                                                                                                                                                                                                                                        out.model.type=model_type;

                                                                                                                                                                                                                                                        switch model_type
                                                                                                                                                                                                                                                        case SPHERICAL_MODEL
                                                                                                                                                                                                                                                            out.model.cx=fread(fid,1,'double');
                                                                                                                                                                                                                                                            out.model.cy=fread(fid,1,'double');
                                                                                                                                                                                                                                                            out.model.cz=fread(fid,1,'double');
                                                                                                                                                                                                                                                            out.model.radius=fread(fid,1,'double');
                                                                                                                                                                                                                                                        case LAYERED_MODEL
                                                                                                                                                                                                                                                            out.model.ax=fread(fid,1,'double');
                                                                                                                                                                                                                                                            out.model.ay=fread(fid,1,'double');
                                                                                                                                                                                                                                                            out.model.az=fread(fid,1,'double');
                                                                                                                                                                                                                                                            out.model.c=fread(fid,1,'double');
                                                                                                                                                                                                                                                        otherwise
                                                                                                                                                                                                                                                        end


                                                                                                                                                                                                                                                        fseek(fid,0,'bof');

                                                                                                                                                                                                                                                    catch





                                                                                                                                                                                                                                                        str_error_message=sprintf('Exception : Sorry, reading error was occurred. (MrImage)');
                                                                                                                                                                                                                                                        disp(str_error_message);
                                                                                                                                                                                                                                                        return;
                                                                                                                                                                                                                                                    end














                                                                                                                                                                                                                                                    function out=GetSqfMatching(varargin)
























                                                                                                                                                                                                                                                        try
                                                                                                                                                                                                                                                            function_revision=0;
                                                                                                                                                                                                                                                            function_name='GetSqfMatching';




                                                                                                                                                                                                                                                            out=[];


                                                                                                                                                                                                                                                            if nargin==1
                                                                                                                                                                                                                                                                fid=varargin{1};
                                                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                                                disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                                                                                                                                                return;
                                                                                                                                                                                                                                                            end


                                                                                                                                                                                                                                                            sqf_slot=GetSqfConstantsDirectory;
                                                                                                                                                                                                                                                            if isempty(sqf_slot)
                                                                                                                                                                                                                                                                return;
                                                                                                                                                                                                                                                            end



                                                                                                                                                                                                                                                            MaxFileNameLength=256;

                                                                                                                                                                                                                                                            MaxMarkerCount=8;


                                                                                                                                                                                                                                                            direc=GetSqfDirectory(fid,sqf_slot.SqfMatchingSlot,function_name);
                                                                                                                                                                                                                                                            if isempty(direc)
                                                                                                                                                                                                                                                                disp(['ERROR ( ',function_name,' ): This file is not Meg160 format!!']);
                                                                                                                                                                                                                                                                return;
                                                                                                                                                                                                                                                            end




                                                                                                                                                                                                                                                            fseek(fid,direc.offset,'bof');


                                                                                                                                                                                                                                                            done=fread(fid,1,'int32');
                                                                                                                                                                                                                                                            meg_to_mri=fread(fid,[4,4],'double');if(done&&meg_to_mri(4,4)~=1);meg_to_mri(4,4)=1;end;
                                                                                                                                                                                                                                                            mri_to_meg=fread(fid,[4,4],'double');
                                                                                                                                                                                                                                                            marker_count=fread(fid,1,'int32');
                                                                                                                                                                                                                                                            marker=[];
                                                                                                                                                                                                                                                            for no=1:MaxMarkerCount
                                                                                                                                                                                                                                                                marker(no).mri_type=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                marker(no).meg_type=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                marker(no).mri_done=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                marker(no).meg_done=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                marker(no).mri_pos=fread(fid,[1,3],'double');
                                                                                                                                                                                                                                                                marker(no).meg_pos=fread(fid,[1,3],'double');
                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                            marker_file=fread(fid,MaxFileNameLength,'uchar');index=min(find(marker_file==0));marker_file=GetSqfData2str(marker_file(1:index));

                                                                                                                                                                                                                                                            if~done

                                                                                                                                                                                                                                                                index_nan=isnan(meg_to_mri);
                                                                                                                                                                                                                                                                if find(index_nan)
                                                                                                                                                                                                                                                                    meg_to_mri=zeros(4,4);
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                index_nan=isnan(mri_to_meg);
                                                                                                                                                                                                                                                                if find(index_nan)
                                                                                                                                                                                                                                                                    mri_to_meg=zeros(4,4);
                                                                                                                                                                                                                                                                end


                                                                                                                                                                                                                                                                index_illegal=abs(meg_to_mri)>1e10;
                                                                                                                                                                                                                                                                if find(index_illegal)
                                                                                                                                                                                                                                                                    meg_to_mri=zeros(4,4);
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                index_illegal=abs(mri_to_meg)>1e10;
                                                                                                                                                                                                                                                                if find(index_illegal)
                                                                                                                                                                                                                                                                    mri_to_meg=zeros(4,4);
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                            end


                                                                                                                                                                                                                                                            fseek(fid,0,'bof');


                                                                                                                                                                                                                                                            out.done=done;
                                                                                                                                                                                                                                                            out.meg_to_mri=meg_to_mri.';
                                                                                                                                                                                                                                                            out.mri_to_meg=mri_to_meg.';
                                                                                                                                                                                                                                                            out.marker_count=marker_count;
                                                                                                                                                                                                                                                            out.marker=marker;
                                                                                                                                                                                                                                                            out.marker_file=marker_file;

                                                                                                                                                                                                                                                        catch





                                                                                                                                                                                                                                                            str_error_message=sprintf('Exception : Sorry, reading error was occurred. (Matching)');

                                                                                                                                                                                                                                                            disp(str_error_message);
                                                                                                                                                                                                                                                            return;
                                                                                                                                                                                                                                                        end














                                                                                                                                                                                                                                                        function out=GetSqfSource(varargin)












                                                                                                                                                                                                                                                            try
                                                                                                                                                                                                                                                                function_revision=0;
                                                                                                                                                                                                                                                                function_name='GetSqfSource';




                                                                                                                                                                                                                                                                out=[];


                                                                                                                                                                                                                                                                if nargin>=3
                                                                                                                                                                                                                                                                    disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                                                                                                                                                    return;
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                if nargin>=1
                                                                                                                                                                                                                                                                    fid=varargin{1};
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                    disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                                                                                                                                                    return;
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                if nargin>=2
                                                                                                                                                                                                                                                                    sqf_sysinfo=varargin{2};

                                                                                                                                                                                                                                                                    if~(isfield(sqf_sysinfo,'version')&isfield(sqf_sysinfo,'revision'))
                                                                                                                                                                                                                                                                        sqf_sysinfo=GetSqfSystemInfo(fid);
                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                    sqf_sysinfo=GetSqfSystemInfo(fid);
                                                                                                                                                                                                                                                                end


                                                                                                                                                                                                                                                                sqf_slot=GetSqfConstantsDirectory;
                                                                                                                                                                                                                                                                if isempty(sqf_slot)
                                                                                                                                                                                                                                                                    return;
                                                                                                                                                                                                                                                                end


                                                                                                                                                                                                                                                                MaxSourceCommentLength=80;

                                                                                                                                                                                                                                                                NO_MODEL=0;
                                                                                                                                                                                                                                                                SPHERICAL_MODEL=1;
                                                                                                                                                                                                                                                                LAYERED_MODEL=2;
                                                                                                                                                                                                                                                                ELLIPTIC_MODEL=3;
                                                                                                                                                                                                                                                                MULTILAYER_SPHERICAL_MODEL=4;












                                                                                                                                                                                                                                                                DipoleModel=hex2dec('1');
                                                                                                                                                                                                                                                                DistributedSourceModel=hex2dec('2');










                                                                                                                                                                                                                                                                UndefinedCorrelationCoefficiency=-1.0;
                                                                                                                                                                                                                                                                DefaultConfidenceVolumeRatio=0.95;
                                                                                                                                                                                                                                                                DefaultConfidenceVolume=100.0*1.0e-9;
                                                                                                                                                                                                                                                                UndefinedConfidenceVolumeRatio=-1.0;
                                                                                                                                                                                                                                                                UndefinedConfidenceVolume=-1.0;


                                                                                                                                                                                                                                                                direc=GetSqfDirectory(fid,sqf_slot.SqfSourceSlot,function_name);
                                                                                                                                                                                                                                                                if isempty(direc)
                                                                                                                                                                                                                                                                    disp(['ERROR ( ',function_name,' ): This file is not Meg160 format!!']);
                                                                                                                                                                                                                                                                    return;
                                                                                                                                                                                                                                                                end



                                                                                                                                                                                                                                                                fseek(fid,direc.offset,'bof');


                                                                                                                                                                                                                                                                source=[];
                                                                                                                                                                                                                                                                if direc.count>0
                                                                                                                                                                                                                                                                    for no=1:direc.count
                                                                                                                                                                                                                                                                        fseek(fid,direc.offset+direc.size*(no-1),'bof');


                                                                                                                                                                                                                                                                        if(sqf_sysinfo.version<=0&&sqf_sysinfo.revision<=119)

                                                                                                                                                                                                                                                                            size=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            flags=0;
                                                                                                                                                                                                                                                                            source(no).type=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            source(no).type=DipoleModel;
                                                                                                                                                                                                                                                                            source(no).time=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            source(no).sample_no=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            source(no).channel_list=GetSqfSourceDecodeChannelList(fid);
                                                                                                                                                                                                                                                                            source(no).model.type=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            switch source(no).model.type
                                                                                                                                                                                                                                                                            case SPHERICAL_MODEL
                                                                                                                                                                                                                                                                                source(no).model.cx=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.cy=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.cz=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.radius=fread(fid,1,'double');
                                                                                                                                                                                                                                                                            case LAYERED_MODEL
                                                                                                                                                                                                                                                                                source(no).model.ax=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.ay=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.az=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.c=fread(fid,1,'double');
                                                                                                                                                                                                                                                                            otherwise
                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                            algorithm=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            source(no).algorithm.magnetic_field_calc=2;
                                                                                                                                                                                                                                                                            source(no).algorithm.variable_restraint=0;
                                                                                                                                                                                                                                                                            source(no).algorithm.optimization=1;
                                                                                                                                                                                                                                                                            source(no).filter=[];
                                                                                                                                                                                                                                                                            source(no).gof=fread(fid,1,'double');
                                                                                                                                                                                                                                                                            source(no).correlation=UndefinedCorrelationCoefficiency;
                                                                                                                                                                                                                                                                            source(no).confidence_ratio=UndefinedConfidenceVolumeRatio;
                                                                                                                                                                                                                                                                            source(no).confidence_volume=UndefinedConfidenceVolume;
                                                                                                                                                                                                                                                                            source(no).label=0;
                                                                                                                                                                                                                                                                            source(no).reference_no=0;
                                                                                                                                                                                                                                                                            source(no).comment='';
                                                                                                                                                                                                                                                                            source(no).total_intensity=0;
                                                                                                                                                                                                                                                                            source(no).dipole_count=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                        elseif((sqf_sysinfo.version<1)||(sqf_sysinfo.version<=1&&sqf_sysinfo.revision<=6))

                                                                                                                                                                                                                                                                            size=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            flags=0;
                                                                                                                                                                                                                                                                            source(no).type=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            source(no).time=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            source(no).sample_no=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            source(no).channel_list=GetSqfSourceDecodeChannelList(fid);
                                                                                                                                                                                                                                                                            source(no).model.type=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            switch source(no).model.type
                                                                                                                                                                                                                                                                            case SPHERICAL_MODEL
                                                                                                                                                                                                                                                                                source(no).model.cx=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.cy=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.cz=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.radius=fread(fid,1,'double');
                                                                                                                                                                                                                                                                            case LAYERED_MODEL
                                                                                                                                                                                                                                                                                source(no).model.ax=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.ay=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.az=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.c=fread(fid,1,'double');
                                                                                                                                                                                                                                                                            otherwise
                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                            source(no).algorithm=GetSqfSourceDecodeAlgorithm(fid);
                                                                                                                                                                                                                                                                            source(no).filter=[];
                                                                                                                                                                                                                                                                            source(no).gof=fread(fid,1,'double');
                                                                                                                                                                                                                                                                            source(no).correlation=UndefinedCorrelationCoefficiency;
                                                                                                                                                                                                                                                                            source(no).confidence_ratio=UndefinedConfidenceVolumeRatio;
                                                                                                                                                                                                                                                                            source(no).confidence_volume=UndefinedConfidenceVolume;
                                                                                                                                                                                                                                                                            source(no).label=0;
                                                                                                                                                                                                                                                                            source(no).reference_no=0;
                                                                                                                                                                                                                                                                            temp=fread(fid,MaxSourceCommentLength,'uchar');index=min(find(temp==0));temp=GetSqfData2str(temp(1:index));
                                                                                                                                                                                                                                                                            source(no).comment=temp;
                                                                                                                                                                                                                                                                            source(no).total_intensity=0;
                                                                                                                                                                                                                                                                            source(no).dipole_count=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                        elseif((sqf_sysinfo.version<2)||(sqf_sysinfo.version<=2&&sqf_sysinfo.revision<=3))

                                                                                                                                                                                                                                                                            size=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            flags=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            source(no).type=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            source(no).time=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            source(no).sample_no=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            source(no).channel_list=GetSqfSourceDecodeChannelList(fid);
                                                                                                                                                                                                                                                                            source(no).model.type=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            switch source(no).model.type
                                                                                                                                                                                                                                                                            case SPHERICAL_MODEL
                                                                                                                                                                                                                                                                                source(no).model.cx=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.cy=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.cz=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.radius=fread(fid,1,'double');
                                                                                                                                                                                                                                                                            case LAYERED_MODEL
                                                                                                                                                                                                                                                                                source(no).model.ax=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.ay=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.az=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.c=fread(fid,1,'double');
                                                                                                                                                                                                                                                                            otherwise
                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                            source(no).algorithm=GetSqfSourceDecodeAlgorithm(fid);
                                                                                                                                                                                                                                                                            source(no).filter=[];
                                                                                                                                                                                                                                                                            source(no).gof=fread(fid,1,'double');
                                                                                                                                                                                                                                                                            source(no).correlation=fread(fid,1,'double');
                                                                                                                                                                                                                                                                            source(no).confidence_ratio=fread(fid,1,'double');
                                                                                                                                                                                                                                                                            source(no).confidence_volume=fread(fid,1,'double');
                                                                                                                                                                                                                                                                            source(no).label=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            source(no).reference_no=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            temp=fread(fid,MaxSourceCommentLength,'uchar');index=min(find(temp==0));temp=GetSqfData2str(temp(1:index));
                                                                                                                                                                                                                                                                            source(no).comment=temp;
                                                                                                                                                                                                                                                                            source(no).total_intensity=fread(fid,1,'double');
                                                                                                                                                                                                                                                                            source(no).dipole_count=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                        else

                                                                                                                                                                                                                                                                            size=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            flags=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            source(no).type=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            source(no).time=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            source(no).sample_no=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            source(no).channel_list=GetSqfSourceDecodeChannelList(fid);
                                                                                                                                                                                                                                                                            source(no).model.type=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            switch source(no).model.type
                                                                                                                                                                                                                                                                            case SPHERICAL_MODEL
                                                                                                                                                                                                                                                                                source(no).model.cx=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.cy=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.cz=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.radius=fread(fid,1,'double');
                                                                                                                                                                                                                                                                            case LAYERED_MODEL
                                                                                                                                                                                                                                                                                source(no).model.ax=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.ay=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.az=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                source(no).model.c=fread(fid,1,'double');
                                                                                                                                                                                                                                                                            otherwise
                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                            source(no).algorithm=GetSqfSourceDecodeAlgorithm(fid);
                                                                                                                                                                                                                                                                            source(no).filter=GetSqfSourceFilterSetupInLocalization(fid);
                                                                                                                                                                                                                                                                            source(no).gof=fread(fid,1,'double');
                                                                                                                                                                                                                                                                            source(no).correlation=fread(fid,1,'double');
                                                                                                                                                                                                                                                                            source(no).confidence_ratio=fread(fid,1,'double');
                                                                                                                                                                                                                                                                            source(no).confidence_volume=fread(fid,1,'double');
                                                                                                                                                                                                                                                                            source(no).label=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            source(no).reference_no=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                            temp=fread(fid,MaxSourceCommentLength,'uchar');index=min(find(temp==0));temp=GetSqfData2str(temp(1:index));
                                                                                                                                                                                                                                                                            source(no).comment=temp;
                                                                                                                                                                                                                                                                            source(no).total_intensity=fread(fid,1,'double');
                                                                                                                                                                                                                                                                            source(no).dipole_count=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                        if source(no).dipole_count>0

                                                                                                                                                                                                                                                                            for dipole=1:source(no).dipole_count
                                                                                                                                                                                                                                                                                current_dipole(dipole).x=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                current_dipole(dipole).y=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                current_dipole(dipole).z=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                current_dipole(dipole).zdir=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                current_dipole(dipole).xdir=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                current_dipole(dipole).intensity=fread(fid,1,'double');
                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                            source(no).dipole_list=current_dipole;
                                                                                                                                                                                                                                                                        else
                                                                                                                                                                                                                                                                            source(no).dipole_list=[];
                                                                                                                                                                                                                                                                        end

                                                                                                                                                                                                                                                                        if(sqf_sysinfo.version<=0&&sqf_sysinfo.revision<=119)||((sqf_sysinfo.version<1)||(sqf_sysinfo.version<=1&&sqf_sysinfo.revision<=6))
                                                                                                                                                                                                                                                                            total_intensity=0;
                                                                                                                                                                                                                                                                            for dipole=1:source(no).dipole_count
                                                                                                                                                                                                                                                                                total_intensity=total_intensity+source(no).dipole_list(dipole).intensity;
                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                            source(no).total_intensity=total_intensity;
                                                                                                                                                                                                                                                                        end

                                                                                                                                                                                                                                                                    end


                                                                                                                                                                                                                                                                    tt=1;
                                                                                                                                                                                                                                                                    for no=1:direc.count
                                                                                                                                                                                                                                                                        if source(no).sample_no>=0
                                                                                                                                                                                                                                                                            source_accept(tt)=source(no);
                                                                                                                                                                                                                                                                            tt=tt+1;
                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                    if tt==1
                                                                                                                                                                                                                                                                        source_accept=[];
                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                    source_accept=[];
                                                                                                                                                                                                                                                                end


                                                                                                                                                                                                                                                                fseek(fid,0,'bof');


                                                                                                                                                                                                                                                                out=source_accept;

                                                                                                                                                                                                                                                            catch

                                                                                                                                                                                                                                                                last_error=lasterror;
                                                                                                                                                                                                                                                                str_error_message=sprintf('Exception [%s] : %s %s',function_name,last_error.identifier,last_error.message);


                                                                                                                                                                                                                                                                str_error_message=sprintf('Exception : Sorry, reading error was occurred. (Source)');

                                                                                                                                                                                                                                                                disp(str_error_message);
                                                                                                                                                                                                                                                                return;
                                                                                                                                                                                                                                                            end






                                                                                                                                                                                                                                                            function out=GetSqfSourceDecodeChannelList(fid)
                                                                                                                                                                                                                                                                out=[];


                                                                                                                                                                                                                                                                MAX_CHANNEL_BIT_LIST=128;

                                                                                                                                                                                                                                                                channel_list=fread(fid,MAX_CHANNEL_BIT_LIST,'uchar');
                                                                                                                                                                                                                                                                mask_list={'01','02','04','08','10','20','40','80'};
                                                                                                                                                                                                                                                                used_channel_no=[];

                                                                                                                                                                                                                                                                for ii=1:MAX_CHANNEL_BIT_LIST
                                                                                                                                                                                                                                                                    for jj=1:8
                                                                                                                                                                                                                                                                        if channel_list(ii,:)&hex2dec(mask_list{jj})
                                                                                                                                                                                                                                                                            used_channel_no=[used_channel_no;8*(ii-1)-1+jj];
                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                out=used_channel_no;





                                                                                                                                                                                                                                                                function out=GetSqfSourceFilterSetupInLocalization(fid)


                                                                                                                                                                                                                                                                    out.hpf.enable=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                    out.hpf.cutoff_frequency=fread(fid,1,'double');
                                                                                                                                                                                                                                                                    out.hpf.window_type=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                    out.hpf.width=fread(fid,1,'double');
                                                                                                                                                                                                                                                                    hpf_channel_select=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                    out.lpf.enable=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                    out.lpf.cutoff_frequency=fread(fid,1,'double');
                                                                                                                                                                                                                                                                    out.lpf.window_type=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                    out.lpf.width=fread(fid,1,'double');
                                                                                                                                                                                                                                                                    lpf_channel_select=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                    out.bpf.enable=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                    out.bpf.low_frequency=fread(fid,1,'double');
                                                                                                                                                                                                                                                                    out.bpf.high_frequency=fread(fid,1,'double');
                                                                                                                                                                                                                                                                    out.bpf.window_type=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                    out.bpf.width=fread(fid,1,'double');
                                                                                                                                                                                                                                                                    bpf_channel_select=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                    out.bef.enable=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                    out.bef.low_frequency=fread(fid,1,'double');
                                                                                                                                                                                                                                                                    out.bef.high_frequency=fread(fid,1,'double');
                                                                                                                                                                                                                                                                    out.bef.window_type=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                    out.bef.width=fread(fid,1,'double');
                                                                                                                                                                                                                                                                    bef_channel_select=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                    out.moveave.enable=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                    out.moveave.width=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                    moveave_channel_select=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                    out.baseadj.enable=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                    out.baseadj.type=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                    out.baseadj.start_time=fread(fid,1,'double');
                                                                                                                                                                                                                                                                    out.baseadj.end_time=fread(fid,1,'double');
                                                                                                                                                                                                                                                                    baseadj_channel_select=fread(fid,1,'int32');





                                                                                                                                                                                                                                                                    function out=GetSqfSourceDecodeAlgorithm(fid)
                                                                                                                                                                                                                                                                        out=[];

                                                                                                                                                                                                                                                                        algo=fread(fid,1,'int32');





















                                                                                                                                                                                                                                                                        MagneticFieldCalculationMask=hex2dec('00000f00');
                                                                                                                                                                                                                                                                        BiotSavartLaw=hex2dec('00000100');
                                                                                                                                                                                                                                                                        SarvasLaw=hex2dec('00000200');
                                                                                                                                                                                                                                                                        MagneticDipoleLaw=hex2dec('00000400');

                                                                                                                                                                                                                                                                        VariableRestraintMask=hex2dec('0000f000');
                                                                                                                                                                                                                                                                        PositionRestraint=hex2dec('00001000');
                                                                                                                                                                                                                                                                        DirectionRestraint=hex2dec('00002000');
                                                                                                                                                                                                                                                                        IntensityRestraint=hex2dec('00004000');

                                                                                                                                                                                                                                                                        OptimizationAlgorithmMask=hex2dec('00ff0000');
                                                                                                                                                                                                                                                                        GradientAlgorithm=hex2dec('00010000');
                                                                                                                                                                                                                                                                        LeadFieldReconstructionAlgorithm=hex2dec('00020000');
                                                                                                                                                                                                                                                                        ManualSetAlgorithm=hex2dec('00080000');
                                                                                                                                                                                                                                                                        UserAlgorithm=hex2dec('00100000');

                                                                                                                                                                                                                                                                        DecMagneticFieldCalculation=bitand(MagneticFieldCalculationMask,algo);
                                                                                                                                                                                                                                                                        DecVariableRestraint=bitand(VariableRestraintMask,algo);
                                                                                                                                                                                                                                                                        DecOptimizationAlgorithm=bitand(OptimizationAlgorithmMask,algo);




                                                                                                                                                                                                                                                                        switch DecMagneticFieldCalculation
                                                                                                                                                                                                                                                                        case BiotSavartLaw
                                                                                                                                                                                                                                                                            out.magnetic_field_calc=1;
                                                                                                                                                                                                                                                                        case SarvasLaw
                                                                                                                                                                                                                                                                            out.magnetic_field_calc=2;
                                                                                                                                                                                                                                                                        case MagneticDipoleLaw
                                                                                                                                                                                                                                                                            out.magnetic_field_calc=3;
                                                                                                                                                                                                                                                                        otherwise
                                                                                                                                                                                                                                                                            out.magnetic_field_calc=0;
                                                                                                                                                                                                                                                                        end





                                                                                                                                                                                                                                                                        switch DecVariableRestraint
                                                                                                                                                                                                                                                                        case PositionRestraint
                                                                                                                                                                                                                                                                            out.variable_restraint=1;
                                                                                                                                                                                                                                                                        case DirectionRestraint
                                                                                                                                                                                                                                                                            out.variable_restraint=2;
                                                                                                                                                                                                                                                                        case IntensityRestraint
                                                                                                                                                                                                                                                                            out.variable_restraint=3;
                                                                                                                                                                                                                                                                        otherwise
                                                                                                                                                                                                                                                                            out.variable_restraint=0;
                                                                                                                                                                                                                                                                        end





                                                                                                                                                                                                                                                                        switch DecOptimizationAlgorithm
                                                                                                                                                                                                                                                                        case GradientAlgorithm
                                                                                                                                                                                                                                                                            out.optimization=1;
                                                                                                                                                                                                                                                                        case LeadFieldReconstructionAlgorithm
                                                                                                                                                                                                                                                                            out.optimization=2;
                                                                                                                                                                                                                                                                        case ManualSetAlgorithm
                                                                                                                                                                                                                                                                            out.optimization=3;
                                                                                                                                                                                                                                                                        case UserAlgorithm
                                                                                                                                                                                                                                                                            out.optimization=4;
                                                                                                                                                                                                                                                                        otherwise
                                                                                                                                                                                                                                                                            out.optimization=0;
                                                                                                                                                                                                                                                                        end












                                                                                                                                                                                                                                                                        function out=GetSqfTriggerEvent(varargin)













                                                                                                                                                                                                                                                                            try
                                                                                                                                                                                                                                                                                function_revision=0;
                                                                                                                                                                                                                                                                                function_name='GetSqfTriggerEvent';




                                                                                                                                                                                                                                                                                out=[];


                                                                                                                                                                                                                                                                                if nargin>=4
                                                                                                                                                                                                                                                                                    disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                                                                                                                                                                    return;
                                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                                if nargin>=1
                                                                                                                                                                                                                                                                                    fid=varargin{1};
                                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                                    disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                                                                                                                                                                    return;
                                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                                if nargin>=2
                                                                                                                                                                                                                                                                                    sqf_sysinfo=varargin{2};

                                                                                                                                                                                                                                                                                    if~(isfield(sqf_sysinfo,'version')&isfield(sqf_sysinfo,'revision'))
                                                                                                                                                                                                                                                                                        sqf_sysinfo=GetSqfSystemInfo(fid);
                                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                                    sqf_sysinfo=GetSqfSystemInfo(fid);
                                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                                if nargin>=3
                                                                                                                                                                                                                                                                                    sqf_acqcond=varargin{3};
                                                                                                                                                                                                                                                                                    if~isfield(sqf_acqcond,'acq_type')
                                                                                                                                                                                                                                                                                        sqf_acqcond=GetSqfAcqCondition(fid,sqf_sysinfo);
                                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                                    sqf_acqcond=GetSqfAcqCondition(fid,sqf_sysinfo);
                                                                                                                                                                                                                                                                                end


                                                                                                                                                                                                                                                                                sqf_slot=GetSqfConstantsDirectory;
                                                                                                                                                                                                                                                                                if isempty(sqf_slot)
                                                                                                                                                                                                                                                                                    return;
                                                                                                                                                                                                                                                                                end


                                                                                                                                                                                                                                                                                ContinuousRawDataAcquisition=1;
                                                                                                                                                                                                                                                                                EvokedAverageDataAcquisition=2;
                                                                                                                                                                                                                                                                                EvokedRawDataAcquisition=3;


                                                                                                                                                                                                                                                                                direc=GetSqfDirectory(fid,sqf_slot.SqfTriggerEventSlot,function_name);
                                                                                                                                                                                                                                                                                if isempty(direc)
                                                                                                                                                                                                                                                                                    disp(['ERROR ( ',function_name,' ): This file is not Meg160 format!!']);
                                                                                                                                                                                                                                                                                    return;
                                                                                                                                                                                                                                                                                end




                                                                                                                                                                                                                                                                                fseek(fid,direc.offset,'bof');


                                                                                                                                                                                                                                                                                trigger_event=[];

                                                                                                                                                                                                                                                                                if direc.count>0
                                                                                                                                                                                                                                                                                    trigger_event=zeros(direc.count,2);
                                                                                                                                                                                                                                                                                    if(sqf_sysinfo.version<=1)||(sqf_sysinfo.version==2&&sqf_sysinfo.revision<=3)
                                                                                                                                                                                                                                                                                        change_flag=false;
                                                                                                                                                                                                                                                                                        switch sqf_acqcond.acq_type
                                                                                                                                                                                                                                                                                        case ContinuousRawDataAcquisition
                                                                                                                                                                                                                                                                                            change_flag=false;
                                                                                                                                                                                                                                                                                        case EvokedAverageDataAcquisition
                                                                                                                                                                                                                                                                                            change_flag=true;
                                                                                                                                                                                                                                                                                        case EvokedRawDataAcquisition
                                                                                                                                                                                                                                                                                            change_flag=true;
                                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                                        if change_flag

                                                                                                                                                                                                                                                                                            for no=1:direc.count
                                                                                                                                                                                                                                                                                                trigger_event(no,1)=sqf_acqcond.frame_length*(no-1)+sqf_acqcond.pretrigger_length;
                                                                                                                                                                                                                                                                                                trigger_event(no,2)=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                                        else

                                                                                                                                                                                                                                                                                            for no=1:direc.count
                                                                                                                                                                                                                                                                                                trigger_event(no,1)=-1;
                                                                                                                                                                                                                                                                                                trigger_event(no,2)=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                                                                        for no=1:direc.count
                                                                                                                                                                                                                                                                                            trigger_event(no,1)=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                                            trigger_event(no,2)=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                                    end


                                                                                                                                                                                                                                                                                    trigger_event(:,2)=GetTriggerLineNo(trigger_event(:,2));

                                                                                                                                                                                                                                                                                end


                                                                                                                                                                                                                                                                                fseek(fid,0,'bof');


                                                                                                                                                                                                                                                                                out=trigger_event;

                                                                                                                                                                                                                                                                            catch





                                                                                                                                                                                                                                                                                str_error_message=sprintf('Exception : Sorry, reading error was occurred. ()');

                                                                                                                                                                                                                                                                                disp(str_error_message);
                                                                                                                                                                                                                                                                                return;
                                                                                                                                                                                                                                                                            end


                                                                                                                                                                                                                                                                            function trigger_no=GetTriggerLineNo(event_code)
















                                                                                                                                                                                                                                                                                TriggerEventCodeMask=hex2dec('0000ffff');

                                                                                                                                                                                                                                                                                trigger_count=size(event_code,1);

                                                                                                                                                                                                                                                                                for ii=1:trigger_count
                                                                                                                                                                                                                                                                                    trigger_no(ii,:)=bitand(event_code(ii,:),TriggerEventCodeMask)+1;
                                                                                                                                                                                                                                                                                end












                                                                                                                                                                                                                                                                                function out=GetSqfBookmark(varargin)

















                                                                                                                                                                                                                                                                                    try
                                                                                                                                                                                                                                                                                        function_revision=0;
                                                                                                                                                                                                                                                                                        function_name='GetSqfBookmark';




                                                                                                                                                                                                                                                                                        out=[];


                                                                                                                                                                                                                                                                                        if nargin>=3
                                                                                                                                                                                                                                                                                            disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                                                                                                                                                                            return;
                                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                                        if nargin>=1
                                                                                                                                                                                                                                                                                            fid=varargin{1};
                                                                                                                                                                                                                                                                                        else
                                                                                                                                                                                                                                                                                            disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                                                                                                                                                                            return;
                                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                                        if nargin>=2
                                                                                                                                                                                                                                                                                            sqf_sysinfo=varargin{2};

                                                                                                                                                                                                                                                                                            if~(isfield(sqf_sysinfo,'version')&isfield(sqf_sysinfo,'revision'))
                                                                                                                                                                                                                                                                                                sqf_sysinfo=GetSqfSystemInfo(fid);
                                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                                        else
                                                                                                                                                                                                                                                                                            sqf_sysinfo=GetSqfSystemInfo(fid);
                                                                                                                                                                                                                                                                                        end


                                                                                                                                                                                                                                                                                        sqf_slot=GetSqfConstantsDirectory;
                                                                                                                                                                                                                                                                                        if isempty(sqf_slot)
                                                                                                                                                                                                                                                                                            return;
                                                                                                                                                                                                                                                                                        end

















                                                                                                                                                                                                                                                                                        MaxBookmarkCommentLength=32;
                                                                                                                                                                                                                                                                                        MaxSourceCommentLength=80;




























                                                                                                                                                                                                                                                                                        direc=GetSqfDirectory(fid,sqf_slot.SqfBookmarkSlot,function_name);
                                                                                                                                                                                                                                                                                        if isempty(direc)
                                                                                                                                                                                                                                                                                            disp(['ERROR ( ',function_name,' ): This file is not Meg160 format!!']);
                                                                                                                                                                                                                                                                                            return;
                                                                                                                                                                                                                                                                                        end




                                                                                                                                                                                                                                                                                        fseek(fid,direc.offset,'bof');


                                                                                                                                                                                                                                                                                        bookmark=[];
                                                                                                                                                                                                                                                                                        if direc.count>0
                                                                                                                                                                                                                                                                                            if(sqf_sysinfo.version==0)||(sqf_sysinfo.version==1&&sqf_sysinfo.revision<=6)
                                                                                                                                                                                                                                                                                                for no=1:direc.count
                                                                                                                                                                                                                                                                                                    bookmark(no).sample_no=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                                                    bookmark(no).type=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                                                    dummy=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                                                    comment=fread(fid,MaxBookmarkCommentLength+2,'uchar');index=min(find(comment==0));comment=GetSqfData2str(comment(1:index));
                                                                                                                                                                                                                                                                                                    bookmark(no).comment=comment;
                                                                                                                                                                                                                                                                                                    bookmark(no).label=0;
                                                                                                                                                                                                                                                                                                    bookmark(no).reference_no=0;
                                                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                                                                                for no=1:direc.count
                                                                                                                                                                                                                                                                                                    bookmark(no).sample_no=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                                                    bookmark(no).type=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                                                    bookmark(no).label=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                                                    bookmark(no).reference_no=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                                                    comment=fread(fid,MaxSourceCommentLength,'uchar');index=min(find(comment==0));comment=GetSqfData2str(comment(1:index));
                                                                                                                                                                                                                                                                                                    bookmark(no).comment=comment;
                                                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                                        end


                                                                                                                                                                                                                                                                                        fseek(fid,0,'bof');


                                                                                                                                                                                                                                                                                        out=bookmark;

                                                                                                                                                                                                                                                                                    catch





                                                                                                                                                                                                                                                                                        str_error_message=sprintf('Exception : Sorry, reading error was occurred. (Bookmark)');

                                                                                                                                                                                                                                                                                        disp(str_error_message);
                                                                                                                                                                                                                                                                                        return;
                                                                                                                                                                                                                                                                                    end



















































































                                                                                                                                                                                                                                                                                    function out=GetSqfDigitizerInfo(varargin)



















                                                                                                                                                                                                                                                                                        try
                                                                                                                                                                                                                                                                                            function_revision=0;
                                                                                                                                                                                                                                                                                            function_name='GetSqfDigitizerInfo';




                                                                                                                                                                                                                                                                                            out=[];


                                                                                                                                                                                                                                                                                            if nargin>=3
                                                                                                                                                                                                                                                                                                disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                                                                                                                                                                                return;
                                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                                            if nargin>=1
                                                                                                                                                                                                                                                                                                fid=varargin{1};
                                                                                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                                                                                disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                                                                                                                                                                                return;
                                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                                            if nargin>=2
                                                                                                                                                                                                                                                                                                sqf_sysinfo=varargin{2};

                                                                                                                                                                                                                                                                                                if~(isfield(sqf_sysinfo,'version')&isfield(sqf_sysinfo,'revision'))
                                                                                                                                                                                                                                                                                                    sqf_sysinfo=GetSqfSystemInfo(fid);
                                                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                                                                                sqf_sysinfo=GetSqfSystemInfo(fid);
                                                                                                                                                                                                                                                                                            end


                                                                                                                                                                                                                                                                                            sqf_slot=GetSqfConstantsDirectory;
                                                                                                                                                                                                                                                                                            if isempty(sqf_slot)
                                                                                                                                                                                                                                                                                                return;
                                                                                                                                                                                                                                                                                            end








                                                                                                                                                                                                                                                                                            NoDigitizer=hex2dec('00000000');
                                                                                                                                                                                                                                                                                            PolhemusFastrak=hex2dec('00000001');
                                                                                                                                                                                                                                                                                            SurfacePointFile=hex2dec('00000100');
                                                                                                                                                                                                                                                                                            DigitizerHoseiNoHosei=0;
                                                                                                                                                                                                                                                                                            DigitizerHoseiArgSize=64;
                                                                                                                                                                                                                                                                                            MaxFileNameLength=256;


                                                                                                                                                                                                                                                                                            direc=GetSqfDirectory(fid,sqf_slot.SqfDigitizerSlot,function_name);
                                                                                                                                                                                                                                                                                            if isempty(direc)
                                                                                                                                                                                                                                                                                                disp(['ERROR ( ',function_name,' ): This file is not Meg160 format!!']);
                                                                                                                                                                                                                                                                                                return;
                                                                                                                                                                                                                                                                                            end




                                                                                                                                                                                                                                                                                            fseek(fid,direc.offset,'bof');


                                                                                                                                                                                                                                                                                            digitizer_info=[];
                                                                                                                                                                                                                                                                                            if direc.count>0
                                                                                                                                                                                                                                                                                                if(sqf_sysinfo.version<=1)||(sqf_sysinfo.version==2&&sqf_sysinfo.revision<=3)
                                                                                                                                                                                                                                                                                                    digitizer_info.type=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                                                    digitizer_info.digitizer_file='';
                                                                                                                                                                                                                                                                                                    digitizer_info.hosei_type=DigitizerHoseiNoHosei;
                                                                                                                                                                                                                                                                                                    digitizer_info.hosei_args='';
                                                                                                                                                                                                                                                                                                    digitizer_info.done=fread(fid,1,'int32');digitizer_info.done=false;
                                                                                                                                                                                                                                                                                                    digitizer_info.meg_to_digitizer=fread(fid,[4,4],'double').';
                                                                                                                                                                                                                                                                                                    digitizer_info.digitizer_to_meg=fread(fid,[4,4],'double').';
                                                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                                                    digitizer_info.type=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                                                    temp=fread(fid,MaxFileNameLength,'uchar');index=min(find(temp==0));temp=GetSqfData2str(temp(1:index));
                                                                                                                                                                                                                                                                                                    digitizer_info.digitizer_file=temp;
                                                                                                                                                                                                                                                                                                    digitizer_info.hosei_type=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                                                    temp=fread(fid,DigitizerHoseiArgSize,'uchar');index=min(find(temp==0));temp=GetSqfData2str(temp(1:index));
                                                                                                                                                                                                                                                                                                    digitizer_info.hosei_args=temp;
                                                                                                                                                                                                                                                                                                    digitizer_info.done=fread(fid,1,'int32');
                                                                                                                                                                                                                                                                                                    digitizer_info.meg_to_digitizer=fread(fid,[4,4],'double').';
                                                                                                                                                                                                                                                                                                    digitizer_info.digitizer_to_meg=fread(fid,[4,4],'double').';
                                                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                                            end


                                                                                                                                                                                                                                                                                            fseek(fid,0,'bof');


                                                                                                                                                                                                                                                                                            out=digitizer_info;

                                                                                                                                                                                                                                                                                        catch





                                                                                                                                                                                                                                                                                            str_error_message=sprintf('Exception : Sorry, reading error was occurred. (Digitizer Information)');

                                                                                                                                                                                                                                                                                            disp(str_error_message);
                                                                                                                                                                                                                                                                                            return;
                                                                                                                                                                                                                                                                                        end















                                                                                                                                                                                                                                                                                        function out=GetSqfDigitizationPoint(varargin)
















                                                                                                                                                                                                                                                                                            try
                                                                                                                                                                                                                                                                                                function_revision=0;
                                                                                                                                                                                                                                                                                                function_name='GetSqfDigitizationPoint';




                                                                                                                                                                                                                                                                                                out=[];


                                                                                                                                                                                                                                                                                                if nargin==1
                                                                                                                                                                                                                                                                                                    fid=varargin{1};
                                                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                                                    disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
                                                                                                                                                                                                                                                                                                    return;
                                                                                                                                                                                                                                                                                                end


                                                                                                                                                                                                                                                                                                sqf_slot=GetSqfConstantsDirectory;
                                                                                                                                                                                                                                                                                                if isempty(sqf_slot)
                                                                                                                                                                                                                                                                                                    return;
                                                                                                                                                                                                                                                                                                end


























                                                                                                                                                                                                                                                                                                DigitizationPointNameLength=8;


                                                                                                                                                                                                                                                                                                direc=GetSqfDirectory(fid,sqf_slot.SqfDigitizationPointSlot,function_name);
                                                                                                                                                                                                                                                                                                if isempty(direc)
                                                                                                                                                                                                                                                                                                    disp(['ERROR ( ',function_name,' ): This file is not Meg160 format!!']);
                                                                                                                                                                                                                                                                                                    return;
                                                                                                                                                                                                                                                                                                end




                                                                                                                                                                                                                                                                                                fseek(fid,direc.offset,'bof');


                                                                                                                                                                                                                                                                                                point=[];
                                                                                                                                                                                                                                                                                                if direc.count>0
                                                                                                                                                                                                                                                                                                    for no=1:direc.count
                                                                                                                                                                                                                                                                                                        name=fread(fid,DigitizationPointNameLength,'uchar');index=min(find(name==0));name=deblank(GetSqfData2str(name(1:index)));
                                                                                                                                                                                                                                                                                                        point(no).name=name;
                                                                                                                                                                                                                                                                                                        point(no).x=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                                        point(no).y=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                                        point(no).z=fread(fid,1,'double');
                                                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                                                end


                                                                                                                                                                                                                                                                                                fseek(fid,0,'bof');


                                                                                                                                                                                                                                                                                                out=point;

                                                                                                                                                                                                                                                                                            catch





                                                                                                                                                                                                                                                                                                str_error_message=sprintf('Exception : Sorry, reading error was occurred. (Digitization Point)');

                                                                                                                                                                                                                                                                                                disp(str_error_message);
                                                                                                                                                                                                                                                                                                return;
                                                                                                                                                                                                                                                                                            end














                                                                                                                                                                                                                                                                                            function str_out=GetSqfData2str(str_in)



                                                                                                                                                                                                                                                                                                try
                                                                                                                                                                                                                                                                                                    function_revision=0;
                                                                                                                                                                                                                                                                                                    function_name='GetSqfData2str';


                                                                                                                                                                                                                                                                                                    str_out=[];


                                                                                                                                                                                                                                                                                                    if nargin~=1
                                                                                                                                                                                                                                                                                                        disp(sprintf('ERROR [ %s ] Argument is illegal.',function_name));
                                                                                                                                                                                                                                                                                                        return;
                                                                                                                                                                                                                                                                                                    end

                                                                                                                                                                                                                                                                                                    tmp_ver=version;
                                                                                                                                                                                                                                                                                                    mat_ver=str2num(tmp_ver(1));
                                                                                                                                                                                                                                                                                                    if mat_ver<=6


                                                                                                                                                                                                                                                                                                        str_out=sprintf('%s',str_in);
                                                                                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                                                                                        str_out=native2unicode(str_in)';
                                                                                                                                                                                                                                                                                                        if str_in==0,str_out='';,end
                                                                                                                                                                                                                                                                                                    end

                                                                                                                                                                                                                                                                                                catch





                                                                                                                                                                                                                                                                                                    str_error_message=sprintf('Exception : Sorry, reading error was occurred. (data2str)');
                                                                                                                                                                                                                                                                                                    disp(str_error_message);
                                                                                                                                                                                                                                                                                                    return;
                                                                                                                                                                                                                                                                                                end

