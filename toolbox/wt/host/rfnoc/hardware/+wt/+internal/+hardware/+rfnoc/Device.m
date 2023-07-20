classdef Device<matlab.mixin.SetGet&matlab.mixin.Copyable




    properties(Abstract,Hidden,SetAccess=immutable)
AvailableMasterClockRate
Type
Product
ConnectionProperties
AvailableHardwareMemory
TransmitGainRange
ReceiveGainRange
TransmitCenterFrequencyRange
ReceiveCenterFrequencyRange
    end
    properties(Abstract,Hidden,SetAccess=protected)
MasterClockRate
    end
    properties(Hidden,Dependent)
AvailableSampleRates
    end
    properties(Access=private)
pAvailableSampleRates
    end
    properties(Abstract,Hidden)
ClockSource
TimeSource
CustomDeviceArgs
    end

    properties(Hidden,SetAccess=protected)
AvailableAntennas
AvailableTransmitAntennas
AvailableReceiveAntennas
    end

    properties(Hidden,SetAccess=protected)

        SampleRateMinThreshold=1;

        SampleRateMaxThreshold=1e3;
    end


    methods(Abstract,Hidden)
        args=getDeviceArgs(obj)
        success=setupHardware(obj,handoff);
        populateAntennas(obj)
        rates=calculateAvailableSampleRates(obj);
    end

    methods
        function val=get.AvailableSampleRates(obj)
            if isempty(obj.pAvailableSampleRates)
                obj.pAvailableSampleRates=calculateAvailableSampleRates(obj);
            end
            val=obj.pAvailableSampleRates(end,:);
        end
    end
    methods(Hidden)
        function checkNetworkConnection(~,IPAddress)

            arch=computer('arch');
            switch(arch)
            case{'win32','win64'}
                pingcmd=['ping -n 3 ',IPAddress];
            case{'glnxa64'}
                pingcmd=['ping -c 3 ',IPAddress];
            end
            [st,msg]=system(pingcmd);
            success=(st==0)&&~isempty(regexpi(msg,'\sTTL=','once'));
            if~success
                error(message("wt:rfnoc:hardware:RadioPingFailed",IPAddress))
            end
        end
        function validateReceiveGain(obj,val)
            mustBeNumeric(val);
            mustBeInRange(val,obj.ReceiveGainRange(1),obj.ReceiveGainRange(2));
            mustBeVector(val);
        end

        function validateTransmitGain(obj,val)
            mustBeNumeric(val);
            mustBeInRange(val,obj.TransmitGainRange(1),obj.TransmitGainRange(2));
            mustBeVector(val);
        end

        function val=getDefaultReceiveGain(obj)
            val=10;
            validateReceiveGain(obj,val);
        end
        function val=getDefaultTransmitGain(obj)
            val=10;
            validateTransmitGain(obj,val);
        end
        function validateReceiveCenterFrequency(obj,val)
            mustBeNumeric(val);
            mustBeInRange(val,obj.ReceiveCenterFrequencyRange(1),obj.ReceiveCenterFrequencyRange(2));
            mustBeVector(val);
        end

        function validateTransmitCenterFrequency(obj,val)
            mustBeNumeric(val);
            mustBeInRange(val,obj.TransmitCenterFrequencyRange(1),obj.TransmitCenterFrequencyRange(2));
            mustBeVector(val);
        end

        function val=getDefaultReceiveCenterFrequency(obj)
            val=2.4e9;
            validateReceiveCenterFrequency(obj,val);
        end
        function val=getDefaultTransmitCenterFrequency(obj)
            val=2.4e9;
            validateTransmitCenterFrequency(obj,val);
        end
        function validateReceiveAntennas(obj,val)
            mustBeText(val);
            mustBeVector(val);
            mustBeMember(val,obj.AvailableReceiveAntennas);
        end

        function validateTransmitAntennas(obj,val)
            mustBeText(val);
            mustBeVector(val);
            mustBeMember(val,obj.AvailableTransmitAntennas);
        end

        function val=getDefaultReceiveAntennas(obj)
            val=obj.AvailableReceiveAntennas(1);
        end
        function val=getDefaultTransmitAntennas(obj)
            val=obj.AvailableTransmitAntennas(1);
        end
        function setMasterClockRate(obj,val)
            mustBeMember(val,obj.AvailableMasterClockRate);
            obj.MasterClockRate=val;
        end
        function[blockID,channel]=getAntennaInfo(obj,antenna)
            if isKey(obj.AvailableAntennas,antenna)
                ant=obj.AvailableAntennas(antenna);
                blockID=ant.Block;
                channel=ant.Channel;
            else
                error(message("wt:rfnoc:hardware:InvalidAntenna",antenna,strjoin(keys(obj.AvailableAntennas),", ")));
            end
        end

        function[mcr,farrowFactor,factor,possibleRate]=getClockInfo(obj,rate)
            [farrowFactor,~,idx]=validateSampleRate(obj,rate);
            mcr=obj.pAvailableSampleRates(1,idx);
            factor=obj.pAvailableSampleRates(2,idx);
            possibleRate=obj.pAvailableSampleRates(3,idx);
        end






        function[farrowFactor,integerRate,index]=validateSampleRate(obj,val)


            mustBeNumeric(val);
            possibleRates=obj.AvailableSampleRates;
            mustBeInRange(val,min(possibleRates),max(possibleRates));
            validateattributes(val,{'numeric'},{'scalar'});
            [isValid,idxs]=ismember(val,possibleRates);
            if isValid
                index=idxs(end);
                integerRate=possibleRates(idxs(end));
                farrowFactor=1;
            else
                [farrowFactor,integerRate,index]=calculateASRCRatesHelper(obj,possibleRates,val);
            end
        end

        function val=getDefaultSampleRate(obj)
            val=obj.AvailableSampleRates(end);
        end
        function tf=isMasterClockRateSupported(obj,val)
            tf=any(ismember(val,obj.AvailableMasterClockRate));
        end
        function[bytes,alignment]=getAvailableHardwareMemory(obj)
            bytes=obj.AvailableHardwareMemory;
            alignment=8;
        end
        function setConnectionAddress(obj,name,address)
            mustBeMember(name,obj.ConnectionProperties);
            for n=1:length(obj.ConnectionProperties)
                if isequal(name,obj.ConnectionProperties(n))
                    set(obj,name,address);
                end
            end
        end

        function rates=calculateAvailableSampleRatesHelper(obj,factors)
            sortedMCR=sort(obj.AvailableMasterClockRate);
            totalSampleRates=zeros(3,length(factors)*length(sortedMCR));

            for n=1:length(sortedMCR)
                totalSampleRates(:,(n-1)*length(factors)+1:(n)*length(factors))=[sortedMCR(n)*ones(1,length(factors));factors;sortedMCR(n)./factors];
            end


            [~,idx]=unique(totalSampleRates(end,:));
            rates=totalSampleRates(:,idx);
        end

        function[farrowFactor,integerRate,index]=calculateASRCRatesHelper(obj,possibleRates,targetSampleRate)

            if targetSampleRate<possibleRates(end)


                integerRate=interp1(possibleRates,possibleRates,targetSampleRate,'next');


                [~,index]=ismembertol(integerRate,possibleRates,1e-12);
            end

            if ismember(integerRate,obj.AvailableMasterClockRate)
                error(message("wt:rfnoc:hardware:InvalidSampleRateASRC",strjoin(string(obj.AvailableMasterClockRate))));
            end

            farrowFactor=integerRate/targetSampleRate;
        end

    end
end
