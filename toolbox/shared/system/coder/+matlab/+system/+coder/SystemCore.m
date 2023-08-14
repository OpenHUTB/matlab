classdef SystemCore<handle&matlab.mixin.internal.indexing.Paren


%#codegen
%#ok<*EMCLS>
%#ok<*EMCA>








    properties(Access=private)
        isInitialized=int32(0);
        isSetupComplete;
    end

    properties(Access=private)
setupCompiled
        TunablePropsChanged=false

        MajorVersionNumber=matlab.system.coder.SystemProp.createVersionNumber('major');
        MinorVersionNumber=matlab.system.coder.SystemProp.createVersionNumber('minor');
    end

    properties(Access=protected)
skipReleaseCodeGen
    end

    properties(Hidden)




        isInMATLABSystemBlock=false

        fxpDataTypeOverride=0
        fxpDataTypeOverrideAppliesTo=0
propInputSize

        currentTime=-1;
        sampleTimeType='';
        sampleTime=-1;
        offsetTime=-1;
        ticksUntilNextHit=0;
        sampleTimeClassIsSingle=false;

nMsgInputs
nMsgOutputs
    end

    properties(Access=private)
inputDataType

inputFixedPointType

inputSize

inputVarSize

isInputFixedSize

isInputLocked

isInputComplex

inputDirectFeedthrough

        CacheInputSizes=false

HasTunableProps
HasTunablePropsProcessingCode


