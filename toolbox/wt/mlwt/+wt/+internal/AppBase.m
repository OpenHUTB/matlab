classdef AppBase<matlab.System

    properties(Dependent)
TransmitGain
ReceiveGain
TransmitCenterFrequency
ReceiveCenterFrequency
    end


    properties(Dependent,Nontunable)
SampleRate
ReceiveAntennas
TransmitAntennas
AvailableHardwareMemory
    end


    properties(Access=private)
pTransmitGain
pReceiveGain
pTransmitCenterFrequency
pReceiveCenterFrequency
pSampleRate
pReceiveAntennas
pTransmitAntennas
        pAllocatedHardwareMemory=0;
    end


    properties(Access=protected)
RadioID
Radio
Driver
DeviceSetup
        pBytesPerSampleOTW=4;
        pPageSize=4096;
    end


    properties(Access=protected)
        DriverPropertyList={'Antennas',...
        'ReceiveCenterFrequency',...
        'TransmitCenterFrequency',...
        'SampleRate',...
        'TransmitGain',...
        'ReceiveGain',...
        'ReceiveAntennas',...
        'TransmitAntennas'};
    end


    properties(Abstract,Access=protected)
ApplicationID
PackageBase
    end


    properties
        HardwareSetupCompleted=false;
    end


    methods(Access=protected)

        function bytes=memoryRequired(obj,numChannels,numSamples)
            channelBytes=numSamples*obj.pBytesPerSampleOTW;
            channelAllocation=obj.pPageSize*ceil(channelBytes/obj.pPageSize);
            bytes=channelAllocation*numChannels;
        end


        function allocateHardwareMemory(obj,numChannels,numSamples,errorID)

            if canAllocateHardwareMemory(obj,numChannels,numSamples)
                bytesToAllocate=memoryRequired(obj,numChannels,numSamples);
                obj.pAllocatedHardwareMemory=obj.pAllocatedHardwareMemory+bytesToAllocate;
            else
                error(message(errorID,numChannels*numSamples,floor((obj.AvailableHardwareMemory-obj.pAllocatedHardwareMemory)/obj.pBytesPerSampleOTW)));
            end
        end


        function canAllocate=canAllocateHardwareMemory(obj,numChannels,numSamples)
            bytesToCheck=memoryRequired(obj,numChannels,numSamples);
            canAllocate=obj.pAllocatedHardwareMemory+bytesToCheck<=obj.AvailableHardwareMemory;
        end


        function allocatedHardwareMemory=freeHardwareMemory(obj,numChannels,numSamples)
            bytesToFree=memoryRequired(obj,numChannels,numSamples);
            allocatedHardwareMemory=obj.pAllocatedHardwareMemory-bytesToFree;
            if allocatedHardwareMemory>0
                obj.pAllocatedHardwareMemory=allocatedHardwareMemory;
            else
                obj.pAllocatedHardwareMemory=0;
            end
        end
    end


    methods
        function value=getExpandedValue(~,possibleValues,index)
            if isscalar(possibleValues)
                value=possibleValues;
            else
                value=possibleValues(index);
            end
        end


        function set.SampleRate(obj,val)
            validateSampleRate(obj,val);
            obj.pSampleRate=val;
        end


        function val=get.SampleRate(obj)
            if isempty(obj.pSampleRate)
                obj.pSampleRate=getDefaultSampleRate(obj);
            end
            val=obj.pSampleRate;
        end


        function set.ReceiveCenterFrequency(obj,val)
            validateReceiveCenterFrequency(obj,val);
            obj.pReceiveCenterFrequency=val;
        end


        function val=get.ReceiveCenterFrequency(obj)
            if isempty(obj.pReceiveCenterFrequency)
                obj.pReceiveCenterFrequency=getDefaultReceiveCenterFrequency(obj);
            end
            val=obj.pReceiveCenterFrequency;
        end


        function set.TransmitCenterFrequency(obj,val)
            validateTransmitCenterFrequency(obj,val);
            obj.pTransmitCenterFrequency=val;
        end


        function val=get.TransmitCenterFrequency(obj)
            if isempty(obj.pTransmitCenterFrequency)
                obj.pTransmitCenterFrequency=getDefaultTransmitCenterFrequency(obj);
            end
            val=obj.pTransmitCenterFrequency;
        end


        function set.ReceiveGain(obj,val)
            validateReceiveGain(obj,val);
            obj.pReceiveGain=val;
        end


        function val=get.ReceiveGain(obj)
            if isempty(obj.pReceiveGain)
                obj.pReceiveGain=getDefaultReceiveGain(obj);
            end
            val=obj.pReceiveGain;
        end


        function set.TransmitGain(obj,val)
            validateTransmitGain(obj,val);
            obj.pTransmitGain=val;
        end


        function val=get.TransmitGain(obj)
            if isempty(obj.pTransmitGain)
                obj.pTransmitGain=getDefaultTransmitGain(obj);
            end
            val=obj.pTransmitGain;
        end


        function set.ReceiveAntennas(obj,val)
            validateReceiveAntennas(obj,val);
            obj.pReceiveAntennas=val;
        end


        function val=get.ReceiveAntennas(obj)
            if isempty(obj.pReceiveAntennas)
                obj.pReceiveAntennas=getDefaultReceiveAntennas(obj);
            end
            val=obj.pReceiveAntennas;
        end


        function set.TransmitAntennas(obj,val)
            validateTransmitAntennas(obj,val);
            obj.pTransmitAntennas=val;
        end


        function val=get.TransmitAntennas(obj)
            if isempty(obj.pTransmitAntennas)
                obj.pTransmitAntennas=getDefaultTransmitAntennas(obj);
            end
            val=obj.pTransmitAntennas;
        end


        function val=get.AvailableHardwareMemory(obj)
            val=obj.Radio.getAvailableHardwareMemory();
        end


        function obj=AppBase(radioID,varargin)

            setProperties(obj,nargin-1,varargin{:});
            obj.RadioID=radioID;
            obj.Radio=wt.internal.hardware.RadioManager.leaseRadio(obj.RadioID,obj.ApplicationID);
            obj.DeviceSetup=wt.internal.getDeviceSetup(obj.Radio,obj,obj.PackageBase);
        end
    end


    methods(Hidden)
        function delete(obj)
            if~isempty(obj.Radio)
                wt.internal.hardware.RadioManager.returnRadio(obj.RadioID,obj.ApplicationID);
            end
        end
    end


    methods(Access=protected)
        function[farrotFactor,integerRate,index]=validateSampleRate(obj,val)
            [farrotFactor,integerRate,index]=validateSampleRate(obj.Radio,val);
        end


        function val=getDefaultSampleRate(obj)
            val=getDefaultSampleRate(obj.Radio);
        end


        function validateTransmitCenterFrequency(obj,val)
            validateTransmitCenterFrequency(obj.Radio,val);
        end


        function val=getDefaultTransmitCenterFrequency(obj)
            val=getDefaultTransmitCenterFrequency(obj.Radio);
        end


        function validateReceiveCenterFrequency(obj,val)
            validateReceiveCenterFrequency(obj.Radio,val);
        end


        function val=getDefaultReceiveCenterFrequency(obj)
            val=getDefaultReceiveCenterFrequency(obj.Radio);
        end


        function validateTransmitGain(obj,val)
            validateTransmitGain(obj.Radio,val);
        end


        function val=getDefaultTransmitGain(obj)
            val=getDefaultTransmitGain(obj.Radio);
        end


        function validateReceiveGain(obj,val)
            validateReceiveGain(obj.Radio,val);
        end


        function val=getDefaultReceiveGain(obj)
            val=getDefaultReceiveGain(obj.Radio);
        end


        function validateTransmitAntennas(obj,val)
            validateTransmitAntennas(obj.Radio,val);
        end


        function val=getDefaultTransmitAntennas(obj)
            val=getDefaultTransmitAntennas(obj.Radio);
        end


        function validateReceiveAntennas(obj,val)
            validateReceiveAntennas(obj.Radio,val);
        end


        function val=getDefaultReceiveAntennas(obj)
            val=getDefaultReceiveAntennas(obj.Radio);
        end


        function setupHardware(obj)
            if~obj.HardwareSetupCompleted
                obj.Driver=wt.internal.getDriver(obj.Radio,obj,obj.PackageBase);

                try
                    skipSetup=canRadioRunApplication(obj.DeviceSetup,obj.Driver);
                catch
                    skipSetup=false;
                end
                if~skipSetup
                    try
                        delete(obj.Driver);
                        obj.HardwareSetupCompleted=obj.DeviceSetup.setupHardware();
                    catch ME
                        throwAsCaller(ME);
                    end
                end
            end
        end


        function setupImpl(obj,varargin)

            obj.setupHardware();
            obj.Driver=wt.internal.getDriver(obj.Radio,obj,obj.PackageBase);
            obj.Driver.configure(obj.DriverPropertyList);
        end


        function processTunedPropertiesImpl(obj)
            numTransmitAntennas=length(obj.TransmitAntennas);
            numReceiveAntennas=length(obj.ReceiveAntennas);
            if isChangedProperty(obj,'TransmitGain')

                for n=1:numTransmitAntennas
                    obj.Driver.setTransmitGain(obj.TransmitAntennas(n),getExpandedValue(obj,obj.TransmitGain,n));
                end
            end
            if isChangedProperty(obj,'ReceiveGain')

                for n=1:numReceiveAntennas
                    obj.Driver.setReceiveGain(obj.ReceiveAntennas(n),getExpandedValue(obj,obj.ReceiveGain,n));
                end
            end
            if isChangedProperty(obj,'TransmitCenterFrequency')

                for n=1:numTransmitAntennas
                    obj.Driver.setTransmitCenterFrequency(obj.TransmitAntennas(n),getExpandedValue(obj,obj.TransmitCenterFrequency,n));
                end
            end
            if isChangedProperty(obj,'ReceiveCenterFrequency')

                for n=1:numReceiveAntennas
                    obj.Driver.setReceiveCenterFrequency(obj.ReceiveAntennas(n),getExpandedValue(obj,obj.ReceiveCenterFrequency,n));
                end
            end
        end


        function stepImpl(~)
        end


        function releaseImpl(obj)
            obj.Driver.disconnect()
            freeHardwareMemory(obj,1,obj.AvailableHardwareMemory);
        end


        function validatePropertiesImpl(obj)
            if isstring(obj.ReceiveAntennas)&&isstring(obj.TransmitAntennas)...
                &&length(obj.ReceiveAntennas)+length(obj.TransmitAntennas)>4
                error(message("wt:appbase:TooManyAntennas"))
            end
            validatePropertyLengthsOrScalar(obj,"ReceiveCenterFrequency",length(obj.ReceiveAntennas),"capture center frequency","capture");
            validatePropertyLengthsOrScalar(obj,"ReceiveGain",length(obj.ReceiveAntennas),"capture gain","capture");
            validatePropertyLengthsOrScalar(obj,"TransmitCenterFrequency",length(obj.TransmitAntennas),"transmit center frequency","transmit");
            validatePropertyLengthsOrScalar(obj,"TransmitGain",length(obj.TransmitAntennas),"transmit gain","transmit");
        end


        function validatePropertyLengthsOrScalar(obj,propName,propLength,errorName,errorAntennaName)

            if~isscalar(obj.(propName))&&length(obj.(propName))~=propLength
                error(message("wt:appbase:InconsistentPropertyLengths",errorName,errorAntennaName))
            end
        end
    end
end
