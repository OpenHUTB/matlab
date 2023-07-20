classdef TestManagerMUnitResultProvider<slreq.verification.ResultProviderIntf







    events
verificationStarted
verificationFinished
    end

    methods
        function this=TestManagerMUnitResultProvider()
        end

        function scanProject(~,~)
        end

        function[resultStatus,resultTimestamp,reason]=getResult(this,dataLinksOrSourceItems)


            resultStatus=repmat(slreq.verification.ResultStatus.Unknown,1,length(dataLinksOrSourceItems));
            if isa(dataLinksOrSourceItems,'slreq.data.Link')
                resultTimestamp=arrayfun(@(link)link.modifiedOn,dataLinksOrSourceItems);
            else
                resultTimestamp=repmat(datetime('now','TimeZone','Local')...
                ,1,length(dataLinksOrSourceItems));
            end

            reason=repmat(struct('type','','message',''),1,length(dataLinksOrSourceItems));

            if~slreq.verification.TestManagerResultProvider.hasSTMLicenseAndInstallation()
                iReason.type='info';
                iReason.message=getString(message('Slvnv:slreq:VerificationNoSimulinkTestLicenseOrProduct'));
                reason=repmat(iReason,1,length(dataLinksOrSourceItems));
                return;
            end

            for i=1:length(dataLinksOrSourceItems)
                if isa(dataLinksOrSourceItems(i),'slreq.data.Link')

                    linkSource=dataLinksOrSourceItems(i).source;
                else
                    linkSource=dataLinksOrSourceItems(i);
                end
                testFile=linkSource.artifactUri;

                procedureName=this.getProcedureNameFromLinkSource(linkSource);





                try

                    resultIds=stm.internal.getTestResultIdsFromRequirementMetaData(procedureName,testFile);
                catch
                    reason(i).type='info';
                    reason(i).message=getString(message('Slvnv:slreq:VerificationNoSimulinkTestLicenseOrProduct'));
                    reason=repmat(reason(i),1,length(dataLinksOrSourceItems));
                    return;
                end




                numResultIds=numel(resultIds);
                allOutcomes=sltest.testmanager.TestResultOutcomes.empty([0,numResultIds]);
                allStopTimes=datetime(NaT,'TimeZone','Local');
                for j=1:numResultIds
                    iResultID=resultIds(j);
                    if iResultID>0
                        testResult=sltest.testmanager.TestResult.getResultFromID(iResultID);
                        allOutcomes(j)=testResult.Outcome;
                        allStopTimes(j)=testResult.StopTime;
                    else

                        allOutcomes(j)=sltest.testmanager.TestResultOutcomes.Untested;
                    end
                end

                finalOutcome=this.consolidateTestResultOutcomes(allOutcomes);



                finalStopTime=max(allStopTimes);
                resultStatus(i)=this.convertOutcomeToSlreqStatus(finalOutcome);
                if~isempty(finalStopTime)
                    resultTimestamp(i)=finalStopTime;
                end
            end
        end

        function[runSuccess,resultStatus,resultTimestamp,reason]=runTest(this,verificationItems)


            runSuccess=false(1,length(verificationItems));
            resultStatus=repmat(slreq.verification.ResultStatus.Unknown,1,length(verificationItems));


            resultTimestamp=repmat(datetime('now','TimeZone','Local'),1,length(verificationItems));
            reason=repmat(struct('type','','message',''),1,length(verificationItems));

            if~slreq.verification.TestManagerResultProvider.hasSTMLicenseAndInstallation()
                reason.type='info';
                reason.message=getString(message('Slvnv:slreq:VerificationNoSimulinkTestLicenseOrProduct'));
                reason=repmat(reason,1,length(verificationItems));
                return;
            end


            if isa(verificationItems,'slreq.data.Link')
                verificationItems=arrayfun(@(link)link.source,verificationItems);
            elseif~isa(verificationItems,'slreq.data.SourceItem')
                return;
            end

            testFiles=arrayfun(@(source)source.artifactUri,verificationItems,'UniformOutput',false);
            [uniqueTestFiles,~,indexes]=unique(testFiles);

            for thisfile=1:length(uniqueTestFiles)

                verifItemsForThisFile=verificationItems(indexes==thisfile);
                numVerifItemsForThisFile=length(verifItemsForThisFile);
                continueTests=true;



                notificationData=struct('items',verifItemsForThisFile...
                ,'status',repmat(slreq.verification.ResultStatus.Running,1,numVerifItemsForThisFile));
                notify(this,'verificationStarted',...
                slreq.verification.VerificationChangeEvent('Verif.Start',notificationData));
                drawnow();

                testList=[];
                thisFileReason=repmat(struct('type','','message',''),1,numVerifItemsForThisFile);
                thisFileRunSuccess=false(1,numVerifItemsForThisFile);
                thisFileResultStatus=repmat(slreq.verification.ResultStatus.Unknown,1,numVerifItemsForThisFile);
                thisFileResultTimestamp=repmat(datetime('now','TimeZone','Local'),1,numVerifItemsForThisFile);

                for i=1:length(verifItemsForThisFile)
                    testFile=verifItemsForThisFile(i).artifactUri;
                    procedureName=this.getProcedureNameFromLinkSource(verifItemsForThisFile(i));

                    try

                        testIds=sltest.internal.getTestIdsFromTestNameAndTestFile(procedureName,testFile);
                    catch
                        thisFileReason(i).type='info';
                        thisFileReason(i).message=getString(message('Slvnv:slreq:VerificationNoSimulinkTestLicenseOrProduct'));
                        continueTests=false;
                        continue;
                    end



                    iTestList=repmat(int32([0,0]),numel(testIds),1);
                    for j=1:length(testIds)

                        testType=stm.internal.getTestType(testIds(j));

                        if strcmp(testType,'testFile')
                            intTestType=2;
                        else
                            intTestType=0;
                        end

                        iTestList(j,:)=int32([testIds(j),intTestType]);
                    end

                    testList=[testList;iTestList];%#ok<AGROW>
                end
                if~continueTests
                    reason(indexes==thisfile)=thisFileReason;
                else
                    resultID=0;
                    try



                        testList((testList(:,1)==0),:)=[];%#ok<AGROW>
                        if~isempty(testList)
                            resultID=stm.internal.executeTests(testList);
                        end
                    catch
                        thisFileReason(i).type='info';
                        thisFileReason(i).message=getString(message('Slvnv:slreq:UnknownError'));
                        reason(indexes==thisfile)=thisFileReason;
                    end
                    if resultID>0
                        thisFileRunSuccess=true(1,numVerifItemsForThisFile);
                        [thisFileResultStatus,thisFileResultTimestamp]=this.getResult(verifItemsForThisFile);
                    end
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

        function navigate(this,dataLink)

            if~slreq.verification.TestManagerMUnitResultProvider.hasSTMLicenseAndInstallation()
                return;
            end

            linkSource=dataLink.source;


            testFile=linkSource.artifactUri;
            procedureName=this.getProcedureNameFromLinkSource(linkSource);

            resultId=stm.internal.getTestResultIdFromUUIDAndTestFile(procedureName,testFile);
            if resultId>0
                stm.internal.util.highlightTestResult(resultId);
            end
        end

        function sourceTimestamp=getSourceTimestamp(~,dataLinkOrSourceItem)
            if isa(dataLinkOrSourceItem,'slreq.data.Link')
                sourceTimestamp=dataLinkOrSourceItem.modifiedOn;
                sourceItem=dataLinkOrSourceItem.source.artifactUri;
            else
                sourceTimestamp=datetime('now','TimeZone','Local');
                sourceItem=dataLinkOrSourceItem.artifactUri;
            end

            sourceFileInfo=dir(sourceItem);
            if~isempty(sourceFileInfo)
                sourceTimestamp=datetime(sourceFileInfo.datenum,'ConvertFrom','datenum','TimeZone','Local');
            end
        end

        function id=getIdentifier(~)
            id='Simulink Test Manager MATLAB Unit';
        end
    end

    methods(Static)
        function tf=hasSTMLicenseAndInstallation()
            tf=license('test','Simulink_Test')&&...
            dig.isProductInstalled('Simulink Test');
        end
    end

    methods(Access=private)
        function procedureName=getProcedureNameFromLinkSource(~,linkSource)

            procedureName='';

            startPos=linkSource.startPos;
            endPos=linkSource.endPos;
            testFile=linkSource.artifactUri;
            [procedures,isFileLevel]=rmiml.RmiMUnitData.getTestNamesUnderRange(testFile,[startPos,endPos]);
            if~isempty(procedures)
                procedureName=procedures{1};
            else
                if isFileLevel
                    procedureName=rmiml.RmiMUnitData.getTestClassName(testFile);
                end
            end
        end

        function finalOutcome=consolidateTestResultOutcomes(~,allOutcomes)




            if all(allOutcomes==sltest.testmanager.TestResultOutcomes.Passed)
                finalOutcome=sltest.testmanager.TestResultOutcomes.Passed;
            elseif any(allOutcomes==sltest.testmanager.TestResultOutcomes.Failed)
                finalOutcome=sltest.testmanager.TestResultOutcomes.Failed;
            else
                finalOutcome=sltest.testmanager.TestResultOutcomes.Untested;
            end
        end

        function status=convertOutcomeToSlreqStatus(~,outcome)
            if isempty(outcome)
                status=slreq.verification.ResultStatus.Unknown;
                return;
            end

            switch outcome
            case sltest.testmanager.TestResultOutcomes.Passed
                status=slreq.verification.ResultStatus.Pass;
            case sltest.testmanager.TestResultOutcomes.Failed
                status=slreq.verification.ResultStatus.Fail;
            otherwise
                status=slreq.verification.ResultStatus.Unknown;
            end
        end
    end
end


