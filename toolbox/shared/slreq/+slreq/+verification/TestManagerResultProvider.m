classdef TestManagerResultProvider<slreq.verification.ResultProviderIntf




    events
verificationStarted
verificationFinished
    end

    methods
        function this=TestManagerResultProvider()
        end

        function scanProject(this,project)
        end








































































        function[resultStatus,resultTimestamp,reason]=getResult(this,links)


            resultStatus=repmat(slreq.verification.ResultStatus.Unknown,1,length(links));
            if isa(links,'slreq.data.Link')
                resultTimestamp=arrayfun(@(link)link.modifiedOn,links);
            else
                resultTimestamp=repmat(datetime(now,'ConvertFrom','datenum','TimeZone','Local')...
                ,1,length(links));
            end

            reason=repmat(struct('type','','message',''),1,length(links));
            for i=1:length(links)
                if isa(links(i),'slreq.data.Link')

                    linkSource=links(i).source;
                else
                    linkSource=links(i);
                end
                testFile=linkSource.artifactUri;
                id=linkSource.id;





                if~slreq.verification.TestManagerResultProvider.hasSTMLicenseAndInstallation()
                    reason(i).type='info';
                    reason(i).message=getString(message('Slvnv:slreq:VerificationNoSimulinkTestLicenseOrProduct'));
                    reason=repmat(reason(i),1,length(links));
                    return;
                end


                try

                    resultId=stm.internal.getTestResultIdsFromRequirementMetaData(id,testFile);
                catch Mex
                    reason(i).type='info';
                    reason(i).message=getString(message('Slvnv:slreq:VerificationNoSimulinkTestLicenseOrProduct'));
                    reason=repmat(reason(i),1,length(links));
                    return;
                end

                if resultId>0
                    testId=stm.internal.getTestIdFromUUIDAndTestFile(id,testFile);
                    testType=stm.internal.getTestType(testId);
                    assessmentName='';
                    if strcmp(testType,'assessments')
                        testCriteriaResult=stm.internal.getAssessmentResultTestCaseResult(resultId);
                        if testCriteriaResult==-1

                            continue
                        end
                        assessmentName=stm.internal.getAssessmentResultName(resultId);
                        resultId=testCriteriaResult;
                    end

                    testResult=sltest.testmanager.TestResult.getResultFromID(resultId);
                    if testType=="assessments"&&class(testResult)=="sltest.testmanager.TestIterationResult"
                        outcome=testResult.Parent.getAssessmentOutcomeAcrossIterations(assessmentName);
                    else
                        outcome=testResult.Outcome;
                    end

                    if outcome==sltest.testmanager.TestResultOutcomes.Passed
                        resultStatus(i)=slreq.verification.ResultStatus.Pass;
                    elseif outcome==sltest.testmanager.TestResultOutcomes.Failed
                        resultStatus(i)=slreq.verification.ResultStatus.Fail;
                    else
                        resultStatus(i)=slreq.verification.ResultStatus.Unknown;
                    end

                    if~isnat(testResult.StopTime)


                        resultTimestamp(i)=datetime(testResult.StopTime,'TimeZone','Local');
                    end
                end
            end
        end















































        function[runSuccess,resultStatus,resultTimestamp,reason]=runTest(this,verificationItems)


            runSuccess=false(1,length(verificationItems));
            resultStatus=repmat(slreq.verification.ResultStatus.Unknown,1,length(verificationItems));


            resultTimestamp=repmat(datetime(now,'ConvertFrom','datenum','TimeZone','Local'),1,length(verificationItems));
            reason=repmat(struct('type','','message',''),1,length(verificationItems));

            if~slreq.verification.TestManagerResultProvider.hasSTMLicenseAndInstallation()
                reason.type='info';
                reason.message=getString(message('Slvnv:slreq:VerificationNoSimulinkTestLicenseOrProduct'));
                reason=repmat(reason,1,length(verificationItems));
                return;
            end

            continueTests=true;


            if isa(verificationItems,'slreq.data.Link')
                verificationItems=arrayfun(@(link)link.source,verificationItems);
            elseif~isa(verificationItems,'slreq.data.SourceItem')
                return;
            end

            testFiles=arrayfun(@(source)source.artifactUri,verificationItems,'UniformOutput',false);
            [uniqueTestFiles,firsts,indexes]=unique(testFiles);

            for thisfile=1:length(uniqueTestFiles)

                verifItemsForThisFile=verificationItems(indexes==thisfile);
                numVerifItemsForThisFile=length(verifItemsForThisFile);



                notificationData=struct('items',verifItemsForThisFile...
                ,'status',repmat(slreq.verification.ResultStatus.Running,1,numVerifItemsForThisFile));
                notify(this,'verificationStarted',...
                slreq.verification.VerificationChangeEvent('Verif.Start',notificationData));
                drawnow();

                testList=repmat(int32([0,0]),numVerifItemsForThisFile,1);
                thisFileReason=repmat(struct('type','','message',''),1,numVerifItemsForThisFile);
                thisFileRunSuccess=false(1,numVerifItemsForThisFile);
                thisFileResultStatus=repmat(slreq.verification.ResultStatus.Unknown,1,numVerifItemsForThisFile);
                thisFileResultTimestamp=repmat(datetime(now,'ConvertFrom','datenum','TimeZone','Local'),1,numVerifItemsForThisFile);

                for i=1:length(verifItemsForThisFile)
                    testFile=verifItemsForThisFile(i).artifactUri;
                    id=verifItemsForThisFile(i).id;

                    try

                        testId=stm.internal.getTestIdFromUUIDAndTestFile(id,testFile);
                    catch Mex
                        thisFileReason(i).type='info';
                        thisFileReason(i).message=getString(message('Slvnv:slreq:VerificationNoSimulinkTestLicenseOrProduct'));
                        continueTests=false;
                        continue;
                    end

                    testType=stm.internal.getTestType(testId);

                    switch testType
                    case 'testFile'
                        intTestType=2;
                    case 'testSuite'
                        intTestType=1;
                    case 'iteration'
                        intTestType=3;
                    case 'assessments'
                        intTestType=4;
                    otherwise
                        intTestType=0;
                    end

                    testList(i,:)=int32([testId,intTestType]);
                end
                if~continueTests


                    reason(indexes==thisfile)=thisFileReason;
                    continue;
                end
                resultID=0;
                try



                    testList((testList(:,1)==0),:)=[];
                    if~isempty(testList)
                        resultID=stm.internal.executeTests(testList);
                    end
                catch err
                    thisFileReason(i).type='info';
                    thisFileReason(i).message=getString(message('Slvnv:slreq:UnknownError'));
                    reason(indexes==thisfile)=thisFileReason;
                end
                if resultID>0
                    thisFileRunSuccess=true(1,numVerifItemsForThisFile);
                    [thisFileResultStatus,thisFileResultTimestamp]=this.getResult(verifItemsForThisFile);
                end



                runSuccess(indexes==thisfile)=thisFileRunSuccess;
                resultStatus(indexes==thisfile)=thisFileResultStatus;
                resultTimestamp(indexes==thisfile)=thisFileResultTimestamp;


                notificationData=struct('items',verifItemsForThisFile...
                ,'status',thisFileResultStatus);
                notify(this,'verificationFinished',...
                slreq.verification.VerificationChangeEvent('Verif.End',notificationData));
                drawnow();
            end
        end

        function navigate(~,link)

            if~slreq.verification.TestManagerResultProvider.hasSTMLicenseAndInstallation()
                return;
            end

            linkSource=link.source;


            testFile=linkSource.artifactUri;
            id=linkSource.id;

            resultId=stm.internal.getTestResultIdFromUUIDAndTestFile(id,testFile);
            if resultId>0
                stm.internal.util.highlightTestResult(resultId);
            end
        end

        function sourceTimestamp=getSourceTimestamp(this,link)
            if isa(link,'slreq.data.Link')
                sourceTimestamp=link.modifiedOn;
                sourceItem=link.source.artifactUri;
            else
                sourceTimestamp=datetime(now,'ConvertFrom','datenum','TimeZone','Local');
                sourceItem=link.artifactUri;
            end

            sourceFileInfo=dir(sourceItem);
            if~isempty(sourceFileInfo)
                sourceTimestamp=datetime(sourceFileInfo.datenum,'ConvertFrom','datenum','TimeZone','Local');
            end
        end

        function id=getIdentifier(this)
            id='Simulink Test Manager';
        end
    end
    methods(Static)
        function tf=hasSTMLicenseAndInstallation()
            tf=license('test','Simulink_Test')&&...
            dig.isProductInstalled('Simulink Test');
        end
    end
end
