classdef ExternalResultProvider<slreq.verification.ResultProviderIntf




    properties
domain
registration
    end

    properties(Constant,Hidden)


        FIELD_STATUS string="status";
        FIELD_TIMESTAMP string="timestamp";
        FIELD_ERRORS string="error";
        FIELD_INFO string="info";

        REASON_INFO string="info";
        REASON_ERROR string="error";
    end

    events
verificationStarted
verificationFinished
    end

    methods
        function this=ExternalResultProvider(d)
            this.domain=d;
            this.registration=rmi.linktype_mgr('resolveByRegName',this.domain);
        end

        function scanProject(this,project)
        end

        function[resultStatus,resultTimestamp,reason]=getResult(this,dataLinks)
            numLinks=length(dataLinks);
            resultStatus=repmat(slreq.verification.ResultStatus.Unknown,1,numLinks);
            resultTimestamp=repmat(datetime(now,'ConvertFrom','datenum','TimeZone','Local'),1,numLinks);
            reason=repmat(struct('type','','message',''),1,numLinks);




            [uniqueDomains,linkDomainIndexes]=this.getUniqueDomains(dataLinks);

            for i=1:length(uniqueDomains)
                iDomain=uniqueDomains(i);
                linkTypeObj=this.getDomainTypeObj(iDomain);
                if~isempty(linkTypeObj)&&~isempty(linkTypeObj.GetResultFcn)
                    verifLinks=arrayfun(@(x)slreq.utils.dataToApiObject(x),dataLinks(linkDomainIndexes==i));
                    try
                        statusStruct=linkTypeObj.GetResultFcn(verifLinks);
                        [iResult,iTimestamp,iReason]=this.dealStatusOutput(statusStruct);
                    catch mEx
                        [iResult,iTimestamp,iReason]=this.reportError('GetResultFcn',iDomain,mEx.message);
                    end



                    resultStatus(linkDomainIndexes==i)=iResult;
                    resultTimestamp(linkDomainIndexes==i)=iTimestamp;
                    reason(linkDomainIndexes==i)=iReason;
                end
            end
        end

        function[runSuccess,resultStatus,resultTimestamp,reason]=runTest(this,dataLinks)
            numLinks=length(dataLinks);
            runSuccess=false(1,numLinks);
            resultStatus=repmat(slreq.verification.ResultStatus.Unknown,1,numLinks);
            resultTimestamp=repmat(datetime(now,'ConvertFrom','datenum','TimeZone','Local'),1,numLinks);
            reason=repmat(struct('type','','message',''),1,numLinks);




            [uniqueDomains,linkDomainIndexes]=this.getUniqueDomains(dataLinks);

            for i=1:length(uniqueDomains)
                iDomain=uniqueDomains(i);
                linkTypeObj=this.getDomainTypeObj(iDomain);
                if~isempty(linkTypeObj)&&~isempty(linkTypeObj.RunTestFcn)
                    verifLinks=arrayfun(@(x)slreq.utils.dataToApiObject(x),dataLinks(linkDomainIndexes==i));
                    [iRunSuccess,iResult,iTimestamp,iReason]=linkTypeObj.RunTestFcn(verifLinks);



                    runSuccess(linkDomainIndexes==i)=iRunSuccess;
                    resultStatus(linkDomainIndexes==i)=iResult;
                    resultTimestamp(linkDomainIndexes==i)=iTimestamp;
                    reason(linkDomainIndexes==i)=iReason;
                end
            end
        end

        function navigate(this,dataLink)
            linkTypeObj=this.getDomainTypeObj(dataLink);
            if~isempty(linkTypeObj)&&~isempty(linkTypeObj.ResultNavigateFcn)
                linkTypeObj.ResultNavigateFcn(slreq.utils.dataToApiObject(dataLink));
            end
        end

        function sourceTimestamp=getSourceTimestamp(this,dataLink)









            sourceTimestamp=dataLink.modifiedOn;


            linkTypeObj=this.getDomainTypeObj(dataLink);
            if~isempty(linkTypeObj)&&~isempty(linkTypeObj.GetSourceTimestampFcn)
                sourceTimestamp=linkTypeObj.GetSourceTimestampFcn(slreq.utils.dataToApiObject(dataLink));
            end
        end

        function id=getIdentifier(this)
            id=this.domain;
        end
    end
    methods

        function[uniqueDomains,linkDomainIndexes]=getUniqueDomains(~,dataLinks)
            destinationLinkTypes=arrayfun(@(l)string(getDomain(l)),dataLinks);
            [uniqueDomains,~,linkDomainIndexes]=unique(destinationLinkTypes,'stable');

            function domain=getDomain(dataLink)

                domain="";
                destination=dataLink.dest;
                if~isempty(destination)
                    domain=destination.domain;
                end

            end
        end

        function domainTypeObj=getDomainTypeObj(~,domain)


            domainTypeObj=rmi.linktype_mgr('resolveByRegName',domain);
        end

        function[status,timestamp,reason]=dealStatusOutput(this,statusStruct)





            status=slreq.verification.ResultStatus.Unknown;
            timestamp=datetime(NaT,'TimeZone','Local');
            reason=struct('type',this.REASON_INFO,'message','');



            if~isstruct(statusStruct)
                error(message('Slvnv:slreq:ExtVerifOutputNotStruct'));
            end
            if~isfield(statusStruct,this.FIELD_STATUS)

                error(message('Slvnv:slreq:ExtVerifMissingFieldInOutput',this.FIELD_STATUS));
            end


            if isa(statusStruct.status,'slreq.verification.Status')

                status=statusStruct.status.getInternalStatus();
            else
                error(message('Slvnv:slreq:ExtVerifMissingFieldInOutput',this.FIELD_STATUS));
            end


            if isfield(statusStruct,this.FIELD_TIMESTAMP)
                if isa(statusStruct.timestamp,'datetime')
                    timestamp=statusStruct.timestamp;




                    if isempty(timestamp.TimeZone)
                        timestamp.TimeZone='local';
                    end
                else
                    error(message('Slvnv:slreq:ExtVerifIncorrectTimestampType'));
                end
            end


            if isfield(statusStruct,this.FIELD_INFO)&&~isempty(statusStruct.(this.FIELD_INFO))
                if ischar(statusStruct.(this.FIELD_INFO))||isstring(statusStruct.(this.FIELD_INFO))
                    reason.type=this.REASON_INFO;
                    reason.message=statusStruct.(this.FIELD_INFO);
                else
                    error(message('Slvnv:slreq:ExtVerifIncorrectCharStringType',this.FIELD_INFO));
                end
            end



            if isfield(statusStruct,this.FIELD_ERRORS)&&~isempty(statusStruct.(this.FIELD_ERRORS))
                if ischar(statusStruct.(this.FIELD_ERRORS))||isstring(statusStruct.(this.FIELD_ERRORS))
                    reason.type=this.REASON_ERROR;
                    reason.message=statusStruct.(this.FIELD_ERRORS);
                else
                    error(message('Slvnv:slreq:ExtVerifIncorrectCharStringType',this.FIELD_ERRORS));
                end
            end
        end

        function[status,timestamp,reason]=reportError(this,method,domain,errMessage)

            status=slreq.verification.ResultStatus.Unknown;
            timestamp=datetime(NaT,'TimeZone','Local');
            reason.type=this.REASON_ERROR;
            reason.message=message('Slvnv:slreq:ExtVerifCustomVerificationMethodError',method,domain,errMessage).getString();
        end
    end
end

