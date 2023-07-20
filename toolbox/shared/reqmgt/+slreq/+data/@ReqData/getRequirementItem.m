function dataReq=getRequirementItem(this,itemIdStruct,doCreate)






















    if~isstruct(itemIdStruct)
        error('Input argument must be a structure with fields .domain, .artifact, .id');
    end

    itemIdStruct=ensureRequiredFieldNames(itemIdStruct);

    if isfield(itemIdStruct,'reqSet')&&~isempty(itemIdStruct.reqSet)

        reqSet=this.getReqSet(itemIdStruct.reqSet);
        dataReq=this.getRequirement(reqSet,itemIdStruct.sid);
        if isempty(dataReq)

            dataReq=reqSet.find('artifactUri',itemIdStruct.artifact,'artifactId',itemIdStruct.id);
        end
    else

        dataReq=this.findProxyItem(itemIdStruct.domain,itemIdStruct.artifact,itemIdStruct.id,true);
    end

    if isempty(dataReq)&&nargin>2&&doCreate
        error('getDestinationItem() called with doCreate=TRUE, which is not yet supported.');
    end
end

function arg=ensureRequiredFieldNames(arg)

    if isfield(arg,'doc')&&~isfield(arg,'artifact')
        arg.artifact=arg.doc;
    end
    if isfield(arg,'reqsys')&&~isfield(arg,'domain')
        arg.domain=arg.reqsys;
    end

    if strcmp(arg.domain,'linktype_rmi_slreq')

        if~isfield(arg,'reqSet')
            arg.reqSet=arg.artifact;
        end




        if isfield(arg,'sid')
            if ischar(arg.sid)
                arg.sid=str2num(arg.sid);%#ok<ST2NM>
            end
        elseif isfield(arg,'SID')
            if ischar(arg.SID)
                arg.sid=str2num(arg.SID);%#ok<ST2NM>
            else
                arg.sid=arg.SID;
            end
        else
            arg.sid=str2num(arg.id);%#ok<ST2NM>
        end
    end
end

