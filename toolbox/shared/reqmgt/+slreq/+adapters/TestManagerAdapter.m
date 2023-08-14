classdef TestManagerAdapter<slreq.adapters.BaseAdapter




    properties(Constant,Hidden)
        TYPE_TESTFILE="testFile"
        TYPE_TESTSUITE="testSuite"
        TYPE_TESTCASE="testcase"
        TYPE_ITERATION="iteration"
        TYPE_ASSESSMENT="assessments"
    end

    methods
        function this=TestManagerAdapter()
            this.domain='linktype_rmi_testmgr';
        end

        function tf=isResolved(~,artifact,id)


            if rmiut.isCompletePath(artifact)
                tf=local_checkInTestManager(artifact,id);
            else


                shortName=slreq.uri.getShortNameExt(artifact);
                loadedFiles=sltest.testmanager.getTestFiles();
                if~isempty(loadedFiles)
                    filePaths={loadedFiles.FilePath};
                    isMatch=endsWith(filePaths,shortName);

                    for i=find(isMatch)
                        if local_checkInTestManager(filePaths{i},id)
                            tf=true;
                            return;
                        end
                    end
                end
                tf=false;
            end

            function result=local_checkInTestManager(artifact,id)
                try
                    result=stm.internal.getTestIdFromUUIDAndTestFile(id,artifact)>0;
                catch ex %#ok<NASGU>
                    result=false;
                end
            end
        end

        function str=getLinkLabel(this,artifact,id)

            shortFilename=slreq.uri.getShortNameExt(artifact);
            if~this.isResolved(artifact,id)
                str=getString(message('Slvnv:rmitm:TestCaseIn',id,shortFilename));
                return;
            end
            itemName=this.getSummary(artifact,id);
            str=getString(message('Slvnv:reqmgt:LinkSet:updateContents:LocationInDoc',itemName,shortFilename));
        end

        function str=getSummary(this,artifact,id)





            [~,baseName]=fileparts(artifact);
            licStatus=license('test','Simulink_Test');
            if~(licStatus&&(dig.isProductInstalled('Simulink Test')))

                str=sprintf('%s:%s',baseName,'??');
                return;
            end

            if~this.isResolved(artifact,id)
                str=sprintf('%s:%s',baseName,'??');
                return;
            end

            testId=this.getTestIdFromArtifactId(artifact,id);
            if testId>0
                [~,str]=this.testPropByTestId(testId,id);
            else


                str=[getString(message('Slvnv:rmitm:TestCase')),' ',id];
            end
        end

        function icon=getIcon(this,artifact,id)
            if this.isResolved(artifact,id)
                icon=slreq.gui.IconRegistry.instance.testMgr;
            else
                icon=slreq.gui.IconRegistry.instance.warning;
            end
        end

        function tooltip=getTooltip(this,artifact,id)
            if this.isResolved(artifact,id)
                testId=this.getTestIdFromArtifactId(artifact,id);
                if testId>0
                    testProp=this.testPropByTestId(testId,id);
                    tooltip=testProp.testFilePath;
                    return;
                end
            else
                tooltip=getString(message('Slvnv:slreq:UnableToResolveLinkTargetForTestCase'));
            end
        end

        function out=getSourceObject(this,artifact,id)
            tcID=stm.internal.getTestIdFromUUIDAndTestFile(id,artifact);
            if~isempty(tcID)&&tcID>0
                testType=stm.internal.getTestType(tcID);
                switch testType
                case 'testFile'
                    out=sltest.testmanager.load(artifact);
                case 'testSuite'
                    out=sltest.testmanager.TestSuite([],tcID);
                case{'simulationTest','baselineTest','equivalenceTest'}
                    out=sltest.testmanager.TestCase([],tcID);
                case 'iteration'
                    out=sltest.testmanager.Test.getTestObjFromID(tcID);
                case 'assessments'




                    out.artifact=artifact;
                    out.id=id;
                    out.domain=this.domain;

                    assessmentID=split(id,':');
                    if numel(assessmentID)>1
                        assessmentID=str2double(assessmentID(end));

                        assessmentDef=stm.internal.getAssessmentsDefinitionHelper(stm.internal.getAssessmentsInfo(tcID),assessmentID);
                        if(isfield(assessmentDef,'assessmentsDefinition'))
                            out.assessment.Definition=assessmentDef.assessmentsDefinition.textLabel;
                            out.assessment.Name=assessmentDef.assessmentsDefinition.assessmentName;
                        else

                            error(message('Slvnv:slreq:UnableToResolveObject',id))
                        end
                    end
                otherwise
                    error(message('Slvnv:slreq:UnsupportedLinkedItem',testType));
                end
            else

                error(message('Slvnv:slreq:UnableToResolveObject',id))
            end
        end

        function success=select(this,artifact,id,~)
            rmi.navigate(this.domain,artifact,id,'');
            success=true;
        end

        function success=highlight(this,artifact,id,~)
            rmi.navigate(this.domain,artifact,id,'');
            success=true;
        end

        function success=onClickHyperlink(this,artifact,id,~)
            rmi.navigate(this.domain,artifact,id,'');
            success=true;
        end

        function str=getClickActionCommandString(~,artifact,id,~)
            str=sprintf('rmitmnavigate(''%s'',''%s'');',artifact,id);
        end

        function url=getURL(this,artifact,id)
            [isInstalled,isLicensed]=rmi.isInstalled();
            if~isInstalled||~isLicensed
                error(message('Slvnv:reqmgt:setReqs:NoLicense'));
            end
            if strcmp(rmipref('ModelPathReference'),'none')



                externallyReferencedArtifact=slreq.uri.getShortNameExt(artifact);
            else




                externallyReferencedArtifact=artifact;
            end
            cmd=this.getClickActionCommandString(externallyReferencedArtifact,id);
            url=rmiut.cmdToUrl(cmd,false);
        end



        function fullPath=getFullPathToArtifact(~,artifact,varargin)


            fullPath=rmitm.getFilePath(artifact,varargin{:});
        end

        function refreshLinkOwner(~,linkedArtifact,linkedId,~,~)

            rmitm.UpdateNotifier.notifyReqUpdate(linkedArtifact,linkedId);
        end

        function linkType=getDefaultLinkType(this,artifactUri,artifactId)%#ok<INUSD>
            linkType=slreq.custom.LinkType.Verify;
        end


        function[status,revisionInfo]=getRevisionInfo(this,sourceObj)
            status=slreq.analysis.ChangeStatus.UnsupportedArtifact;
            revisionInfo=slreq.utils.DefaultValues.getRevisionInfo();
            if reqmgt('rmiFeature','ChangeTrackingSltest')
                status=slreq.analysis.ChangeStatus.Undecided;

                revisionInfo.uuid=sourceObj.id;




                testId=this.getTestIdFromArtifactId(sourceObj.artifactUri,sourceObj.id);



                testType=this.getTestTypeById(testId);
                if isempty(testType)||testType==this.TYPE_ASSESSMENT
                    status=slreq.analysis.ChangeStatus.UnsupportedArtifact;
                    return;
                end

                if testType==this.TYPE_ITERATION



                    it=sltest.internal.TestIterationWrapper(testId);
                    revisionInfo.revision=it.RevisionUUID;
                else






                    testProperties=this.testPropByTestId(testId,sourceObj.id);
                    if~isempty(testProperties)&&~isempty(testProperties.revisionuuid)
                        revisionInfo.revision=testProperties.revisionuuid;
                    end
                end
            end
        end

    end

    methods(Access=private)
        function testId=getTestIdFromArtifactId(this,artifact,id)




            testFilePath=this.getFullPathToArtifact(artifact);
            testId=stm.internal.getTestIdFromUUIDAndTestFile(id,testFilePath);
        end

        function[testProp,label]=testPropByTestId(this,testId,testUUID)
            testProp=[];
            if testId>0


                testType=this.getTestTypeById(testId);

                switch testType
                case this.TYPE_ITERATION
                    it=sltest.internal.TestIterationWrapper(testId);
                    label=it.Name;
                    testCaseID=it.getTestID();
                    testProp=stm.internal.getTestProperty(testCaseID,'testcase');
                case this.TYPE_ASSESSMENT
                    testCaseID=stm.internal.getAssessmentsTestCaseID(testId);
                    testProp=stm.internal.getTestProperty(testCaseID,'testcase');
                    label=sltest.assessments.internal.getAssessmentName(testId,testUUID);
                otherwise
                    testProp=stm.internal.getTestProperty(testId,testType);
                    label=testProp.name;
                end
            end
        end

        function testType=getTestTypeById(this,testId)
            testType=[];
            if testId>0
                testType=stm.internal.getTestType(testId);
                if(strcmpi(testType,'simulationTest')...
                    ||strcmpi(testType,'baselineTest')...
                    ||strcmpi(testType,'equivalenceTest'))
                    testType=this.TYPE_TESTCASE;
                elseif(strcmpi(testType,'testFile')||strcmpi(testType,'testSuite'))
                    testType=this.TYPE_TESTSUITE;
                elseif strcmpi(testType,'assessments')
                    testType=this.TYPE_ASSESSMENT;
                else
                    testType=this.TYPE_ITERATION;
                end
            end
        end
    end
end
