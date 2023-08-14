function[command,args]=parseConnectorURL(connectorURL)













    command='';
    args=[];

    matched=regexp(connectorURL,'feval/([\w\.]+)\?arguments=','tokens');
    if isempty(matched)
        return;
    end

    command=matched{1}{1};
    if strcmp(command,'rmi.navigate')



        [args.artifact,args.id,args.domain]=mcParseArgs(connectorURL,true);
    else



        [args.artifact,args.id]=mcParseArgs(connectorURL,false);
        args.domain='';
    end

end

function[mwArtifact,mwId,mwDomain]=mcParseArgs(connectorURL,hasDomainLabelArgument)


    if any(connectorURL=='"')
        firstArgRegexp='"([^"]+)"';
        nextArgRegexp=',"([^"]*)"';
    else
        firstArgRegexp='%22([^%]+)%22';
        nextArgRegexp=',%22([^%]*)%22';
    end

    if any(connectorURL=='[')
        argsBracket='[';
    else
        argsBracket='%5b';
    end
    myRegexp=['\?arguments=\',argsBracket,firstArgRegexp];
    if hasDomainLabelArgument
        myRegexp=[myRegexp,nextArgRegexp,nextArgRegexp];
        matched=regexp(connectorURL,myRegexp,'tokens');
        mwDomain=matched{1}{1};
        mwArtifact=matched{1}{2};
        mwId=matched{1}{3};
    else
        myRegexp=[myRegexp,nextArgRegexp];
        matched=regexp(connectorURL,myRegexp,'tokens');
        mwDomain='';
        mwArtifact=matched{1}{1};
        mwId=matched{1}{2};
    end

end
