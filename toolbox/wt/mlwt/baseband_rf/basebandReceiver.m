classdef basebandReceiver<handle&matlab.mixin.SetGet






































































    properties(Dependent)






        RadioGain double{mustBeFinite,mustBeVector}






        CenterFrequency double{mustBeFinite,mustBePositive,mustBeVector}





        SampleRate(1,1)double{mustBeFinite,mustBePositive}







        Antennas{mustBeText}



        DroppedSamplesAction{mustBeTextScalar}





        CaptureDataType{mustBeTextScalar}
    end

    properties(Access=protected)
sysObj
propHelper
        nonTunableErrorMessage=@(propName)message("wt:baseband_rf:StopTxThenTune",propName)
    end

    methods
        function set.CaptureDataType(obj,val)
            val=validatestring(val,["int16","double","single"],"","CaptureDataType");
            obj.propHelper.setNontunable("CaptureDataType",val,canRelease(obj),obj.nonTunableErrorMessage("CaptureDataType"));
        end
        function val=get.CaptureDataType(obj)
            val=obj.sysObj.CaptureDataType;
        end
        function set.DroppedSamplesAction(obj,val)
            val=validatestring(val,["error","warning","none"],"","DroppedSamplesAction");
            obj.sysObj.DroppedSamplesAction=val;
        end
        function val=get.DroppedSamplesAction(obj)
            val=obj.sysObj.DroppedSamplesAction;
        end
        function set.RadioGain(obj,val)
            obj.propHelper.applyVectorTunable("ReceiveGain",val,length(obj.Antennas),canRelease(obj),obj.nonTunableErrorMessage("RadioGain"))
        end
        function val=get.RadioGain(obj)
            val=obj.sysObj.ReceiveGain;
        end
        function set.CenterFrequency(obj,val)
            obj.propHelper.applyVectorTunable("ReceiveCenterFrequency",val,length(obj.Antennas),canRelease(obj),obj.nonTunableErrorMessage("CenterFrequency"))
        end
        function val=get.CenterFrequency(obj)
            val=obj.sysObj.ReceiveCenterFrequency;
        end

        function set.Antennas(obj,val)
            val=convertCharsToStrings(val);
            mustBeMember(val,obj.sysObj.AvailableReceiveAntennas);
            obj.propHelper.setNontunable("ReceiveAntennas",val,canRelease(obj),obj.nonTunableErrorMessage("Antennas"));
        end
        function val=get.Antennas(obj)
            val=obj.sysObj.ReceiveAntennas;
        end
        function set.SampleRate(obj,val)
            obj.propHelper.setNontunable("SampleRate",val,canRelease(obj),obj.nonTunableErrorMessage("SampleRate"));
        end
        function val=get.SampleRate(obj)
            val=obj.sysObj.SampleRate;
        end
    end

    methods
        function obj=basebandReceiver(radioID,varargin)
            radioID=convertCharsToStrings(radioID);
            obj.sysObj=wt.internal.basebandTransceiver(radioID);
            obj.propHelper=wt.internal.app.PropertyHelper(obj.sysObj);


            obj.sysObj.TransmitAntennas=-1;
            obj.sysObj.ReceiveAntennas=obj.sysObj.ReceiveAntennas(1);


            if~isempty(varargin)
                set(obj,varargin{:});
            end
        end

        function[data,timestamp,droppedSamples]=capture(obj,length)




























            [data,timestamp,droppedSamples]=capture(obj.sysObj,length,1);
        end
    end

    methods(Access=public,Hidden=true)
        function setHardwareSetupCompleted(obj,value)
            obj.sysObj.HardwareSetupCompleted=value;
        end
        function value=getHardwareSetupCompleted(obj)
            value=obj.sysObj.HardwareSetupCompleted;
        end
        function setSystemObjectProperty(obj,name,value)
            obj.sysObj.(name)=value;
        end
        function value=getSystemObjectProperty(obj,name)
            value=obj.sysObj.(name);
        end
    end

    methods(Access=protected)
        function releasable=canRelease(~)
            releasable=true;
        end
    end
end

