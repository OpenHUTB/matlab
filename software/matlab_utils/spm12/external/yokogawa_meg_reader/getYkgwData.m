





















































function out=getYkgwData(varargin)
    try
        function_revision=7;
        function_name='getYkgwData';




        out=[];


        if nargin>3
            disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
            return;
        end
        if nargin==3
            sample_length=varargin{3};
        else
            sample_length=Inf;
        end
        if nargin>=2
            start_sample=varargin{2};
        else
            start_sample=0;
        end
        if nargin>=1
            filepath=varargin{1};
        else
            disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
            return;
        end


        key='tzsvq27h';

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


        fid=fopen(filepath,'rb','ieee-le');
        if fid==-1
            disp('ERROR: File can not be opened!');
            return;
        end




        sqf_sysinfo=GetSqf(fid,key,'SystemInfo');
        if isempty(sqf_sysinfo)
            disp(['ERROR ( ',function_name,' ): Sorry, could not read header information.']);
            fclose(fid);
            return;
        end


        sqf_channel=GetSqf(fid,key,'Channel',sqf_sysinfo);
        if isempty(sqf_channel)
            disp(['ERROR ( ',function_name,' ): Sorry, could not read header information.']);
            fclose(fid);
            return;
        end


        sqf_fll=GetSqf(fid,key,'FLL');
        if isempty(sqf_fll)
            disp(['ERROR ( ',function_name,' ): Sorry, could not read header information.']);
            fclose(fid);
            return;
        end


        sqf_afa=GetSqf(fid,key,'AFA');
        if isempty(sqf_afa)
            disp(['ERROR ( ',function_name,' ): Sorry, could not read header information.']);
            fclose(fid);
            return;
        end


        sqf_calib=GetSqf(fid,key,'Calibration',sqf_sysinfo,sqf_channel,sqf_fll,sqf_afa);
        if isempty(sqf_calib)
            disp(['ERROR ( ',function_name,' ): Sorry, could not read header information.']);
            fclose(fid);
            return;
        end


        sqf_acqcond=GetSqf(fid,key,'AcqCondition',sqf_sysinfo,sqf_channel);
        if isempty(sqf_acqcond)
            disp(['ERROR ( ',function_name,' ): Sorry, could not read header information.']);
            fclose(fid);
            return;
        end


        ContinuousRawDataAcquisition=1;
        EvokedAverageDataAcquisition=2;
        EvokedRawDataAcquisition=3;
        switch sqf_acqcond.acq_type
        case ContinuousRawDataAcquisition
        case EvokedRawDataAcquisition
            if start_sample==0
                start_sample=1;
            end
        case EvokedAverageDataAcquisition
        otherwise
        end


        data=GetSqf(fid,key,'Data',start_sample,sample_length,sqf_sysinfo,sqf_channel,sqf_acqcond);
        if isempty(data)
            disp(['ERROR ( ',function_name,' ): Sorry, could not read data.']);
            fclose(fid);
            return;
        end



        [channel_count,sample_count]=size(data);
        out=zeros(channel_count,sample_count);


        for ch=1:sqf_sysinfo.channel_count
            switch sqf_channel(ch).type
            case MagnetoMeter
                unit_type='tesla';
            case AxialGradioMeter
                unit_type='tesla';
            case PlannerGradioMeter
                unit_type='tesla';
            case RefferenceMagnetoMeter
                unit_type='tesla';
            case RefferenceAxialGradioMeter
                unit_type='tesla';
            case RefferencePlannerGradioMeter
                unit_type='tesla';
            case TriggerChannel
                unit_type='volt';
            case EegChannel
                if sqf_channel(ch).data.type==1
                    unit_type='NK';
                else
                    unit_type='volt';
                end
            case EcgChannel
                unit_type='volt';
            case EtcChannel
                unit_type='volt';
            case NullChannel
                unit_type='volt';
            otherwise
                disp(['ERROR ( ',function_name,' ): Channel information is illegal.']);
                fclose(fid);
                return;
            end

            out(ch,:)=GetCalibrationData(data(ch,:),sqf_sysinfo,sqf_acqcond,sqf_channel(ch),sqf_calib.calib_data(ch).offset,sqf_calib.calib_data(ch).gain,unit_type);



            switch sqf_channel(ch).type
            case EegChannel
                if sqf_channel(ch).data.type==1

                else
                    out(ch,:)=out(ch,:)./sqf_channel(ch).data.gain;
                end
            case EcgChannel
                out(ch,:)=out(ch,:)./sqf_channel(ch).data.gain;
            end
        end


        fclose(fid);

    catch

        last_error=lasterror;



        switch last_error.identifier
        case 'MATLAB:nomem'
            str_error_message=sprintf('Exception : Sorry, not enough memory. (data)');
        otherwise
            str_error_message=sprintf('Exception : Sorry, reading error was occurred. (data)');
        end

        try
            fclose(fid);
        catch
        end

        disp(str_error_message);
    end



    function calib_data=GetCalibrationData(data,sqf_sysinfo,sqf_acqcond,sqf_channel,calib_offset,calib_gain,unit_type)





















        calib_data=[];


        AdcAnalogRange4=8.0;
        AdcAnalogRange5=10.0;
        AdcAnalogZero=0.0;
        AdcDigitalZero=0;
        AdcDigitalMin12=-2048;
        AdcDigitalMax12=2047;
        AdcDigitalRange12=4096;
        AdcDigitalMin14=-8192;
        AdcDigitalMax14=8191;
        AdcDigitalRange14=16384;
        AdcDigitalMin16=-32768;
        AdcDigitalMax16=32767;
        AdcDigitalRange16=65536;
        AdcAtoDConvPara16=6553.4;

        ContinuousRawDataAcquisition=1;
        EvokedAverageDataAcquisition=2;
        EvokedRawDataAcquisition=3;
        VarianceDataAcquisition=8;
        MarkerDataAcquisition=9;
        EvokedBothDataAcquisition=10;
        MarkerDataShotAcquisition=19;
        AllDataAcquisition=999;
        NoDataAcquisition=-1;


        switch sqf_acqcond.acq_type
        case ContinuousRawDataAcquisition
            data=double(data);
        case EvokedAverageDataAcquisition

        case EvokedRawDataAcquisition
            data=double(data);
        end


        m_fAdcAnalogRange=sqf_sysinfo.adc_range;
        if sqf_sysinfo.adc_allocated==16&&sqf_sysinfo.adc_stored==12
            m_nAdcDigitalMin=AdcDigitalMin12;
            m_nAdcDigitalMax=AdcDigitalMax12;
            m_nAdcDigitalRange=AdcDigitalRange12;
        elseif sqf_sysinfo.adc_allocated==16&&sqf_sysinfo.adc_stored==14
            m_nAdcDigitalMin=AdcDigitalMin14;
            m_nAdcDigitalMax=AdcDigitalMax14;
            m_nAdcDigitalRange=AdcDigitalRange14;
        elseif sqf_sysinfo.adc_allocated==16&&sqf_sysinfo.adc_stored==16
            m_nAdcDigitalMin=AdcDigitalMin16;
            m_nAdcDigitalMax=AdcDigitalMax16;
            m_nAdcDigitalRange=AdcDigitalRange16;
        else
            return;
        end
















        switch unit_type
        case 'tesla'



            calib_data=((data-AdcDigitalZero).*m_fAdcAnalogRange./m_nAdcDigitalRange-calib_offset).*calib_gain;
        case 'volt'





            calib_data=(data-AdcDigitalZero).*m_fAdcAnalogRange./m_nAdcDigitalRange;
        case 'NK'

            negative_idx=data<0;
            data(negative_idx)=data(negative_idx)+hex2dec('10000');
            calib_data=(data-sqf_channel.data.offset).*sqf_channel.data.gain;
        otherwise
            return;
        end

