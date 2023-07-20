classdef ArrayVectorDivider<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Dimension
VectorSource
RoundingMethod
OverflowAction
VectorDataType
CustomVectorDataType
OutputDataType
CustomOutputDataType
    end
    properties
Vector
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=ArrayVectorDivider(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('dspcodegen.ArrayVectorDivider.propListManager');
            coder.extrinsic('dspcodegen.ArrayVectorDivider.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=dsp.ArrayVectorDivider(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:});
            numValueOnlyProps=0;
            s=dspcodegen.ArrayVectorDivider.propListManager();
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=dspcodegen.ArrayVectorDivider.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(dspcodegen.ArrayVectorDivider.propListManager(s,'Dimension',false))
                val=coder.internal.const(dspcodegen.ArrayVectorDivider.getFieldFromMxStruct(propValues,'Dimension'));
                obj.Dimension=val;
            end
            if~coder.internal.const(dspcodegen.ArrayVectorDivider.propListManager(s,'VectorSource',false))
                val=coder.internal.const(dspcodegen.ArrayVectorDivider.getFieldFromMxStruct(propValues,'VectorSource'));
                obj.VectorSource=val;
            end
            if~coder.internal.const(dspcodegen.ArrayVectorDivider.propListManager(s,'RoundingMethod',false))
                val=coder.internal.const(dspcodegen.ArrayVectorDivider.getFieldFromMxStruct(propValues,'RoundingMethod'));
                obj.RoundingMethod=val;
            end
            if~coder.internal.const(dspcodegen.ArrayVectorDivider.propListManager(s,'OverflowAction',false))
                val=coder.internal.const(dspcodegen.ArrayVectorDivider.getFieldFromMxStruct(propValues,'OverflowAction'));
                obj.OverflowAction=val;
            end
            if~coder.internal.const(dspcodegen.ArrayVectorDivider.propListManager(s,'VectorDataType',false))
                val=coder.internal.const(dspcodegen.ArrayVectorDivider.getFieldFromMxStruct(propValues,'VectorDataType'));
                obj.VectorDataType=val;
            end
            if~coder.internal.const(dspcodegen.ArrayVectorDivider.propListManager(s,'CustomVectorDataType',false))
                val=coder.internal.const(dspcodegen.ArrayVectorDivider.getFieldFromMxStruct(propValues,'CustomVectorDataType'));
                obj.CustomVectorDataType=val;
            end
            if~coder.internal.const(dspcodegen.ArrayVectorDivider.propListManager(s,'OutputDataType',false))
                val=coder.internal.const(dspcodegen.ArrayVectorDivider.getFieldFromMxStruct(propValues,'OutputDataType'));
                obj.OutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.ArrayVectorDivider.propListManager(s,'CustomOutputDataType',false))
                val=coder.internal.const(dspcodegen.ArrayVectorDivider.getFieldFromMxStruct(propValues,'CustomOutputDataType'));
                obj.CustomOutputDataType=val;
            end
            if~coder.internal.const(dspcodegen.ArrayVectorDivider.propListManager(s,'Vector',false))
                val=coder.internal.const(dspcodegen.ArrayVectorDivider.getFieldFromMxStruct(propValues,'Vector'));
                obj.Vector=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Vector(obj,val)
            coder.inline('always');
            noTuningError=true;
            if coder.internal.const(~coder.target('Rtw'))
                noTuningError=obj.NoTuningBeforeLockingCodeGenError;
            end
            setSfunSystemObject(obj.cSFunObject,'Vector',val,noTuningError);%#ok<MCSUP>
            obj.Vector=val;
        end
        function set.Dimension(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Dimension),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.ArrayVectorDivider');
            obj.Dimension=val;
        end
        function set.VectorSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.VectorSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.ArrayVectorDivider');
            obj.VectorSource=val;
        end
        function set.RoundingMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.RoundingMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.ArrayVectorDivider');
            obj.RoundingMethod=val;
        end
        function set.OverflowAction(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OverflowAction),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.ArrayVectorDivider');
            obj.OverflowAction=val;
        end
        function set.VectorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.VectorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.ArrayVectorDivider');
            obj.VectorDataType=val;
        end
        function set.CustomVectorDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomVectorDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.ArrayVectorDivider');
            obj.CustomVectorDataType=val;
        end
        function set.OutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.ArrayVectorDivider');
            obj.OutputDataType=val;
        end
        function set.CustomOutputDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.CustomOutputDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','dsp.ArrayVectorDivider');
            obj.CustomOutputDataType=val;
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
            result='dsp.ArrayVectorDivider';
        end
    end
end
