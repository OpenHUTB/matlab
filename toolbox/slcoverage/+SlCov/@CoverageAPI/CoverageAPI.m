



classdef CoverageAPI<handle
    properties
    end
    methods
    end
    methods(Static)
        description=getCoverageDef(blockH,cvmetric)
        description=getCoverageMetricsDef(covId,metricNames,varargin)
        [sfId,blockH,errormsg]=getBlockIds(block,sfId,blockH,errormsg)
        [dataMat,blockCvId,newBlockCvId,sfPortEquiv,codeInfo]=getCvdata(data,id,covMode)
        cvId=getCovId(blkH,sfId,varargin)
        str=getTextOf(id,index,elements,detailLevel)
        compileForCoverage(blockH)
        chks=getChecksum(modelH)
        rootId=getRootId(blkH,sfId)
        cvstruct=getCoverageHierarchy(covdata)
        res=complexityinfo(blkH)
        varargout=getComplexityInfoInternal(data,block,varargin)
        [isFiltered,isJustified,filterRationale]=filterInheritanceLogic(isFiltered,isJustified,...
        isFilteredParent,isJustifiedParent,...
        filterRationale,filterRationaleParent)
        [isFiltered,isJustified]=isFilteredOutcome(filteredOutcomes,filteredOutcomeModes,idx)
        [isPredExcluded,isPredJustified,predFilterRationale]=checkMcdcPredicateFiltering(...
        mcdcId,condId,predIdx,...
        isBlockExcluded,isBlockJustified,blockFilterRationale)
        varargout=getComplexityInfo(data,block,varargin)
        varargout=getConditionInfo(data,block,varargin)
        varargout=getCoverageInfo(covdata,block,varargin)
        varargout=getDecisionInfo(data,block,varargin)
        varargout=getExecutionInfo(covdata,block,varargin)
        varargout=getMcdcInfo(data,block,varargin)
        varargout=getOverflowSaturationInfo(covdata,block,ignoreDescendants)
        varargout=getRelationalBoundaryInfo(covdata,block,varargin)
        varargout=getSignalRangeInfo(covdata,block,portIdx,includeAllSizes)
        varargout=getSignalSizeInfo(covdata,block,portIdx)
        varargout=getTableInfo(data,block,ignoreDescendants)

        varargout=getMLCoderCoverageInfoInternal(data,metric,ids,covMode)

        [numSatisfied,numJustified,numTotal]=getHitCount(data,model,metric)

        prevVal=feature(name,varargin)

        simInput=setupSimInputForCoverage(simInput,workingDir,useUniqueFileName,isSerial)
        simInput=setupSimInputForRunall(simInput)
        res=isSimInputCoverageOn(simInput)
        [dirName,fileName]=getCovOutputFullDir(simInput,workingDir)

        modelUnderTest=resolveModelUnderTest(model)
        res=isCovAccelSimSupport(topModelH)
        res=isCovAccelSimSFSupport(modelName)
        res=hasSupportedModelRefs(topModelH)
        cacheTopModelInfo(topModel)
        res=isModelRefEnabledFromTop(modelName)
        setupModelRefs(accelMdlRefs,allMdlRefs)
        addModelRefToCache(modelH)
        resetOverrideOnCachedModels()
        setupRefMdlForInstanceCov(refMdlH,mdlBlkH,topMdlH)
        [tests,data]=loadCoverage(fileName,varargin)
        fixReleaseDatabaseCompatibility(testIds,cvdataVer,newObjects)
        fixReleaseChecksumCompatibility(modelcovId)
        data=quickLoad(filename)
        saveCoverage(fileName,varargin)
        res=isCovToolUsedBySlicer(model)
        res=isCovDataUsedBySlicer(varargin)

        setActiveData(model,cvd)
        setActiveDataNeedsRegen(model)
        obj=getActiveData(model)
        highlightActiveData(modelName)
        res=sfAutoscaleCache(modelName,cmd)


        function modelcovId=createModelcov(modelName,handle,mode)
            if nargin<3
                mode=SlCov.CovMode.Normal;
            end
            modelcovId=cv('new','modelcov','.handle',handle,'.simMode',mode);
            ver=SlCov.CoverageAPI.getDbVersion();
            cv('set',modelcovId,'.dbVersion',ver);
            SlCov.CoverageAPI.setModelcovName(modelcovId,modelName)
        end

        function res=getDbVersion()
            res=SlCov.CoverageAPI.injectedVersionMangle('get');
            if isempty(res)
                res=SlCov.CoverageAPI.getVersion;

                if isempty(res)
                    v=ver('Simulink');
                    res=v.Release;
                end
            end
        end

        function modelcovId=findModelcov(modelcovUnMangledName)
            modelcovId=cv('find','all','modelcov.unmangledName',modelcovUnMangledName);
        end


        function modelName=getModelcovName(modelcovId)
            modelName=cv('get',modelcovId,'.unmangledName');
        end

        function setModelcovName(modelcovId,modelName)
            cv('set',modelcovId,'.unmangledName',modelName);
            mode=cv('get',modelcovId,'.simMode');
            ver=cv('get',modelcovId,'.dbVersion');
            modelcovMangledName=SlCov.CoverageAPI.mangleModelcovName(modelName,mode,ver);
            cv('SetModelcovName',modelcovId,modelcovMangledName);
        end

        function traits=getModelcovCompatTraits(modelcovId)
            traits=[];
            rootId=cv('get',modelcovId,'.activeRoot');
            if rootId==0
                rootId=cv('RootsIn',modelcovId);


                if~isempty(rootId)
                    rootId=rootId(1);
                end
            end
            if~isempty(rootId)&&rootId~=0
                traits.checksum=cv('get',rootId,'.checksum');
            end
        end


        function res=isCompatible(modelcovId1,modelcovId2)
            traits1=SlCov.CoverageAPI.getModelcovCompatTraits(modelcovId1);
            traits2=SlCov.CoverageAPI.getModelcovCompatTraits(modelcovId2);
            res=true;
            if~isempty(traits1)&&~isempty(traits2)
                res=isequal(traits1.checksum,traits2.checksum);
            end
        end


        function modelName=mangleModelcovName(modelName,mode,ver)
            if nargin<3
                ver=SlCov.CoverageAPI.getDbVersion();
            end
            if nargin<2
                mode=SlCov.CovMode.Normal;
            end
            if mode~=SlCov.CovMode.Normal
                modelName=[modelName,' (',SlCov.CovMode.toString(mode),')'];
            end
            modelName=[modelName,'@',ver];
        end


        function res=injectedVersionMangle(command,txt)
            persistent versionMangle;
            if strcmpi(command,'set')
                versionMangle=txt;
            else
                res=versionMangle;
            end
        end

        function modelNames=removeVersionMangle(modelNames)
            modelNames=regexprep(modelNames,'@\([R]\d{4}[a,b]\)','');
        end


        function modelcovId=findModelcovMangled(modelcovMangledName)
            modelcovId=cv('find','all','modelcov.name',modelcovMangledName);
        end


        function modelcovMangledName=getModelcovMangledName(modelcovId)
            modelcovMangledName=cv('GetModelcovName',modelcovId);
        end

        function manlgedNames=getAllModelcovMangledNames()
            manlgedNames={};
            modelcovIds=cv('find','all','.isa',cv('get','default','modelcov.isa'));

            if isempty(modelcovIds)
                return;
            end
            manlgedNames=cell(numel(modelcovIds),1);
            for idx=1:numel(modelcovIds)
                manlgedNames{idx}=cv('get',modelcovIds(idx),'.name');
            end
        end


        function deleteModelcov(modelName,dbVersion)
            if(nargin>1)

                modelcovIds=SlCov.CoverageAPI.findModelcovMangled(SlCov.CoverageAPI.mangleModelcovName(modelName,0,dbVersion));
            else

                modelcovIds=SlCov.CoverageAPI.findModelcov(modelName);
            end
            for i=1:numel(modelcovIds)
                cv('ClearModel',modelcovIds(i));
            end
        end

        function[newVersion,oldVersion]=getModelVersions(modelcovId,modelVersionInData)
            modelHandle=cv('get',modelcovId,'modelcov.handle');
            newVersion=sprintf('(%s: %s %s)',getString(message('Slvnv:simcoverage:cvhtml:ModelVersion')),get_param(modelHandle,'ModelVersion'),SlCov.CoverageAPI.getDbVersion);
            oldVersion=sprintf('(%s: %s %s)',getString(message('Slvnv:simcoverage:cvhtml:ModelVersion')),modelVersionInData,cv('get',modelcovId,'.dbVersion'));
        end

        function status=isGeneratedCode(modelcovIdOrCvdata)
            if isa(modelcovIdOrCvdata,'cvdata')
                simMode=modelcovIdOrCvdata.simMode;
            else
                simMode=cv('get',modelcovIdOrCvdata,'.simMode');
            end
            status=SlCov.CovMode.isGeneratedCode(simMode);
        end

        function res=hasEnabledMetric(cvId,cvs)
            [allMetricNames,allTOMetricNames]=cvi.MetricRegistry.getAllMetricNames;
            metricNames=[allMetricNames,allTOMetricNames];
            if~iscell(metricNames)
                metricNames={metricNames};
            end
            desc=SlCov.CoverageAPI.getCoverageMetricsDef(cvId,metricNames);
            res=false;
            for idx=1:numel(desc)
                mn=desc(idx).name;
                if isfield(cvs,mn)&&...
                    cvs.(mn)==1
                    res=true;
                    break;
                end
            end
        end

        function res=hasAnyCoverage(cvId,cvd)
            [allMetricNames,allTOMetricNames]=cvi.MetricRegistry.getAllMetricNames;
            metricNames=[allMetricNames,allTOMetricNames];
            if~iscell(metricNames)
                metricNames={metricNames};
            end

            desc=SlCov.CoverageAPI.getCoverageMetricsDef(cvId,metricNames,cvd);
            res=false;
            if~isempty([desc.executed])
                res=true;
            end
        end

        function[name,msgId]=getLicenseName()
            name='Simulink_Coverage';
            msgId='Slvnv:simcoverage:ioerrors:SlCoverageLicenseCheckoutFailed';
        end


        function[status,msgId]=checkPolyspaceLicense()
            status=~isempty(which('polyspaceroot'));
            if~status
                msgId='Slvnv:simcoverage:ioerrors:PolyspaceLicenseCheckoutFailed';
            else
                msgId='';
            end
        end


        function res=isCvInstalled()
            res=~isempty(which('cvsim'));
        end


        function[status,msgId]=checkCvLicense()
            try
                [name,msgId]=SlCov.CoverageAPI.getLicenseName;
                status=SlCov.CoverageAPI.isCvInstalled&&...
                license('test',name)&&...
                ~builtin('_license_checkout',name,'quiet');
            catch MEx %#ok<NASGU>
                status=0;
                msgId='';
            end
        end

        function res=getVersion()
            persistent slcoverage_version
            res='';
            try
                if isempty(slcoverage_version)
                    v=ver('slcoverage');
                    slcoverage_version=v.Release;
                end
                res=slcoverage_version;
            catch

            end
        end

        function checkCvdataInput(data)
            narginchk(1,1);
            if numel(data)>1||(~isa(data,'cvdata')&&~isa(data,'cv.cvdatagroup'))
                error(message('Slvnv:simcoverage:cvdata:NotCvData'));
            end
            if~valid(data)
                error(message('Slvnv:simcoverage:cvdata:InvalidCvData',1));
            end
        end

        function res=isSfCoverageOnOrAutoscale(machineName,isAutoscale)
            res=false;
            modelName=machineName;
            origModelName=get_param(modelName,'ModelReferenceNormalModeOriginalModelName');
            if strcmpi(get_param(origModelName,'RecordCoverage'),'on')||...
