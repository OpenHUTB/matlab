













classdef cvdata<cv.internal.cvdata&SlCov.CovEngineProxy

    properties(GetAccess=public,SetAccess=private,Dependent=true)
test
rootID
checksum
modelinfo
startTime
stopTime
simulationStartTime
simulationStopTime
intervalStartTime
intervalStopTime
    end

    properties(GetAccess=public,SetAccess=public,Dependent=true,Hidden=true)
testSettings
sfcnCovData
codeCovData
filter
filterApplied
description
simMode
tag
aggregatedIds
uniqueId
dbVersion
ownerModel
ownerBlock
harnessModel
trace
traceOn
filterData
excludeInactiveVariants
testRunInfo
aggregatedTestInfo
reqTestMapInfo
scopeDataToReqs
    end
    properties(GetAccess=public,SetAccess=private,Dependent=true,Hidden=true)



rootId
metrics
startTimeEnum
stopTimeEnum
isObserver
isExternalMATLABFile
isSubsystem
isSimulinkCustomCode
isSharedUtility
isCustomCode
covSFcnEnable
structuralChecksum
relBndMetricChecksum
satOvfMetricChecksum
    end

    properties(Hidden=true)
        localData={}
variantChecksum
    end

    properties(Hidden=true,Transient=true)
cachedSFcnCovInfoStruct
        traceMap=[]
        aggInfoMap=[]
        traceMask=[]
    end
    methods



        function this=cvdata(varargin)

            if nargin==0
                this.localData.type='DERIVED_DATA';
                this.localData.tag='';
                this.localData.description='';
            elseif nargin>=1
                cvd=varargin{1};
                if isa(cvd,class(this))
                    cvd.load();
                    this=cvd;
                elseif isa(cvd,'double')
                    if~cv('ishandle',cvd)
                        error(message('Slvnv:simcoverage:cvdata:CvObjNotExists',cvd));
                    end
                    if cv('get',varargin{1},'.isa')~=cv('get','default','testdata.isa')
                        error(message('Slvnv:simcoverage:cvdata:CvObjNotTestdata',cvd));
                    end

                    this.id=cvd;
                elseif ischar(cvd)||isstring(cvd)
                    uuid='';
                    if nargin>1
                        srcCvd=varargin{2};
                        uuid=srcCvd.uniqueId;
                    end
                    fileName=convertStringsToChars(cvd);
                    this=cv.internal.cvdata.setupFileRef(this,fileName,uuid);
                else
                    error(message('Slvnv:simcoverage:cvdata:BadInput'))
                end
            else
                error(message('Slvnv:simcoverage:cvdata:BadSyntax'));
            end
            if nargin~=0&&this.isLoaded&&isempty(this.uniqueId)
                this.setUniqueId;
            end
        end



        display(cvdata)
        r=minus(p,q)
        r=mtimes(p,q)
        r=plus(p,q)
        B=saveobj(A)
        r=times(p,q)
        res=extract(cvdata,subsysH)
        out=validRoot(cvdata)

        function value=get.test(this)
            checkId(this);
            if this.id==0
                value=[];
            else
                value=cvtest(this.id);
            end
        end

        function value=get.testSettings(this)
            checkId(this);
            if this.id==0
                value=this.localData.testSettings;
            else
                cvt=cvtest(this.id);
                value=cvt.settings;
            end
        end

        function value=get.rootID(this)
            checkId(this);
            value=[];
            if this.id==0
                value=this.localData.rootId;
            else
                rId=getRootId(this.id);
                if rId
                    value=rId;
                end
            end
        end

        function value=get.rootId(this)
            value=this.rootID;
        end

        function value=get.checksum(this)
            checkId(this);

            value=[];
            if this.id==0
                value=this.localData.variantChecksum;
                if isempty(value)
                    value=this.localData.checksum;
                end
            else
                chks=cv('get',this.id,'.variantChecksum');
                if~any(chks)
                    rId=getRootId(this.id);
                    if rId
                        chks=cv('get',rId,'.checksum');
                    end
                end
                value=checksumArray2Struct(chks);
            end
        end

        function value=get.structuralChecksum(this)
            checkId(this);

            if this.id==0
                value=this.localData.structuralChecksum;
            else
                rId=getRootId(this.id);
                chks=cv('get',rId,'.structuralChecksum');
                value=checksumArray2Struct(chks);
            end
        end

        function value=get.relBndMetricChecksum(this)
            checkId(this);

            if this.id==0
                value=this.localData.relBndMetricChecksum;
            else
                rId=getRootId(this.id);
                chks=cv('get',rId,'.metricChecksum.relationalBoundary');
                value=checksumArray2Struct(chks);
            end
        end

        function value=get.satOvfMetricChecksum(this)
            checkId(this);

            if this.id==0
                value=this.localData.satOvfMetricChecksum;
            else
                rId=getRootId(this.id);
                chks=cv('get',rId,'.metricChecksum.saturationOverflow');
                value=checksumArray2Struct(chks);
            end
        end

        function value=get.startTimeEnum(this)
            checkId(this);
            if this.id==0
                value=this.localData.startTimeEnum;
            else
                value=cv('get',this.id,'testdata.startTime');
            end
        end

        function value=get.stopTimeEnum(this)
            checkId(this);
            if this.id==0
                value=this.localData.stopTimeEnum;
            else
                value=cv('get',this.id,'testdata.stopTime');
            end
        end

        function value=get.startTime(this)
            value=datestr(this.startTimeEnum);
        end

        function value=get.stopTime(this)
            value=datestr(this.stopTimeEnum);
        end

        function value=get.simulationStartTime(this)
            checkId(this);
            if this.id==0
                value=this.localData.simulationStartTime;
            else
                value=cv('get',this.id,'testdata.simStartTime');
            end
        end

        function value=get.simulationStopTime(this)
            checkId(this);
            if this.id==0
                value=this.localData.simulationStopTime;
            else
                value=cv('get',this.id,'testdata.simStopTime');
            end
        end

        function value=get.intervalStartTime(this)
            checkId(this);
            if this.id==0
                value=this.localData.intervalStartTime;
            else
                value=cvtest.getMf0Settings(this.id).intervalStartTime;
            end
        end

        function value=get.intervalStopTime(this)
            checkId(this);
            if this.id==0
                value=this.localData.intervalStopTime;
            else
                value=cvtest.getMf0Settings(this.id).intervalStopTime;
            end
        end

        function value=get.metrics(this)
            checkId(this);

            id=this.id;
            if id==0
                value=this.localData.metrics;
            else
                [allMetricNames,allTOMetricNames]=cvi.MetricRegistry.getAllMetricNames();
                value=[];

                for idx=1:numel(allMetricNames)
                    metric=allMetricNames{idx};
                    value.(metric)=getMetricData(id,metric);
                end

                if~isempty(allTOMetricNames)
                    value.testobjectives=getToMetricData(id,allTOMetricNames);
                end
            end
        end

        function value=get.traceOn(this)
            checkId(this);

            id=this.id;
            if id==0
                value=this.localData.traceOn;
            else
                value=cv('get',id,'.traceOn');
            end
        end


        function set.traceOn(this,value)
            checkId(this);
            id=this.id;
            if id==0
                this.localData.traceOn=value;
            else
                cv('set',id,'.traceOn',value);
            end
        end


        function value=get.trace(this)
            checkId(this);

            id=this.id;
            value=[];


            if id==0
                if isfield(this.localData,'trace')
                    value=this.localData.trace;
                end
            else
                if any(cv('get',id,'.traceData'))
                    allMetricNames=cvi.MetricRegistry.getAllMetricNames();
                    allMetricNames=setdiff(allMetricNames,{'sigrange','sigsize'});
                    for idx=1:numel(allMetricNames)
                        metric=allMetricNames{idx};
                        value.(metric)=getTraceData(id,metric);
                    end
                end
                toTrace=getTOTraceData(id);
                if~isempty(toTrace)
                    value.testobjectives=toTrace;
                end
            end
        end

        function set.testRunInfo(this,value)
            checkId(this);
            id=this.id;
            if id==0
                this.localData.testRunInfo=value;
            else
                cv('set',id,'.testRunInfo',value);
            end

            obj=this.sfcnCovData;
            if isa(obj,'SlCov.results.CodeCovDataGroup')&&obj.hasData()
                obj.setTestRunInfo(value);
            end
            obj=this.codeCovData;
            if isa(obj,'SlCov.results.CodeCovData')&&obj.hasResults()
                obj.setTestRunInfo(value);
            end
        end

        function value=get.testRunInfo(this)
            checkId(this);
            id=this.id;
            value=[];
            if id==0
                if isfield(this.localData,'testRunInfo')
                    value=this.localData.testRunInfo;
                end
            else
                value=cv('get',id,'.testRunInfo');
            end

            if isempty(value)

                value=struct('runId',0,'runName','','testId',[]);
            end
        end


        function set.aggregatedTestInfo(this,value)
            checkId(this);
            id=this.id;
            if id==0
                this.localData.aggregatedTestInfo=value;
            else
                cv('set',id,'.aggregatedTestInfo',value);
            end

            if SlCov.isCodeAggregatedTestInfoFeatureOn()
                obj=this.sfcnCovData;
                if isa(obj,'SlCov.results.CodeCovDataGroup')&&obj.hasData()
                    obj.setAggregatedTestInfo(value);
                end
                obj=this.codeCovData;
                if isa(obj,'SlCov.results.CodeCovData')&&obj.hasResults()
                    obj.setAggregatedTestInfo(value);
                end
            end
        end

        function value=get.aggregatedTestInfo(this)
            checkId(this);
            id=this.id;
            value=[];
            if id==0
                if isfield(this.localData,'aggregatedTestInfo')
                    value=this.localData.aggregatedTestInfo;
                end
            else
                value=cv('get',id,'.aggregatedTestInfo');
            end
        end


        function set.reqTestMapInfo(this,value)
            checkId(this);
            id=this.id;
            if id==0
                this.localData.reqTestMapInfo=value;
            else
                cv('set',id,'.reqTestMapInfo',value);
            end

            this.traceMask=[];
            if this.scopeDataToReqs
                this.applyReqMask(true);
            end
        end

        function value=get.reqTestMapInfo(this)
            checkId(this);
            id=this.id;
            value=[];
            if id==0
                if isfield(this.localData,'reqTestMapInfo')
                    value=this.localData.reqTestMapInfo;
                end
            else
                value=cv('get',id,'.reqTestMapInfo');
            end
        end


        function set.scopeDataToReqs(this,value)
            checkId(this);
            value=logical(value);
            isChanged=(value~=this.scopeDataToReqs);
            id=this.id;
            if id==0
                this.localData.scopeDataToReqs=value;
            else
                cv('set',id,'.scopeDataToReqs',value);
            end

            if isChanged
                this.applyReqMask(value);
            end
        end

        function value=get.scopeDataToReqs(this)
            checkId(this);
            id=this.id;
            value=false;
            if id==0
                if isfield(this.localData,'scopeDataToReqs')
                    value=this.localData.scopeDataToReqs;
                end
            else
                value=cv('get',id,'.scopeDataToReqs');
            end
        end


        function value=getTraceMask(this)
            if isempty(this.traceMask)
                this.buildTraceMask();
            end
            value=this.traceMask;
        end


        function set.filterData(this,fd)
            checkId(this);

            id=this.id;
            if id==0
                this.localData.filterData=fd;
            else
                cv('set',id,'.filterData',fd);
            end
        end

        function value=get.filterData(this)
            checkId(this);

            id=this.id;
            if id==0
                value=this.localData.filterData;
            else
                value=cv('get',id,'.filterData');
            end
        end


        function set.excludeInactiveVariants(this,fd)
            checkId(this);

            id=this.id;
            if id==0
                this.localData.excludeInactiveVariants=fd;
            else
                cv('set',id,'.excludeInactiveVariants',fd);
            end








            is21b=contains(this.dbVersion,'21b');
            if is21b
                backtraceState=warning('off','backtrace');
                restoreBacktrace=onCleanup(@()warning(backtraceState));
                warning(message('Slvnv:simcoverage:cvload:StartupVariant_cannotExcludeInactive'));
            end


        end

        function value=get.excludeInactiveVariants(this)
            checkId(this);

            id=this.id;
            if id==0
                value=this.localData.excludeInactiveVariants;
            else
                value=cv('get',id,'.excludeInactiveVariants');
            end
        end


        function value=get.modelinfo(this)
            checkId(this);
            value=this.getRawModelInfo();
            value=cvdata.addModelInfoMessages(value);
        end

        function set.harnessModel(this,value)
            checkId(this);
            if this.id==0
                this.localData.modelinfo.harnessModel=value;
            else
                cv('set',this.id,'testdata.harnessModel',value);
            end
        end

        function value=get.harnessModel(this)
            checkId(this);
            if this.id==0
                value=this.localData.modelinfo.harnessModel;
            else
                value=cv('get',this.id,'.harnessModel');
            end
        end

        function set.ownerModel(this,value)
            checkId(this);
            if this.id==0
                this.localData.modelinfo.ownerModel=value;
            else
                cv('set',this.id,'testdata.ownerModel',value);
            end
        end

        function value=get.ownerModel(this)
            checkId(this);
            if this.id==0
                value=this.localData.modelinfo.ownerModel;
            else
                value=cv('get',this.id,'.ownerModel');
            end
        end

        function set.filter(this,value)
            checkId(this);
            value=convertStringsToChars(value);
            if this.id==0
                this.localData.covFilter=value;
            else
                cv('set',this.id,'testdata.covFilter',value);
            end
            loadAndApplyFilter(this);
        end

        function value=get.filter(this)
            checkId(this);
            if this.id==0
                value=this.localData.covFilter;
            else
                value=cv('get',this.id,'.covFilter');
            end
            if isempty(value)
                value='';
            end
        end


        function set.filterApplied(this,value)
            checkId(this);
            if this.id==0
                this.localData.filterApplied=value;
            else
                cv('set',this.id,'testdata.filterApplied',value);
            end
        end

        function value=get.filterApplied(this)
            checkId(this);
            if this.id==0
                value=this.localData.filterApplied;
            else
                value=cv('get',this.id,'.filterApplied');
            end
        end

        function value=get.sfcnCovData(this)
            checkId(this);
            if this.id==0
                value=this.localData.sfcnCovData;
            else
                value=cv('get',this.id,'.data.sfcnCovData');
            end
        end

        function set.sfcnCovData(this,obj)
            checkId(this);
            obj=convertStringsToChars(obj);
            if this.id==0
                this.localData.sfcnCovData=obj;
            else
                if isempty(obj)
                    obj=SlCov.results.CodeCovDataGroup.empty();
                else
                    if~ischar(obj)
                        validateattributes(obj,{'SlCov.results.CodeCovDataGroup'},{'scalar'},'cvdata.set.sfcnCovData','',1);
                    end
                end

                SlCov.CoverageAPI.safe_set_cv_object(this.id,'.data.sfcnCovData',obj);
            end
            if~isempty(obj)
                obj.setCovData(this);
            end
        end

        function value=get.codeCovData(this)
            checkId(this);
            if this.id==0
                value=this.localData.codeCovData;
            else
                value=cv('get',this.id,'.data.codeCovData');
            end
        end

        function set.codeCovData(this,obj)
            checkId(this);
            obj=convertStringsToChars(obj);
            if this.id==0
                this.localData.codeCovData=obj;
            else
                if isempty(obj)
                    obj=SlCov.results.CodeCovData.empty();
                else
                    if~ischar(obj)
                        validateattributes(obj,{'SlCov.results.CodeCovData'},{'scalar'},'cvdata.set.codeCovData','',1);
                    end
                end

                SlCov.CoverageAPI.safe_set_cv_object(this.id,'.data.codeCovData',obj);
            end
            if~isempty(obj)
                obj.setCovData(this);
            end
        end

        function value=get.simMode(this)
            checkId(this);
            if this.id==0
                value=this.localData.simMode;
            else
                value=SlCov.CovMode(cv('get',cv('get',this.rootId,'.modelcov'),'.simMode'));
            end
        end

        function val=get.isObserver(this)
            checkId(this);
            if this.id==0
                val=logical(this.localData.isObserver);
            else
                rId=this.rootId;
                val=cv('get',cv('get',rId,'.modelcov'),'.isObserver')==1;
            end
        end

        function val=get.isExternalMATLABFile(this)
            checkId(this);
            if this.id==0
                val=logical(this.localData.isExternalMATLABFile);
            else
                rId=this.rootId;
                val=cv('get',cv('get',rId,'.modelcov'),'.isScript')==1&&...
                cv('get',cv('get',rId,'.topSlsf'),'.origin')==3;
            end
        end

        function val=get.isSubsystem(this)
            checkId(this);
            if this.id==0
                val=logical(this.localData.isSubsystem);
            else
                rId=this.rootId;
                val=~isempty(cv('get',rId,'.path'));
            end
        end

        function val=get.isSimulinkCustomCode(this)
            if~SlCov.isSLCustomCodeCovFeatureOn()
                val=false;
                return
            end
            checkId(this);
            if this.id==0
                val=logical(this.localData.isSimulinkCustomCode);
            else
                rId=this.rootId;
                modelcovId=cv('get',rId,'.modelcov');
                val=cv('get',modelcovId,'.isScript')==1&&...
                cv('get',cv('get',rId,'.topSlsf'),'.origin')==4&&...
                ~SlCov.CoverageAPI.isGeneratedCode(modelcovId);
                if val
                    codeGrp=this.sfcnCovData;
                    if~isempty(codeGrp)
                        allRes=codeGrp.getAll();
                        allModes=[allRes.Mode];
                        val=val&&all(allModes==SlCov.CovMode.SLCustomCode);
                    end
                end
            end
        end

        function val=get.isSharedUtility(this)
            checkId(this);
            if this.id==0
                val=logical(this.localData.isSharedUtility);
            else
                rId=this.rootId;
                modelcovId=cv('get',rId,'.modelcov');
                val=cv('get',modelcovId,'.isScript')==1&&...
                SlCov.CoverageAPI.isGeneratedCode(modelcovId)&&...
                cv('get',cv('get',rId,'.topSlsf'),'.origin')==4&&...
                cv('get',cv('get',cv('get',rId,'.topSlsf'),'.treeNode.child'),'.origin')==4;
            end
        end

        function val=get.isCustomCode(this)
            checkId(this);
            if this.id==0
                val=logical(this.localData.isCustomCode);
            else
                rId=this.rootId;
                modelcovId=cv('get',rId,'.modelcov');
                val=cv('get',modelcovId,'.isScript')==1&&...
                SlCov.CoverageAPI.isGeneratedCode(modelcovId)&&...
                cv('get',cv('get',rId,'.topSlsf'),'.origin')==4&&...
                cv('get',cv('get',cv('get',rId,'.topSlsf'),'.treeNode.child'),'.origin')~=4;
            end
        end

        function val=get.covSFcnEnable(this)
            checkId(this);
            if this.id==0
                val=logical(this.localData.covSFcnEnable);
            else
                val=cv('get',this.id,'.covSFcnEnable');
            end

        end

        function set.tag(this,str)
            checkId(this);
            str=convertStringsToChars(str);
            if this.id==0
                this.localData.tag=str;
            else
                cv('SetTag',this.id,str);
            end
        end
        function descr=get.tag(this)
            checkId(this);
            if this.id==0
                descr=this.localData.tag;
            else
                descr=cv('GetTag',this.id);
            end
        end
        function set.description(this,str)
            checkId(this);
            str=convertStringsToChars(str);
            if this.id==0
                this.localData.description=str;
            else
                cv('SetDescription',this.id,str);
            end

            obj=this.sfcnCovData;
            if isa(obj,'SlCov.results.CodeCovDataGroup')&&obj.hasData()
                obj.setDescription(str);
            end
            obj=this.codeCovData;
            if isa(obj,'SlCov.results.CodeCovData')&&obj.hasResults()
                obj.Description=str;
            end
        end
        function descr=get.description(this)
            checkId(this);
            if this.id==0
                descr=this.localData.description;
            else
                descr=cv('GetDescription',this.id);
            end
        end
        function set.aggregatedIds(this,fN)
            if isempty(fN)
                return;
            end
            checkId(this);
            if~iscell(fN)
                fN={fN};
            end
            str=strjoin(fN,',');
            if this.id==0
                this.localData.aggregatedIds=str;
            else
                cv('set',this.id,'.aggregatedIds',str);
            end
        end
        function aggregatedIds=get.aggregatedIds(this)
            checkId(this);
            aggregatedIds=[];
            if this.id==0
                if isfield(this.localData,'aggregatedIds')
                    str=this.localData.aggregatedIds;
                else
                    str='';
                end
            else
                str=cv('get',this.id,'.aggregatedIds');
            end
            if~isempty(str)
                aggregatedIds=strsplit(str,',');
            end
        end
        function set.uniqueId(this,id)
            checkId(this);
            if this.id==0
                this.localData.uniqueId=id;
            else
                cv('set',this.id,'.uniqueId',id);
            end
        end
        function id=get.uniqueId(this)
            checkId(this);
            id=[];
            if this.id==0
                if isfield(this.localData,'uniqueId')
                    id=this.localData.uniqueId;
                end
            else
                id=cv('get',this.id,'.uniqueId');
            end
        end
        function ver=get.dbVersion(this)
            checkId(this);
            ver='';
            if this.id==0
                if isfield(this.localData,'dbVersion')
                    ver=this.localData.dbVersion;
                end
            else
                ver=cv('get',this.id,'.dbVersion');
            end
        end

    end

    methods(Hidden)


        cvdSum=sum(cvdArray)
        cvdata=applyFilter(cvdata,fileName)
        s=loadAndApplyFilter(cvd)
        ddObj=commitdd(mObj)
        [enabled,enabledTO]=getEnabledMetricNames(cvdata)
        result=isDerived(Obj)
        [metricStruct,traceStruct]=perform_operation(lhs_cvdata,rhs_cvdata,opFcn,opChar,joinedAggregatedTestInfo)
        foundCvIds=findCvIdsInScope(this,scope,invert)
        newCvd=getAggregatedSubset(this,traceIdxs)
        resetTrace(this)
        ssid=mapFromHarnessSID(this,ssid)
        ssid=mapToHarnessSID(this,ssid)
        out=valid(cvdata)
        out=isCompatible(this,cvd)


        function setUniqueId(this)
            checkId(this);
            if isempty(this.uniqueId)
                guidStr=char(matlab.lang.internal.uuid);
                this.uniqueId=guidStr;
            end
        end

        function clearUniqueId(this)
            this.uniqueId='';
        end


        function status=isAtomicSubsystemCode(this)
            status=false;
            if SlCov.CovMode.isGeneratedCode(this.simMode)
                modelInfo=this.modelinfo;
                if~isempty(modelInfo.harnessModel)&&...
                    ~isempty(modelInfo.ownerModel)&&...
                    ~isempty(modelInfo.ownerBlock)&&...
                    (startsWith(modelInfo.analyzedModel,[modelInfo.harnessModel,'/'])||...
                    (strcmp(modelInfo.analyzedModel,modelInfo.ownerBlock)&&~strcmp(modelInfo.ownerBlock,modelInfo.ownerModel)))
                    status=true;
                end
            end
        end


        function out=getAnalyzedModel(this)
            out=this.modelinfo.analyzedModel;
        end


        function val=getAnalyzedModelForATS(this)


            val=this.modelinfo.ownerModel;
        end


        function res=isExternalFile(this)
            res=this.isExternalMATLABFile||this.isSimulinkCustomCode||...
            this.isCustomCode||this.isSharedUtility;
        end


        function res=isEmpty(this)
            res=~any(this.metrics.testobjectives.cvmetric_Structural_block)&&...
            (isempty(this.metrics.decision)||~any(this.metrics.decision))&&...
            isempty(this.sfcnCovData)&&...
            isempty(this.codeCovData);
        end


        function fillCachedSFcnCovInfoStruct(this)
            this.cachedSFcnCovInfoStruct=cvi.SFunctionCov.extractResultsInfo({this});
        end




        function refreshSimMode(this)
            checkId(this);
            if this.id==0
                val=SlCov.CovMode(this.localData.simMode);
            else
                val=SlCov.CovMode(cv('get',cv('get',this.rootId,'.modelcov'),'.simMode'));
            end

            newVal=SlCov.CovMode.fixTopMode(val);

            if newVal~=val
                if this.id==0
                    this.localData.simMode=newVal;
                else
                    cv('set',cv('get',this.rootId,'.modelcov'),'.simMode',newVal);
                end
            end
        end

        function load(this)
            if this.isLoaded
                return;
            end
            cvd=cvdata.loadFileRef(this);
            ri=getRootId(cvd.id);
            if ri==0
                throwAsCaller(MException(message('Slvnv:simcoverage:cvdata:InvalidCvDataNoObj')));
            end
            this.isLoaded=true;
            this.id=cvd.id;
        end

    end

    methods(Static,Hidden)
        metricIndexMap=getMetricIndices(data,descendantCvIds,allMetricNames)

        u=processMetric(rootId,metric,collectedMetricData,opFcn,opChar)

        [metricStruct,traceStruct]=processSubsystemMetric(targetRootId,targetCvd,targetIndices,...
        sourceCvd,sourceIndices,...
        joinedAggregatedTestInfo,...
        metricNames,toMetricNames,op,isSameSubsys)

        ssid=mapFromHarnessBlockCvId(blockCvId)
        ssid=mapFromHarnessSID_internal(ssid,rootId,ownerBlock,analyzedModel)

        function cvd=findCvdataByUniqueId(uniqueId)
            cvd=[];
            if isempty(uniqueId)
                return;
            end

            testdataIds=cv('find','all','.isa',cv('get','default','testdata.isa'));
            allCvds=[];
            if~iscell(uniqueId)
                uniqueId={uniqueId};
            end
            for idx=1:numel(uniqueId)
                foundId=cv('find',testdataIds,'.uniqueId',uniqueId{idx});
                cvdTemp=[];
                if(numel(foundId)==1)
                    cvdTemp=cvdata(foundId);
                    if cvdTemp.valid()
                        allCvds=[allCvds,cvdTemp];%#ok<AGROW>
                    end
                end
                if isempty(cvdTemp)

                    return
                end
            end
            if isempty(allCvds)

                return
            end
            if numel(allCvds)==1
                cvd=allCvds;
            else
                cvd=cv.cvdatagroup(allCvds(:));
            end
        end

        function cvd=loadFileRef(this)
            cvd=[];
            if~this.isLoaded

                this.isLoaded=true;
                cvd=cvdata.findCvdataByUniqueId(this.fileRef.uuid);
                if~isempty(cvd)
                    return;
                end
                cv.internal.cvdata.checkFileRef(this);
                [~,d]=cvload(this.fileRef.name);
                if isempty(d)
                    throwAsCaller(MException(message('Slvnv:simcoverage:cvdata:InvalidCvDataNoObj')));
                end
                cvd=d{1};
            end
        end



        function[modelName,modelcovId]=findModel(testObj)

            validateattributes(testObj,{'cvdata'},{'scalar'},'cvdata.findModel','',1);

            modelcovId=cv('get',testObj.rootId,'.modelcov');
            modelName=SlCov.CoverageAPI.getModelcovName(modelcovId);
        end



        function[topModelName,topModelcovId]=findTopModel(testObj)

            validateattributes(testObj,{'cvdata'},{'scalar'},'cvdata.findTopModel','',1);

            modelCovId=cv('get',testObj.rootId,'.modelcov');

            topModelcovId=cv('get',modelCovId,'.topModelcovId');

            topModelName='';
            if~isempty(topModelcovId)&&cv('ishandle',topModelcovId)
                topModelName=SlCov.CoverageAPI.getModelcovName(topModelcovId);
            end
        end



        function[topModelHandle,topModelcovId]=findTopModelHandle(testObj)

            validateattributes(testObj,{'cvdata'},{'scalar'},'cvdata.findTopModelHandle','',1);

            [~,topModelcovId]=cvdata.findTopModel(testObj);
            topModelHandle=0;
            if cv('ishandle',topModelcovId)
                topModelHandle=cv('get',topModelcovId,'.handle');
                if isempty(topModelHandle)||topModelHandle==0||~ishandle(topModelHandle)
                    topModelName=SlCov.CoverageAPI.getModelcovName(topModelcovId);
                    try
                        topModelHandle=get_param(topModelName,'Handle');
                    catch
                    end
                end
            end
        end



        function options=getHTMLOptions(testObj)

            validateattributes(testObj,{'cvdata'},{'scalar'},'cvdata.getHTMLOptions','',1);

            topModelName=cvdata.findTopModel(testObj);
            if~isempty(topModelName)
                options=cvi.CvhtmlSettings(topModelName);
                options.topModelName=topModelName;
            else
                modelName=cvdata.findModel(testObj);
                options=cvi.CvhtmlSettings(modelName);
            end
        end



        function modelinfo=addModelInfoMessages(modelinfo)
            fieldNames=fieldnames(modelinfo);
            for idx=1:numel(fieldNames)
                fn=fieldNames{idx};
                value=modelinfo.(fn);
                if isequal(fn,'blockReductionStatus')
                    if strcmpi(value,'forcedOff')
                        modelinfo.(fn)=getString(message('Slvnv:simcoverage:cvhtml:BlockReductionForcedOff'));
                    elseif strcmpi('on',value)
                        modelinfo.(fn)=getString(message('Slvnv:simcoverage:cvhtml:on'));
                    elseif strcmpi('off',value)
                        modelinfo.(fn)=getString(message('Slvnv:simcoverage:cvhtml:off'));
                    else
                        modelinfo.(fn)=getString(message('Slvnv:simcoverage:cvdata:NotUnique'));
                    end
                elseif strcmpi(value,'notUnique')
                    modelinfo.(fn)=getString(message('Slvnv:simcoverage:cvdata:NotUnique'));
                end
            end
        end

    end


    methods(Hidden)
        newCvd=addSubsystem(this,targetSubsys,cvd)
        newCvd=cutSubsystem(this,targetSubsys)

        newCvd=applyMask(this,mask)
        newCvd=applyDataMask(this,targetCvIds)
        applyHierarchyMask(this,targetCvIds,mask)
        cvIds=findMaskCvIds(this,mask)
        setAggregatedTestInfo(this,lhsCvd,rhsCvd)
        processAgregatedInfo(this)

        traceLabel=getTrace(this,metricName,idx,toString)
        res=getTraceLabel(this,traceId)
        traceInfo=getTraceInfo(this,metricName,idx)

        applyReqMask(this,isMasked)
        buildTraceMask(this)
        reaggregateFromTrace(this,metricName,isTOMetric,traceMask)


        createDerivedData(this,lhs,rhs,metrics,trace)
        setMetricData(this,metricData)

        function addFilterData(this,fd)
            oldFD=this.filterData;
            if isempty(oldFD)
                newFD=fd;
            else
                newFD=[oldFD,fd];
            end
            this.filterData=newFD;
        end


        function setRootId(this,id)
            if this.id==0
                this.localData.rootId=id;
            end
        end

        function variantStates=getRootVariantStates(this)
            if this.id==0
                variantStates=this.localData.variantStates;
            else
                variantStates=cv('get',this.id,'.variantStates');
            end
        end

        function setRootVariantStates(this,variantStates)
            if this.id==0
                this.localData.variantStates=variantStates;
            else
                cv('set',this.id,'.variantStates',variantStates);
            end
        end
        function storeRootVariants(this)
            variantStates=cvi.RootVariant.getRootVariantStates(this.rootID);
            if~isempty(variantStates)
                this.setRootVariantStates(variantStates);
                chks=cv('get',this.rootID,'.checksum');
                if this.id==0
                    tvchks=checksumArray2Struct(chks);
                    this.localData.variantChecksum=tvchks;
                else
                    cv('set',this.id,'.variantChecksum',chks);
                end
            end
        end

        function setAnalyzedModel(this,value)
            id=this.id;
            if id==0
                this.localData.modelinfo.analyzedModel=value;
            end
        end



        function checkId(this)
            if this.isInvalidated
                throwAsCaller(MException(message('Slvnv:simcoverage:cvdata:InvalidCvDataNoObj')));
            end

            if~this.isLoaded
                this.load();
            end

            id=this.id;

            if id==0
                if~isstruct(this.localData)||...
                    ~isfield(this.localData,'rootId')||...
                    ~cv('ishandle',this.localData.rootId)

                    throwAsCaller(MException(message('Slvnv:simcoverage:cvdata:InvalidCvDataNoObj')));
                end
            else
                if~cv('ishandle',id)||isempty(cv('get',id,'.isa'))||...
                    cv('get',id,'.isa')~=cv('get','default','testdata.isa')

                    throwAsCaller(MException(message('Slvnv:simcoverage:cvdata:InvalidCvDataNoObj')));
                end
            end

        end

        function value=canHarnessMapBackToOwner(this)
            value=cv('get',cv('get',this.rootId,'.modelcov'),'.canHarnessMapBackToOwner');
        end

        function modelinfo=getRawModelInfo(this)
            if this.id==0
                modelinfo=this.localData.modelinfo;
            else
                id=this.id;
                fieldNames={'modelVersion','creator','lastModifiedDate','defaultParameterBehavior','blockReductionStatus',...
                'conditionallyExecuteInputs','mcdcMode','analyzedModel','reducedBlocks','ownerModel','ownerBlock','harnessModel'};
                modelinfo=[];
                for idx=1:numel(fieldNames)
                    fn=fieldNames{idx};
                    modelinfo.(fn)=getModelInfoField(id,fn);
                end

                modelinfo.logicBlkShortcircuit=cvtest.getMf0Settings(id).logicBlkShortcircuit;
            end


            if~isempty(modelinfo.harnessModel)&&...
                ~isempty(modelinfo.ownerModel)&&...
                ~isempty(modelinfo.ownerBlock)&&...
                SlCov.CovMode.isGeneratedCode(this.simMode)&&...
                ~(this.isSharedUtility||this.isCustomCode)

                isNotUniqueStr=@(str)strcmp(str,getString(message('Slvnv:simcoverage:cvdata:NotUnique')))||...
                strcmpi(str,'notUnique');
                if strcmp(modelinfo.analyzedModel,modelinfo.ownerModel)&&...
                    ~isNotUniqueStr(modelinfo.ownerBlock)
                    modelinfo.analyzedModel=modelinfo.ownerBlock;
                end
            end
        end

    end
