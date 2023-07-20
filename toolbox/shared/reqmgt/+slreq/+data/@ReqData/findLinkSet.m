function linkSet=findLinkSet(this,artifact,domain,matchFullPath)






    if nargin<3
        domain='';
    end

    if nargin<4
        matchFullPath=false;
    end

    linkSet=[];

    if isempty(this.repository)
        return;
    end

    linkSets=this.repository.linkSets.toArray();
    for i=1:length(linkSets)
        if strcmp(linkSets(i).artifactUri,artifact)
            linkSet=linkSets(i);
            return;
        end
    end

    if matchFullPath

        return;
    else

        [~,shortName]=fileparts(artifact);
        if contains(shortName,'~')
            tIdx=find(shortName=='~');
            shortName=shortName(1:(tIdx(end)-1));
        end

        for i=1:length(linkSets)
            if~isempty(domain)&&~strcmp(linkSets(i).domain,domain)
                continue;
            end
            [~,sName]=fileparts(linkSets(i).artifactUri);
            if strcmp(sName,shortName)
                linkSet=linkSets(i);
                return;
            end
        end
    end
end
