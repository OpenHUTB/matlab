function success=addLinkFromResource(req,linkUrl,linkLabel,linkType)






    if startsWith(linkUrl,'https://')

        encodedTargetURI=strrep(linkUrl,'&','&amp;');
        encodedTargetURI=strrep(encodedTargetURI,'#','%23');
    else

        encodedTargetURI=replaceSquareBrackets(linkUrl);
    end

    if nargin<4
        linkType='';
    end

    try
        myConnection=oslc.connection();
        resourceURL=req.resource;


        proj=oslc.Project.get(req.projectName);
        if~isempty(proj.context)
            contextUri=proj.context.uri;
            if~isempty(contextUri)
                escapedContextUri=urlencode(contextUri);
                resourceURL=[resourceURL,'?',sprintf('oslc_config.context=%s',escapedContextUri)];
            end
        end

        result=char(myConnection.addLink(resourceURL,encodedTargetURI,linkLabel,linkType));
        success=strcmp(result,'OK');
        if~success
            if contains(result,linkLabel)

                rmiut.warnNoBacktrace(result)
            else
                rmiut.warnNoBacktrace('Slvnv:oslc:FailedToAddBacklink',result);
            end
        end
    catch ex
        success=false;
        rmiut.warnNoBacktrace(ex.message);
    end
end

function out=replaceSquareBrackets(in)
    left=strrep(in,'[','%5B');
    out=strrep(left,']','%5D');
end

