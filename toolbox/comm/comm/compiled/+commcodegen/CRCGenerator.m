classdef CRCGenerator<matlab.System
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Polynomial
InitialConditions
DirectMethod
ReflectInputBytes
ReflectChecksums
FinalXOR
ChecksumsPerFrame
    end
    properties
    end
    properties(Nontunable,Hidden)
CheckSumsPerFrame
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=CRCGenerator(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('commcodegen.CRCGenerator.propListManager');
            coder.extrinsic('commcodegen.CRCGenerator.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=comm.CRCGenerator(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'Polynomial');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=commcodegen.CRCGenerator.propListManager(numValueOnlyProps,'Polynomial');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=commcodegen.CRCGenerator.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(commcodegen.CRCGenerator.propListManager(s,'Polynomial',false))
                val=coder.internal.const(commcodegen.CRCGenerator.getFieldFromMxStruct(propValues,'Polynomial'));
                obj.Polynomial=val;
            end
            if~coder.internal.const(commcodegen.CRCGenerator.propListManager(s,'InitialConditions',false))
                val=coder.internal.const(commcodegen.CRCGenerator.getFieldFromMxStruct(propValues,'InitialConditions'));
                obj.InitialConditions=val;
            end
            if~coder.internal.const(commcodegen.CRCGenerator.propListManager(s,'DirectMethod',false))
                val=coder.internal.const(commcodegen.CRCGenerator.getFieldFromMxStruct(propValues,'DirectMethod'));
                obj.DirectMethod=val;
            end
            if~coder.internal.const(commcodegen.CRCGenerator.propListManager(s,'ReflectInputBytes',false))
                val=coder.internal.const(commcodegen.CRCGenerator.getFieldFromMxStruct(propValues,'ReflectInputBytes'));
                obj.ReflectInputBytes=val;
            end
            if~coder.internal.const(commcodegen.CRCGenerator.propListManager(s,'ReflectChecksums',false))
                val=coder.internal.const(commcodegen.CRCGenerator.getFieldFromMxStruct(propValues,'ReflectChecksums'));
                obj.ReflectChecksums=val;
            end
            if~coder.internal.const(commcodegen.CRCGenerator.propListManager(s,'FinalXOR',false))
                val=coder.internal.const(commcodegen.CRCGenerator.getFieldFromMxStruct(propValues,'FinalXOR'));
                obj.FinalXOR=val;
            end
            if~coder.internal.const(commcodegen.CRCGenerator.propListManager(s,'ChecksumsPerFrame',false))
                val=coder.internal.const(commcodegen.CRCGenerator.getFieldFromMxStruct(propValues,'ChecksumsPerFrame'));
                obj.ChecksumsPerFrame=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.CheckSumsPerFrame(obj,val)
            coder.extrinsic('commcodegen.CRCGenerator.localSet');
            coder.internal.const(commcodegen.CRCGenerator.localSet(eml_sea_get_obj(obj.cSFunObject),'CheckSumsPerFrame',val));
        end
        function val=get.CheckSumsPerFrame(obj)
            val=get(obj.cSFunObject,'CheckSumsPerFrame');
        end
        function set.Polynomial(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Polynomial),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.CRCGenerator');
            obj.Polynomial=val;
        end
        function set.InitialConditions(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InitialConditions),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.CRCGenerator');
            obj.InitialConditions=val;
        end
        function set.DirectMethod(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.DirectMethod),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.CRCGenerator');
            obj.DirectMethod=val;
        end
        function set.ReflectInputBytes(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ReflectInputBytes),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.CRCGenerator');
            obj.ReflectInputBytes=val;
        end
        function set.ReflectChecksums(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ReflectChecksums),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.CRCGenerator');
            obj.ReflectChecksums=val;
        end
        function set.FinalXOR(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FinalXOR),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.CRCGenerator');
            obj.FinalXOR=val;
        end
        function set.ChecksumsPerFrame(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ChecksumsPerFrame),'MATLAB:system:codeGenNontunableSetAfterConstructor','comm.CRCGenerator');
            obj.ChecksumsPerFrame=val;
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
            result='comm.CRCGenerator';
        end
        function s=localSet(obj,prop,val)
            set(obj,prop,val);
            s=1;
        end
    end
end
