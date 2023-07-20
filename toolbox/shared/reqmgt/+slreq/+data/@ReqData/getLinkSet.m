function linkSetObj=getLinkSet(this,artifact,domain)






    linkSetObj=[];

    [aDir,aName,aExt]=fileparts(artifact);
    isFullPathGiven=false;
    if~isempty(aDir)
        if rmiut.isCompletePath(aDir)
            isFullPathGiven=true;
        else
            aDir=rmiut.simplifypath(fullfile(pwd,aDir),filesep);
        end
    end


    if strcmp(aExt,'.slmx')


        if~isempty(aDir)

            linkSets=this.getLoadedLinkSets();
            if~isempty(linkSets)
                matchIdx=strcmp({linkSets.filepath},fullfile(aDir,[aName,aExt]));
                if any(matchIdx)
                    linkSetObj=linkSets(matchIdx);
                end
            end
            return;
        else


            artifact=aName;
            if contains(artifact,'~')
                artifact=regexprep(artifact,'~\w*$','');
            end
        end
    end

    if nargin<3
        domain=slreq.utils.getDomainLabel(artifact);
    end

    requireFullPathMatch=isFullPathGiven&&isfile(artifact);

    linkSet=this.findLinkSet(artifact,domain,requireFullPathMatch);

    if~isempty(linkSet)
        linkSetObj=this.wrap(linkSet);
    end
end
