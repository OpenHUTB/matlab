classdef ChromaResampler<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Resampling
InterpolationFilter
AntialiasingFilterSource
HorizontalFilterCoefficients
VerticalFilterCoefficients
TransposedInput
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=ChromaResampler(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('visioncodegen.ChromaResampler.propListManager');
            coder.extrinsic('visioncodegen.ChromaResampler.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=vision.ChromaResampler(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=visioncodegen.ChromaResampler.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=visioncodegen.ChromaResampler.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(visioncodegen.ChromaResampler.propListManager(s,'Resampling',false))
                val=coder.internal.const(visioncodegen.ChromaResampler.getFieldFromMxStruct(propValues,'Resampling'));
                obj.Resampling=val;
            end
            if~coder.internal.const(visioncodegen.ChromaResampler.propListManager(s,'InterpolationFilter',false))
                val=coder.internal.const(visioncodegen.ChromaResampler.getFieldFromMxStruct(propValues,'InterpolationFilter'));
                obj.InterpolationFilter=val;
            end
            if~coder.internal.const(visioncodegen.ChromaResampler.propListManager(s,'AntialiasingFilterSource',false))
                val=coder.internal.const(visioncodegen.ChromaResampler.getFieldFromMxStruct(propValues,'AntialiasingFilterSource'));
                obj.AntialiasingFilterSource=val;
            end
            if~coder.internal.const(visioncodegen.ChromaResampler.propListManager(s,'HorizontalFilterCoefficients',false))
                val=coder.internal.const(visioncodegen.ChromaResampler.getFieldFromMxStruct(propValues,'HorizontalFilterCoefficients'));
                obj.HorizontalFilterCoefficients=val;
            end
            if~coder.internal.const(visioncodegen.ChromaResampler.propListManager(s,'VerticalFilterCoefficients',false))
                val=coder.internal.const(visioncodegen.ChromaResampler.getFieldFromMxStruct(propValues,'VerticalFilterCoefficients'));
                obj.VerticalFilterCoefficients=val;
            end
            if~coder.internal.const(visioncodegen.ChromaResampler.propListManager(s,'TransposedInput',false))
                val=coder.internal.const(visioncodegen.ChromaResampler.getFieldFromMxStruct(propValues,'TransposedInput'));
                obj.TransposedInput=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Resampling(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Resampling),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.ChromaResampler');
            obj.Resampling=val;
        end
        function set.InterpolationFilter(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InterpolationFilter),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.ChromaResampler');
            obj.InterpolationFilter=val;
        end
        function set.AntialiasingFilterSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.AntialiasingFilterSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.ChromaResampler');
            obj.AntialiasingFilterSource=val;
        end
        function set.HorizontalFilterCoefficients(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.HorizontalFilterCoefficients),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.ChromaResampler');
            obj.HorizontalFilterCoefficients=val;
        end
        function set.VerticalFilterCoefficients(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.VerticalFilterCoefficients),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.ChromaResampler');
            obj.VerticalFilterCoefficients=val;
        end
        function set.TransposedInput(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.TransposedInput),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.ChromaResampler');
            obj.TransposedInput=val;
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
            result='vision.ChromaResampler';
        end
    end
end
