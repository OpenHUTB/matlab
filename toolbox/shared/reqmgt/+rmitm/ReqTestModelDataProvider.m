classdef ReqTestModelDataProvider<handle

    properties(Access=public)

        reqFileName2IdxMap;
        reqFullID2IdxMap;
        reqFullID2ImplIndexMap;
        reqFullID2VerifIndexMap;
        modelSID2IdxMap;
        testCaseID2IdxMap;
        testCaseID2IdxMapWithDesc;
        runID2IdxMap;
    end

    properties(SetAccess=private,GetAccess=public)
ReqFile
Requirement
LinkFile
ImplementLink
VerifyLink
ModelItem
Test
Simulation
    end


    properties(Access=public)
        modelList;
        testFilePath;
    end


    properties(Access=private)

        reqIdx;
reqFileIdx
linkFileIdx
        implIdx;
        verifIdx;
        testIdx;
        simIdx;
        modelsForcedLoaded;
    end


    methods

        function this=ReqTestModelDataProvider()

            this.init();
        end


        function init(this)
            this.reqFullID2IdxMap=containers.Map('KeyType','char','ValueType','double');
            this.modelSID2IdxMap=containers.Map('KeyType','char','ValueType','double');
            this.reqFullID2ImplIndexMap=containers.Map('KeyType','char','ValueType','Any');
            this.reqFullID2VerifIndexMap=containers.Map('KeyType','char','ValueType','Any');
            this.testCaseID2IdxMap=containers.Map('KeyType','char','ValueType','Any');
            this.testCaseID2IdxMapWithDesc=containers.Map('KeyType','char','ValueType','Any');
            this.runID2IdxMap=containers.Map('KeyType','int32','ValueType','Any');

            this.ReqFile=struct([]);
            this.Requirement=struct([]);
            this.reqFileIdx=1;
            this.reqIdx=1;

            this.LinkFile=struct([]);
            this.ImplementLink=struct([]);
            this.VerifyLink=struct([]);
            this.ModelItem=struct([]);
            this.Test=struct([]);
            this.Simulation=struct([]);

            this.linkFileIdx=1;
            this.implIdx=1;
            this.verifIdx=1;
            this.testIdx=1;
            this.simIdx=1;

            this.modelsForcedLoaded={};
        end


        function populateData(this)
            this.preprocessModelList();
            this.loadModelIfNeeded();
            this.includeLibraries();

            this.populateRequirementsData();

            this.populateLinksData();

            this.resolveCrossReference();
            this.unloadModelIfForcedLoaded();
        end


        function info=getInfoStructure(this)
            info.ReqFile=this.ReqFile;
            info.Requirement=this.Requirement;
            info.LinkFile=this.LinkFile;
            info.ImplementLink=this.ImplementLink;
            info.VerifyLink=this.VerifyLink;
            info.ModelItem=this.ModelItem;
            info.Test=this.Test;
            info.Simulation=this.Simulation;
            info.modelItemMap=this.modelSID2IdxMap;
            info.testUuid2IdxMap=this.testCaseID2IdxMapWithDesc;
        end


        function loadModelIfNeeded(this)
            if isempty(this.modelList)
                return;
            end
            for n=1:length(this.modelList)
                mdl=this.modelList{n};
                if dig.isProductInstalled('Simulink')&&~bdIsLoaded(mdl)

                    load_system(mdl);
                    this.modelsForcedLoaded{end+1}=mdl;
                end
            end
        end


        function unloadModelIfForcedLoaded(this)
            for n=1:length(this.modelsForcedLoaded)
                close_system(this.modelsForcedLoaded{n},0);
            end
        end


        function preprocessModelList(this)

            if ischar(this.modelList)
                if isempty(this.modelList)
                    this.modelList={};
                else
                    this.modelList={this.modelList};
                end
            end
            assert(isa(this.modelList,'cell'),'modelList must be a cell array');
        end


        function includeLibraries(this)
            mList=this.modelList;
            mListWithLibs=this.modelList;
            for n=1:length(mList)
                libs=libinfo(mList{n},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
                for m=1:length(libs)
                    mListWithLibs{end+1}=libs(m).Library;%#ok<AGROW>
                end
            end
            this.modelList=unique(mListWithLibs);
        end


        function populateRequirementsData(this)
            dataReqSets=slreq.data.ReqData.getInstance().getLoadedReqSets;

            for n=1:length(dataReqSets)
                rSet=dataReqSets(n);
                this.ReqFile(n).Name=rSet.name;
                this.ReqFile(n).Version=num2str(rSet.revision);
                this.ReqFile(n).ModifiedDate=rSet.modifiedOn;
                this.reqFileName2IdxMap(rSet.name)=n;
                this.populateRequirements(rSet);
                this.reqFileIdx=this.reqFileIdx+1;
            end
        end


        function populateLinksData(this)
            dataLinkSets=slreq.data.ReqData.getInstance().getLoadedLinkSets();

            for n=1:length(dataLinkSets)
                linkSet=dataLinkSets(n);
                if~(this.isRequestedModel(linkSet)||this.isRequestedTestFile(linkSet))

                    continue;
                end
                lnkFile.Name=linkSet.name;
                lnkFile.Artifact=linkSet.artifact;
                lnkFile.Version=num2str(linkSet.revision);
                lnkFile.ModifiedDate=linkSet.modifiedOn;
                this.LinkFile=append(this.LinkFile,lnkFile);

                this.populateLinks(linkSet);
                this.linkFileIdx=this.linkFileIdx+1;
            end
        end


        function resolveCrossReference(this)

            for n=1:length(this.Requirement)
                req=this.Requirement(n);
                fullId=req.FullID;

                if isKey(this.reqFullID2ImplIndexMap,fullId)
                    req.ImplementInd=this.reqFullID2ImplIndexMap(fullId);
                end

                if isKey(this.reqFullID2VerifIndexMap,fullId)
                    req.VerifyInd=this.reqFullID2VerifIndexMap(fullId);
                end
                this.Requirement(n)=req;
            end
        end
    end


    methods(Access=private)
        function populateRequirements(this,dataReqSet)
            dataReqs=dataReqSet.getAllItems();
            populateReqs(this,dataReqs);


            function populateReqs(this,dataReqs)
                for j=1:length(dataReqs)
                    dataReq=dataReqs(j);
                    doc=[dataReq.getReqSet.name,'.slreqx'];
                    id=num2str(dataReq.sid);
                    url=getURL('linktype_rmi_slreq',doc,id);
                    fullId=dataReq.getFullID;
                    rq=struct('Label',dataReq.summary,'URL',url,'fileIdx',this.reqFileIdx,...
                    'ImplementInd',[],'VerifyInd',[],'FullID',fullId);
                    this.Requirement=append(this.Requirement,rq);
                    this.reqFullID2IdxMap(fullId)=this.reqIdx;
                    this.reqIdx=this.reqIdx+1;
                end
            end
        end


        function populateLinks(this,dataLinkSet)
            links=dataLinkSet.getAllLinks();
            isSimulink=false;
            isTestManager=false;
            if strcmp(dataLinkSet.domain,'linktype_rmi_simulink')
                isSimulink=true;
                [~,modelName]=fileparts(dataLinkSet.artifact);
                if dig.isProductInstalled('Simulink')&&~bdIsLoaded(modelName)

                    load_system(dataLinkSet.artifact);
                    this.modelsForcedLoaded{end+1}=modelName;
                end
            elseif strcmp(dataLinkSet.domain,'linktype_rmi_testmgr')
                isTestManager=true;
            end
            for n=1:length(links)
                dataLink=links(n);
                srcItem=dataLink.source;
                dstItem=dataLink.dest;
                if isempty(dstItem)
                    continue;
                end
                reqId=dstItem.getFullID;
                if isSimulink&&slreq.app.LinkTypeManager.isa(dataLink.type,...
                    slreq.custom.LinkType.Implement,dataLink.getLinkSet())
                    impl=this.getImplementLinkStruct(dataLink,srcItem,reqId);
                    this.ImplementLink=append(this.ImplementLink,impl);
                    this.reqFullID2ImplIndexMap=appendInMap(this.reqFullID2ImplIndexMap,reqId,this.implIdx);
                    this.implIdx=this.implIdx+1;
                elseif isTestManager&&slreq.app.LinkTypeManager.isa(...
                    dataLink.type,slreq.custom.LinkType.Verify,dataLink.getLinkSet())
                    verif=this.getVerificationLinkStruct(dataLink,srcItem,reqId);
                    this.VerifyLink=append(this.VerifyLink,verif);
                    this.reqFullID2VerifIndexMap=appendInMap(this.reqFullID2VerifIndexMap,reqId,this.verifIdx);
                    this.verifIdx=this.verifIdx+1;
                end

            end
        end


        function impl=getImplementLinkStruct(this,dataLink,srcItem,reqId)

            impl.Label=dataLink.description;
            impl.URL=getURLToLink(dataLink);
            if isKey(this.reqFullID2IdxMap,reqId)
                impl.RequirementIdx=this.reqFullID2IdxMap(reqId);
            else
                impl.RequirementIdx=[];
            end
            this.populateModelItem(srcItem,this.implIdx);
            impl.ModelItemIdx=this.modelSID2IdxMap(srcItem.getSID);
            impl.fileIdx=this.linkFileIdx;
        end


        function populateModelItem(this,srcItem,nImpl)
            sid=srcItem.getSID();
            if~isKey(this.modelSID2IdxMap,sid)
                mItem.SID=sid;
                mItem.ImplementedInd=nImpl;
                mItem.SimulationInd=[];
                this.ModelItem=append(this.ModelItem,mItem);
                this.modelSID2IdxMap(sid)=numel(this.ModelItem);
            else
                idx=this.modelSID2IdxMap(sid);
                mItem=this.ModelItem(idx);
                mItem.ImplementedInd=append(mItem.ImplementedInd,nImpl);
                this.ModelItem(idx)=mItem;
            end
        end


        function verif=getVerificationLinkStruct(this,dataLink,srcItem,reqId)
            verif.Label=dataLink.description;
            if isKey(this.reqFullID2IdxMap,reqId)
                verif.RequirementIdx=this.reqFullID2IdxMap(reqId);
            else
                verif.RequirementIdx=[];
            end
            this.populateTest(srcItem,this.verifIdx);
            verif.URL=getURLToLink(dataLink);
            if isKey(this.testCaseID2IdxMap,srcItem.id)
                verif.TestIdx=this.testCaseID2IdxMap(srcItem.id);
                verif.fileIdx=this.linkFileIdx;
            end
        end


        function populateTest(this,srcItem,nVerif)
            if~isKey(this.testCaseID2IdxMap,srcItem.id)
                [adapter,artifact,id]=srcItem.getAdapter();
                testItem.Label=adapter.getSummary(artifact,id);
                testItem.VerifyInd=nVerif;
                testItem.SimulationInd=[];
                shortNameExt=slreq.uri.getShortNameExt(artifact);
                testItem.URL=['matlab:',adapter.getClickActionCommandString(shortNameExt,id,'')];
                this.Test=append(this.Test,testItem);
                tIdx=numel(this.Test);
                this.testCaseID2IdxMap(srcItem.id)=tIdx;
                this.addTestObjWithDescendentsToMap(getTestObj(srcItem),tIdx)
                this.testIdx=this.testIdx+1;
            else
                tIdx=this.testCaseID2IdxMap(srcItem.id);
                testItem=this.Test(tIdx);
                testItem.VerifyInd=append(testItem.VerifyInd,nVerif);
                this.Test(tIdx)=testItem;
            end
        end


        function addTestObjWithDescendentsToMap(this,testObjects,tIdx)
            for toIdx=1:length(testObjects)
                testObj=testObjects(toIdx);

                if isa(testObj,'sltest.testmanager.TestIteration')
                    uuid=testObj.getIterationProperties.uuid;
                else
                    uuid=testObj.UUID;
                end
                if~this.appendToTestIdxMap(uuid,tIdx)

                    return;
                end

                if isa(testObj,'sltest.testmanager.TestFile')
                    testSuites=testObj.getTestSuites;
                    for i=1:length(testSuites)
                        this.addTestObjWithDescendentsToMap(testSuites(i),tIdx);
                    end
                elseif isa(testObj,'sltest.testmanager.TestSuite')
                    testSuites=testObj.getTestSuites;
                    for i=1:length(testSuites)
                        this.addTestObjWithDescendentsToMap(testSuites(i),tIdx);
                    end
                    testCases=testObj.getTestCases;
                    for i=1:length(testCases)
                        this.addTestObjWithDescendentsToMap(testCases(i),tIdx);
                    end
                elseif isa(testObj,'sltest.testmanager.TestCase')
                    testIterations=testObj.getIterations;
                    for i=1:length(testIterations)
                        this.addTestObjWithDescendentsToMap(testIterations(i),tIdx);
                    end
                end
            end
        end


        function added=appendToTestIdxMap(this,uuid,testIdx)
            added=false;
            if isKey(this.testCaseID2IdxMapWithDesc,uuid)
                idxList=this.testCaseID2IdxMapWithDesc(uuid);
                if~ismember(testIdx,idxList)
                    idxList=append(idxList,testIdx);
                    added=true;
                end
            else
                idxList=testIdx;
                added=true;
            end
            this.testCaseID2IdxMapWithDesc(uuid)=idxList;
        end


        function tf=isRequestedModel(this,dataLinkSet)
            tf=false;
            if strcmp(dataLinkSet.domain,'linktype_rmi_simulink')
                if isempty(this.modelList)
                    tf=true;
                else
                    [~,modelName]=fileparts(dataLinkSet.artifact);
                    tf=any(contains(this.modelList,modelName));
                end
            end
        end

        function tf=isRequestedTestFile(this,dataLinkSet)
            tf=false;
            if strcmp(dataLinkSet.domain,'linktype_rmi_testmgr')
                if isempty(this.testFilePath)

                    tf=true;
                else
                    tf=any(contains(this.testFilePath,dataLinkSet.artifact));
                end
            end
        end
    end
end


function url=getURL(domain,artifact,id)
    navCmd=sprintf('rmi.navigate(''%s'',''%s'',''%s'',''%s'')',...
    domain,artifact,id,'');
    url=sprintf('matlab:%s',navCmd);
end


function url=getURLToLink(dataLink)
    navCmd=sprintf('slreq.app.CallbackHandler.selectObjectByUuid(''%s'',''standalone'')',dataLink.getUuid);
    url=sprintf('matlab:%s',navCmd);
end


function map=appendInMap(map,id,value)
    if isKey(map,id)
        v=map(id);
        v=[v,value];
        map(id)=v;
    else
        map(id)=value;
    end
end


function lhs=append(lhs,in)
    if isempty(lhs)
        lhs=in;
    else
        lhs=[lhs,in];
    end
end


function testObj=getTestObj(srcItem)
    testObj=[];
    uuid=srcItem.id;
    artifact=srcItem.artifactUri;
    itemId=stm.internal.getTestIdFromUUIDAndTestFile(uuid,artifact);
    if~isempty(itemId)&&itemId>0
        testType=stm.internal.getTestType(itemId);
        switch testType
        case 'testFile'
            testObj=sltest.testmanager.TestFile(artifact);
        case 'testSuite'
            testObj=sltest.testmanager.TestSuite([],itemId);
        case{'simulationTest','baselineTest','equivalenceTest'}
            testObj=sltest.testmanager.TestCase([],itemId);
        case 'iteration'
            iterProps=stm.internal.getTestIterationProperty(itemId);
            tc=sltest.testmanager.TestCase([],iterProps.testCaseId);
            testObj=tc.getIterations(iterProps.name);
        case 'assessments'
            tcId=stm.internal.getAssessmentsTestCaseID(itemId);
            tc=sltest.testmanager.TestCase([],tcId);
            tciAll=tc.getIterations;
            if isempty(tciAll)
                testObj=tc;
            else
                assessmentName=sltest.assessments.internal.getAssessmentName(itemId,uuid);
                for i=1:length(tciAll)
                    if checkIterationHasAssessment(tciAll(i),assessmentName)
                        if isempty(testObj)
                            testObj=tciAll(i);
                        else
                            testObj(end+1)=tciAll(i);%#ok<AGROW>
                        end
                    end
                end
            end

        otherwise
            testObj=[];
        end
    end
end


function res=checkIterationHasAssessment(iteration,assessmentName)
    res=false;
    tp=iteration.TestParams;
    assessmentParamIdx=cellfun(@(x)strcmpi(x{1},'Assessments'),tp);
    assessmentParam=tp{assessmentParamIdx};
    if~isempty(assessmentParam)
        assessmentParam=assessmentParam{2};
        if ischar(assessmentParam)
            if isempty(assessmentParam)

                res=true;
            else
                res=contains(assessmentParam,['"',assessmentName,'"']);
            end
        end
    end
end

