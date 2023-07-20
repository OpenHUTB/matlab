classdef DeployableVideoPlayer<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Location
Name
Size
CustomSize
InputColorFormat
VideoSize
figureID
FrameRate
CoderTarget
    end
    properties
    end
    properties(Nontunable,Hidden)
WindowCaption
    end
    properties(Nontunable,Hidden)
WindowLocation
    end
    properties(Nontunable,Hidden)
WindowSize
    end
    properties(Nontunable,Hidden)
CustomWindowSize
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=DeployableVideoPlayer(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('visioncodegen.DeployableVideoPlayer.propListManager');
            coder.extrinsic('visioncodegen.DeployableVideoPlayer.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=vision.DeployableVideoPlayer(varargin{:},'CoderTarget',coder.target);
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=visioncodegen.DeployableVideoPlayer.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=visioncodegen.DeployableVideoPlayer.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(visioncodegen.DeployableVideoPlayer.propListManager(s,'Location',false))
                val=coder.internal.const(visioncodegen.DeployableVideoPlayer.getFieldFromMxStruct(propValues,'Location'));
                obj.Location=val;
            end
            if~coder.internal.const(visioncodegen.DeployableVideoPlayer.propListManager(s,'Name',false))
                val=coder.internal.const(visioncodegen.DeployableVideoPlayer.getFieldFromMxStruct(propValues,'Name'));
                obj.Name=val;
            end
            if~coder.internal.const(visioncodegen.DeployableVideoPlayer.propListManager(s,'Size',false))
                val=coder.internal.const(visioncodegen.DeployableVideoPlayer.getFieldFromMxStruct(propValues,'Size'));
                obj.Size=val;
            end
            if~coder.internal.const(visioncodegen.DeployableVideoPlayer.propListManager(s,'CustomSize',false))
                val=coder.internal.const(visioncodegen.DeployableVideoPlayer.getFieldFromMxStruct(propValues,'CustomSize'));
                obj.CustomSize=val;
            end
            if~coder.internal.const(visioncodegen.DeployableVideoPlayer.propListManager(s,'InputColorFormat',false))
                val=coder.internal.const(visioncodegen.DeployableVideoPlayer.getFieldFromMxStruct(propValues,'InputColorFormat'));
                obj.InputColorFormat=val;
            end
            if~coder.internal.const(visioncodegen.DeployableVideoPlayer.propListManager(s,'VideoSize',false))
                val=coder.internal.const(get(obj.cSFunObject,'VideoSize'));
                obj.VideoSize=val;
            end
            if~coder.internal.const(visioncodegen.DeployableVideoPlayer.propListManager(s,'figureID',false))
                val=coder.internal.const(get(obj.cSFunObject,'figureID'));
                obj.figureID=val;
            end
            if~coder.internal.const(visioncodegen.DeployableVideoPlayer.propListManager(s,'FrameRate',false))
                val=coder.internal.const(get(obj.cSFunObject,'FrameRate'));
                obj.FrameRate=val;
            end
            if~coder.internal.const(visioncodegen.DeployableVideoPlayer.propListManager(s,'CoderTarget',false))
                val=coder.internal.const(get(obj.cSFunObject,'CoderTarget'));
                obj.CoderTarget=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.WindowCaption(obj,val)
            coder.extrinsic('visioncodegen.DeployableVideoPlayer.localSet');
            coder.internal.const(visioncodegen.DeployableVideoPlayer.localSet(eml_sea_get_obj(obj.cSFunObject),'WindowCaption',val));
        end
        function val=get.WindowCaption(obj)
            val=get(obj.cSFunObject,'WindowCaption');
        end
        function set.WindowLocation(obj,val)
            coder.extrinsic('visioncodegen.DeployableVideoPlayer.localSet');
            coder.internal.const(visioncodegen.DeployableVideoPlayer.localSet(eml_sea_get_obj(obj.cSFunObject),'WindowLocation',val));
        end
        function val=get.WindowLocation(obj)
            val=get(obj.cSFunObject,'WindowLocation');
        end
        function set.WindowSize(obj,val)
            coder.extrinsic('visioncodegen.DeployableVideoPlayer.localSet');
            coder.internal.const(visioncodegen.DeployableVideoPlayer.localSet(eml_sea_get_obj(obj.cSFunObject),'WindowSize',val));
        end
        function val=get.WindowSize(obj)
            val=get(obj.cSFunObject,'WindowSize');
        end
        function set.CustomWindowSize(obj,val)
            coder.extrinsic('visioncodegen.DeployableVideoPlayer.localSet');
            coder.internal.const(visioncodegen.DeployableVideoPlayer.localSet(eml_sea_get_obj(obj.cSFunObject),'CustomWindowSize',val));
        end
        function val=get.CustomWindowSize(obj)
            val=get(obj.cSFunObject,'CustomWindowSize');
        end
        function set.Location(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Location),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.DeployableVideoPlayer');
            obj.Location=val;
        end
        function set.Name(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Name),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.DeployableVideoPlayer');
            obj.Name=val;
        end
        function set.Size(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Size),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.DeployableVideoPlayer');
            obj.Size=val;
        end
        function set.CustomSize(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomSize),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.DeployableVideoPlayer');
            obj.CustomSize=val;
        end
        function set.InputColorFormat(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InputColorFormat),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.DeployableVideoPlayer');
            obj.InputColorFormat=val;
        end
        function flag=isOpen(~)
            flag=false;
            coder.internal.errorIf(true,'vision:DeployableVideoPlayer:unsupportedIsOpenInCG');
        end
        function sObj=getCSFun(obj)
            sObj=obj.cSFunObject;
        end
        function args=getConstructionArgs(obj)
            args=obj.ConstructorArgs;
        end
        function cloneProp(obj,prop,value)
            if coder.internal.const(~coder.target('Rtw'))
                oldFlag=obj.NoTuningBeforeLockingCodeGenError;
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.(prop)=value;
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=oldFlag;
            end
        end
    end
    methods(Access=protected)
        function num=getNumInputsImpl(obj)
            num=getNumInputs(obj.cSFunObject);
        end
        function num=getNumOutputsImpl(obj)
            num=getNumOutputs(obj.cSFunObject);
        end
        function resetImpl(obj)
            reset(obj.cSFunObject);
        end
        function setupImpl(obj,varargin)
            setup(obj.cSFunObject,varargin{:});
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
        end
        function varargout=isInputDirectFeedthroughImpl(obj,varargin)
            [varargout{1:nargout}]=isInputDirectFeedthrough(obj.cSFunObject,varargin{:});
        end
        function releaseImpl(obj)
            release(obj.cSFunObject);
        end
        function varargout=outputImpl(obj,varargin)
            [varargout{1:nargout}]=output(obj.cSFunObject,varargin{:});
        end
        function updateImpl(obj,varargin)
            update(obj.cSFunObject,varargin{:});
        end
        function out=getDiscreteStateImpl(~)
            out.s=1;
            coder.internal.assert(false,'MATLAB:system:getDiscreteStateNotSupported');
        end
        function out=getContinuousStateImpl(~)
            out.s=1;
            coder.internal.assert(false,'MATLAB:system:getContinuousStateNotSupported');
        end
        function setDiscreteStateImpl(~,~)
            coder.internal.assert(false,'MATLAB:system:setDiscreteStateNotSupported');
        end
        function setContinuousStateImpl(~,~)
            coder.internal.assert(false,'MATLAB:system:setContinuousStateNotSupported');
        end
    end
    methods(Static,Hidden)
        function s=propListManager(varargin)














            if nargin>0&&isstruct(varargin{1})
                s=varargin{1};
                fieldName=varargin{2};
                if varargin{3}
                    s.(fieldName)=true;
                else
                    s=isfield(s,fieldName);
                end
            else
                s=struct;
                if nargin>0
                    for ii=1:varargin{1}
                        s.(varargin{ii+1})=true;
                    end
                end
            end
        end
        function y=getFieldFromMxStruct(s,field)







            y=s.(field);
        end
        function result=matlabCodegenUserReadableName
            result='vision.DeployableVideoPlayer';
        end
        function s=localSet(obj,prop,val)
            set(obj,prop,val);
            s=1;
        end
    end
end