isAutoscale
                res=strcmpi(get_param(modelName,'compileSupportsCoverage'),'on')||...
                cvi.ModelInfoCache.checkMdlRefEnabled(modelName);
            end
        end

        function cacheSfAutoscale(machineName)
            SlCov.CoverageAPI.sfAutoscaleCache(machineName,'set');
        end

        function res=isSfCoverageOn(machineName)
            res=false;
            if sfc('coder_options','forceDebugOff')
                return;
            end
            res=SlCov.CoverageAPI.isSfCoverageOnOrAutoscale(machineName,SlCov.CoverageAPI.sfAutoscaleCache(machineName,'get'));
        end

        function res=isAnyModelEnabledForCoverage(modelName)
            if nargin==1

                res=SlCov.CoverageAPI.isCovAccelSimSupport(modelName)&&...
                strcmpi(get_param(modelName,'RecordCoverage'),'on');
            else

                info=cvi.ModelInfoCache.getTopModelInfo();
                res=~isempty(info.topModel)&&...
                SlCov.CoverageAPI.isCovAccelSimSupport(info.topModel)&&...
                ~(info.excludeTopModel&&isempty(cvi.ModelInfoCache.modelRefCache()));

            end
        end




        function res=isMdlRefEnabledForAccelCoverage(modelName)





            info=cvi.ModelInfoCache.getTopModelInfo();
            res=~isempty(info.topModel)&&...
            SlCov.CoverageAPI.isCovAccelSimSupport(info.topModel)&&...
            SlCov.CoverageAPI.isModelRefEnabledFromTop(modelName)&&...
            bdIsLoaded(modelName);
        end


        function res=isEnabledForAccelCoverage(model)


            res=SlCov.CoverageAPI.isSupportedAccelModelRef(model)&&...
            strcmpi(get_param(model,'RecordCoverage'),'on');
        end

        function res=isSFEnabledForAccelCoverage(mainMachineName)
            res=SlCov.CoverageAPI.isSupportedAccelModelRef(mainMachineName)&&...
            SlCov.CoverageAPI.isSfCoverageOn(mainMachineName);
        end

        function res=isSupportedAccelModelRef(modelName)






            res=false;
            coveng=cvi.TopModelCov.getInstance(modelName);
            if~isempty(coveng)&&...
                SlCov.CoverageAPI.isCovAccelSimSupport(coveng.topModelH)

                if strcmpi(get_param(coveng.topModelH,'name'),modelName)

                    res=true;
                elseif~isempty(coveng.covModelRefData)&&...
                    ~isempty(coveng.covModelRefData.accelModels)



                    res=ismember(modelName,coveng.covModelRefData.accelModels);
                    if~isempty(coveng.covModelRefData.notSupportedAccelModels)
                        res=~ismember(modelName,coveng.covModelRefData.notSupportedAccelModels);
                    end
                end
            end
        end

        function res=isEnabledAccelModelRef(modelName)

            res=false;
            try
                coveng=cvi.TopModelCov.getInstance(modelName);
                if~isempty(coveng)&&~isempty(coveng.covModelRefData)&&~isempty(coveng.covModelRefData.accelModels)
                    res=ismember(modelName,coveng.covModelRefData.accelModels);
                end
            catch
                res=false;
            end
        end


        function resetModelInfoCache()
            cvi.ModelInfoCache.reset()
        end

        function resetModelRefCache()
            cvi.ModelInfoCache.resetModelRefCache()
        end

        function res=isModelRefInstanceCovEnabled(modelH)
            res=false;
            coveng=cvi.TopModelCov.getInstance(modelH);
            if~isempty(coveng)
                topModelH=coveng.topModelH;
                res=strcmp(get_param(topModelH,'RecordRefInstanceCoverage'),'on');
            end
        end


        function[status,msgId]=checkSlicerLicense
            try
                status=double(SliceUtils.isSlicerAvailable());
                msgId='Sldv:ModelSlicer:ModelSlicer:NotLicensed';
            catch MEx %#ok<NASGU>
                status=0;
            end
        end


        function isEnabled=supportObserverCoverage
            try
                isEnabled=slfeature('ObserverSLDV');
            catch
                isEnabled=false;
            end
        end


        function isValid=isaValidCvId(cvid,expType)
            isValid=(cvid~=0)&&...
            cv('ishandle',cvid)&&...
            (cv('get',cvid,'.isa')==cv('get','default',expType));
        end


        function[hasSLCov,hasMLCoderCov]=hasSLOrMLCoderCovData(varargin)
            hasSLCov=false;
            hasMLCoderCov=false;
            for ii=1:numel(varargin)
                arg=varargin{ii};
                if isa(arg,'cvdata')||isa(arg,'cv.cvdatagroup')
                    hasSLCov=true;
                end
                if isa(arg,'cv.coder.cvdata')||isa(arg,'cv.coder.cvdatagroup')
                    hasMLCoderCov=true;
                end
            end
        end


        function[mlCoderCovData,hasSLCovData]=extractMLCoderCovData(varargin)
            mlCoderCovData=struct('test',{{}},'data',{{}},'group',{{}});
            hasSLCovData=false;
            for ii=1:numel(varargin)
                arg=varargin{ii};
                if isa(arg,'cv.coder.cvtest')
                    mlCoderCovData.test{end+1}=arg;
                elseif isa(arg,'cv.coder.cvdata')
                    mlCoderCovData.data{end+1}=arg;
                elseif isa(arg,'cv.coder.cvdatagroup')
                    mlCoderCovData.group{end+1}=arg;
                elseif isa(arg,'cvdata')||isa(arg,'cv.cvdatagroup')||isa(arg,'cvtest')
                    hasSLCovData=true;
                end
            end
        end


        function hasMatch=hasMatchingPossibleRoot(topRootId,blockNameToFind,checksumToFind)



            matchingSlsfObj=cvi.TopModelCov.findMatchingPossibleRoot(topRootId,blockNameToFind,checksumToFind);
            hasMatch=~isempty(matchingSlsfObj);
        end


        function safe_set_cv_object(id,field,newVal)








            oldVal=cv('get',id,field);%#ok<NASGU> 
            cv('set',id,field,newVal);
        end
    end
end



