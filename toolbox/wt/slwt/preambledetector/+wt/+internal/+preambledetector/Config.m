classdef Config<handle

    properties(Constant,Access=protected)
        F=fimath('OverflowAction','Wrap','RoundingMethod','Nearest');
        T=numerictype(1,16,15)
    end

    properties(Access=protected)
FiltersetNum
    end

    properties
WaveformName
SampleRate
Ts
CenterFrequency
ReceiverGain
TransmitterGain
Antennas
FilterArchitecture
FilterCoefficients
ThresholdMethod
FixedThreshold
AdaptiveThresholdWindowLength
AdaptiveThresholdScaler
DelayNum
MinThreshold
TriggerSelect
RecordNum
WaitNum
    end

    properties(SetAccess=protected,GetAccess=public)
FilterCoefficientsQuant
ReuseFactor
FilterCoefficientsHW
ReuseFactorHW
    end


    properties(Constant,Access=protected)
        y_vht=[-0.2774+0.0000i,0.0218-0.1732i,0.1628-0.1879i,-0.1631-0.2044i,-0.0050-0.0955i,...
        0.1333+0.1314i,-0.2260+0.0364i,-0.2164+0.0294i,-0.0622+0.2678i,-0.1002+0.0387i...
        ,-0.1071-0.1443i,0.1235-0.0251i,0.1459-0.1639i,-0.2330-0.1158i,-0.1015-0.0698i,...
        0.0655-0.1746i,0.1109+0.1109i,0.2117+0.0073i,-0.0399-0.2852i,0.1041+0.0265i,...
        0.0434+0.1039i,-0.2428+0.0841i,0.0018+0.2041i,0.0947-0.0072i,0.1731+0.0460i,...
        -0.0680+0.1885i,-0.2044+0.0979i,0.1062+0.1557i,0.0375-0.0495i,0.1719-0.1470i,...
        0.0706+0.1973i,-0.0091+0.2136i,0.2774+0.0000i,-0.0091-0.2136i,0.0706-0.1973i,...
        0.1719+0.1470i,0.0375+0.0495i,0.1062-0.1557i,-0.2044-0.0979i,-0.0680-0.1885i,...
        0.1731-0.0460i,0.0947+0.0072i,0.0018-0.2041i,-0.2428-0.0841i,0.0434-0.1039i,...
        0.1041-0.0265i,-0.0399+0.2852i,0.2117-0.0073i,0.1109-0.1109i,0.0655+0.1746i,...
        -0.1015+0.0698i,-0.2330+0.1158i,0.1459+0.1639i,0.1235+0.0251i,-0.1071+0.1443i,...
        -0.1002-0.0387i,-0.0622-0.2678i,-0.2164-0.0294i,-0.2260-0.0364i,0.1333-0.1314i,...
        -0.0050+0.0955i,-0.1631+0.2044i,0.1628+0.1879i,0.0218+0.1732i,-0.2774+0.0000i,...
        0.0218-0.1732i,0.1628-0.1879i,-0.1631-0.2044i,-0.0050-0.0955i,0.1333+0.1314i,...
        -0.2260+0.0364i,-0.2164+0.0294i,-0.0622+0.2678i,-0.1002+0.0387i,-0.1071-0.1443i,...
        0.1235-0.0251i,0.1459-0.1639i,-0.2330-0.1158i,-0.1015-0.0698i,0.0655-0.1746i,...
        0.1109+0.1109i,0.2117+0.0073i,-0.0399-0.2852i,0.1041+0.0265i,0.0434+0.1039i,...
        -0.2428+0.0841i,0.0018+0.2041i,0.0947-0.0072i,0.1731+0.0460i,-0.0680+0.1885i,...
        -0.2044+0.0979i,0.1062+0.1557i,0.0375-0.0495i,0.1719-0.1470i,0.0706+0.1973i,...
        -0.0091+0.2136i,0.2774+0.0000i,-0.0091-0.2136i,0.0706-0.1973i,0.1719+0.1470i,...
        0.0375+0.0495i,0.1062-0.1557i,-0.2044-0.0979i,-0.0680-0.1885i,0.1731-0.0460i,...
        0.0947+0.0072i,0.0018-0.2041i,-0.2428-0.0841i,0.0434-0.1039i,0.1041-0.0265i,...
        -0.0399+0.2852i,0.2117-0.0073i,0.1109-0.1109i,0.0655+0.1746i,-0.1015+0.0698i,...
        -0.2330+0.1158i,0.1459+0.1639i,0.1235+0.0251i,-0.1071+0.1443i,-0.1002-0.0387i,...
        -0.0622-0.2678i,-0.2164-0.0294i,-0.2260-0.0364i,0.1333-0.1314i,-0.0050+0.0955i,...
        -0.1631+0.2044i,0.1628+0.1879i,0.0218+0.1732i,-0.2774+0.0000i,0.0218-0.1732i,...
        0.1628-0.1879i,-0.1631-0.2044i,-0.0050-0.0955i,0.1333+0.1314i,-0.2260+0.0364i,...
        -0.2164+0.0294i,-0.0622+0.2678i,-0.1002+0.0387i,-0.1071-0.1443i,0.1235-0.0251i,...
        0.1459-0.1639i,-0.2330-0.1158i,-0.1015-0.0698i,0.0655-0.1746i,0.1109+0.1109i,...
        0.2117+0.0073i,-0.0399-0.2852i,0.1041+0.0265i,0.0434+0.1039i,-0.2428+0.0841i,...
        0.0018+0.2041i,0.0947-0.0072i,0.1731+0.0460i,-0.0680+0.1885i,-0.2044+0.0979i,...
        0.1062+0.1557i,0.0375-0.0495i,0.1719-0.1470i,0.0706+0.1973i,-0.0091+0.2136i].';
    end


    methods
        function obj=Config(wavename)
            obj.WaveformName=wavename;
            if(~strcmp(wavename,'Custom'))
                obj.presetWaveforms();
            else

                obj.SampleRate=20e6;
                obj.Ts=1/obj.SampleRate;
            end
        end

        function[VariableData,ConstantData,SimDataBus]=getDataForSimulation(obj,sampleData)
            if nargin<2
                [sampleData,datalength]=obj.getSampleData();
            else
                datalength=180+length(obj.FilterCoefficients);
            end
            dataIn=[sampleData;zeros(datalength,1)];
            dataIn=fi(dataIn,obj.T,obj.F);
            dataIn=storedInteger(dataIn);

            simpar.StartTime=15;
            simpar.FilterTime=9000;
            simpar.CoeffGap=15;
            simpar.FilterStartGap=18;
            simpar.FilterTime=length(dataIn)*obj.ReuseFactor+200;

            t_coeff_axi=...
            [zeros(simpar.StartTime,1);...
            obj.FilterCoefficientsHW{1}(1:32);0;...
            obj.FilterCoefficientsHW{1}(33);0;obj.FilterCoefficientsHW{1}(34);0;obj.FilterCoefficientsHW{1}(35:64);...
            obj.FilterCoefficientsHW{1}(65:94);obj.FilterCoefficientsHW{1}(95);0;obj.FilterCoefficientsHW{1}(96);
            obj.FilterCoefficientsHW{1}(97:512);...
            zeros(simpar.CoeffGap-4,1);...
            obj.FilterCoefficientsHW{2}(1:32);0;...
            obj.FilterCoefficientsHW{2}(33);0;obj.FilterCoefficientsHW{2}(34);0;obj.FilterCoefficientsHW{2}(35:64);...
            obj.FilterCoefficientsHW{2}(65:94);obj.FilterCoefficientsHW{2}(95);0;obj.FilterCoefficientsHW{2}(96);
            obj.FilterCoefficientsHW{2}(97:512);...
            zeros(simpar.CoeffGap-4,1);...
            obj.FilterCoefficientsHW{3}(1:32);0;...
            obj.FilterCoefficientsHW{3}(33);0;obj.FilterCoefficientsHW{3}(34);0;obj.FilterCoefficientsHW{3}(35:64);...
            obj.FilterCoefficientsHW{3}(65:94);obj.FilterCoefficientsHW{3}(95);0;obj.FilterCoefficientsHW{3}(96);
            obj.FilterCoefficientsHW{3}(97:512);...
            zeros(simpar.FilterStartGap-4,1);zeros(simpar.FilterTime,1)];
            t_coeff_validin=...
            [zeros(simpar.StartTime,1);...
            ones(32,1);0;...
            1;0;1;0;ones(30,1);...
            ones(31,1);0;1;...
            ones(512-96,1);...
            zeros(simpar.CoeffGap-4,1);...
            ones(32,1);0;...
            1;0;1;0;ones(30,1);...
            ones(31,1);0;1;...
            ones(512-96,1);...
            zeros(simpar.CoeffGap-4,1);...
            ones(32,1);0;...
            1;0;1;0;ones(30,1);...
            ones(31,1);0;1;...
            ones(512-96,1);...
            zeros(simpar.FilterStartGap-4,1);zeros(simpar.FilterTime,1)];
            t_coeff_lastin=...
            [zeros(simpar.StartTime,1);zeros(32,1);...
            0;0;zeros(32,1);...
            0;0;[zeros(511-64,1);1];...
            zeros(simpar.CoeffGap-4,1);zeros(32,1);...
            0;0;zeros(32,1);...
            0;0;[zeros(511-64,1);1];...
            zeros(simpar.CoeffGap-4,1);zeros(32,1);...
            0;0;zeros(32,1);...
            0;0;[zeros(511-64,1);1];...
            zeros(simpar.FilterStartGap-4,1);zeros(simpar.FilterTime,1)];

            t_lv=...
            [zeros(simpar.StartTime-9,1);ones(9,1);ones(512,1);...
            ones(9,1);ones(simpar.CoeffGap-9,1)*2;ones(512,1)*2;...
            ones(9,1)*2;ones(simpar.CoeffGap-9,1)*3;ones(512,1)*3;...
            ones(9,1)*3;zeros(simpar.FilterStartGap-9,1);zeros(simpar.FilterTime,1)];

            t_prog=...
            [zeros(5,1);ones(simpar.StartTime-5,1);ones(512,1);...
            ones(simpar.CoeffGap,1);ones(512,1);...
            ones(simpar.CoeffGap,1);ones(512,1);...
            ones(9,1);zeros(simpar.FilterStartGap-9,1);zeros(simpar.FilterTime,1)];

            axi_sel=...
            [zeros(2,1);ones(simpar.StartTime-2,1);zeros(512,1);...
            zeros(simpar.CoeffGap,1);zeros(512,1);...
            zeros(simpar.CoeffGap,1);zeros(512,1);...
            zeros(9,1);ones(simpar.FilterStartGap-9,1);ones(simpar.FilterTime,1)];

            if(length(dataIn)<1025)
                t_datain=dataIn.';
                dataLength=length(t_datain);
                t_data_validin=ones(length(t_datain),1);
            else
                dataIn=dataIn.';
                t_data_validin=ones(1,length(dataIn));
                dataIn(2:obj.ReuseFactor,:)=0;
                t_data_validin(2:obj.ReuseFactor,:)=0;
                t_data_validin=t_data_validin(:);
                t_datain=dataIn(:);
                dataLength=length(t_datain);
            end
            temp=complex(int16(zeros(simpar.FilterTime,1)));
            temp(1:dataLength)=t_datain;
            t_data_axi=...
            [zeros(simpar.StartTime,1);zeros(512,1);...
            zeros(simpar.CoeffGap,1);zeros(512,1);...
            zeros(simpar.CoeffGap,1);zeros(512,1);...
            zeros(simpar.FilterStartGap,1);...
            temp];
            temp=zeros(simpar.FilterTime,1);
            temp(1:dataLength)=t_data_validin;
            t_data_validin_axi=...
            [zeros(simpar.StartTime,1);zeros(512,1);...
            zeros(simpar.CoeffGap,1);zeros(512,1);...
            zeros(simpar.CoeffGap,1);zeros(512,1);...
            zeros(simpar.FilterStartGap,1);...
            temp];
            t_data_lastin_axi=...
            [zeros(simpar.StartTime,1);zeros(512,1);...
            zeros(simpar.CoeffGap,1);zeros(512,1);...
            zeros(simpar.CoeffGap,1);zeros(512,1);...
            zeros(simpar.FilterStartGap,1);...
            zeros(length(temp)-1,1);1];

            issamelength=length(unique([length(t_coeff_axi),...
            length(t_coeff_validin),...
            length(t_lv),...
            length(axi_sel),...
            length(t_data_axi),...
            length(t_data_validin_axi),...
            length(t_prog)]));
            if(issamelength~=1)
                warning(message('wt:preambledetector:UnmatchedSimulationInputLength'));
            end

            t_lv=fi(t_lv,0,2,0);
            t_coeff_validin_axi=logical(t_coeff_validin);
            t_coeff_lastin_axi=logical(t_coeff_lastin);
            t_data_validin_axi=logical(t_data_validin_axi);
            t_data_lastin_axi=logical(t_data_lastin_axi);

            ConstantData.ReuseFactor=obj.ReuseFactor-1;
            ConstantData.RecordNum=obj.RecordNum;
            ConstantData.TriggerSelect=obj.TriggerSelect;
            if(strcmp(obj.FilterArchitecture,'serial'))
                ConstantData.FilterArchitecture=true;
            elseif(strcmp(obj.FilterArchitecture,'parallel'))
                ConstantData.FilterArchitecture=false;
            else
                error(message('wt:preambledetector:UnknownFilterArchitecture',['''','serial',''''],['''','parallel',''''],['''',obj.FilterArchitecture,'''']));
            end
            ConstantData.DelayNum=obj.DelayNum;
            if strcmpi(obj.ThresholdMethod,'adaptive')
                ConstantData.ThresholdMethod=0;
            else
                ConstantData.ThresholdMethod=1;
            end
            ConstantData.FixedThreshold=obj.FixedThreshold;
            ConstantData.AdaptiveThresholdWindowLength=obj.AdaptiveThresholdWindowLength;
            ConstantData.AdaptiveThresholdScaler=obj.AdaptiveThresholdScaler;
            ConstantData.MinThreshold=obj.MinThreshold;
            ConstantData.WaitNum=obj.WaitNum;
            timeval=(0:length(t_data_axi)-1)*obj.Ts;

            VariableData.CoeffStreamer.Data=timeseries(t_coeff_axi,timeval);
            VariableData.CoeffStreamer.Valid=timeseries(t_coeff_validin_axi,timeval);
            VariableData.CoeffStreamer.Last=timeseries(t_coeff_lastin_axi,timeval);
            VariableData.Control.FIRSel=timeseries(t_lv,timeval);
            VariableData.Control.DataInEnb=timeseries(axi_sel,timeval);
            VariableData.DataStreamer.Data=timeseries(t_data_axi,timeval);
            VariableData.DataStreamer.Valid=timeseries(t_data_validin_axi,timeval);
            VariableData.DataStreamer.Last=timeseries(t_data_lastin_axi,timeval);
            VariableData.Control.Program=timeseries(t_prog,timeval);
            busInfo=Simulink.Bus.createObject(VariableData);
            SimDataBus=evalin('base',busInfo.busName);
            evalin('base','clear slBus1');
        end

        function referenceSignal=getReferenceSignal(obj)
            [sampledata,~]=obj.getSampleData;
            referenceSignal=fi(sampledata,obj.T,obj.F);
        end

        function generateHWCoefficients(obj,filterCoefficients,filterArchitecture)






            MACs=16;

            obj.FilterCoefficientsQuant=fi(filterCoefficients,obj.T,obj.F);
            if(filterArchitecture==1)
                filterLength=length(filterCoefficients);
                possibleReuseFactor=ceil(ceil(filterLength/MACs)./[1,2,3]);
                obj.ReuseFactor=min(possibleReuseFactor);
                obj.FiltersetNum=find(possibleReuseFactor==obj.ReuseFactor,1);
                obj.AdaptiveThresholdWindowLength=filterLength;
                obj.TriggerSelect=obj.FiltersetNum-1;
                obj.DelayNum=filterLength-1;
                obj.AdaptiveThresholdScaler=0.83;
                obj.MinThreshold=0.004;
                obj.FilterArchitecture=filterArchitecture;
                paddingNum=obj.ReuseFactor*MACs*obj.FiltersetNum-filterLength;
                paddedMatchedFilter=[filterCoefficients;zeros(paddingNum,1)];
                temp=reshape(paddedMatchedFilter,[],MACs*obj.FiltersetNum);
                temp(:,(16*obj.FiltersetNum+1):48)=0;
                temp(obj.ReuseFactor+1:32,:)=0;
                temp=temp(:);
                temp((length(temp)+1):1536)=0;
                temp=fi(temp,obj.T,obj.F);
                temp=storedInteger(temp);
                obj.FilterCoefficientsHW={temp(1:512);temp(513:1024);temp(1025:1536)};
                obj.FilterCoefficientsHW={temp(1:512);temp(513:1024);temp(1025:1536)};
            elseif(filterArchitecture==0)
                issamelength=length(unique([length(filterCoefficients(:,1)),...
                length(filterCoefficients(:,2)),...
                length(filterCoefficients(:,3))]));
                if(issamelength~=1)
                    error(message('wt:preambledetector:UnmatchedCoefficientsLength'));
                end
                filterLength=length(filterCoefficients(:,1));
                obj.ReuseFactor=ceil(filterLength/MACs);
                obj.FilterArchitecture=filterArchitecture;
                paddingNum=obj.ReuseFactor*MACs-filterLength;
                paddedMatchedFilter=[filterCoefficients;zeros(paddingNum,3)];
                temp=reshape(paddedMatchedFilter,[],48);
                obj.ReuseFactor=size(temp,1);

                temp(MACs+1:32,:)=0;
                temp=temp(:);
                temp=fi(temp,obj.T,obj.F);
                temp=storedInteger(temp);
                obj.FilterCoefficientsHW={temp(1:512);temp(513:1024);temp(1025:1536)};
            else
                obj.FilterCoefficientsHW=[];
                error(message('wt:preambledetector:InvalidPresetWaveform'));
            end
            obj.FilterCoefficients=filterCoefficients;
        end
    end

    methods(Access=protected)
        function[sampledata,dummydatalength]=getSampleData(obj)


            dummydatalength=300;
            switch(obj.WaveformName)
            case 'WLAN 20MHz'
                sampledata=obj.y_vht;
            case 'WLANFrame 20MHz'
                nonHTCfg=wlanNonHTConfig('Modulation','OFDM',...
                'ChannelBandwidth','CBW20',...
                'MCS',4,...
                'PSDULength',1000);
                numPackets=1;

                in=ones(1000,1);

                sampledata=wlanWaveformGenerator(in,nonHTCfg,...
                'NumPackets',numPackets,...
                'IdleTime',0,...
                'ScramblerInitialization',93,...
                'WindowTransitionTime',1e-07);
                sampledata=sampledata/5;
            case '5GNR PSS'
                dummydatalength=500;
                sampledata=ifft(fftshift([nrPSS(1);0]));
                sampledata=sampledata/sqrt(sampledata'*sampledata);
            otherwise
                error(message('wt:preambledetector:InvalidPresetWaveform'));
            end
        end

        function presetWaveforms(obj)
            switch obj.WaveformName
            case{'WLAN 20MHz','none'}
                Taps=64;
                matchedFilter=flipud(conj(obj.y_vht(Taps/2+1:Taps/2*3)));
                matchedFilter=matchedFilter/sqrt(real(matchedFilter'*matchedFilter));

                obj.generateHWCoefficients(matchedFilter,1);

                obj.SampleRate=20e6;
                obj.Ts=1/obj.SampleRate;
                obj.CenterFrequency=2.4e9;
                obj.ReceiverGain=10;
                obj.TransmitterGain=10;
                obj.Antennas='RF0';

                obj.FilterArchitecture='serial';
                obj.FilterCoefficients=matchedFilter;

                obj.ThresholdMethod='adaptive';
                obj.FixedThreshold=0.5;
                obj.AdaptiveThresholdWindowLength=Taps;
                obj.AdaptiveThresholdScaler=0.85;
                obj.DelayNum=Taps+Taps/2-1;
                obj.MinThreshold=0.004;
                obj.TriggerSelect=obj.FiltersetNum-1;
                obj.RecordNum=159;
                obj.ReuseFactorHW=obj.ReuseFactor-1;
                obj.WaitNum=0;
            case 'WLANFrame 20MHz'
                Taps=64;
                matchedFilter=flipud(conj(obj.y_vht(Taps/2+1:Taps/2*3)));
                matchedFilter=matchedFilter/sqrt(real(matchedFilter'*matchedFilter));

                obj.generateHWCoefficients(matchedFilter,1);

                obj.SampleRate=20e6;
                obj.Ts=1/obj.SampleRate;
                obj.CenterFrequency=2.4e9;
                obj.ReceiverGain=10;
                obj.TransmitterGain=10;
                obj.Antennas='RF0';

                obj.FilterArchitecture='serial';
                obj.FilterCoefficients=matchedFilter;

                obj.ThresholdMethod='adaptive';
                obj.FixedThreshold=0.5;
                obj.AdaptiveThresholdWindowLength=Taps;
                obj.AdaptiveThresholdScaler=0.85;
                obj.DelayNum=Taps+Taps/2+160-1+3;
                obj.MinThreshold=0.004;
                obj.TriggerSelect=obj.FiltersetNum-1;
                obj.RecordNum=7119;
                obj.ReuseFactorHW=obj.ReuseFactor-1;
                obj.WaitNum=0+2;
            case '5GNR PSS'
                psscoef0=ifft(fftshift([nrPSS(0);0]));
                psscoef0=psscoef0/sqrt(psscoef0'*psscoef0);
                psscoef1=ifft(fftshift([nrPSS(1);0]));
                psscoef1=psscoef1/sqrt(psscoef1'*psscoef1);
                psscoef2=ifft(fftshift([nrPSS(2);0]));
                psscoef2=psscoef2/sqrt(psscoef2'*psscoef2);
                matchedFilter=flipud(conj([psscoef0,psscoef1,psscoef2]));

                obj.generateHWCoefficients(matchedFilter,0);

                obj.SampleRate=30.72e6;
                obj.Ts=1/obj.SampleRate;
                obj.CenterFrequency=2.4e9;
                obj.ReceiverGain=10;
                obj.TransmitterGain=10;
                obj.Antennas='RF0';

                obj.FilterArchitecture='parallel';
                obj.FilterCoefficients=matchedFilter;
                obj.ThresholdMethod='adaptive';
                obj.FixedThreshold=0.5;
                obj.AdaptiveThresholdWindowLength=length(psscoef0);
                obj.AdaptiveThresholdScaler=0.5;
                obj.DelayNum=length(psscoef0)-1;
                obj.MinThreshold=0.004;
                obj.TriggerSelect=3;
                obj.RecordNum=127;
                obj.ReuseFactorHW=obj.ReuseFactor-1;
                obj.WaitNum=0;
            otherwise
                error(message('wt:preambledetector:InvalidPresetWaveform'));
            end

















































        end
    end
end


