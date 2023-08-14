classdef Window<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
WindowFunction
StopbandAttenuation
Beta
NumConstantSidelobes
MaximumSidelobeLevel
Sampling
RoundingMethod
OverflowAction
WindowDataType
CustomWindowDataType
ProductDataType
CustomProductDataType
OutputDataType
CustomOutputDataType
WeightsOutputPort
FullPrecisionOverride
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=Window(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.Window.propListManager');
            coder.extrinsic('dspcodegen.Window.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.Window(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'WindowFunction');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=dspcodegen.Window.propListManager(numValueOnlyProps,'WindowFunction');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.Window.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.Window.propListManager(s,'WindowFunction',false))
                val=coder.internal.const(dspcodegen.Window.getFieldFromMxStruct(propValues,'WindowFunction'));
                obj.WindowFunction=val;
            end
            if~coder.internal.const(dspcodegen.Window.propListManager(s,'StopbandAttenuation',false))
                val=coder.internal.const(dspcodegen.Window.getFieldFromMxStruct(propValues,'StopbandAttenuation'));
                obj.StopbandAttenuation=val;
            end
            if~coder.internal.const(dspcodegen.Window.propListManager(s,'Beta',false))
                val=coder.internal.const(dspcodegen.Window.getFieldFromMxStruct(propValues,'Beta'));
                obj.Beta=val;
            end
            if~coder.internal.const(dspcodegen.Window.propListManager(s,'NumConstantSidelobes',false))
                val=coder.internal.const(dspcodegen.Window.getFieldFromMxStruct(propValues,'NumConstantSidelobes'));
                obj.NumConstantSidelobes=val;
            end
            if~coder.internal.const(dspcodegen.Window.propListManager(s,'MaximumSidelobeLevel',false))
                val=coder.internal.const(dspcodegen.Window.getFieldFromMxStruct(propValues,'MaximumSidelobeLevel'));
                obj.MaximumSidelobeLevel=val;
            end
            if~coder.internal.const(dspcodegen.Window.propListManager(s,'Sampling',false))
                val=coder.internal.const(dspcodegen.Window.getFieldFromMxStruct(propValues,'Sampling'));
                obj.Sampling=val;
            end
            if~coder.internal.const(dspcodegen.Window.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(dspcodegen.Window.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(dspcodegen.Window.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(dspcodegen.Window.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(dspcodegen.Window.propListManager(s,'WindowDataType',false))
                val=coder.internal.const(dspcodegen.Window.getFieldFromMxStruct(propValues,'WindowDataType'));
                obj.WindowDataType=val;
            end
            if~coder.internal.const(dspcodegen.Window.propListManager(s,'CustomWindowDataType',false))
                val=coder.internal.const(dspcodegen.Window.getFieldFromMxStruct(propValues,'CustomWindowDataType'));
                obj.CustomWindowDataType=val;
            end
            if~coder.internal.const(dspcodegen.Window.propListManager(s,'ProductDataType',false))
                val=coder.internal.const(dspcodegen.Window.getFieldFromMxStruct(propValues,'ProductDataType'));
                obj.ProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.Window.propListManager(s,'CustomProductDataType',false))
                val=coder.internal.const(dspcodegen.Window.getFieldFromMxStruct(propValues,'CustomProductDataType'));
                obj.CustomProductDataType=val;
            end
            if~coder.internal.const(dspcodegen.Window.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(dspcodegen.Window.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.Window.propListManager(s,'CustomOutputDataType',false))
                val=coder.internal.const(dspcodegen.Window.getFieldFromMxStruct(propValues,'CustomOutputDataType'));
                obj.CustomOutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.Window.propListManager(s,'WeightsOutputPort',false))
                val=coder.internal.const(dspcodegen.Window.getFieldFromMxStruct(propValues,'WeightsOutputPort'));
                obj.WeightsOutputPort=val;
            end
            if~coder.internal.const(dspcodegen.Window.propListManager(s,'FullPrecisionOverride',false))
                val=coder.internal.const(dspcodegen.Window.getFieldFromMxStruct(propValues,'FullPrecisionOverride'));
                obj.FullPrecisionOverride=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.WindowFunction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.WindowFunction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Window');
            obj.WindowFunction=val;
        end
        function set.StopbandAttenuation(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.StopbandAttenuation),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Window');
            obj.StopbandAttenuation=val;
        end
        function set.Beta(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Beta),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Window');
            obj.Beta=val;
        end
        function set.NumConstantSidelobes(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumConstantSidelobes),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Window');
            obj.NumConstantSidelobes=val;
        end
        function set.MaximumSidelobeLevel(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MaximumSidelobeLevel),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Window');
            obj.MaximumSidelobeLevel=val;
        end
        function set.Sampling(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Sampling),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Window');
            obj.Sampling=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Window');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Window');
            obj.OverflowAction=val;
        end
        function set.WindowDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.WindowDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Window');
            obj.WindowDataType=val;
        end
        function set.CustomWindowDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomWindowDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Window');
            obj.CustomWindowDataType=val;
        end
        function set.ProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Window');
            obj.ProductDataType=val;
        end
        function set.CustomProductDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomProductDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Window');
            obj.CustomProductDataType=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Window');
            obj.OutputDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Window');
            obj.CustomOutputDataType=val;
        end
        function set.WeightsOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.WeightsOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Window');
            obj.WeightsOutputPort=val;
        end
        function set.FullPrecisionOverride(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FullPrecisionOverride),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.Window');
            obj.FullPrecisionOverride=val;
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
            result='dsp.Window';
        end
    end
end
