


classdef m2m_icm<slEnginePir.model2model
    properties(Access='public')
        fExcludedClass;
        fMaskedProperties;
        fCls2IdxMap;
        fObj2IdxMap;
        fIcmCls2IdxMap;
        fIcmObj2IdxMap;
        fSS2FcnCallMap;
        fTestMode;
        fIsForBosch;
        tSortedFcnCallerMap;
        fNestedObj;
    end

    properties(Hidden)
        cleanup_icm;
    end

    methods(Access='public')
        function m2mObj=m2m_icm(aOriSys)
            if~checkRequiredSlfeatures()
                error('Bosch features are required for ICM transformation. Please turn on the feature and try again...');
            end
            p=pir;
            p.destroyPirCtx(aOriSys);
            m2mObj@slEnginePir.model2model(aOriSys);

            m2mObj.fExcludedClass=[];
            m2mObj.fMaskedProperties=containers.Map('KeyType','char','ValueType','any');
            m2mObj.fMaskedProperties('Constant')={'Value'};
            m2mObj.fMaskedProperties('Lookup_n-D')={'Table','BreakpointsForDimension1','BreakpointsForDimension2'};
            m2mObj.fCandidateInfo=struct('Class',{},'HasThis',{},'MaskParamType',{},'MemberFcns',{},'GetFcns',{},'SetFcns',{},'Objects',{},'MemberVars',{},'ConstVars',{},'isExcluded',{});
            m2mObj.fXformedInfo=struct('Class',{},'ClassMdlRef',{},'MemberFcns',{},'Objects',{});
            m2mObj.fPirCreator=slEnginePir.CloneDetectionCreator(Simulink.SLPIR.Event.PostCompBlock);
            m2mObj.fPirCreator.createGraphicalPir([{m2mObj.fOriMdl},m2mObj.fRefMdls]);
            m2mObj.fTestMode=0;
            m2mObj.fIsForBosch=1;
            m2mObj.fNestedObj=[];
            m2mObj.tSortedFcnCallerMap=containers.Map('KeyType','char','ValueType','any');

            mdls=[{m2mObj.fOriMdl},m2mObj.fRefMdls];
            m2mObj.cleanup_icm=onCleanup(@()CleanupFcn(m2mObj,mdls));
        end

        errMsg=identify(this);
        result=getCandidateInfo(this);
        result=hiliteCandObj(this,aCIdx,aOIdx);
        result=hiliteCandidate(this,Arg1,Arg2);
        result=hiliteICM(this,Arg1,Arg2);
        msg=exclude(this,aBlk);
        msg=include(this,aBlk);
        msg=excludeCls(this,aBus,aParamType);
        msg=includeCls(this,aBus,aParamType);
        numCls=genClassMdl(this,aClsIdx,aNumCls,aThisPortMap);
        numObj=genObject(this,aClsIdx,aObjIdx,aNumCls,aNumObj,aThisPortMap);
        errMsg=xformSpecificPreProc(this);
        errMsg=performXformation(this);
        dataType=getBasicNumericType(this,aDataTypeStr,aFcnCallerBlk);
        rewireFcnCallerBlk(this,aFcnCallerBlk,aParams,aThisIOsIdx);
        addMaskedProperty(this,aBlkType,aProperty);
        removeMaskedProperty(this,aBlkType,aProperty);
        errMsg=insertExecutionOrder(this);
        xformSpecificInit(this);
    end

    methods(Access='private')
        function CleanupFcn(m2mObj,aPIRs)%#ok

        end
    end
end

function hasAllRequiredFeatures=checkRequiredSlfeatures
    hasAllRequiredFeatures=slfeature('SLDataDictionarySetUserData')&&...
    slfeature('SLDataDictionarySetCSCSource')&&...
    slfeature('SimulinkFunctionMultiInstance')&&...
    slfeature('PluggableInterface');
end
