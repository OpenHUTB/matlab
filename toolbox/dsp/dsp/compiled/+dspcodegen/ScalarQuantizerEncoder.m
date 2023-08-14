classdef ScalarQuantizerEncoder<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
BoundaryPointsSource
Partitioning
SearchMethod
TiebreakerRule
OutputIndexDataType
RoundingMethod
OverflowAction
CodewordOutputPort
QuantizationErrorOutputPort
ClippingStatusOutputPort
BoundaryPoints
    end
    properties
Codebook
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=ScalarQuantizerEncoder(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.ScalarQuantizerEncoder.propListManager');
            coder.extrinsic('dspcodegen.ScalarQuantizerEncoder.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.ScalarQuantizerEncoder(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=dspcodegen.ScalarQuantizerEncoder.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.ScalarQuantizerEncoder.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.ScalarQuantizerEncoder.propListManager(s,'BoundaryPointsSource',false))
                val=coder.internal.const(dspcodegen.ScalarQuantizerEncoder.getFieldFromMxStruct(propValues,'BoundaryPointsSource'));
                obj.BoundaryPointsSource=val;
            end
            if~coder.internal.const(dspcodegen.ScalarQuantizerEncoder.propListManager(s,'Partitioning',false))
                val=coder.internal.const(dspcodegen.ScalarQuantizerEncoder.getFieldFromMxStruct(propValues,'Partitioning'));
                obj.Partitioning=val;
            end
            if~coder.internal.const(dspcodegen.ScalarQuantizerEncoder.propListManager(s,'SearchMethod',false))
                val=coder.internal.const(dspcodegen.ScalarQuantizerEncoder.getFieldFromMxStruct(propValues,'SearchMethod'));
                obj.SearchMethod=val;
            end
            if~coder.internal.const(dspcodegen.ScalarQuantizerEncoder.propListManager(s,'TiebreakerRule',false))
                val=coder.internal.const(dspcodegen.ScalarQuantizerEncoder.getFieldFromMxStruct(propValues,'TiebreakerRule'));
                obj.TiebreakerRule=val;
            end
            if~coder.internal.const(dspcodegen.ScalarQuantizerEncoder.propListManager(s,'OutputIndexDataType',false))
                val=coder.internal.const(dspcodegen.ScalarQuantizerEncoder.getFieldFromMxStruct(propValues,'OutputIndexDataType'));
                obj.OutputIndexDataType=val;
            end
            if~coder.internal.const(dspcodegen.ScalarQuantizerEncoder.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(dspcodegen.ScalarQuantizerEncoder.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(dspcodegen.ScalarQuantizerEncoder.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(dspcodegen.ScalarQuantizerEncoder.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(dspcodegen.ScalarQuantizerEncoder.propListManager(s,'CodewordOutputPort',false))
                val=coder.internal.const(dspcodegen.ScalarQuantizerEncoder.getFieldFromMxStruct(propValues,'CodewordOutputPort'));
                obj.CodewordOutputPort=val;
            end
            if~coder.internal.const(dspcodegen.ScalarQuantizerEncoder.propListManager(s,'QuantizationErrorOutputPort',false))
                val=coder.internal.const(dspcodegen.ScalarQuantizerEncoder.getFieldFromMxStruct(propValues,'QuantizationErrorOutputPort'));
                obj.QuantizationErrorOutputPort=val;
            end
            if~coder.internal.const(dspcodegen.ScalarQuantizerEncoder.propListManager(s,'ClippingStatusOutputPort',false))
                val=coder.internal.const(dspcodegen.ScalarQuantizerEncoder.getFieldFromMxStruct(propValues,'ClippingStatusOutputPort'));
                obj.ClippingStatusOutputPort=val;
            end
            if~coder.internal.const(dspcodegen.ScalarQuantizerEncoder.propListManager(s,'BoundaryPoints',false))
                val=coder.internal.const(dspcodegen.ScalarQuantizerEncoder.getFieldFromMxStruct(propValues,'BoundaryPoints'));
                obj.BoundaryPoints=val;
            end
            if~coder.internal.const(dspcodegen.ScalarQuantizerEncoder.propListManager(s,'Codebook',false))
                val=coder.internal.const(dspcodegen.ScalarQuantizerEncoder.getFieldFromMxStruct(propValues,'Codebook'));
                obj.Codebook=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Codebook(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'Codebook',val,noTuningError);%#ok<MCSUP>
            obj.Codebook=val;
        end
        function set.BoundaryPointsSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.BoundaryPointsSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.ScalarQuantizerEncoder');
            obj.BoundaryPointsSource=val;
        end
        function set.Partitioning(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Partitioning),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.ScalarQuantizerEncoder');
            obj.Partitioning=val;
        end
        function set.SearchMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SearchMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.ScalarQuantizerEncoder');
            obj.SearchMethod=val;
        end
        function set.TiebreakerRule(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.TiebreakerRule),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.ScalarQuantizerEncoder');
            obj.TiebreakerRule=val;
        end
        function set.OutputIndexDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputIndexDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.ScalarQuantizerEncoder');
            obj.OutputIndexDataType=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.ScalarQuantizerEncoder');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.ScalarQuantizerEncoder');
            obj.OverflowAction=val;
        end
        function set.CodewordOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CodewordOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.ScalarQuantizerEncoder');
            obj.CodewordOutputPort=val;
        end
        function set.QuantizationErrorOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.QuantizationErrorOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.ScalarQuantizerEncoder');
            obj.QuantizationErrorOutputPort=val;
        end
        function set.ClippingStatusOutputPort(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ClippingStatusOutputPort),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.ScalarQuantizerEncoder');
            obj.ClippingStatusOutputPort=val;
        end
        function set.BoundaryPoints(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.BoundaryPoints),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.ScalarQuantizerEncoder');
            obj.BoundaryPoints=val;
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
            result='dsp.ScalarQuantizerEncoder';
        end
    end
end
