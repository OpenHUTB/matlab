function reqInfo=apiArgsToReqStruct(varargin)









    if isempty(varargin)
        reqInfo=[];
    else
        for i=1:2:length(varargin)
            name=varargin{i};
            if i==length(varargin)
                error('Missing value argument for name %s',name);
            else
                value=varargin{i+1};
            end
            switch lower(name)
            case 'artifact'
                reqInfo.artifactUri=value;
            case 'id'

                if~isempty(value)&&value(1)=='#'
                    error(message('Slvnv:slreq:BadCustomID',value));
                end
                reqInfo.id=value;
            case 'summary'
                reqInfo.summary=value;
            case{'text','details','description'}
                reqInfo.description=value;
            case 'rationale'
                reqInfo.rationale=value;
            case 'keywords'
                reqInfo.keywords=value;
            case{'domain','reqsys'}
                reqInfo.domain=value;
            case{'type','typename'}
                reqInfo.typeName=value;
            otherwise
                reqInfo.(name)=value;
            end
        end



        if~isfield(reqInfo,'description')
            reqInfo.description='';
        end
        if~isfield(reqInfo,'summary')
            reqInfo.summary='';
        end
        if~isfield(reqInfo,'id')
            reqInfo.id='';
        end

        if isfield(reqInfo,'artifactUri')
            if~isfield(reqInfo,'domain')
                reqInfo.domain=resolveDomainTypeLabel(reqInfo.artifactUri);
            end
            if~isfield(reqInfo,'artifactId')
                if isfield(reqInfo,'id')
                    reqInfo.artifactId=reqInfo.id;
                else
                    reqInfo.artifactId='';
                end
            end
        end

        if isfield(reqInfo,'typeName')



            slreq.app.RequirementTypeManager.checkIfKnownType(reqInfo.typeName);
        end
    end
end

function domainTypeLabel=resolveDomainTypeLabel(artifactPath)
    [~,~,fExt]=fileparts(artifactPath);
    if~isempty(fExt)
        linkType=rmi.linktype_mgr('resolveByFileExt',fExt);
        if~isempty(linkType)
            domainTypeLabel=linkType.Registration;
            return;
        end
    end

    error('Unable to resolve Domain Type for %s. Please provided a name-value pair for ''Domain''.');
end
