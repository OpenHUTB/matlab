

















































function link=createLink(src,dst,varargin)
    link=slreq.Link.empty;

    stopAction=slreq.app.MainManager.startUserAction();%#ok<NASGU>


    if ischar(src)||length(src)==1
        if ischar(dst)
            link(end+1)=createSingleLink(src,dst,varargin{:});
        else
            for i=1:length(dst)
                link(end+1)=createSingleLink(src,dst(i),varargin{:});%#ok<AGROW>
            end
        end
        return;
    end


    if ischar(dst)||length(dst)==1
        if ischar(src)
            link(end+1)=createSingleLink(src,dst,varargin{:});
        else
            for i=1:length(src)
                link(end+1)=createSingleLink(src(i),dst,varargin{:});%#ok<AGROW>
            end
        end
        return;
    end


    if length(src)~=length(dst)
        error(message('Slvnv:slreq:LengthMismatch'));
    end

    for i=1:length(src)
        link(end+1)=createSingleLink(src(i),dst(i),varargin{:});%#ok<AGROW>
    end
end

function link=createSingleLink(src,dst,varargin)

    link=[];

    try

        if isa(src,'slreq.data.Requirement')
            srcData=src;

        elseif isa(src,'slreq.BaseItem')
            srcData=localApiToData(src);

        else
            if isa(src,'string')
                src=convertStringsToChars(src);
            end

            if isStructWithCorrectFields(src)

                srcData=ensureCharFields(src);
            else

                srcData=slreq.utils.resolveSrc(src);
            end
            if strcmp(srcData.domain,'linktype_rmi_simulink')&&rmiut.isBuiltinNoRmi(srcData.artifact)


                ME=MException(message('Slvnv:reqmgt:BuiltInLibNoRMI'));
                throw(ME);
            end
        end

        if isa(dst,'slreq.BaseItem')
            if isa(dst,'slreq.Justification')
                error(message('Slvnv:slreq:IncomingLinkToJustificationError'));
            else
                link=dst.addLink(srcData);
                dstStruct=convertToLegacyDestStruct(dst);
            end

        elseif isa(dst,'slreq.data.Requirement')
            linkData=dst.addLink(srcData);
            if~isempty(linkData)
                link=slreq.utils.dataToApiObject(linkData);
            end
            dstStruct=convertToLegacyDestStruct(dst);

        else
            if isa(dst,'string')
                dst=convertStringsToChars(dst);
            end

            if isa(dst,'struct')
                dstStruct=ensureCharFields(dst);
            else
                dstStruct=slreq.utils.resolveDest(dst);
            end

            nvarargin=length(varargin);
            if nvarargin==1

                if ischar(varargin{1})||isstring(varargin{1})
                    dstStruct.description=varargin{1};
                else
                    error(message('Slvnv:slreq:InvalidInputType'));
                end
            elseif nvarargin>1&&mod(nvarargin,2)==0
                for i=1:2:length(varargin)
                    dstStruct.(varargin{i})=varargin{i+1};
                end
            end


            if~isstruct(srcData)
                srcData=slreq.utils.resolveSrc(srcData);
            end
            if~slreq.utils.isNativeDomain(srcData.domain)
                srcData=convertToProxyItemStruct(srcData);
            end


            linkSetData=slreq.data.ReqData.getInstance.getLinkSet(srcData.artifact);
            if isempty(linkSetData)
                linkSetData=slreq.data.ReqData.getInstance.createLinkSet(srcData.artifact,srcData.domain);
            end







            dstStruct=slreq.utils.populateLegacyFieldNames(dstStruct,srcData.artifact);


            linkData=linkSetData.addLink(srcData,dstStruct);
            if~isempty(linkData)
                link=slreq.utils.dataToApiObject(linkData);
            end
        end


        if isa(srcData,'slreq.data.Requirement')
            return;
        end
        adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(srcData.domain);
        if isa(srcData,'slreq.data.SourceItem')
            sourceArtifact=srcData.artifactUri;
        else
            sourceArtifact=srcData.artifact;
        end
        if isfield(srcData,'parent')
            locationId=slreq.utils.getLongIdFromShortId(srcData.parent,srcData.id);
        else
            locationId=srcData.id;
        end
        adapter.refreshLinkOwner(sourceArtifact,locationId,[],dstStruct);

    catch ex
        if strcmp(ex.identifier,'Slvnv:slreq:SimulinkRequirementsNoLicense')
            rethrow(ex);
        else
            ME=MException(message('Slvnv:slreq:APIFailedToCreateLink'));
            ME=ME.addCause(ex);
            throwAsCaller(ME);
        end
    end
end

function tf=isStructWithCorrectFields(in)
    if isstruct(in)
        tf=isfield(in,'domain')&&isfield(in,'artifact')&&isfield(in,'id');
    else
        tf=false;
    end
end

function refStruct=convertToProxyItemStruct(src)












    if isfield(src,'reqSet')&&~slreq.data.ReqData.getInstance.isReservedReqSetName(src.reqSet)
        refStruct.domain='linktype_rmi_slreq';
        refStruct.artifact=src.reqSet;
        refStruct.id=num2str(src.sid);
    else
        error(message('Slvnv:slreq:EmbedCalledForWrongSource','slreq.createLink'));
    end
end

function refStruct=convertToLegacyDestStruct(dst)
    refStruct=rmi.createEmptyReqs(1);


    refStruct.reqsys='linktype_rmi_slreq';
    if isa(dst,'slreq.data.Requirement')
        [~,refStruct.doc]=fileparts(dst.getReqSet.filepath);
        refStruct.id=dst.id;
        refStruct.description=dst.summary;
    else
        [~,refStruct.doc]=fileparts(dst.reqSet.Filename);
        refStruct.id=dst.Id;
        refStruct.description=dst.Summary;
    end
end

function dataObj=localApiToData(apiObj)
    reqSetName=apiObj.reqSet.Name;
    reqData=slreq.data.ReqData.getInstance();
    reqSet=reqData.getReqSet(reqSetName);
    dataObj=reqSet.getRequirementById(num2str(apiObj.SID));
end

function myStruct=ensureCharFields(myStruct)
    allFields=fields(myStruct);
    for i=1:numel(allFields)
        field=allFields{i};
        if ischar(myStruct.(field))

        elseif isnumeric(myStruct.(field))
            myStruct.(field)=num2str(myStruct.(field));
        else

            myStruct.(field)=convertStringsToChars(myStruct.(field));
        end
    end
end
