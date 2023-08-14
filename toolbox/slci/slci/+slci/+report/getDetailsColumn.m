


function detailsMessage=getDetailsColumn(Obj,reportConfig)


    status=Obj.getTraceStatus();
    substatus=Obj.getTraceSubstatus();

    reasonMessage=reportConfig.getTraceabilityMessage(substatus);
    if~isempty(reasonMessage)
        reasonMessage=slci.internal.encodeString(reasonMessage,'all','encode');
    end

    statusMessage=reportConfig.getStatusMessage(status);
    if~isempty(statusMessage)
        statusMessage=slci.internal.ReportUtil.appendColorAndTip(...
        statusMessage,status);
    end

    if strcmp(substatus,'UNSUPPORTED')||...
        strcmp(substatus,'VIRTUAL')||...
        strcmp(substatus,'INLINED')||...
        strcmp(substatus,'ROOTINPORT')

        detailsMessage=reasonMessage;
        if isa(Obj,'slci.results.BlockObject')
            detailsMessage=[detailsMessage,' ('...
            ,slci.internal.encodeString(Obj.getDispBlockType(),...
            'all',...
            'encode'),')'];
        end

    elseif strcmp(status,'NOT_PROCESSED')&&...
        strcmp(substatus,'OUT_OF_SCOPE')



        detailsMessage=statusMessage;

    elseif strcmp(status,'FAILED_TO_TRACE')||...
        strcmp(status,'UNABLE_TO_PROCESS')||...
        strcmp(status,'PARTIALLY_PROCESSED')||...
        strcmp(status,'NON_FUNCTIONAL')||...
        strcmp(status,'NOT_PROCESSED')

        detailsMessage=statusMessage;
        if~isempty(reasonMessage)
            detailsMessage=[detailsMessage,' (',reasonMessage,') '];
        end

    else
        detailsMessage=reasonMessage;
    end

    if isempty(detailsMessage)
        detailsMessage='-';
    end

end