end


function invalid_subscript
    throwAsCaller(MException(message('Slvnv:simcoverage:subsref:InvalidSubscript')));
end


function rootId=getRootId(id)

    rootId=cv('get',id,'.linkNode.parent');
    if~cv('ishandle',rootId)||cv('get','default','root.isa')~=cv('get',rootId,'.isa')

        rootId=0;
    end

end


function value=getModelInfoField(id,fn)

    if strcmpi(fn,'analyzedModel')
        value=cv('get',id,'.analyzedModel');
        if~isempty(value)
            return;
        end

        rootId=getRootId(id);
        modelcovId=cv('get',rootId,'.modelcov');
        if isempty(modelcovId)||~cv('ishandle',modelcovId)
            return;
        end

        value='';
        topSlSfId=cv('get',rootId,'.topSlsf');
        if cv('ishandle',topSlSfId)


            th=cv('get',topSlSfId,'.handle');
            if is_simulink_handle(th)
                value=getfullname(th);
            end
        end



        if isempty(value)
            value=SlCov.CoverageAPI.getModelcovName(modelcovId);
            path=cv('get',rootId,'.path');
            if~isempty(path)
                value=[value,'/',path];
            end
        end
    else
        value=cv('get',id,['.',fn]);
    end

end


function value=getToMetricData(id,allTOMetricNames)

    value=[];
    for idx=1:numel(allTOMetricNames)
        value.(allTOMetricNames{idx})=zeros(0,1);
    end

    metricdataIds=cv('get',id,'testdata.testobjectives');
    metricdataIds(metricdataIds==0)=[];
    if~isempty(metricdataIds)
        for idx=1:numel(metricdataIds)
            if metricdataIds(idx)~=0
                data=cv('get',metricdataIds(idx),'.data.rawdata');
                metricName=cv('get',metricdataIds(idx),'.metricName');
                value.(metricName)=data;
            end
        end
    end

end


function value=getTOTraceData(id)

    value=[];

    metricdataIds=cv('get',id,'testdata.testobjectives');
    metricdataIds(metricdataIds==0)=[];
    if~isempty(metricdataIds)
        for idx=1:numel(metricdataIds)
            if metricdataIds(idx)~=0
                data=cv('get',metricdataIds(idx),'.trace.rawdata');
                if~isempty(data)
                    metricName=cv('get',metricdataIds(idx),'.metricName');
                    value.(metricName)=data;
                end
            end
        end
    end

end


function value=getMetricData(id,metricName)

    enumVal=cvi.MetricRegistry.getEnum(metricName);
    if enumVal<0
        invalid_subscript;
    end
    value=cv('get',id,['testdata.data.',metricName]);

end

function value=getTraceData(id,metricName)

    enumVal=cvi.MetricRegistry.getEnum(metricName);
    if enumVal<0
        invalid_subscript;
    end
    value=cv('get',id,['testdata.traceData.',metricName]);

end

function checksumStruct=checksumArray2Struct(checkSumArr)
    checksumStruct=struct('u1',checkSumArr(1),'u2',checkSumArr(2),'u3',checkSumArr(3),'u4',checkSumArr(4));
end




