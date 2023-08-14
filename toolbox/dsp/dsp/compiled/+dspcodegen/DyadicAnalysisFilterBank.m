classdef DyadicAnalysisFilterBank<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Filter
CustomLowpassFilter
CustomHighpassFilter
WaveletOrder
FilterOrder
NumLevels
TreeStructure
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=DyadicAnalysisFilterBank(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.DyadicAnalysisFilterBank.propListManager');
            coder.extrinsic('dspcodegen.DyadicAnalysisFilterBank.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.DyadicAnalysisFilterBank(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=dspcodegen.DyadicAnalysisFilterBank.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.DyadicAnalysisFilterBank.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.DyadicAnalysisFilterBank.propListManager(s,'Filter',false))
                val=coder.internal.const(dspcodegen.DyadicAnalysisFilterBank.getFieldFromMxStruct(propValues,'Filter'));
                obj.Filter=val;
            end
            if~coder.internal.const(dspcodegen.DyadicAnalysisFilterBank.propListManager(s,'CustomLowpassFilter',false))
                val=coder.internal.const(dspcodegen.DyadicAnalysisFilterBank.getFieldFromMxStruct(propValues,'CustomLowpassFilter'));
                obj.CustomLowpassFilter=val;
            end
            if~coder.internal.const(dspcodegen.DyadicAnalysisFilterBank.propListManager(s,'CustomHighpassFilter',false))
                val=coder.internal.const(dspcodegen.DyadicAnalysisFilterBank.getFieldFromMxStruct(propValues,'CustomHighpassFilter'));
                obj.CustomHighpassFilter=val;
            end
            if~coder.internal.const(dspcodegen.DyadicAnalysisFilterBank.propListManager(s,'WaveletOrder',false))
                val=coder.internal.const(dspcodegen.DyadicAnalysisFilterBank.getFieldFromMxStruct(propValues,'WaveletOrder'));
                obj.WaveletOrder=val;
            end
            if~coder.internal.const(dspcodegen.DyadicAnalysisFilterBank.propListManager(s,'FilterOrder',false))
                val=coder.internal.const(dspcodegen.DyadicAnalysisFilterBank.getFieldFromMxStruct(propValues,'FilterOrder'));
                obj.FilterOrder=val;
            end
            if~coder.internal.const(dspcodegen.DyadicAnalysisFilterBank.propListManager(s,'NumLevels',false))
                val=coder.internal.const(dspcodegen.DyadicAnalysisFilterBank.getFieldFromMxStruct(propValues,'NumLevels'));
                obj.NumLevels=val;
            end
            if~coder.internal.const(dspcodegen.DyadicAnalysisFilterBank.propListManager(s,'TreeStructure',false))
                val=coder.internal.const(dspcodegen.DyadicAnalysisFilterBank.getFieldFromMxStruct(propValues,'TreeStructure'));
                obj.TreeStructure=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Filter(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Filter),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.DyadicAnalysisFilterBank');
            obj.Filter=val;
        end
        function set.CustomLowpassFilter(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomLowpassFilter),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.DyadicAnalysisFilterBank');
            obj.CustomLowpassFilter=val;
        end
        function set.CustomHighpassFilter(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomHighpassFilter),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.DyadicAnalysisFilterBank');
            obj.CustomHighpassFilter=val;
        end
        function set.WaveletOrder(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.WaveletOrder),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.DyadicAnalysisFilterBank');
            obj.WaveletOrder=val;
        end
        function set.FilterOrder(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FilterOrder),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.DyadicAnalysisFilterBank');
            obj.FilterOrder=val;
        end
        function set.NumLevels(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NumLevels),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.DyadicAnalysisFilterBank');
            obj.NumLevels=val;
        end
        function set.TreeStructure(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.TreeStructure),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.DyadicAnalysisFilterBank');
            obj.TreeStructure=val;
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
            result='dsp.DyadicAnalysisFilterBank';
        end
    end
end