HasVarSizeProcessingCode
    end

    methods
        function dc=getInputDimensionConstraint(~,~)%#ok<STOUT>
            eml_invariant(false,...
            eml_message('MATLAB:system:MethodDoesntSupportCodeGen',...
            'getInputDimensionConstraint'));
        end
        function dc=getOutputDimensionConstraint(~,~)%#ok<STOUT>
            eml_invariant(false,...
            eml_message('MATLAB:system:MethodDoesntSupportCodeGen',...
            'getOutputDimensionConstraint'));
        end
    end

    methods(Hidden)
        function ver=getVersionString(obj)
            ver=[num2str(obj.MajorVersionNumber),'.'...
            ,num2str(obj.MinorVersionNumber)];
        end
        function[majorv,minorv]=getVersionNumber(this)
            majorv=this.MajorVersionNumber;
            minorv=this.MinorVersionNumber;
        end
        function checkTunableProps(obj)
            if obj.HasTunableProps&&obj.HasTunablePropsProcessingCode
                if obj.TunablePropsChanged
                    obj.validatePropertiesImpl();
                    obj.TunablePropsChanged=false;
                    obj.processTunedPropertiesImpl();
                    obj.clearTunablePropertyChanged();
                end
            elseif obj.isInMATLABSystemBlock&&obj.HasTunableProps&&coder.target('sfun')


                if obj.TunablePropsChanged
                    obj.TunablePropsChanged=false;
                end
            end
        end
        function flag=isAccelerated(~)
            flag=false;
        end
        function checkTunablePropChange(obj)
            if obj.HasTunableProps&&obj.isInMATLABSystemBlock&&coder.target('sfun')


                eml_invariant(~obj.TunablePropsChanged,...
                eml_message('MATLAB:system:invalidTunableModAccessCodegen'));
            end
        end


        function num=getNumFixedInputsImpl(obj)
            num=getNumInputsImpl(obj);
        end
    end

    methods
        function obj=SystemCore()
            coder.extrinsic('int2str');
            coder.allowpcode('plain');
            coder.internal.allowHalfInputs;
            obj.isInitialized=int32(0);
            obj.checkCodeGenSupport(class(obj));
            [obj.HasTunableProps,obj.HasTunablePropsProcessingCode]=initializeTunablePropertyChanged(obj);
            hasValidateInputsImpl=matlab.system.coder.hasUserImplementation.do(class(obj),'validateInputsImpl');
            hasProcessInputSizeChangeImpl=matlab.system.coder.hasUserImplementation.do(class(obj),'processInputSizeChangeImpl');
            hasProcessInputSpecChangeImpl=matlab.system.coder.hasUserImplementation.do(class(obj),'processInputSpecificationChangeImpl');
            obj.HasVarSizeProcessingCode=hasValidateInputsImpl...
            ||hasProcessInputSizeChangeImpl...
            ||hasProcessInputSpecChangeImpl;

        end

        function reset(obj)


            eml_invariant(obj.isInitialized~=int32(2),...
            eml_message('MATLAB:system:methodCalledWhenReleasedCodegen','reset'));

            if obj.HasTunableProps&&obj.isInMATLABSystemBlock&&coder.target('sfun')
                tunablePropChangedBeforeResetImpl=obj.TunablePropsChanged;
            end

            if obj.isInitialized==int32(1)
                coder.internal.defer_inference('resetImpl',obj);
            end
            if obj.HasTunableProps&&obj.isInMATLABSystemBlock&&coder.target('sfun')


                eml_invariant(tunablePropChangedBeforeResetImpl==obj.TunablePropsChanged,...
                eml_message('MATLAB:system:invalidTunableModAccessCodegen'));
            end
        end

        function s=info(obj)
            s=obj.infoImpl;
        end

        function systemblock_prestep(obj,varargin)
            if obj.isInMATLABSystemBlock&&...
                eml_const(obj.isInputVarSize(varargin{:}))&&~obj.CacheInputSizes
                obj.CacheInputSizes=true;
                if coder.internal.is_defined(obj.nMsgInputs)

                    checkInputs(obj,varargin{:});
                    checkInputSizes(obj,varargin{:});
                end
                initializeInputSizes(obj,varargin{:});
                validateInputsImpl(obj,varargin{:});
            end
        end

        function varargout=step(obj,varargin)

            eml_invariant(obj.isInitialized~=int32(2),...
            eml_message('MATLAB:system:methodCalledWhenReleasedCodegen','step'));

            if~coder.internal.is_defined(obj.nMsgInputs)
                if obj.isInitialized~=int32(1)
                    obj.setupAndReset(varargin{:});
                end
            end

            if isa(obj,'matlab.DiscreteEventSystem')
                return;
            end

            systemblock_prestep(obj,varargin{:});

            if~strcmp(coder.target,'hdl')
                updateSourceSetProperties(obj,false,varargin{:});
                checkTunableProps(obj);
            end

            numInputs=eml_const(getNumInputsImpl(obj));
            numOutputs=eml_const(getNumOutputs(obj));




            numInValidateInputs=getNumInputsToPass(obj,numInputs,'validateInputsImpl');
            [numInProcessInputSizeChange,NotStrictLocking]=getNumInputsToPass(obj,numInputs,'processInputSizeChangeImpl');
            numInProcessInputSpecChange=getNumInputsToPass(obj,numInputs,'processInputSpecificationChangeImpl');

            if obj.HasVarSizeProcessingCode


                if NotStrictLocking
                    anyInputSizeChanged=detectInputSizeChange(obj,false,varargin{:});
                    if anyInputSizeChanged

                        obj.validateInputsImpl(varargin{1:min(length(varargin),numInValidateInputs)});
                        obj.processInputSpecificationChangeImpl(varargin{1:min(length(varargin),numInProcessInputSpecChange)});
                    end
                else
                    anyInputSizeChanged=detectInputSizeChange(obj,false,varargin{:});
                    if anyInputSizeChanged

                        obj.validateInputsImpl(varargin{1:min(length(varargin),numInValidateInputs)});
                        obj.processInputSizeChangeImpl(varargin{1:min(length(varargin),numInProcessInputSizeChange)});
                    end
                end
            end

            hasGetNumOutputsImpl=matlab.system.coder.hasUserImplementation.do(class(obj),'getNumOutputsImpl');
            [~,numOut,method]=getNumInOutForStepImplOrOutputImpl(obj);

            eml_invariant((nargout<=numOutputs)||...
            hasGetNumOutputsImpl||...
            (eml_const(numOut)~=-1),...
            'MATLAB:system:getNumOutputsImplNotDef',...
            1,eml_const(method),'getNumOutputsImpl',...
            'getNumOutputsImpl',eml_const(method));

            eml_invariant((nargout<=numOutputs)||~hasGetNumOutputsImpl,...
            'MATLAB:system:maxNumOutputs',...
            eml_const(nargout),numOutputs);

            stepPresent=checkStepImpl(obj,numOutputs);
            if stepPresent||matlab.system.coder.isOutputUpdate.do(class(obj))
                eml_const(checkNumArgsStepImplOrOutputImpl(obj,numInputs,numOutputs));
                numInPassed=min(numInputs,nargin-1);

                if nargout>0
                    [varargout{1:nargout}]=obj.stepImpl(varargin{1:numInPassed});
                else
                    obj.stepImpl(varargin{1:numInPassed});
                end
            end
            checkTunablePropChange(obj);
        end

        function checkAndWarnObsoleteAPI(obj)
            coder.extrinsic('warning','message');
            if matlab.system.coder.hasUserImplementation.do(class(obj),'isInputSizeLockedImpl')
                msg=coder.const(message('MATLAB:system:ObsoleteSystemObjectAPI',class(obj),'isInputSizeLockedImpl','isInputSizeMutableImpl'));
                coder.internal.const(warning(msg));
            end
            if matlab.system.coder.hasUserImplementation.do(class(obj),'isInputComplexityLockedImpl')
                msg=coder.const(message('MATLAB:system:ObsoleteSystemObjectAPI',class(obj),'isInputComplexityLockedImpl','isInputComplexityMutableImpl'));
                coder.internal.const(warning(msg));
            end
            if matlab.system.coder.hasUserImplementation.do(class(obj),'isOutputComplexityLockedImpl')
                msg=coder.const(message('MATLAB:system:ObsoleteSystemObjectAPI2',class(obj),'isOutputComplexityLockedImpl'));
                coder.internal.const(warning(msg));
            end
            if matlab.system.coder.hasUserImplementation.do(class(obj),'processInputSizeChangeImpl')
                msg=coder.const(message('MATLAB:system:ObsoleteSystemObjectAPI',class(obj),'processInputSizeChangeImpl','processInputSpecificationChangeImpl'));
                coder.internal.const(warning(msg));
            end
        end

        function checkAndWarnObsoleteMixin(obj)
            coder.extrinsic('warning','message');

            mixinClasses={'matlab.system.mixin.SampleTime',...
            'matlab.system.mixin.Nondirect',...
            'matlab.system.mixin.Propagates',...
            'matlab.system.mixin.CustomIcon',...
            'matlab.system.mixin.internal.CustomIcon'};

            for i=1:length(mixinClasses)
                if isa(obj,mixinClasses{i})
                    msg=coder.const(message('MATLAB:system:ObsoleteSystemObjectMixin',class(obj),mixinClasses{i}));
                    coder.internal.const(warning(msg));
                end
            end
        end

        function setup(obj,varargin)

            obj.checkAndWarnObsoleteAPI();


            obj.checkAndWarnObsoleteMixin();

            obj.isSetupComplete=false;
            if isa(obj,'matlab.DiscreteEventSystem')
                checkNumArgs(obj,'setupImpl',0,0,true);
                obj.isInitialized=int32(1);
                obj.setupImpl();
                obj.setupCompiled=true;
                obj.isSetupComplete=true;
            else
                if~strcmp(coder.target,'hdl')

                    eml_invariant(obj.isInitialized==int32(0),...
                    eml_message('MATLAB:system:methodCalledWhenLockedReleasedCodegen','setup'));





                    obj.isInitialized=int32(1);


                    if~coder.internal.is_defined(obj.nMsgInputs)
                        checkInputs(obj,varargin{:});
                        checkInputSizes(obj,varargin{:});
                        initializeInputSizes(obj,varargin{:});
                    end
                end


                numParamPorts=0;
                if~strcmp(coder.target,'hdl')
                    numParamPorts=updateSourceSetProperties(obj,true,varargin{:});
                end


                obj.validateProperties();





                if~coder.internal.is_defined(obj.nMsgInputs)
                    checkNumInputs(obj,numParamPorts,varargin{:});
                end


                numInputs=eml_const(getNumInputsImpl(obj));

                if~obj.isInMATLABSystemBlock||(~coder.internal.is_defined(obj.nMsgInputs)&&~eml_const(obj.isInputVarSize(varargin{:})))
                    numInValidateInputs=getNumInputsToPass(obj,numInputs,'validateInputsImpl');

                    obj.validateInputsImpl(varargin{1:min(length(varargin),numInValidateInputs)});
                end


                numInPassed=min(numInputs,length(varargin));


                numInSetup=getNumInputsToPass(obj,numInPassed,'setupImpl');
                obj.setupImpl(varargin{1:numInSetup});
                obj.setupCompiled=true;
                obj.isSetupComplete=true;

                if~strcmp(coder.target,'hdl')
                    isWrappedObject=matlab.system.coder.isWrappedSFunObject.do(class(obj));
                    if matlab.system.coder.isOutputUpdate.do(class(obj))&&~isWrappedObject



                        inDirectFeedthrough=cacheIsInputDirectFeedthroughImpl(obj,varargin{:});
                        eml_invariant(eml_is_const(inDirectFeedthrough),eml_message('MATLAB:system:isInputDirectFeedthroughImplNotConst'));
                        obj.inputDirectFeedthrough=coder.const(inDirectFeedthrough);
                    end
                end

                checkTunablePropChange(obj);




                if(obj.HasTunableProps&&obj.HasTunablePropsProcessingCode)||...
                    obj.HasTunableProps&&obj.isInMATLABSystemBlock&&coder.target('sfun')
                    obj.TunablePropsChanged=false;
                end
            end
        end

        function release(obj)
            hasReleaseImpl=matlab.system.coder.hasUserImplementation.do(class(obj),'releaseImpl');




            if~obj.isInMATLABSystemBlock||hasReleaseImpl
                if obj.isInitialized==int32(1)


                    if~obj.isInMATLABSystemBlock||coder.target('sfun')
                        obj.isInitialized=int32(2);
                    end


                    coder.internal.defer_inference('releaseWrapper',obj);
                end
            end
        end

        function releaseWrapper(obj)
            callRequired=coder.internal.is_defined(obj.setupCompiled)&&obj.setupCompiled;
            if callRequired
                if obj.isSetupComplete
                    releaseImpl(obj);
                end
            else
                obj.setupCompiled=false;
            end
        end

        function delete(obj)
            if~coder.target('HDL')
                obj.release();
            end
        end


        function accelerate(~,~)
        end


        function varargout=simulateUsing(~,~)
            if nargout>0
                varargout{1}='Interpreted execution';
            end
        end

        function copyPublicTunableProperties(obj,srcObj)

            coder.extrinsic('matlabCodegenPublicTunableProperties');
            tunedProps=eml_const(srcObj.matlabCodegenPublicTunableProperties(class(obj)));
            for ix=1:numel(tunedProps)
                propName=tunedProps{ix};
                if coder.internal.is_defined(srcObj.(propName))
                    if coder.const(isa(srcObj.(propName),'matlab.system.coder.SystemCore'))
                        obj.(propName)=clone(srcObj.(propName));
                    else
                        obj.(propName)=srcObj.(propName);
                    end
                end
            end
        end

        function copyPublicNonTunableProperties(obj,srcObj)
            [allProps,bEmpties]=coder.const(@clonableNonTunableProps,srcObj);
            [~,~,allNProps]=coder.const(@feval,'eml_try_catch','matlab.system.coder.SystemCore.findByLogicals',allProps,bEmpties);
            N=numel(allNProps);
            for ix=coder.unroll(1:N)
                propName=coder.const(allNProps{ix});
                if coder.const(isa(srcObj.(propName),'matlab.system.coder.SystemCore'))
                    obj.(propName)=clone(srcObj.(propName));
                else
                    obj.(propName)=coder.const(srcObj.(propName));
                end
            end
        end

        function clonedObj=clone(obj)
            coder.inline('never');
            coder.extrinsic('eml_try_catch');
            coder.extrinsic('matlabCodegenPublicTunableProperties');

            className=class(obj);

            eml_invariant(coder.const(feature('SystemObjectsCloneCodegen')),...
            eml_message('MATLAB:system:cloneFailed'));

            eml_invariant(obj.isInitialized~=int32(1),...
            eml_message('MATLAB:system:codeGenUnSupportedLockedClone'));

            [~,~,wrappedClassName]=coder.const(@feval,'eml_try_catch','matlab.system.coder.getWrappedSFunObjectName.do',className);
            if~isempty(wrappedClassName)
                sargs=coder.const(getConstructionArgs(obj));
                objConstructor=str2func(coder.const(wrappedClassName));
                clonedObj=objConstructor(1,sargs{:});


                tunedProps=eml_const(obj.matlabCodegenPublicTunableProperties(wrappedClassName));
                for ix=1:numel(tunedProps)
                    propName=tunedProps{ix};
                    cloneProp(clonedObj,propName,obj.(propName));
                end
            else
                [~,~,hasCloneImpl]=coder.const(@feval,'eml_try_catch',...
                'matlab.system.coder.hasUserImplementation.do',className,'cloneImpl');
                if hasCloneImpl
                    [~,~,isInternal]=coder.const(@feval,'eml_try_catch','matlab.system.coder.SystemCore.isInToolboxDir',className);
                    eml_invariant(isInternal,eml_message('MATLAB:system:cloneImplImplemented',className));
                    clonedObj=cloneImpl(obj);
                else
                    [~,~,hasSaveImpl]=coder.const(@feval,'eml_try_catch',...
                    'matlab.system.coder.hasUserImplementation.do',className,'saveObjectImpl');
                    [~,~,hasLoadImpl]=coder.const(@feval,'eml_try_catch',...
                    'matlab.system.coder.hasUserImplementation.do',className,'loadObjectImpl');
                    if coder.const(~hasLoadImpl&&~hasSaveImpl)
                        clonedObj=cloneImpl(obj);
                    else
                        eml_invariant(false,eml_message('MATLAB:system:codeGenUnSupportedCloneUsingSaveLoad',className));
                    end
                end
            end
        end

        function num=nargin(obj)
            num=getNumInputs(obj);
        end

        function num=getNumInputs(obj)
            checkNumArgs(obj,'getNumInputsImpl',0,1);
            num=obj.getNumInputsImpl();
            eml_invariant(isa(num,'double'),...
            eml_message('MATLAB:system:mustReturnNonnegativeIntScalarCodegen',...
            class(obj),'getNumInputsImpl','1024'));
            eml_invariant(num>=0,...
            eml_message('MATLAB:system:mustReturnNonnegativeIntScalarCodegen',...
            class(obj),'getNumInputsImpl','1024'));
        end

        function num=nargout(obj)
            num=getNumOutputs(obj);
        end

        function num=getNumOutputs(obj)
            checkNumArgs(obj,'getNumOutputsImpl',0,1);
            num=obj.getNumOutputsImpl();
            eml_invariant(eml_is_const(num),...
            eml_message('MATLAB:system:codeGenNonConstReturnValue',...
            'getNumOutputsImpl'));
            eml_invariant(isa(num,'double'),...
            eml_message('MATLAB:system:mustReturnNonnegativeIntScalarCodegen',...
            class(obj),'getNumOutputsImpl','1024'));
            eml_invariant(num>=0,...
            eml_message('MATLAB:system:mustReturnNonnegativeIntScalarCodegen',...
            class(obj),'getNumOutputsImpl','1024'));
        end

        function varargout=checkedIsInputDirectFeedthroughImpl(obj,varargin)
            checkNumOutputArgs(obj,'isInputDirectFeedthroughImpl',nargout);
            numInIsIDFT=getNumInputsToPass(obj,length(varargin),'isInputDirectFeedthroughImpl');
            [varargout{1:nargout}]=isInputDirectFeedthroughImpl(obj,varargin{1:numInIsIDFT});
            for i=1:nargout
                if~(islogical(varargout{i})||isnumeric(varargout{i})||isempty(varargout{i}))
                    eml_invariant(false,eml_message('MATLAB:system:DirectFeedthroughNotLogical'));
                end
            end
        end

        function inDirectFeedthrough=cacheIsInputDirectFeedthroughImpl(obj,varargin)
            numIn=nargin-1;
            inDirectFeedthrough=true(1,numIn);
            inFeedThroughVarArg=cell(1,numIn);
            [inFeedThroughVarArg{:}]=checkedIsInputDirectFeedthroughImpl(obj,varargin{:});
            for ii=1:numIn
                inDirectFeedthrough(ii)=inFeedThroughVarArg{ii};
            end
        end

        function varargout=isInputDirectFeedthrough(obj,varargin)
            coder.extrinsic('int2str');
            numIn=getNumInputs(obj);
            eml_invariant(nargin==1||nargin==numIn+1,...
            eml_message('MATLAB:system:incorrectDirectFeedthroughArguments',0,numIn));
            isWrappedObject=coder.internal.const(matlab.system.coder.isWrappedSFunObject.do(class(obj)));
            if isWrappedObject
                [varargout{1:numIn}]=isInputDirectFeedthroughImpl(obj,varargin{:});
            elseif matlab.system.coder.isOutputUpdate.do(class(obj))
                eml_invariant(coder.internal.is_defined(obj.inputDirectFeedthrough),...
                'MATLAB:system:codeGenDirectFeedthroughBeforeSetup');
                for ii=1:numIn
                    varargout{ii}=obj.inputDirectFeedthrough(ii);
                end
            else
                [varargout{1:numIn}]=true;
            end
        end

        function flag=isLocked(obj)

            eml_invariant(obj.isInitialized~=int32(2),...
            eml_message('MATLAB:system:methodCalledWhenReleasedCodegen','isLocked'));
            flag=(obj.isInitialized==int32(1));
        end

        function validateProperties(obj)



            validateDynamicEnumerationMembers(obj);


            validatePropertiesImpl(obj);
        end






        function ds=getDiscreteState(obj)
            checkNumArgs(obj,'getDiscreteStateImpl',0,1);
            ds=getDiscreteStateImpl(obj);
        end

        function setDiscreteState(obj,ds)
            eml_invariant(obj.isInitialized==int32(1),...
            eml_message('MATLAB:system:notLocked','setDiscreteState'));
            checkNumArgs(obj,'setDiscreteStateImpl',1,0);
            setDiscreteStateImpl(obj,ds);
        end

        function ds=getContinuousState(obj)
            checkNumArgs(obj,'getContinuousStateImpl',0,1);
            ds=getContinuousStateImpl(obj);
        end

        function setContinuousState(obj,ds)
            eml_invariant(obj.isInitialized==int32(1),...
            eml_message('MATLAB:system:notLocked','setContinuousState'));
            checkNumArgs(obj,'setContinuousStateImpl',1,0);
            setContinuousStateImpl(obj,ds);
        end

        function assignOneValueFromPortsToParams(obj,propName,value)
            eml_invariant(isnumeric(value),...
            eml_message('MATLAB:system:codeGenSourceSetOnlySupportNumeric',propName));
            if obj.isInMATLABSystemBlock&&~isenum(value)
                obj.(propName)=zeros(size(value),'like',value);
            else
                obj.(propName)=value;
            end
        end

        function policy=createPolicyForTargetProp(obj,targetPropName,controlPropName)
            coder.extrinsic('matlab.system.coder.getSourceSetState');

            controlPropValue=obj.(controlPropName);

            eml_invariant(eml_is_const(controlPropValue),...
            eml_message('MATLAB:system:sourceSetControlPropInvalid',controlPropName));

            setPropertyName=[targetPropName,'Set'];

            [policyClass,policyArgs]=coder.const(...
            @matlab.system.coder.getSourceSetState,...
            class(obj),setPropertyName,getExecPlatformIndex(obj));

            policyFcn=str2func(policyClass);
            policy=policyFcn(policyArgs{:});
        end

        function numPorts=updateSourceSetProperties(obj,callFromSetup,varargin)
            coder.extrinsic('matlab.system.coder.getSourceSetInfo');

            numPorts=0;

            [propOrInputTarget,propOrInputControl,propOrMethodTarget,propOrMethodControl]=...
            coder.const(@matlab.system.coder.getSourceSetInfo,class(obj),getExecPlatformIndex(obj));


            for n=coder.unroll(1:numel(propOrInputTarget))
                targetPropName=propOrInputTarget{n};

                policy=createPolicyForTargetProp(obj,targetPropName,propOrInputControl{n});

                updatePropertyFromInput=coder.const(~useProperty(policy,obj,targetPropName));

                if updatePropertyFromInput
                    numPorts=numPorts+1;

                    inputIndex=coder.const(numPorts)+coder.const(obj.getNumInputsImpl());

                    if coder.const(callFromSetup)
                        assignOneValueFromPortsToParams(obj,targetPropName,varargin{inputIndex});

                        if obj.HasTunableProps
                            obj.TunablePropsChanged=false;

                            if obj.HasTunablePropsProcessingCode
                                obj.tunablePropertyChanged(:)=false;
                            end
                        end

                    elseif~isequaln(obj.(targetPropName),varargin{inputIndex})
                        obj.(targetPropName)=varargin{inputIndex};
                    end
                end
            end


            for n=coder.unroll(1:numel(propOrMethodTarget))
                targetPropName=propOrMethodTarget{n};

                policy=createPolicyForTargetProp(obj,targetPropName,propOrMethodControl{n});

                updatePropertyFromMethod=coder.const(~useProperty(policy,obj,targetPropName));

                if updatePropertyFromMethod
                    if(obj.HasTunableProps&&obj.HasTunablePropsProcessingCode)||callFromSetup
                        wasTunablePropsChanged=obj.TunablePropsChanged;
                        obj.(targetPropName)=policy.invokeMethod(obj);
                        obj.TunablePropsChanged=wasTunablePropsChanged;
                    else
                        obj.(targetPropName)=policy.invokeMethod(obj);
                    end
                end
            end
        end

        function numPorts=numSourceSetProperties(obj)
            coder.extrinsic('matlab.system.coder.getSourceSetInfo');

            numPorts=0;

            [propOrInputTarget,propOrInputControl]=...
            coder.const(@matlab.system.coder.getSourceSetInfo,class(obj),getExecPlatformIndex(obj));


            for n=coder.unroll(1:numel(propOrInputTarget))
                targetPropName=propOrInputTarget{n};

                policy=createPolicyForTargetProp(obj,targetPropName,propOrInputControl{n});

                updatePropertyFromInput=coder.const(~useProperty(policy,obj,targetPropName));

                if updatePropertyFromInput
                    numPorts=numPorts+1;
                end
            end
        end

        function bComposite=isClonable(obj)
            coder.extrinsic('matlabCodegenPublicProperties');
            bComposite=true;
            allProps=coder.const(obj.matlabCodegenPublicProperties(class(obj)));
            N=numel(allProps);

            for ii=1:N
                propName=coder.const(allProps{ii});
                if~coder.const(coder.internal.is_defined(obj.(propName)))
                    continue;
                end

                if~(isnumeric(obj.(propName))||ischar(obj.(propName))||...
                    isa(obj.(propName),'embedded.fi')||...
                    isa(obj.(propName),'matlab.system.StringSet'))
                    bComposite=false;
                    return;
                end
            end
        end

        function[allProps,bFlags]=clonableNonTunableProps(other)
            coder.extrinsic('eml_try_catch');
            coder.extrinsic('matlab.system.coder.System.matlabCodegenNontunablePublicProperties');

            [~,~,allProps]=coder.const(@feval,'eml_try_catch','matlab.system.coder.System.matlabCodegenNontunablePublicProperties',class(other));
            N=numel(allProps);
            bFlags=true(1,N);
            for ii=1:N
                propName=allProps{ii};
                [~,~,hasDefault]=coder.const(@feval,'eml_try_catch',...
                'matlab.system.coder.SystemCore.hasDefaultValue',class(other),propName);
                if~coder.internal.is_defined(other.(propName))||~hasDefault
                    bFlags(ii)=false;
                end
            end
        end
    end






    methods(Access=protected)

        function resetImpl(~)

        end

        function info=infoImpl(~)
            info=struct();
        end

        function s=saveObjectImpl(~)
            s=struct();
        end

        function loadObjectImpl(~,~,~)
        end

        function releaseImpl(~)

        end

        function setupImpl(varargin)

        end

        function varargout=outputImpl(~,varargin)%#ok<STOUT>

            if nargout>0
                matlab.system.internal.error('MATLAB:system:outputImplUndefined');
            end
        end

        function updateImpl(~,varargin)

        end

        function varargout=stepImpl(obj,varargin)

            assert(matlab.system.coder.isOutputUpdate.do(class(obj)));
            checkNumArgs(obj,'outputImpl',getNumInputs(obj),getNumOutputs(obj));
            checkNumArgs(obj,'updateImpl',getNumInputs(obj),0);
            [varargout{1:nargout}]=obj.outputImpl(varargin{:});
            obj.updateImpl(varargin{:});
        end

        function num=getNumInputsImpl(obj)



            num=getNumInOutForStepImplOrOutputImpl(obj);

            if(num<0)
                num=1;
            else
                num=num-1;
            end
        end

        function num=getNumOutputsImpl(obj)



            [~,num]=getNumInOutForStepImplOrOutputImpl(obj);

            if(num<0)
                num=1;
            end
        end


        function[numIn,numOut,method,isDefImpl]=getNumInOutForStepImplOrOutputImpl(obj)

            coder.extrinsic('getNumMethodArgs');
            isNondirect=matlab.system.coder.isOutputUpdate.do(class(obj));
            if isNondirect
                method='outputImpl';
            else
                method='stepImpl';
            end
            [in,out]=coder.const(@matlab.system.coder.SystemCore.getNumMethodArgs,class(obj),method);
            hasImpl=matlab.system.coder.hasUserImplementation.do(class(obj),method);
            numIn=coder.const(in);
            numOut=coder.const(out);
            isDefImpl=coder.const(~hasImpl);
        end

        function validateInputsImpl(varargin)


        end


        function flag=isInputSizeMutableImpl(obj,~)

            coder.extrinsic('matlab.system.coder.SystemCore.isStrictLocking');
            flag=coder.const(~matlab.system.coder.SystemCore.isStrictLocking(class(obj),obj.isInMATLABSystemBlock));
        end

        function flag=isInputComplexityMutableImpl(~,~)


            flag=true;
        end

        function flag=isInputDataTypeMutableImpl(~,~)


            flag=true;
        end

        function flag=isInputSizeLockedImpl(~,~)

            flag=false;
        end

        function flag=isTunablePropertyDataTypeLockedImpl(~)

            flag=false;
        end

        function processInputSizeChangeImpl(varargin)


        end

        function processInputSpecificationChangeImpl(varargin)

        end

        function validatePropertiesImpl(~)

        end

        function interface=getInterfaceImpl(~)

            interface=[];
        end

        function ds=getDiscreteStateImpl(obj)
            coder.extrinsic('getDiscreteStateProperties');
            coder.extrinsic('strtrim');
            className=class(obj);

            props=coder.internal.const(matlab.system.coder.SystemCore.getDiscreteStateProperties(className));
            len=size(props,1);
            if len>0
                for i=coder.unroll(1:len)
                    prop=props(i,:);
                    propName=coder.internal.const(strtrim(prop));
                    ds.(propName)=obj.(propName);
                end
            else
                ds=struct;
            end
        end

        function setDiscreteStateImpl(~,~)
        end

        function cs=getContinuousStateImpl(obj)
            coder.extrinsic('getContinuousStateProperties');
            coder.extrinsic('strtrim');
            className=class(obj);

            props=coder.internal.const(matlab.system.coder.SystemCore.getContinuousStateProperties(className));
            len=size(props,1);
            if len>0
                for i=coder.unroll(1:len)
                    prop=props(i,:);
                    propName=coder.internal.const(strtrim(prop));
                    cs.(propName)=obj.(propName);
                end
            else
                cs=struct;
            end
        end

        function setContinuousStateImpl(~,~)
        end

        function processTunedPropertiesImpl(~)
        end

        function varargout=isInputDirectFeedthroughImpl(obj,varargin)
            if matlab.system.coder.isOutputUpdate.do(class(obj))
                [varargout{1:nargout}]=deal(false);
            else
                [varargout{1:nargout}]=deal(true);
            end
        end

        function clonedObj=cloneImpl(obj)

            className=class(obj);


            objs=str2func(coder.const(className));
            clonedObj=objs();


            copyPublicNonTunableProperties(clonedObj,obj);


            copyPublicTunableProperties(clonedObj,obj);
        end


        function result=canAccelerateImpl(~)
            result=false;
        end

        function sts=getSampleTimeImpl(~)
            sts1=matlab.system.SampleTimeSpecification;
            eml_invariant(eml_is_const(sts1),...
            eml_message('MATLAB:system:codegenMethodReturnsNonConst',...
            'getSampleTimeImpl','getSampleTimeImpl'));
            sts=coder.const(sts1);
        end

        function sts=createSampleTime(~,varargin)
            sts1=matlab.system.SampleTimeSpecification(varargin{:});
            eml_invariant(eml_is_const(sts1),...
            eml_message('MATLAB:system:codegenCreateSTReturnsNonConst'));
            sts=coder.const(sts1);
        end

        function setNumTicksUntilNextHit(obj,ticks)
            obj.ticksUntilNextHit=ticks;
        end
    end




    methods(Hidden=true,Sealed=true)
        function flag=isLockedAndNotReleased(obj)
            flag=obj.isInitialized==int32(1);
        end
        function setupAndReset(obj,varargin)
            setup(obj,varargin{:});
            resetImpl(obj);
        end

        function varargout=parenReference(obj,varargin)
            coder.inline('always');
            coder.internal.allowHalfInputs;
            coder.internal.userReadableName([]);
            [varargout{1:nargout}]=step(obj,varargin{:});
        end

        function varargout=output(obj,varargin)
            if~matlab.system.coder.isOutputUpdate.do(class(obj))
                matlab.system.internal.error('MATLAB:system:OutputUpdateOnStepImpl',class(obj));
            end


            eml_invariant(~isReleased(obj),...
            eml_message('MATLAB:system:methodCalledWhenReleasedCodegen','output'));

            wasUninitialized=~obj.isLocked();

            if~obj.isLocked()

                obj.setupAndReset(varargin{:});
            else
                checkInputSizes(obj,varargin{:});
                numParamPorts=updateSourceSetProperties(obj,false,varargin{:});
                checkNumInputs(obj,numParamPorts,varargin{:});
                checkTunableProps(obj);

                numInputs=eml_const(getNumInputsImpl(obj));



                numInValidateInputs=getNumInputsToPass(obj,numInputs,'validateInputsImpl');
                [numInProcessInputSizeChange,NotStrictLocking]=getNumInputsToPass(obj,numInputs,'processInputSizeChangeImpl');
                numInProcessInputSpecChange=getNumInputsToPass(obj,numInputs,'processInputSpecificationChangeImpl');

                if obj.HasVarSizeProcessingCode

                    if NotStrictLocking
                        anyInputSizeChanged=detectInputSizeChange(obj,true,varargin{:});
                        if anyInputSizeChanged

                            obj.validateInputsImpl(varargin{1:min(length(varargin),numInValidateInputs)});
                            obj.processInputSpecificationChangeImpl(varargin{1:min(length(varargin),numInProcessInputSpecChange)});
                        end
                    else
                        anyInputSizeChanged=detectInputSizeChange(obj,true,varargin{:});
                        if anyInputSizeChanged

                            obj.validateInputsImpl(varargin{1:min(length(varargin),numInValidateInputs)});
                            obj.processInputSizeChangeImpl(varargin{1:min(length(varargin),numInProcessInputSizeChange)});
                        end
                    end
                end
            end

            numInputs=eml_const(getNumInputsImpl(obj));
            numOutputs=eml_const(getNumOutputs(obj));
            if wasUninitialized
                eml_invariant(nargout<=numOutputs,...
                'MATLAB:system:maxNumOutputs',...
                eml_const(nargout),numOutputs);

                checkNumArgsStepImplOrOutputImpl(obj,numInputs,numOutputs);
            end

            if strcmp(coder.target,'hdl')
                checkPropertyValues(obj);
            end

            numInPassed=min(numInputs,length(varargin));
            [varargout{1:nargout}]=obj.outputImpl(varargin{1:numInPassed});
            checkTunablePropChange(obj);
        end

        function update(obj,varargin)
            coder.extrinsic('getSourceSetInfo');

            if~matlab.system.coder.isOutputUpdate.do(class(obj))
                matlab.system.internal.error('MATLAB:system:OutputUpdateOnStepImpl',class(obj));
            end


            eml_invariant(~isReleased(obj),...
            eml_message('MATLAB:system:methodCalledWhenReleasedCodegen','update'));

            checkInputs(obj,varargin{:});


            numInputs=eml_const(getNumInputsImpl(obj));
            numOutputs=eml_const(getNumOutputsImpl(obj));

            checkNumArgs(obj,'updateImpl',numInputs,0);

            if~obj.isLocked()

                if numOutputs>0

                    eml_invariant(obj.isLockedAndNotReleased(),...
                    eml_message('MATLAB:system:updateCalledBeforeSetupCodegen',class(obj)));
                end
                obj.setupAndReset(varargin{:});
            else
                checkInputSizes(obj,varargin{:});
                numParamPorts=coder.const(numSourceSetProperties(obj));
                checkNumInputs(obj,numParamPorts,varargin{:});

                checkTunableProps(obj);




                numInValidateInputs=getNumInputsToPass(obj,numInputs,'validateInputsImpl');
                [numInProcessInputSizeChange,NotStrictLocking]=getNumInputsToPass(obj,numInputs,'processInputSizeChangeImpl');
                numInProcessInputSpecChange=getNumInputsToPass(obj,numInputs,'processInputSpecificationChangeImpl');

                if obj.HasVarSizeProcessingCode

                    if NotStrictLocking
                        anyInputSizeChanged=detectInputSizeChange(obj,false,varargin{:});
                        if anyInputSizeChanged

                            obj.validateInputsImpl(varargin{1:min(length(varargin),numInValidateInputs)});
                            obj.processInputSpecificationChangeImpl(varargin{1:min(length(varargin),numInProcessInputSpecChange)});
                        end
                    else
                        anyInputSizeChanged=detectInputSizeChange(obj,false,varargin{:});
                        if anyInputSizeChanged

                            obj.validateInputsImpl(varargin{1:min(length(varargin),numInValidateInputs)});
                            obj.processInputSizeChangeImpl(varargin{1:min(length(varargin),numInProcessInputSizeChange)});
                        end
                    end
                end
            end

            if strcmp(coder.target,'hdl')
                checkPropertyValues(obj);
            end
            numInPassed=min(numInputs,length(varargin));
            obj.updateImpl(varargin{1:numInPassed});
            checkTunablePropChange(obj);
        end

        function sts=getSampleTime(obj)


            if obj.offsetTime<=-20
                if obj.sampleTimeClassIsSingle
                    sts=matlab.system.SampleTimeSpecification(...
                    'Type','Controllable',...
                    'TickTime',single(obj.sampleTime));
                else
                    sts=matlab.system.SampleTimeSpecification(...
                    'Type','Controllable',...
                    'TickTime',obj.sampleTime);
                end
            elseif obj.sampleTime>0
                if obj.sampleTimeClassIsSingle
                    sts=matlab.system.SampleTimeSpecification(...
                    'Type','Discrete',...
                    'SampleTime',single(obj.sampleTime),...
                    'OffsetTime',single(obj.offsetTime));
                else
                    sts=matlab.system.SampleTimeSpecification(...
                    'Type','Discrete',...
                    'SampleTime',obj.sampleTime,...
                    'OffsetTime',obj.offsetTime);
                end
            elseif obj.sampleTime==0&&obj.offsetTime==1
                sts=matlab.system.SampleTimeSpecification(...
                'Type','Fixed In Minor Step');
            elseif obj.sampleTime==-1
                sts=matlab.system.SampleTimeSpecification(...
                'Type','Inherited');
            else
                error(['bad codegen op: ',obj.sampleTimeType]);
            end
        end


        function time=getCurrentTime(obj)
            time=obj.currentTime;
        end


        function time=setCurrentTime(obj,time)
            obj.currentTime=time;
        end


        function setSampleTime(obj,newSts,varargin)
            obj.sampleTime=newSts(1);
            if size(newSts)==2
                obj.offsetTime=newSts;
            end
        end
    end

    methods(Static)

        function props=getDiscreteStateProperties(className)
            mc=meta.class.fromName(className);
            mps=mc.Properties;
            props={};
            for ii=1:length(mps)
                mp=mps{ii};
                if(isa(mp,'matlab.system.CustomMetaProp')&&mp.DiscreteState)
                    props{end+1}=mp.Name;
                end
            end
            props=char(props);
        end

        function props=getContinuousStateProperties(className)
            mc=meta.class.fromName(className);
            mps=mc.Properties;
            props={};
            for ii=1:length(mps)
                mp=mps{ii};
                if(isa(mp,'matlab.system.CustomMetaProp')&&mp.ContinuousState)
                    props{end+1}=mp.Name;
                end
            end
            props=char(props);
        end

        function s=bool2str(val,strFalse,strTrue)
            if val
                s=strTrue;
            else
                s=strFalse;
            end
        end

        function s=size2str(sz)
            coder.extrinsic('int2str');
            s=eml_const(int2str(sz));
            s=['[',s,']'];
        end

        function[numIn,numOut]=getNumMethodArgs(className,method)




            if~matlab.system.coder.hasUserImplementation.do(className,method)
                numIn=-1;
                numOut=-1;
            else
                wrappedClassName=matlab.system.coder.getWrappedSFunObjectName.do(className);
                if isempty(wrappedClassName)
                    mc=meta.class.fromName(className);
                else
                    mc=meta.class.fromName(wrappedClassName);
                end

                m=findobj(mc.MethodList,'Name',method);

                numIn=numel(m.InputNames);

                if(numIn>0)&&strcmp(m.InputNames{end},'varargin')
                    numIn=-1;
                end
                numOut=numel(m.OutputNames);

                if(numOut>0)&&strcmp(m.OutputNames{end},'varargout')
                    numOut=-1;
                end
            end






        end


        function[stepPresent,ouPresent]=checkForExecutionMethods(className)


            mc=meta.class.fromName(className);
            methodNames={mc.MethodList.Name};
            ouPresent=any(strcmp('updateImpl',methodNames)|strcmp('outputImpl',methodNames));



            stepImplMM=findobj(mc.MethodList,'Name','stepImpl');
            stepPresent=~strcmp(stepImplMM.DefiningClass.Name,'matlab.system.SystemImpl');
        end
    end




    methods(Static,Hidden)
        function flag=generatesCode()

            flag=true;
        end
        function newObj=createObjectFromStruct(className,s)
            newObj=feval(className);
            if nargin>1
                set(newObj,s);
            end
        end
        function setObjectProp(newObj,propName,value)
            set(newObj,propName,value);
        end


        function flag=isStrictLocking(className,isInSystemBlock)
            mc=matlab.system.coder.hasUserImplementation.getMetaClassFromClassName(className);

            isNotAuthored=~isempty(?matlab.system.SystemAdaptor)&&(mc<?matlab.system.SystemAdaptor);
            isSystemBlock=isInSystemBlock;
            defOrInheritStrictDefaults=mc.StrictDefaults;
            flag=isNotAuthored||isSystemBlock||defOrInheritStrictDefaults;
        end
    end





    methods
        function size=emlGetInputSize(obj,index)
            size=getInputSize(obj,index);
        end
    end

    methods(Access=protected)

        function flag=propagatedInputFixedSize(obj,index)
            coder.internal.prefer_const(index);
            flag=obj.isInputFixedSize{index};
        end

        function sz=propagatedInputSize(obj,index)
            sz=getInputSize(obj,index);
        end
        function sz=getInputSize(obj,index)
            coder.internal.prefer_const(index);
            coder.extrinsic('int2str');


            sz=coder.internal.getprop_if_defined(obj.inputSize);
            if isempty(sz)||(numel(sz{index})==1&&sz{index}==0)
                propPropSize=coder.internal.getprop_if_defined(obj.propInputSize);
                if~isempty(propPropSize)&&~isempty(propPropSize{index})&&obj.isInMATLABSystemBlock
                    sz=obj.propInputSize{index};
                else
                    sz=obj.inputVarSize{index};
                end
            else
                sz=obj.inputSize{index};
            end
        end

        function flag=isInputFloatingPoint(obj,index)
            coder.internal.prefer_const(index);
            name=obj.getInputDataType(coder.internal.const(index));
            flag=strcmp(name,'double')||strcmp(name,'single');
        end

        function type=getInputDataType(obj,index)
            coder.internal.prefer_const(index);
            coder.extrinsic('int2str');
            type=obj.inputDataType{index};
        end

        function setVarSizeAllowedStatus(~,~)


        end

    end

    methods(Hidden)
        function varargout=getOutputSize(obj)
            checkNumArgs(obj,'getOutputSizeImpl',0,getNumOutputs(obj));
            [varargout{1:nargout}]=obj.getOutputSizeImpl();


            eml_invariant(nargout<=getNumOutputs(obj),...
            eml_message('MATLAB:system:invalidPropagatorNumOutRequested',...
            class(obj),'getOutputSize',nargout,getNumOutputs(obj)));

            for ii=1:nargout
                cur=varargout{ii};
                eml_invariant(matlab.system.coder.SystemCore.isValidSize(cur),...
                eml_message('MATLAB:system:sizeMustBeNonnegativeIntScalarCodegen',...
                class(obj),'getOutputSizeImpl','2^31-1'));
            end
        end
    end

    methods(Access=protected)
        function varargout=getOutputSizeImpl(obj)
            eml_invariant(getNumInputs(obj)==1&&getNumOutputs(obj)==1,...
            eml_message('MATLAB:system:mustImplementPropMethod',...
            'getOutputSizeImpl'));
            varargout{1}=obj.propagatedInputSize(1);
        end
    end

    methods(Static,Access=private)
        function flag=isValidSize(sz)
            flag=isnumeric(sz)&&isvector(sz)&&...
            isequal(sz,floor(sz))&&all(sz>0);
        end
    end

    methods(Static)
        function props=matlabCodegenNontunableProperties(~)
            props={'numInputs','numOutputs','setupCompiled',...
            'MajorVersionNumber','MinorVersionNumber','isInMATLABSystemBlock',...
            'HasTunableProps','HasTunablePropsProcessingCode',...
            'HasVarSizeProcessingCode','inputDataType',...
            'isInputComplex','isInputLocked','inputFixedPointType','inputSize',...
            'propInputSize','inputDirectFeedthrough','fxpDataTypeOverride',...
            'fxpDataTypeOverrideAppliesTo','skipReleaseCodeGen',...
            'sampleTime','offsetTime','sampleTimeType',...
            'sampleTimeClassIsSingle','nMsgInputs','nMsgOutputs',...
            'isInputFixedSize'};
        end

        function methodNames=matlabCodegenUnsupportedMethods
            methodNames={'getImpulseResponseLengthImpl',...
            'getImpulseResponseLength',...
            'getInputDimensionConstraint',...
            'getOutputDimensionConstraint',...
            'isOutputFixedSizeImpl',...
            'getOutputDataTypeImpl',...
            'isOutputComplexImpl',...
            'getDiscreteStateSpecificationImpl',...
            'getContinuousStateSizeImpl',...
            'isOutputFixedSize',...
            'getOutputDataType',...
            'isOutputComplex',...
            'getDiscreteStateSpecification',...
            'getContinuousStateSize',...
            'propagatedInputDataType',...
            'propagatedInputComplexity',...
            'propagatedOutputSize',...
            'propagatedOutputDataType',...
            'propagatedOutputFixedSize',...
'propagatedOutputComplexity'...
            ,'inputDataType',...
            'inputFixedSize',...
            'inputComplexity',...
            'outputSize',...
            'outputDataType',...
            'outputFixedSize',...
            'outputComplexity'};
        end




        function names=matlabCodegenOnceNames
            names={'isInitialized','setupAndReset','setup','setupImpl','resetImpl'};
        end

    end

    methods(Access=protected)
        function checkInputs(obj,varargin)

            coder.extrinsic('num2str');
            coder.extrinsic('tostring');


            inType=coder.internal.getprop_if_defined(obj.inputDataType);
            inCplx=coder.internal.getprop_if_defined(obj.isInputComplex);
            inFiType=coder.internal.getprop_if_defined(obj.inputFixedPointType);
            if~isempty(inType)&&~isempty(inCplx)&&~isempty(inFiType)
                for i=coder.unroll(1:nargin-1)


                    if numel(inType)<i||isempty(inType{i})
                        return;
                    end
                    isComplex=~isreal(varargin{i});

                    eml_invariant(strcmp(inType{i},class(varargin{i})),...
                    eml_message('MATLAB:system:inputsNotSameDataTypeCodegen',...
                    i,inType{i},class(varargin{i})));

                    eml_invariant(inCplx(i)==isComplex,...
                    eml_message('MATLAB:system:inputsNotSameComplexityCodegen',i,...
                    matlab.system.coder.SystemCore.bool2str(inCplx(i),'real','complex'),...
                    matlab.system.coder.SystemCore.bool2str(isComplex,'real','complex')));

                    if strcmp(inType{i},'embedded.fi')
                        nt=numerictype(varargin{i});
                        if~isempty(inFiType{i})
                            eml_invariant(isequal(inFiType{i},nt),...
                            eml_message('MATLAB:system:inputsNotSameNumerictypeCodegen',i,...
                            coder.internal.const(tostring(inFiType{i})),coder.internal.const(tostring(nt))));
                        end
                    end

                end
            end
            if~isempty(inType)
                if numel(inType)~=numel(varargin)
                    return;
                end
            end

            [numFormalIn,~,method]=getNumInOutForStepImplOrOutputImpl(obj);


            obj.inputDataType=matlab.system.coder.SystemCore.cacheInputDataTypes(numFormalIn-1,varargin{:});

            obj.isInputComplex=matlab.system.coder.SystemCore.cacheInputComplexity(numFormalIn-1,varargin{:});

            obj.inputFixedPointType=matlab.system.coder.SystemCore.cacheInputFixedPointType(numFormalIn-1,varargin{:});
        end


        function initializeInputSizes(obj,varargin)
            coder.extrinsic('num2str');
            coder.extrinsic('int2str');

            inputLocked=coder.internal.getprop_if_defined(obj.isInputLocked);
            if numel(varargin)~=numel(inputLocked)
                return;
            end

            varSizes=cell(1,numel(varargin));
            isFixedSize=cell(1,numel(varargin));
            for i=coder.unroll(1:numel(varargin))
                if isempty(inputLocked)
                    inLocked=true;
                else
                    inLocked=inputLocked(i);
                end
                if~eml_is_const(size(varargin{i}))||...
                    (obj.HasVarSizeProcessingCode&&~inLocked)
                    varSizes{i}=uint32([size(varargin{i}),ones(1,8-numel(size(varargin{i})))]);
                else
                    varSizes{i}=ones(1,8,'uint32');
                end
                if~eml_is_const(size(varargin{i}))
                    isFixedSize{i}=false;
                else
                    isFixedSize{i}=true;
                end
            end
            obj.inputVarSize=varSizes;
            if~coder.internal.is_defined(obj.isInputFixedSize)
                obj.isInputFixedSize=isFixedSize;
            end
        end

        function checkStrictPermissiveLocking(obj)



            strictMethods={'isInputComplexityLockedImpl','isInputSizeLockedImpl',...
            'processInputSizeChangeImpl'};
            strictIsDef=zeros(1,size(strictMethods,2));


            for i=1:size(strictMethods,2)
                strictIsDef(i)=~matlab.system.coder.hasUserImplementation.do(class(obj),strictMethods{i});
            end




            permissiveMethods={'isInputComplexityMutableImpl','isInputSizeMutableImpl',...
            'processInputSpecificationChangeImpl','isInputDataTypeMutableImpl',...
            'isTunablePropertyDataTypeMutableImpl','isDiscreteStateSpecificationMutableImpl'};
            permissiveIsDef=zeros(1,size(permissiveMethods,2));


            for i=1:size(permissiveMethods,2)
                permissiveIsDef(i)=~matlab.system.coder.hasUserImplementation.do(class(obj),permissiveMethods{i});
            end


            for i=1:length(strictMethods)
                for j=1:length(permissiveMethods)
                    eml_invariant(permissiveIsDef(j)||strictIsDef(i),...
                    eml_message('MATLAB:system:lockModeConflictMethods',permissiveMethods{j},...
                    strictMethods{i},permissiveMethods{i},strictMethods{i}));
                end
            end


            strictMethodsNoSub='isOutputComplexityLockedImpl';
            NotStrictIsOpCplxLocked=~matlab.system.coder.hasUserImplementation.do(class(obj),strictMethodsNoSub);
            for j=1:length(permissiveMethods)
                eml_invariant(permissiveIsDef(j)||NotStrictIsOpCplxLocked,...
                eml_message('MATLAB:system:lockModeConflictMethodsNoSub',permissiveMethods{j},...
                strictMethodsNoSub,strictMethodsNoSub));
            end

        end

        function inputLocked=cacheInputLocked(obj,numFormalArg,numIn,curLocked)

            if coder.const(numFormalArg>=0)&&...
                ~matlab.system.coder.hasUserImplementation.do(class(obj),'getNumInputsImpl')
                numIn=numFormalArg;
            end

            if~isempty(curLocked)&&numel(curLocked)~=numIn
                inputLocked=curLocked;

                return;
            end

            checkStrictPermissiveLocking(obj);

            NotDefStrictIsSzLocked=~matlab.system.coder.hasUserImplementation.do(class(obj),'isInputSizeLockedImpl');
            inputLocked=false(1,numIn);
            for ii=coder.unroll(1:numIn)



                if coder.internal.is_defined(obj.nMsgInputs)&&coder.const(ii>numIn-obj.nMsgInputs)





                    inLocked=false;
                elseif coder.const(NotDefStrictIsSzLocked)
                    inLocked=~obj.isInputSizeMutableImpl(ii);
                else
                    inLocked=obj.isInputSizeLockedImpl(ii);
                end

                eml_invariant(~isempty(inLocked),eml_message('MATLAB:system:isInputSizeMutableImplNotScalar'));
                eml_invariant(isscalar(inLocked),eml_message('MATLAB:system:isInputSizeMutableImplNotScalar'));
                inputLocked(ii)=inLocked;
            end
        end

        function checkInputSizes(obj,varargin)
            coder.extrinsic('num2str');
            checkNumArgs(obj,'isInputSizeMutableImpl',1,1);


            [numFormalIn,~,method]=coder.const(@getNumInOutForStepImplOrOutputImpl,obj);
            numParamPorts=coder.const(numSourceSetProperties(obj));
            if(numFormalIn>=0)
                numActIn=numFormalIn-1+numParamPorts;
            else
                numActIn=numFormalIn-1;
            end

            curLocked=coder.internal.getprop_if_defined(obj.isInputLocked);
            inputLocked=cacheInputLocked(obj,numActIn,numel(varargin),curLocked);
            coder.internal.prefer_const(inputLocked);
            eml_invariant(eml_is_const(inputLocked),eml_message('MATLAB:system:isInputSizeMutableImplNotConst'));
            obj.isInputLocked=inputLocked;

            inSize=coder.internal.getprop_if_defined(obj.inputSize);
            if~isempty(inSize)
                if numel(inSize)~=numel(varargin)
                    return;
                end
            end
            for i=coder.unroll(1:numel(varargin))





                if i>obj.getNumInputsImpl()
                    inputSizeLocked=true;
                else
                    inputSizeLocked=inputLocked(i);
                end
                if inputSizeLocked
                    curInputSize=size(varargin{i});
                    eml_invariant(eml_is_const(curInputSize),eml_message('MATLAB:system:inputSizeNotFixed',i,class(obj)));

                    if~isempty(inSize)
                        if i>numel(inSize)
                            continue;
                        end
                        oldsize=inSize{i};

                        b=(numel(oldsize)==numel(curInputSize))&&all(oldsize==curInputSize);
                        eml_invariant(b,...
                        eml_message('MATLAB:system:inputsNotSameSizeCodegen',i,...
                        matlab.system.coder.SystemCore.size2str(oldsize),...
                        matlab.system.coder.SystemCore.size2str(curInputSize)));
                    end
                end
            end
            if coder.const(numel(varargin)>0)&&~coder.internal.is_defined(obj.inputSize)
                if coder.const(obj.isInMATLABSystemBlock)


                    obj.inputSize=matlab.system.coder.SystemCore.cacheInputSize(...
                    obj.isInMATLABSystemBlock,obj.propInputSize,obj.isInputLocked,varargin{:});
                else
                    obj.inputSize=matlab.system.coder.SystemCore.cacheInputSize(...
                    obj.isInMATLABSystemBlock,1,obj.isInputLocked,varargin{:});
                end
            elseif coder.const(numel(varargin)==0)
                obj.inputSize=[];
            else




                obj.inputSize=inSize;
            end
        end

        function anyInputSizeChanged=detectInputSizeChange(obj,skipNonDirectFeed,varargin)
            coder.extrinsic('num2str');
            anyInputSizeChanged=false;
            isWrappedObject=coder.internal.const(matlab.system.coder.isWrappedSFunObject.do(class(obj)));
            if isWrappedObject
                return;
            end
            inputLocked=coder.internal.getprop_if_defined(obj.isInputLocked);
            for i=coder.unroll(1:numel(varargin))
                if isempty(inputLocked)
                    inLocked=true;
                else
                    inLocked=inputLocked(i);
                end
                if coder.internal.is_defined(obj.inputVarSize)&&...
                    (~eml_is_const(size(varargin{i}))||...
                    (obj.HasVarSizeProcessingCode&&~inLocked))







                    eml_invariant(numel(size(varargin{i}))<9,eml_message('MATLAB:system:tooManyInputsDimensions',8));
                    inSize=uint32([size(varargin{i}),ones(1,8-numel(size(varargin{i})))]);

                    for k=1:numel(inSize)
                        if~(skipNonDirectFeed&&~obj.inputDirectFeedthrough(i))&&...
                            obj.inputVarSize{i}(k)~=inSize(k)
                            anyInputSizeChanged=true;
                            obj.inputVarSize{i}=inSize;
                            break;
                        end
                    end
                end
            end
        end

        function checkNumInputs(obj,numParamPorts,varargin)
            coder.extrinsic('num2str');

            NumArgsIn=nargin-1;
            if~strcmp(coder.target,'hdl')




                if numParamPorts~=0
                    NumArgsIn=NumArgsIn-numParamPorts;
                end
            end


            numinputs=getNumInputsImpl(obj);

            eml_invariant(eml_is_const(numinputs),...
            'MATLAB:system:codeGenNonConstReturnValue',...
            'getNumInputsImpl');
            hasGetNumInputsImpl=matlab.system.coder.hasUserImplementation.do(class(obj),'getNumInputsImpl');
            [numIn,~,method]=getNumInOutForStepImplOrOutputImpl(obj);

            coder.internal.prefer_const(NumArgsIn);



            eml_invariant(((NumArgsIn-1)==numinputs)||...
            hasGetNumInputsImpl||...
            (eml_const(numIn)~=-1),...
            'MATLAB:system:getNumInputsImplNotDef',...
            eml_const(numinputs),eml_const(method),'getNumInputsImpl',...
            'getNumInputsImpl',eml_const(method));

            eml_invariant((NumArgsIn-1)<=numinputs,...
            'MATLAB:system:maxNumInputs',...
            eml_const(numinputs),NumArgsIn-1);



            eml_invariant(~hasGetNumInputsImpl||(NumArgsIn-1)>=numinputs,...
            'MATLAB:system:minNumInputs',...
            eml_const(numinputs),NumArgsIn-1);
        end

        function validateDynamicEnumerationMembers(obj)
            coder.extrinsic('matlab.system.coder.getDynamicEnumerationPropertyNames');

            propertiesToCheck=coder.internal.const(matlab.system.coder.getDynamicEnumerationPropertyNames(class(obj)));

            for n=coder.unroll(1:numel(propertiesToCheck))
                value=coder.internal.const(obj.(propertiesToCheck{n}));

                isValidValue=coder.internal.const(...
                matlab.system.coder.SystemProp.isValidValueForDynamicEnumeration(obj,propertiesToCheck{n},value));

                coder.internal.assert(isValidValue,...
                'MATLAB:system:Enumeration:InvalidEnumerationValueSetupCodegen',...
                char(value),propertiesToCheck{n},class(obj));
            end
        end

        function hasStepImpl=checkStepImpl(obj,numOutputs)

            hasOutputUpdate=matlab.system.coder.isOutputUpdate.do(class(obj));
            hasStepImpl=matlab.system.coder.hasUserImplementation.do(class(obj),'stepImpl');



            if~hasOutputUpdate&&~hasStepImpl&&(numOutputs>0)
                eml_invariant(hasOutputUpdate,'MATLAB:system:stepImplUndefined');
            end
        end
    end

    methods(Hidden)

        function yes=isReleased(obj)
            yes=(obj.isInitialized==int32(2));
        end

        function checkNumOutputArgs(obj,method,numOutputs)
            coder.extrinsic('getNumMethodArgs');

            [~,out]=matlab.system.coder.SystemCore.getNumMethodArgs(class(obj),method);
            sigOutputs=eml_const(out);

            eml_invariant((sigOutputs==-1)||(sigOutputs>=numOutputs),...
            'MATLAB:system:invalidImplMethodNumOutArgs',...
            method,class(obj),method,numOutputs);
        end

        function checkNumArgs(obj,method,numInputs,numOutputs,allowZeroInputs)
            coder.extrinsic('getNumMethodArgs');

            if nargin<5
                allowZeroInputs=false;
            end
            [in,out]=matlab.system.coder.SystemCore.getNumMethodArgs(class(obj),method);
            sigInputs=eml_const(in);
            sigOutputs=eml_const(out);

            if allowZeroInputs
                eml_invariant((sigInputs==-1)||(sigInputs-1>=numInputs)||(sigInputs-1==0),...
                'MATLAB:system:invalidImplMethodNumInArgs',...
                method,class(obj),method,numInputs);
            else
                eml_invariant((sigInputs==-1)||(sigInputs-1>=numInputs),...
                'MATLAB:system:invalidImplMethodNumInArgs',...
                method,class(obj),method,numInputs);
            end
            eml_invariant((sigOutputs==-1)||(sigOutputs>=numOutputs),...
            'MATLAB:system:invalidImplMethodNumOutArgs',...
            method,class(obj),method,numOutputs);
        end

        function checkNumArgsStepImplOrOutputImpl(obj,numInputs,numOutputs)




            [in,out,method,isDefImpl]=getNumInOutForStepImplOrOutputImpl(obj);
            sigInputs=eml_const(in);
            sigOutputs=eml_const(out);
            isMethodDefImpl=eml_const(isDefImpl);

            if(sigInputs==-1)&&(isMethodDefImpl~=1)
                hasGetNumInputsImpl=matlab.system.coder.hasUserImplementation.do(class(obj),'getNumInputsImpl');
                if~hasGetNumInputsImpl

                    sigInputsMod=1;

                    eml_invariant((numInputs==1),...
                    'MATLAB:system:getNumInputsImplNotDef',...
                    1,eml_const(method),'getNumInputsImpl',...
                    'getNumInputsImpl',eml_const(method));
                    eml_invariant((sigInputsMod>=numInputs),...
                    'MATLAB:system:invalidImplMethodNumInArgs',...
                    eml_const(method),class(obj),eml_const(method),numInputs);
                end
            else
                eml_invariant(((sigInputs-1)>=numInputs)||(sigInputs==-1),...
                'MATLAB:system:invalidImplMethodNumInArgs',...
                eml_const(method),class(obj),eml_const(method),numInputs);
            end

            if(sigOutputs==-1)&&(isMethodDefImpl~=1)
                hasGetNumOutputsImpl=matlab.system.coder.hasUserImplementation.do(class(obj),'getNumOutputsImpl');
                if~hasGetNumOutputsImpl

                    sigOutputsMod=1;

                    eml_invariant((numOutputs==1),...
                    'MATLAB:system:getNumOutputsImplNotDef',...
                    1,eml_const(method),'getNumOutputsImpl',...
                    'getNumOutputsImpl',eml_const(method));
                    eml_invariant((sigOutputsMod>=numOutputs),...
                    'MATLAB:system:invalidImplMethodNumOutArgs',...
                    eml_const(method),class(obj),eml_const(method),numOutputs);
                end
            else
                eml_invariant((sigOutputs>=numOutputs)||(sigOutputs==-1),...
                'MATLAB:system:invalidImplMethodNumOutArgs',...
                eml_const(method),class(obj),eml_const(method),numOutputs);
            end
        end
    end

    methods(Static,Access=private)
        function checkCodeGenSupport(className)
            coder.extrinsic('matlab.system.isCodeGenSupported');
            eml_invariant(coder.internal.const(...
            matlab.system.isCodeGenSupported(className,eml_option('MCOS'))),...
            eml_message('MATLAB:system:noCodegen',className));
        end

        function y=isInputVarSize(varargin)
            y=false;
            for ii=coder.unroll(1:nargin)
                if~eml_is_const(size(varargin{ii}))
                    y=true;
                    break;
                end
            end
        end
        function types=cacheInputDataTypes(numFormalArg,varargin)
            if numFormalArg<0
                types=cell(1,nargin-1);
            else
                types=cell(1,numFormalArg);
            end
            for ii=1:numel(types)
                if ii<=length(varargin)
                    types{ii}=class(varargin{ii});
                else
                    types{ii}='';
                end
            end
        end
        function isComplex=cacheInputComplexity(numFormalArg,varargin)


            if numFormalArg<0
                isComplex=false(1,nargin-1);
            else
                isComplex=false(1,numFormalArg);
            end
            for ii=1:numel(isComplex)
                if ii<=length(varargin)
                    isComplex(ii)=~isreal(varargin{ii});
                end
            end
        end
        function inputFixedPoint=cacheInputFixedPointType(numFormalArg,varargin)
            if numFormalArg<0
                inputFixedPoint=cell(1,nargin-1);
            else
                inputFixedPoint=cell(1,numFormalArg);
            end
            for ii=1:numel(inputFixedPoint)
                if ii<=length(varargin)
                    if isa(varargin{ii},'embedded.fi')
                        inputFixedPoint{ii}=numerictype(varargin{ii});
                    else
                        inputFixedPoint{ii}=numerictype;
                    end
                else
                    inputFixedPoint{ii}=numerictype;
                end
            end
        end
        function inSizes=cacheInputSize(isInSystemBlock,propInputSize,inputLocked,varargin)
            inSizes=cell(1,numel(inputLocked));
            for i=coder.unroll(1:numel(inputLocked))
                if length(varargin)<i
                    inSizes{i}=0;
                elseif inputLocked(i)||eml_is_const(size(varargin{i}))
                    inSizes{i}=size(varargin{i});
                elseif eml_is_const(size(varargin{i}))&&isInSystemBlock
                    inSizes{i}=propInputSize{i};
                else
                    inSizes{i}=0;
                end
            end
        end
    end

    methods(Sealed,Hidden)


        function disp(~)

        end

        function display(~)%#ok<DISPLAY>

        end

        function details(~)

        end

        function flag=getExecPlatformIndex(obj)
            flag=obj.isInMATLABSystemBlock;
        end
    end

    methods(Access=protected,Hidden,Sealed)
        function getPropertyGroups(~)

        end
        function setFixptDataTypeOverride(obj,val)
            obj.fxpDataTypeOverride=val;
        end
        function val=getFixptDataTypeOverride(obj)
            val=obj.fxpDataTypeOverride;
        end
        function val=getFixptDataTypeOverrideAppliesTo(obj)
            val=obj.fxpDataTypeOverrideAppliesTo;
        end
        function dtoNT=overrideDataType(obj,oNT)
            fxpDTOver=getFixptDataTypeOverride(obj);
            fxpDTAppliesTo=getFixptDataTypeOverrideAppliesTo(obj);
            isdouble=strcmpi(oNT.DataType,'double');
            issingle=strcmpi(oNT.DataType,'single');
            isboolean=strcmpi(oNT.DataType,'boolean');
            isFloat=isdouble||issingle;

            if isboolean

                dtoNT=oNT;
            else
                switch fxpDTAppliesTo
                case 0

                    doOverrideType=true;
                case 1

                    doOverrideType=isFloat;
                otherwise

                    doOverrideType=~isFloat;
                end
                if doOverrideType
                    switch fxpDTOver
                    case 2

                        dtoNT=numerictype('double');
                    case 3

                        dtoNT=numerictype('single');
                    case 1

                        if isFloat
                            dtoNT=numerictype('double');
                        else
                            dtoNT=numerictype(oNT,'DataTypeMode','Scaled double: binary point scaling');
                        end
                    otherwise

                        dtoNT=oNT;
                    end
                else

                    dtoNT=oNT;
                end
            end
        end
    end

    methods(Static,Hidden)
        function args=findByLogicals(props,flags)
            args=props(flags);
        end

        function flag=hasDefaultValue(className,propName)
            mc=meta.class.fromName(className);
            p=findobj(mc.PropertyList,'Name',propName);
            flag=p.HasDefault;
        end

        function flag=isInToolboxDir(className)
            filepath=which(className);
            toolboxdir=fullfile(matlabroot);
            flag=strfind(filepath,toolboxdir)==1;
        end
    end

    methods(Access=private)
        function[y,isDefault]=getNumInputsToPass(obj,numIn,method)
            coder.extrinsic('getNumMethodArgs');
            in=eml_const(matlab.system.coder.SystemCore.getNumMethodArgs(class(obj),method));
            hasMethod=matlab.system.coder.hasUserImplementation.do(class(obj),method);
            if hasMethod&&(in~=-1)
                y=eml_const(min(in-1,numIn));
            else
                y=eml_const(numIn);
            end
            isDefault=~hasMethod;
        end
    end
end



