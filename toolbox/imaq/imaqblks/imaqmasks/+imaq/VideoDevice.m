classdef(StrictDefaults)VideoDevice<matlab.System





































































































%#codegen

    properties(Dependent,Nontunable,AbortSet)





        Device='Default';









        VideoFormat='Default';





        DeviceFile=[];







        ROI=[];





        HardwareTriggering='off';







        TriggerConfiguration='none/none';







        ReturnedColorSpace='rgb';







        BayerSensorAlignment='grbg';






        ReturnedDataType='single';





        ReadAllFrames='off';
    end

    properties(Nontunable,SetAccess=private)






        DeviceProperties;
    end


    properties(Hidden,Access=private)

VideoDeviceInternalObj
    end

    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
'Device'...
            ,'VideoFormat'...
            ,'DeviceFile'...
            ,'ROI'...
            ,'HardwareTriggering'...
            ,'TriggerConfiguration'...
            ,'ReturnedColorSpace'...
            ,'BayerSensorAlignment'...
            ,'ReturnedDataType'...
            ,'DeviceProperties'...
            ,'ReadAllFrames'...
            };
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)

            props=getInactiveProps(obj);
            flag=ismember(prop,props);
        end


        function out=saveObjectImpl(obj)

            out=saveObjectImpl@matlab.System(obj);
            out.VideoDeviceInternalStruct=matlab.System.saveObject(obj.VideoDeviceInternalObj);
            out.SaveLockedData=false;
        end

        function loadObjectImpl(obj,in,wasLocked)

            obj.VideoDeviceInternalObj=matlab.System.loadObject(in.VideoDeviceInternalStruct);

            props=getInactiveProps(obj);
            if~ismember('Device',props)
                obj.Device=obj.VideoDeviceInternalObj.Device;
            end
            if~ismember('VideoFormat',props)
                obj.VideoFormat=obj.VideoDeviceInternalObj.VideoFormat;
            end
            if~ismember('DeviceFile',props)
                obj.DeviceFile=obj.VideoDeviceInternalObj.DeviceFile;
            end
            if~ismember('ROI',props)
                obj.ROI=obj.VideoDeviceInternalObj.ROI;
            end
            if~ismember('HardwareTriggering',props)
                obj.HardwareTriggering=obj.VideoDeviceInternalObj.HardwareTriggering;
            end
            if~ismember('TriggerConfiguration',props)
                obj.TriggerConfiguration=obj.VideoDeviceInternalObj.TriggerConfiguration;
            end
            if~ismember('ReturnedColorSpace',props)
                obj.ReturnedColorSpace=obj.VideoDeviceInternalObj.ReturnedColorSpace;
            end
            if~ismember('BayerSensorAlignment',props)
                obj.BayerSensorAlignment=obj.VideoDeviceInternalObj.BayerSensorAlignment;
            end
            if~ismember('ReturnedDataType',props)
                obj.ReturnedDataType=obj.VideoDeviceInternalObj.ReturnedDataType;
            end
            if~ismember('DeviceProperties',props)
                obj.DeviceProperties=obj.VideoDeviceInternalObj.DeviceProperties;
            end
            if~ismember('ReadAllFrames',props)
                obj.ReadAllFrames=obj.VideoDeviceInternalObj.ReadAllFrames;
            end
        end

        function varargout=cloneImpl(obj)%#ok<*MANU>
            varargout={};%#ok<NASGU>
            error(message('imaq:videodevice:cloneNotSupported',class(obj)));
        end
    end
    methods

        function this=VideoDevice(varargin)

            coder.allowpcode('plain');


            setVarSizeAllowedStatus(this,false);

            for i=1:nargin
                if(isstring(varargin{i})&&isscalar(varargin{i}))
                    varargin{i}=char(varargin{i});
                end
            end


            this.VideoDeviceInternalObj=imaq.internal.VideoDeviceInternal(varargin{:});
        end


        function set.Device(obj,inDevice)

            obj.VideoDeviceInternalObj.Device=inDevice;
        end

        function set.VideoFormat(obj,inFormat)

            obj.VideoDeviceInternalObj.VideoFormat=inFormat;
        end

        function set.DeviceFile(obj,inDeviceFile)

            obj.VideoDeviceInternalObj.DeviceFile=inDeviceFile;
        end

        function set.ROI(obj,roi)

            obj.VideoDeviceInternalObj.ROI=roi;
        end

        function set.HardwareTriggering(obj,setState)

            obj.VideoDeviceInternalObj.HardwareTriggering=setState;
        end

        function set.TriggerConfiguration(obj,triggerConfig)

            obj.VideoDeviceInternalObj.TriggerConfiguration=triggerConfig;
        end

        function set.ReturnedColorSpace(obj,rcs)

            obj.VideoDeviceInternalObj.ReturnedColorSpace=rcs;
        end

        function set.BayerSensorAlignment(obj,bayerSA)

            obj.VideoDeviceInternalObj.BayerSensorAlignment=bayerSA;
        end

        function set.ReturnedDataType(obj,dataType)

            obj.VideoDeviceInternalObj.ReturnedDataType=dataType;
        end


        function device=get.Device(obj)
            device=obj.VideoDeviceInternalObj.Device;
        end

        function videoFormat=get.VideoFormat(obj)
            videoFormat=obj.VideoDeviceInternalObj.VideoFormat;
        end

        function deviceFile=get.DeviceFile(obj)
            deviceFile=obj.VideoDeviceInternalObj.DeviceFile;
        end

        function deviceProps=get.DeviceProperties(obj)
            deviceProps=obj.VideoDeviceInternalObj.DeviceProperties;
        end

        function outROI=get.ROI(obj)
            outROI=obj.VideoDeviceInternalObj.ROI;
        end

        function hwTriggering=get.HardwareTriggering(obj)
            hwTriggering=obj.VideoDeviceInternalObj.HardwareTriggering;
        end

        function triggerConfig=get.TriggerConfiguration(obj)
            triggerConfig=obj.VideoDeviceInternalObj.TriggerConfiguration;
        end

        function rcs=get.ReturnedColorSpace(obj)
            rcs=obj.VideoDeviceInternalObj.ReturnedColorSpace;
        end

        function bayerSA=get.BayerSensorAlignment(obj)
            bayerSA=obj.VideoDeviceInternalObj.BayerSensorAlignment;
        end

        function dataType=get.ReturnedDataType(obj)
            dataType=obj.VideoDeviceInternalObj.ReturnedDataType;
        end
        function ReadAllFrames=get.ReadAllFrames(obj)
            ReadAllFrames=obj.VideoDeviceInternalObj.ReadAllFrames;
        end
    end

    methods(Access=protected)
        function num=getNumInputsImpl(obj)

            num=0;
        end

        function num=getNumOutputsImpl(obj)

            num=2;
        end

        function[imgData,metaData]=stepImpl(obj,varargin)
            if isKinectDepthDevice(obj)
                [imgData,metaData.IsPositionTracked,metaData.IsSkeletonTracked,...
                metaData.JointDepthIndices,metaData.JointImageIndices,...
                metaData.JointTrackingState,metaData.JointWorldCoordinates,...
                metaData.PositionDepthIndices,metaData.PositionImageIndices,...
                metaData.PositionWorldCoordinates,metaData.SegmentationData,...
                metaData.SkeletonTrackingID]=step(obj.VideoDeviceInternalObj);
            else
                if isKinectV2DepthDevice(obj)
                    [imgData,metaData.BodyIndexFrame,metaData.BodyTrackingID,...
                    metaData.ColorJointIndices,metaData.DepthJointIndices,...
                    metaData.HandLeftConfidence,metaData.HandLeftState,...
                    metaData.HandRightConfidence,metaData.HandRightState,metaData.IsBodyTracked,...
                    metaData.JointPositions,metaData.JointTrackingState]=...
                    step(obj.VideoDeviceInternalObj);
                else
                    metaData=[];
                    imgData=step(obj.VideoDeviceInternalObj);
                end
            end
        end
        function releaseImpl(obj)
            release(obj.VideoDeviceInternalObj);
        end
    end

    methods(Hidden,Access=private)
        function isKinectDepth=isKinectDepthDevice(obj)
            kinectDepth='Kinect Depth';
            isKinectDepth=false;
            if strncmp(obj.Device,kinectDepth,length(kinectDepth))
                isKinectDepth=true;
            end
        end
        function isKinectV2Depth=isKinectV2DepthDevice(obj)
            kinectV2Depth='Kinect V2 Depth';
            isKinectV2Depth=false;
            if strncmp(obj.Device,kinectV2Depth,length(kinectV2Depth))
                isKinectV2Depth=true;
            end
        end

    end
    methods(Access=public)
        function hImage=preview(obj)
















            if nargout>0
                hImage=[];
            end


            imHandle=preview(obj.VideoDeviceInternalObj);


            if nargout>0
                hImage=imHandle;
            end
        end

        function closepreview(obj)






            closepreview(obj.VideoDeviceInternalObj);
        end

        function out=imaqhwinfo(obj,varargin)












            narginchk(1,2);
            if(nargin==1)
                out=imaqhwinfo(obj.VideoDeviceInternalObj);
            else
                out=imaqhwinfo(obj.VideoDeviceInternalObj,varargin{1});
            end
        end

        function varargout=set(obj,varargin)
            if(nargin<=2)
                out=set(obj.VideoDeviceInternalObj,varargin{:});
                varargout={out};%#ok<*EMCA>
            else
                varargout={};
                set(obj.VideoDeviceInternalObj,varargin{:});
            end
        end
    end



    methods(Hidden)
        function start(obj)%#ok<*MANU>
            error(message('imaq:videodevice:useStepMethod','START'));
        end
        function trigger(obj)
            error(message('imaq:videodevice:useStepMethod','TRIGGER'));
        end
        function getdata(~,varargin)
            error(message('imaq:videodevice:useStepMethod','GETDATA'));
        end
        function getsnapshot(obj)
            error(message('imaq:videodevice:useStepMethod','GETSNAPSHOT'));
        end
        function stop(obj)
            error(message('imaq:videodevice:useReleaseMethod','STOP'));
        end
    end

    methods(Access=private)
        function props=getInactiveProps(obj)
            props=getInactiveProps(obj.VideoDeviceInternalObj);
        end
    end
end

