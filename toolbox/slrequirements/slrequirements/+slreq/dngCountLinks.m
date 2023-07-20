











function count=dngCountLinks(source,config)

    if nargin<1||nargin>2
        error(message('Slvnv:oslc:ConfigContextIncorrectUsage',['slreq.',mfilename,'()'],['>> help slreq.',mfilename]));
    end

    source=convertStringsToChars(source);

    if nargin==1
        count=countDngLinks(source);

    else
        if isstruct(config)
            config=config.id;
        else
            config=convertStringsToChars(config);
        end
        count=oslc.config.countLinks(config,source);
    end
end

function count=countDngLinks(source)
    count=0;
    if isa(source,'slreq.LinkSet')
        linkSet=source;
    else
        linkSet=slreq.find('Type','LinkSet','Artifact',source);
    end
    if~isempty(linkSet)
        links=linkSet.getLinks();
        for i=1:numel(links)
            if strcmp(links(i).destination.domain,'linktype_rmi_oslc')
                count=count+1;
            end
        end
    end
end

