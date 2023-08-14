classdef LocalMaximaFinder<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
MaximumNumLocalMaxima
NeighborhoodSize
ThresholdSource
IndexDataType
HoughMatrixInput
    end
    properties
Threshold
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=LocalMaximaFinder(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('visioncodegen.LocalMaximaFinder.propListManager');
            coder.extrinsic('visioncodegen.LocalMaximaFinder.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=vision.LocalMaximaFinder(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'MaximumNumLocalMaxima','NeighborhoodSize');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=visioncodegen.LocalMaximaFinder.propListManager(numValueOnlyProps,'MaximumNumLocalMaxima','NeighborhoodSize');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=visioncodegen.LocalMaximaFinder.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(visioncodegen.LocalMaximaFinder.propListManager(s,'MaximumNumLocalMaxima',false))
                val=coder.internal.const(visioncodegen.LocalMaximaFinder.getFieldFromMxStruct(propValues,'MaximumNumLocalMaxima'));
                obj.MaximumNumLocalMaxima=val;
            end
            if~coder.internal.const(visioncodegen.LocalMaximaFinder.propListManager(s,'NeighborhoodSize',false))
                val=coder.internal.const(visioncodegen.LocalMaximaFinder.getFieldFromMxStruct(propValues,'NeighborhoodSize'));
                obj.NeighborhoodSize=val;
            end
            if~coder.internal.const(visioncodegen.LocalMaximaFinder.propListManager(s,'ThresholdSource',false))
                val=coder.internal.const(visioncodegen.LocalMaximaFinder.getFieldFromMxStruct(propValues,'ThresholdSource'));
                obj.ThresholdSource=val;
            end
            if~coder.internal.const(visioncodegen.LocalMaximaFinder.propListManager(s,'IndexDataType',false))
                val=coder.internal.const(visioncodegen.LocalMaximaFinder.getFieldFromMxStruct(propValues,'IndexDataType'));
                obj.IndexDataType=val;
            end
            if~coder.internal.const(visioncodegen.LocalMaximaFinder.propListManager(s,'HoughMatrixInput',false))
                val=coder.internal.const(visioncodegen.LocalMaximaFinder.getFieldFromMxStruct(propValues,'HoughMatrixInput'));
                obj.HoughMatrixInput=val;
            end
            if~coder.internal.const(visioncodegen.LocalMaximaFinder.propListManager(s,'Threshold',false))
                val=coder.internal.const(visioncodegen.LocalMaximaFinder.getFieldFromMxStruct(propValues,'Threshold'));
                obj.Threshold=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Threshold(obj,val)
            coder.inline('always');
            noTuningError=true;
            setSfunSystemObject(obj.cSFunObject,'Threshold',val,noTuningError);%#ok<MCSUP>
            obj.Threshold=val;
        end
        function set.MaximumNumLocalMaxima(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.MaximumNumLocalMaxima),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.LocalMaximaFinder');
            obj.MaximumNumLocalMaxima=val;
        end
        function set.NeighborhoodSize(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.NeighborhoodSize),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.LocalMaximaFinder');
            obj.NeighborhoodSize=val;
        end
        function set.ThresholdSource(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ThresholdSource),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.LocalMaximaFinder');
            obj.ThresholdSource=val;
        end
        function set.IndexDataType(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.IndexDataType),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.LocalMaximaFinder');
            obj.IndexDataType=val;
        end
        function set.HoughMatrixInput(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.HoughMatrixInput),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.LocalMaximaFinder');
            obj.HoughMatrixInput=val;
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
            result='vision.LocalMaximaFinder';
        end
    end
end
