function title=getTitle(rdf,namespace)













    mainTagMatch=regexp(rdf,makeMainTagPattern('rdf:Description'),'tokens');
    if isempty(mainTagMatch)

        mainTagMatch=regexp(rdf,makeMainTagPattern('oslc_config:Configuration'),'tokens');
    end
    if~isempty(mainTagMatch)
        mainDescription=mainTagMatch{1}{1};
    else
        mainDescription=rdf;
    end

    if nargin<2
        title=oslc.parseValue(mainDescription,'dcterms:title');
        if isempty(title)
            title=oslc.parseValue(mainDescription,'dc:title');
        end
    else
        title=oslc.parseValue(mainDescription,[namespace,':title']);
    end

    if isempty(title)
        title=getString(message('Slvnv:oslc:TitleNotSpecified'));
        return;
    elseif iscell(title)
        isAppTitle=strcmp(title,'Requirements Management');
        projectTitle=title(~isAppTitle);
        title=projectTitle{1};
    end

    if~isempty(title)
        title=oslc.unescapeHtml(title);
    end
end

function pattern=makeMainTagPattern(tag)
    pattern=['<',tag,' rdf:about=[^>]+>([\s\S]+)'];
end



