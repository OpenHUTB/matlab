classdef SldvResultProvider<slreq.verification.ResultProviderIntf




    properties
        results;
        resultFiles;
        reportFiles;
    end

    events
verificationStarted
verificationFinished
    end

    properties(Constant)
        VALID_STATUSES={'Valid','Valid under approximation'};
    end

    methods
        function this=SldvResultProvider()
            this.results=containers.Map('keyType','char','valueType','any');
            this.resultFiles=containers.Map('keyType','char','valueType','char');
            this.reportFiles=containers.Map('keyType','char','valueType','char');
        end

        function scanProject(this,project)

            files=project.Files;
            for i=1:numel(files)
                [~,~,ext]=fileparts(files(i).Path);
                if strcmp(ext,'.mat')
                    this.addResultFile(files(i).Path);
                end
            end

        end

        function resetCachedResults(this)

            this.results.remove(this.results.keys);
            this.resultFiles.remove(this.resultFiles.keys);
            this.reportFiles.remove(this.reportFiles.keys);
        end

        function[result,timestamp,reason]=getResult(this,verificationItems)

            result=repmat(slreq.verification.ResultStatus.Unknown,1,length(verificationItems));
            timestamp=repmat(datetime(now,'ConvertFrom','datenum','TimeZone','Local'),1,length(verificationItems));
            reason=repmat(struct('type','','message',''),1,length(verificationItems));

            if~slreq.verification.SldvResultProvider.hasSLDVLicenseAndInstallation()
                reason.type='info';
                reason.message=getString(message('Slvnv:slreq:VerificationNoSLDVLicenseOrProduct'));
                reason=repmat(reason,1,length(verificationItems));
                return;
            end

            for i=1:length(verificationItems)


                link=verificationItems(i);
                [sid,modelFile]=this.getSIDAndModelFilefromLink(link);

                if~this.results.isKey(sid)||this.isResultStale(link)


                    if dig.isProductInstalled('Simulink')&&bdIsLoaded(modelFile)
                        matFile=[];
                        try

                            matFile=this.getLatestSLDVMATFile(modelFile);
                        catch Mex
                            reason(i).type='info';
                            reason(i).message=getString(message('Slvnv:slreq:VerificationNoSLDVLicenseOrProduct'));
                            continue;
                        end
                        if~isempty(matFile)



                            this.addResultFile(matFile);
                        end
                    end
                end


                if this.results.isKey(sid)
                    resultFile=dir(this.resultFiles(sid));
                    if~isempty(resultFile)

                        timestamp(i)=datetime(resultFile.datenum,'ConvertFrom','datenum','TimeZone','Local');
                        result(i)=this.results(sid);
                    else
                        this.invalidateResult(sid);
                        reason(i).type='info';
                        reason(i).message=getString(message('Slvnv:slreq:VerificationNoSLDVMATFile'));
                    end
                end
            end
        end

        function[runSuccess,resultStatus,resultTimestamp,reason]=runTest(this,verificationItems)

            runSuccess=false(1,length(verificationItems));
            resultStatus=repmat(slreq.verification.ResultStatus.Unknown,1,length(verificationItems));


            resultTimestamp=repmat(datetime(now,'ConvertFrom','datenum','TimeZone','Local'),1,length(verificationItems));
            reason=repmat(struct('type','','message',''),1,length(verificationItems));

            if~slreq.verification.SldvResultProvider.hasSLDVLicenseAndInstallation()
                reason.type='info';
                reason.message=getString(message('Slvnv:slreq:VerificationNoSLDVLicenseOrProduct'));
                reason=repmat(reason,1,length(verificationItems));
                return;
            end

            [~,modelSources,sourceObjs]=arrayfun(@this.getSIDAndModelFilefromLink,verificationItems,'UniformOutput',false);
            [uniqueModelsToRun,~,indexes]=unique(modelSources);

            for thisModel=1:length(uniqueModelsToRun)



                thisModelSourceObjs=cellfun(@(x)x,sourceObjs(indexes==thisModel));
                numThisModelSourceObjs=length(thisModelSourceObjs);
                notificationData=struct('items',thisModelSourceObjs...
                ,'status',repmat(slreq.verification.ResultStatus.Running,1,numThisModelSourceObjs));
                notify(this,'verificationStarted',...
                slreq.verification.VerificationChangeEvent('Verif.Start',notificationData));

                thisModelName=uniqueModelsToRun{thisModel};

                if dig.isProductInstalled('Simulink')&&bdIsLoaded(thisModelName)

                    modelOpts=sldvoptions(thisModelName);
                    opts=modelOpts.deepCopy();
                    opts.Mode='PropertyProving';
                    opts.RebuildModelRepresentation='Always';

                    [~,status,files]=evalc('sldvrun(thisModelName, opts)');




                    if status==1
                        runSuccess(indexes==thisModel)=true;
                        this.addResultFile(files.DataFile);

                        linksForThisModel=thisModelSourceObjs;
                        arrayfun(@this.removeReportFile,linksForThisModel);
                    end

                    [thisResultStatus,thisResultTimeStamp]=this.getResult(thisModelSourceObjs);
                    resultStatus(indexes==thisModel)=thisResultStatus;
                    resultTimestamp(indexes==thisModel)=thisResultTimeStamp;

                end

                notificationData=struct('items',thisModelSourceObjs...
                ,'status',thisResultStatus);
                notify(this,'verificationFinished',...
                slreq.verification.VerificationChangeEvent('Verif.End',notificationData));
            end
        end

        function navigate(this,link)


            if~slreq.verification.SldvResultProvider.hasSLDVLicenseAndInstallation()
                return;
            end

            [sid,modelFile]=this.getSIDAndModelFilefromLink(link);

            if~dig.isProductInstalled('Simulink')||~bdIsLoaded(modelFile)
                return;
            end
            sldvDataFile=this.getLatestSLDVMATFile(modelFile);



            if this.reportFiles.isKey(sid)&&~this.isReportFileStale(sldvDataFile,this.reportFiles(sid))
                web(this.reportFiles(sid));
            else
                if~isempty(sldvDataFile)

                    [status,reportFilePath]=sldvreport(sldvDataFile);

                    if status
                        this.addReportFile(link,reportFilePath);
                    end
                end
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
            id='Simulink Design Verifier';
        end
    end

    methods(Access=private)

        function tf=isResultStale(this,link)
            tf=true;
            sid=this.getSIDAndModelFilefromLink(link);
            resultFile=dir(this.resultFiles(sid));
            if~isempty(resultFile)

                resultTimestamp=datetime(resultFile.datenum,'ConvertFrom','datenum','TimeZone','Local');
                tf=(resultTimestamp<=this.getSourceTimestamp(link));
            end
        end

        function matFile=getLatestSLDVMATFile(this,modelname)

            matFile=sldvresultfiles(modelname,'PropertyProving','latest');
        end

        function addResultFile(this,filePath)

            resultFile=load(filePath);


            if~isfield(resultFile,'sldvData')
                return;
            end


            sldvData=resultFile.sldvData;
            if~strcmp(sldvData.AnalysisInformation.Options.Mode,'PropertyProving')
                return;
            end

            subsystemSIDs=struct('sid',{},'result',{});


            for n=1:length(sldvData.Objectives)
                modelObjIndex=sldvData.Objectives(n).modelObjectIdx;
                sid=sldvData.ModelObjects(modelObjIndex).designSid;


                if ismember(sldvData.Objectives(n).status,this.VALID_STATUSES)
                    objectiveResult=slreq.verification.ResultStatus.Pass;
                else
                    objectiveResult=slreq.verification.ResultStatus.Fail;
                end

                numColons=strfind(sid,':');
                if length(numColons)>1



















                    subsystemSIDs(end+1)=struct('sid',sid(1:(numColons(2)-1)),...
                    'result',objectiveResult);%#ok<AGROW>

                end
                this.resultFiles(sid)=filePath;
                this.results(sid)=objectiveResult;
            end

            if~isempty(subsystemSIDs)

















                [~,indexes,reps]=unique({subsystemSIDs.sid},'stable');
                counts=arrayfun(@(x)nnz(reps==x),1:numel(indexes));
                toShow=(counts==1);
                subSystemSIDsToAdd=subsystemSIDs(indexes(toShow));

                for i=1:nnz(toShow)
                    this.resultFiles(subSystemSIDsToAdd(i).sid)=filePath;
                    this.results(subSystemSIDsToAdd(i).sid)=subSystemSIDsToAdd(i).result;
                end
            end


            clear resultFile;
        end

        function invalidateResult(this,sid)
            this.results.remove(sid);
            this.resultFiles.remove(sid);
            if this.reportFiles.isKey(sid)
                this.reportFiles.remove(sid);
            end
        end

        function addReportFile(this,link,filepath)
            sid=this.getSIDAndModelFilefromLink(link);
            this.reportFiles(sid)=filepath;
        end

        function removeReportFile(this,link)
            sid=this.getSIDAndModelFilefromLink(link);
            if this.reportFiles.isKey(sid)
                this.reportFiles.remove(sid);
            end
        end

        function[sid,modelFile,linkSource]=getSIDAndModelFilefromLink(~,link)


            if isa(link,'slreq.data.Link')

                linkSource=link.source;
            else
                linkSource=link;
            end
            [~,modelFile,~]=fileparts(linkSource.artifactUri);
            id=linkSource.id;
            sid=[modelFile,id];
        end

        function tf=isReportFileStale(~,sldvDataFile,reportFile)

            tf=false;
            sldvDataFileMeta=dir(sldvDataFile);
            reportFileMeta=dir(reportFile);
            if~isempty(sldvDataFileMeta)&&~isempty(reportFileMeta)
                tf=reportFileMeta.datenum<sldvDataFileMeta.datenum;
            end
        end
    end
    methods(Static)
        function tf=hasSLDVLicenseAndInstallation()
            tf=license('test','Simulink_Design_Verifier')&&...
            dig.isProductInstalled('Simulink Design Verifier');
        end
    end
end

