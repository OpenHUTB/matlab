function thisReq=addRequirementItem(docObj,item,parentReq,doProxy,isRichText,description,rationale,importTime)

    if nargin<7
        rationale='';
    end
    if nargin<8
        importTime=datetime('now','TimeZone','UTC');
    end


    if doProxy
        reqInfo=makeProxyInfo(item);



        if isfield(item,'group')
            reqInfo.group=item.group;
        end

        if isfield(item,'modifiedOn')
            reqInfo.modifiedOn=item.modifiedOn;
        end
        if isfield(item,'modifiedBy')
            reqInfo.modifiedBy=item.modifiedBy;
        end
        if isfield(item,'createdOn')
            reqInfo.createdOn=item.createdOn;
        end
        if isfield(item,'createdBy')
            reqInfo.createdBy=item.createdBy;
        end


        reqInfo.synchronizedOn=importTime;

        [reqInfo.description,reqInfo.rationale]=richTextFields(isRichText,description,rationale);
        thisReq=parentReq.addChildExternalRequirement(reqInfo);
    else
        reqInfo=makeReqInfo(item);
        [reqInfo.description,reqInfo.rationale]=richTextFields(isRichText,description,rationale);
        thisReq=parentReq.addChildRequirement(reqInfo);
    end



    if isfield(item,'keywords')&&~isempty(item.keywords)


        reqData=slreq.data.ReqData.getInstance();
        reqData.setKeywords(thisReq,item.keywords);
    end


    if isfield(item,'attrNames')
        attrNames=item.attrNames;
        if~isempty(attrNames)
            attrValues=item.attrValues;
            for i=1:length(attrNames)
                trimmedValue=strtrim(attrValues{i});
                if~isempty(trimmedValue)
                    thisReq.setAttributeByChar(attrNames{i},trimmedValue);
                end
            end
        end
    end

    function[description,rationale]=richTextFields(isRichText,description,rationale)
        if isempty(description)||(isRichText&&slreq.import.html.isEmpty(description))
            description='';
        end
        if isempty(rationale)||(isRichText&&slreq.import.html.isEmpty(rationale))
            rationale='';
        end
    end

    function reqInfo=makeReqInfo(item)

        if isfield(item,'summary')&&~isempty(item.summary)
            reqInfo.summary=item.summary;
        else


            if~isstruct(docObj)


                reqInfo.summary=docObj.makeSummary(item);
            elseif isfield(item,'label')
                reqInfo.summary=item.label;
            else
                reqInfo.summary='';
            end
        end

        if isfield(item,'id')
            reqInfo.id=item.id;
        elseif isfield(item,'label')
            reqInfo.id=item.label;
        else
            reqInfo.id='';
        end
    end

    function reqInfo=makeProxyInfo(item)

        if isstruct(docObj)
            reqInfo.domain=docObj.domain;
            reqInfo.artifactUri=docObj.name;
        else
            reqInfo.domain=rmidotnet.resolveDomainType(docObj);
            reqInfo.artifactUri=docObj.sFile;
        end

        switch item.type
        case 'id'

            if isa(docObj,'rmidotnet.MSExcel')


                reqInfo.artifactId=['?',item.id];
            else
                reqInfo.artifactId=item.id;
            end
            reqInfo.id=item.id;
        case 'bookmark'
            reqInfo.artifactId=['@',item.label];
            reqInfo.id=item.label;
        case 'match'
            reqInfo.artifactId=['?',item.label];
            reqInfo.id=item.label;
        case 'row'
            reqInfo.artifactId=['$',item.id];
        case 'resource'

            reqInfo.artifactId=sprintf('%s (%s)',item.url,item.id);
            reqInfo.id=item.id;
        otherwise






            reqInfo.id=regexprep(item.label,'\.\.\.$','');

            reqInfo.artifactId=['?',reqInfo.id];
        end

        if isfield(item,'summary')
            reqInfo.summary=item.summary;
        elseif isstruct(docObj)
            reqInfo.summary=item.label;
        else

            reqInfo.summary=docObj.makeSummary(item);
        end

    end

end