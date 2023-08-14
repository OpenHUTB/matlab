classdef SLTestTraverser<slreq.report.rtmx.utils.ArtifactTraverser

    properties
TestFile
        TopFullID;
    end

    methods(Access=private)
        function this=SLTestTraverser()

            this@slreq.report.rtmx.utils.ArtifactTraverser()
            this.Domain='sltest';
        end
    end

    methods(Static)
        function obj=getInstance()


            persistent cachedObj
            if isempty(cachedObj)
                cachedObj=slreq.report.rtmx.utils.SLTestTraverser;
            end
            obj=cachedObj;
        end
    end
    methods
        function loadArtifact(this,testFile)

            this.ArtifactPath=testFile;
        end

        function clearData(this)
            clearData@slreq.report.rtmx.utils.ArtifactTraverser(this);
        end

        function traverse(this)


            this.preTraverse(this.ArtifactPath);












            import slreq.report.rtmx.utils.*






            this.traverseFlatList();
            this.traverseHierarchy();
        end


        function traverseFlatList(this)

            import slreq.report.rtmx.utils.*
            tFile=sltest.testmanager.TestFile(this.ArtifactPath);

            this.setProgressRangeItems(0);





































            this.traverseTestFile(tFile);
        end


        function traverseTestFile(this,testFile)

            allTestSuites=testFile.getTestSuites;
            import slreq.report.rtmx.utils.*

            uuid=testFile.getProperty('UUID');
            fullID=testFile.FilePath;
            this.TopFullID=fullID;
            itemData=TestItemIDData(fullID);
            itemData.Desc=testFile.Name;
            itemData.LongDesc=testFile.FilePath;
            itemData.Domain=this.Domain;
            itemData.ItemID=uuid;
            this.updateItemID2FullList(itemData.ItemID,itemData.FullID);
            itemData.IsRoot=true;
            itemData.Type='TestFile';
            itemData.UUID=uuid;
            itemData.ArtifactID=this.ArtifactID;
            itemData.Link='NotLinkable';
            itemData.IconType='linktype-rmi-testmgr';

            this.updateTypeList(itemData.Type,getString(message('Slvnv:slreq_rtmx:FilterTypesSLTestTestFile')));
            for index=1:length(allTestSuites)
                cTestSuite=allTestSuites(index);
                childSuiteID=this.traverseTestSuite(cTestSuite,fullID);
                itemData.ChildrenIDs{end+1}=childSuiteID;
            end

            updateLinkInfo(this,itemData)
            outData=itemData.exportData();

            this.ItemDetails(itemData.FullID)=outData;

        end


        function testSuiteFullID=traverseTestSuite(this,testSuite,parentFullID)

            itemData=this.createTestItemIDData(testSuite,'TestSuite',getString(message('Slvnv:slreq_rtmx:FilterTypesSLTestTestSuite')));
            itemData.ParentID=parentFullID;
            itemData.IconType='linktype-rmi-testmgr';
            testSuiteFullID=itemData.FullID;

            allTestCases=testSuite.getTestCases;

            allTestSuites=testSuite.getTestSuites;

            allItems={};
            if~isempty(allTestCases)&&~isempty(allTestSuites)
                allItems=sortTestItems(allTestCases,allTestSuites);
            elseif~isempty(allTestCases)
                allItems=num2cell(allTestCases);
            elseif~isempty(allTestSuites)
                allItems=num2cell(allTestSuites);
            end

            for index=1:length(allItems)
                cItem=allItems{index};
                if isa(cItem,'sltest.testmanager.TestCase')
                    childFullID=this.traverseTestCase(cItem,testSuiteFullID);
                elseif isa(cItem,'sltest.testmanager.TestSuite')
                    childFullID=this.traverseTestSuite(cItem,testSuiteFullID);
                end
                itemData.ChildrenIDs{end+1}=childFullID;
            end













            updateLinkInfo(this,itemData);

            outData=itemData.exportData();

            this.ItemDetails(itemData.FullID)=outData;
        end


        function itemData=createTestItemIDData(this,testItem,testType,typeLabel)
            this.needContinue();

            uuid=testItem.getProperty('UUID');

            testItemFullID=[this.ArtifactID,':',uuid];

            import slreq.report.rtmx.utils.*

            itemData=TestItemIDData(testItemFullID);
            itemData.Desc=testItem.Name;
            itemData.LongDesc=testItem.Name;
            itemData.Domain=this.Domain;
            itemData.ItemID=uuid;
            this.updateItemID2FullList(itemData.ItemID,itemData.FullID);
            itemData.IsRoot=false;
            itemData.TestPath=testItem.TestPath;
            itemData.UUID=uuid;
            itemData.ArtifactID=this.ArtifactID;
            itemData.Keywords=cellstr(testItem.Tags);
            this.updateKeywordList(itemData.Keywords);

            itemData.Type=testType;
            this.updateTypeList(testType,typeLabel);

            if strcmpi(testType,'testcase')
                itemData.SubType=[itemData.Type,'##',testItem.TestType];

            end

        end

        function testCaseFullID=traverseTestCase(this,testCase,parentFullID)
            itemData=this.createTestItemIDData(testCase,'TestCase',getString(message('Slvnv:slreq_rtmx:FilterTypesSLTestTestCase')));
            itemData.ParentID=parentFullID;
            itemData.IconType='linktype-rmi-testmgr';
            testCaseFullID=itemData.FullID;

            allIterations=testCase.getIterations;

            for index=1:length(allIterations)
                cIteration=allIterations(index);
                testIerationFullID=this.traverseTestIteration(cIteration,testCaseFullID);
                itemData.ChildrenIDs{end+1}=testIerationFullID;
            end

            testCaseID=testCase.getID;
            assessmentsUUID=stm.internal.getAssessmentsUUID(testCaseID);
            assessmentsID=stm.internal.getAssessmentsID(testCaseID);
            assessmentInfoJson=stm.internal.getAssessmentsInfo(assessmentsID);
            allAssessmentsWithProp=containers.Map('KeyType','double','ValueType','any');
            if~isempty(assessmentInfoJson)
                assessmentInfo=jsondecode(assessmentInfoJson);

                allAssessments=sltest.assessments.internal.AssessmentsEvaluator.tableToTree(assessmentInfo.AssessmentsInfo,'placeHolder');
                for index=1:length(allAssessments)
                    cAssessment=allAssessments(index);
                    testAssessmentFullID=this.traverseTestAssessment(cAssessment,assessmentsUUID,testCaseFullID);
                    itemData.ChildrenIDs{end+1}=testAssessmentFullID;
                end























            end












            updateLinkInfo(this,itemData);

            outData=itemData.exportData();

            this.ItemDetails(itemData.FullID)=outData;

        end

        function testIerationFullID=traverseTestIteration(this,testIteration,parentFullID)

            itProp=testIteration.getIterationProperties;
            uuid=itProp.uuid;
            testIerationFullID=[this.ArtifactID,':',uuid];

            import slreq.report.rtmx.utils.*

            itemData=TestItemIDData(testIerationFullID);
            itemData.Desc=testIteration.Name;
            itemData.LongDesc=testIteration.Name;
            itemData.ItemID=uuid;
            this.updateItemID2FullList(itemData.ItemID,itemData.FullID);
            itemData.Description=testIteration.Description;
            itemData.Domain=this.Domain;
            itemData.IsRoot=false;


            itemData.ArtifactID=this.ArtifactID;
            itemData.UUID=uuid;
            itemData.Type='TestIteration';
            itemData.IconType='linktype-rmi-testmgr';
            this.updateTypeList(itemData.Type,getString(message('Slvnv:slreq_rtmx:FilterTypesSLTestTestIteration')));
            itemData.ParentID=parentFullID;

            updateLinkInfo(this,itemData);

            outData=itemData.exportData();

            this.ItemDetails(itemData.FullID)=outData;

        end

        function testAssessmentFullID=traverseTestAssessment(this,testAssessment,assessmentsUUID,parentFullID)

            this.needContinue();
            testAssessmentFullID=[this.ArtifactID,':',assessmentsUUID,':',num2str(testAssessment.id)];

            import slreq.report.rtmx.utils.*

            itemData=TestItemIDData(testAssessmentFullID);
            itemData.Desc=testAssessment.assessmentName;
            itemData.LongDesc=testAssessment.assessmentName;
            itemData.Domain=this.Domain;
            itemData.ItemID=[assessmentsUUID,':',num2str(testAssessment.id)];
            this.updateItemID2FullList(itemData.ItemID,itemData.FullID);
            itemData.IsRoot=false;
            itemData.ArtifactID=this.ArtifactID;
            itemData.UUID=[assessmentsUUID,':',num2str(testAssessment.id)];


            itemData.Type='TestAssessment';
            itemData.IconType='linktype-rmi-testmgr';
            itemData.TestAttributes=testAssessment;
            this.updateTypeList(itemData.Type,getString(message('Slvnv:slreq_rtmx:FilterTypesSLTestTestAssessment')));
            if isfield(testAssessment,'children')&&~isempty(testAssessment.children)











            end
            itemData.ParentID=parentFullID;

            updateLinkInfo(this,itemData);

            outData=itemData.exportData();

            this.ItemDetails(itemData.FullID)=outData;
        end




        function traverseHierarchy(this)
            hierarchy=traverseChildren(this,this.TopFullID,0);
            this.HierarchyInfo=hierarchy;
        end



        function hierarchy=traverseChildren(this,currentID,level)
            itemDetails=this.ItemDetails(currentID);
            itemDetails('Level')=level;

            hierarchy.FullID=currentID;
            children=itemDetails('ChildrenIDs');
            childrenInfo=cell(size(children));
            level=level+1;
            for index=1:length(children)
                child=children{index};
                childrenInfo{index}=traverseChildren(this,child,level);
            end

            hierarchy.Children=childrenInfo;
            this.ItemDetails(currentID)=itemDetails;
        end



        function updateLinkInfo(this,itemData)
            reqData=slreq.data.ReqData.getInstance;
            dataLinkSet=reqData.getLinkSet(this.ArtifactID);

            outgoingLinks=slreq.data.Link.empty();
            if~isempty(dataLinkSet)
                srcItem=dataLinkSet.getLinkedItem(itemData.UUID);
                if~isempty(srcItem)
                    outgoingLinks=srcItem.getLinks();
                end
            end


            sourceStruct=struct();
            sourceStruct.artifact=this.ArtifactID;
            sourceStruct.id=itemData.UUID;
            sourceStruct.domain='linktype_rmi_testmgr';

            dataReq=reqData.getRequirementItem(sourceStruct,false);
            if isempty(dataReq)
                incomingLinks=slreq.data.Link.empty();
            else
                incomingLinks=dataReq.getLinks();
            end

            itemData.updateLinkInfo(incomingLinks,outgoingLinks);

        end
    end

end





function outCellArray=sortTestItems(testCases,testSuites)
    idToItemMap=containers.Map('KeyType','int32','ValueType','any');
    for index=1:length(testCases)
        cTC=testCases(index);
        tcID=cTC.getID;
        if isKey(idToItemMap,tcID)
            error('something wrong');
        end
        idToItemMap(tcID)=cTC;
    end

    for index=1:length(testSuites)
        cTS=testSuites(index);
        tsID=cTS.getID;
        if isKey(idToItemMap,tsID)
            error('something wrong');
        end
        idToItemMap(tsID)=cTS;
    end

    allKeys=idToItemMap.keys;
    values=idToItemMap.values;
    [~,sortedIdx]=sort([allKeys{:}]);
    outCellArray=values(sortedIdx);
end