classdef VideoFileReader<matlab.System&matlab.system.mixin.FiniteSource
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Filename
PlayCount
ImageColorSpace
VideoOutputDataType
AudioOutputDataType
AudioOutputPort
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=VideoFileReader(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('visioncodegen.VideoFileReader.propListManager');
            coder.extrinsic('visioncodegen.VideoFileReader.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=vision.VideoFileReader(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'Filename');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=visioncodegen.VideoFileReader.propListManager(numValueOnlyProps,'Filename');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=visioncodegen.VideoFileReader.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(visioncodegen.VideoFileReader.propListManager(s,'Filename',false))
                val=coder.internal.const(visioncodegen.VideoFileReader.getFieldFromMxStruct(propValues,'Filename'));
                obj.Filename=val;
            end
            if~coder.internal.const(visioncodegen.VideoFileReader.propListManager(s,'PlayCount',false))
                val=coder.internal.const(visioncodegen.VideoFileReader.getFieldFromMxStruct(propValues,'PlayCount'));
                obj.PlayCount=val;
            end
            if~coder.internal.const(visioncodegen.VideoFileReader.propListManager(s,'ImageColorSpace',false))
                val=coder.internal.const(visioncodegen.VideoFileReader.getFieldFromMxStruct(propValues,'ImageColorSpace'));
                obj.ImageColorSpace=val;
            end
            if~coder.internal.const(visioncodegen.VideoFileReader.propListManager(s,'VideoOutputDataType',false))
                val=coder.internal.const(visioncodegen.VideoFileReader.getFieldFromMxStruct(propValues,'VideoOutputDataType'));
                obj.VideoOutputDataType=val;
            end
            if~coder.internal.const(visioncodegen.VideoFileReader.propListManager(s,'AudioOutputDataType',false))
                val=coder.internal.const(visioncodegen.VideoFileReader.getFieldFromMxStruct(propValues,'AudioOutputDataType'));
                obj.AudioOutputDataType=val;
            end
            if~coder.internal.const(visioncodegen.VideoFileReader.propListManager(s,'AudioOutputPort',false))
                val=coder.internal.const(visioncodegen.VideoFileReader.getFieldFromMxStruct(propValues,'AudioOutputPort'));
                obj.AudioOutputPort=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Filename(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Filename),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.VideoFileReader');
            obj.Filename=val;
        end
        function set.PlayCount(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PlayCount),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.VideoFileReader');
            obj.PlayCount=val;
        end
        function set.ImageColorSpace(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ImageColorSpace),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.VideoFileReader');
            obj.ImageColorSpace=val;
        end
        function set.VideoOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.VideoOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.VideoFileReader');
            obj.VideoOutputDataType=val;
        end
        function set.AudioOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AudioOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.VideoFileReader');
            obj.AudioOutputDataType=val;
        end
        function set.AudioOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AudioOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.VideoFileReader');
            obj.AudioOutputPort=val;
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
        function y=isDoneImpl(obj)
            y=isDone(obj.cSFunObject);
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
            result='vision.VideoFileReader';
        end
    end
end
