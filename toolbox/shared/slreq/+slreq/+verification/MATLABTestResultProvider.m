classdef MATLABTestResultProvider<slreq.verification.ResultProviderIntf




    properties
        results containers.Map
        resultTimestamps containers.Map
    end

    properties(Constant,Hidden)
        CACHE_KEY_SEPARATOR="::";
    end

    events
verificationStarted
verificationFinished
    end

    methods
        function this=MATLABTestResultProvider()
            this.results=containers.Map('keyType','char','valueType','any');
            this.resultTimestamps=containers.Map('keyType','char','valueType','any');
        end

        function scanProject(~,~)
        end

        function resetCachedResults(this)

            this.results.remove(this.results.keys);
            this.resultTimestamps.remove(this.resultTimestamps.keys);
        end

        function[resultStatus,resultTimestamp,reason]=getResult(this,verificationItems)



            import matlab.unittest.TestSuite
            import matlab.unittest.TestRunner
            import matlab.unittest.selectors.HasProcedureName


            resultStatus=repmat(slreq.verification.ResultStatus.Unknown,1,length(verificationItems));
            if isa(verificationItems,'slreq.data.Link')
                resultTimestamp=arrayfun(@(link)link.modifiedOn,verificationItems);
            else
                resultTimestamp=repmat(datetime('now','TimeZone','Local')...
                ,1,length(verificationItems));
            end
            reason=repmat(struct('type','','message',''),1,length(verificationItems));


            if isa(verificationItems,'slreq.data.Link')
                verificationItems=arrayfun(@(link)link.source,verificationItems);
            elseif~isa(verificationItems,'slreq.data.SourceItem')

            end

            testFiles=arrayfun(@(source)source.artifactUri,verificationItems,'UniformOutput',false);
            [uniqueTestFiles,~,indexes]=unique(testFiles);

            for thisfile=1:length(uniqueTestFiles)

                verifItemsForThisFile=verificationItems(indexes==thisfile);
                numVerifItemsForThisFile=length(verifItemsForThisFile);

                thisFileReason=repmat(struct('type','','message',''),1,numVerifItemsForThisFile);

                thisFileResultStatus=repmat(slreq.verification.ResultStatus.Unknown,1,numVerifItemsForThisFile);
                thisFileResultTimestamp=repmat(datetime('now','TimeZone','Local'),1,numVerifItemsForThisFile);



                thisTestFilepath=uniqueTestFiles{thisfile};

                for i=1:length(verifItemsForThisFile)
                    [procedureName,isFileLevel]=this.getProcedureNameFromLinkSource(verifItemsForThisFile(i));
                    if~isempty(procedureName)
                        if~isFileLevel

                            resultCacheKey=this.getResultCacheKey(thisTestFilepath,procedureName);

                            if this.results.isKey(resultCacheKey)
                                thisFileResultStatus(i)=this.results(resultCacheKey);
                                thisFileResultTimestamp(i)=this.resultTimestamps(resultCacheKey);
                            end
                        else

                            [fileResult,fileResultTimestamp]=this.consolidateTestResultsForFile(thisTestFilepath);
                            thisFileResultStatus(i)=fileResult;
                            thisFileResultTimestamp(i)=fileResultTimestamp;
                        end
                    end
                end



                resultStatus(indexes==thisfile)=thisFileResultStatus;
                resultTimestamp(indexes==thisfile)=thisFileResultTimestamp;
                reason(indexes==thisfile)=thisFileReason;
            end
        end

        function[runSuccess,resultStatus,resultTimestamp,reason]=runTest(this,verificationItems)

            import matlab.unittest.TestSuite
            import matlab.unittest.TestRunner
            import matlab.unittest.selectors.HasProcedureName

            runSuccess=false(1,length(verificationItems));
            resultStatus=repmat(slreq.verification.ResultStatus.Unknown,1,length(verificationItems));


            resultTimestamp=repmat(datetime('now','TimeZone','Local'),1,length(verificationItems));
            reason=repmat(struct('type','','message',''),1,length(verificationItems));


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



                thisTestFilepath=uniqueTestFiles{thisfile};
                testSuite=TestSuite.fromFile(thisTestFilepath);

                for i=1:length(verifItemsForThisFile)
                    [procedureName,isFileLevel]=this.getProcedureNameFromLinkSource(verifItemsForThisFile(i));

                    if isFileLevel



                        testList=[testList;testSuite];%#ok<AGROW> 
                    else







                        thisTestProcedureSuite=testSuite.selectIf(HasProcedureName(procedureName));

                        testList=[testList;thisTestProcedureSuite];%#ok<AGROW> 
                    end
                end

                try

                    runner=TestRunner.withDefaultPlugins;
                    thisTestFileResults=runner.run(testList);


                    this.updateCacheWithMUnitOutcomes(thisTestFilepath,testList,thisTestFileResults);

                    thisFileRunSuccess=true(1,numVerifItemsForThisFile);
                    [thisFileResultStatus,thisFileResultTimestamp]=this.getResult(verifItemsForThisFile);
                catch Mex


                    thisFileReason=repmat(struct('type','error','message',Mex.message),1,numVerifItemsForThisFile);
                end



                runSuccess(indexes==thisfile)=thisFileRunSuccess;
                resultStatus(indexes==thisfile)=thisFileResultStatus;
                resultTimestamp(indexes==thisfile)=thisFileResultTimestamp;
                reason(indexes==thisfile)=thisFileReason;


                notificationData=struct('items',verifItemsForThisFile...
                ,'status',thisFileResultStatus);
                notify(this,'verificationFinished',...
                slreq.verification.VerificationChangeEvent('Verif.End',notificationData));
                drawnow();
            end
        end

        function navigate(~,~)


            uiwait(warndlg(message("Slvnv:slreq_verification:MUnitResultNavigationUndefinedMsg").getString(),...
            message("Slvnv:slreq_verification:MUnitResultNavigationUndefinedTitle").getString()));
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
            id='MATLAB Test';
        end
    end

    methods(Access=private)
        function[procedureName,isFileLevel]=getProcedureNameFromLinkSource(~,linkSource)

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

        function consolidatedResults=consolidateTestResultOutcomes(~,testList,resultArray)








            assert(numel(testList)==numel(resultArray));



            [uniqueTests,~,testIndices]=unique(arrayfun(@(t)string(t.ProcedureName),testList));

            consolidatedResults=struct('Name',"",'Result',slreq.verification.ResultStatus.empty);
            for i=1:numel(uniqueTests)
                allResultsForThisTest=resultArray(testIndices==i);

                convertToLogicalArray=@(cellArray)cellfun(@(val)val,cellArray);

                if all(convertToLogicalArray({allResultsForThisTest.Passed}))
                    finalOutcome=slreq.verification.ResultStatus.Pass;
                elseif any(convertToLogicalArray({allResultsForThisTest.Failed}))
                    finalOutcome=slreq.verification.ResultStatus.Fail;
                else
                    finalOutcome=slreq.verification.ResultStatus.Unknown;
                end

                consolidatedResults(i).Name=uniqueTests(i);
                consolidatedResults(i).Result=finalOutcome;
            end
        end

        function updateCacheWithMUnitOutcomes(this,testFilepath,testList,munitResultArray)

            consolidatedTestResults=this.consolidateTestResultOutcomes(testList,munitResultArray);
            for i=1:numel(consolidatedTestResults)
                thisResultStruct=consolidatedTestResults(i);
                cacheKey=this.getResultCacheKey(testFilepath,thisResultStruct.Name);

                this.results(cacheKey)=thisResultStruct.Result;
                this.resultTimestamps(cacheKey)=datetime('now','TimeZone','local');
            end
        end

        function[fileResult,fileResultTimestamp]=consolidateTestResultsForFile(this,thisTestFilepath)
            fileResult=slreq.verification.ResultStatus.Fail;
            fileResultTimestamp=datetime('now','TimeZone','local');

            testSuites=matlab.unittest.TestSuite.fromFile(thisTestFilepath);
            procedureNames=unique(arrayfun(@(x)x.ProcedureName,testSuites,'UniformOutput',false));
            if~isempty(procedureNames)
                [procedureResults,procedureTimestamps]=cellfun(@(p)getResultForProcedure(p),procedureNames);

                [fileResult,fileResultTimestamp]=consolidateStatuses(procedureResults,procedureTimestamps);
            end


            function[result,timestamp]=getResultForProcedure(procedureName)
                result=slreq.verification.ResultStatus.Unknown;
                timestamp=NaT;
                cacheKey=this.getResultCacheKey(thisTestFilepath,procedureName);
                if this.results.isKey(cacheKey)
                    result=this.results(cacheKey);
                    timestamp=this.resultTimestamps(cacheKey);
                end
            end

            function[finalResult,finalTimestamp]=consolidateStatuses(statusArray,timestampArray)











                import slreq.verification.ResultStatus;

                passOnes=statusArray==ResultStatus.Pass;
                failOnes=statusArray==ResultStatus.Fail;
                unknownOnes=statusArray==ResultStatus.Unknown;

                if all(passOnes)||(any(passOnes)&&all(passOnes|unknownOnes))
                    finalResult=ResultStatus.Pass;
                elseif any(failOnes)
                    finalResult=ResultStatus.Fail;
                else
                    finalResult=ResultStatus.Unknown;
                end



                finalTimestamp=max(timestampArray);

            end
        end

        function cacheKey=getResultCacheKey(this,testFile,procedureName)
            cacheKey=testFile+this.CACHE_KEY_SEPARATOR+procedureName;
        end
    end
end


