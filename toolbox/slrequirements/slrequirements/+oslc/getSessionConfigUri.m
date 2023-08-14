function configUri=getSessionConfigUri(projectName)





    configUri='';

    [pName,qBase]=oslc.Project.currentProject();

    if~isempty(pName)&&strcmp(pName,projectName)

        configUri=parseConfigIdFromQueryBaseUrl(qBase);
    end

end

function configUri=parseConfigIdFromQueryBaseUrl(url)
    configUri='';

    confMatch=regexp(url,'vvc.configuration=([^& ]+)','tokens');
    if isempty(confMatch)
        confMatch=regexp(url,'oslc_config.context=([^& ]+)','tokens');
    end
    if~isempty(confMatch)
        oneMatch=confMatch{1}{1};
        configUri=strrep(strrep(oneMatch,'%3A',':'),'%2F','/');
    end
end
