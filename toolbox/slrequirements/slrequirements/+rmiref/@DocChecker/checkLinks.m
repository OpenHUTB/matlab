function number_of_problems=checkLinks(this)





    total_links=length(this.links);
    this.pathFixed=false(1,total_links);
    this.labelFixed=false(1,total_links);
    this.isBad=false(1,total_links);
    this.badModel=false(1,total_links);
    this.badObject=false(1,total_links);

    for idx=1:length(this.links)

        if~isempty(this.skipped{idx})
            continue;
        end

        thisLink=this.links(idx);

        issue=thisLink.issue;

        switch issue

        case rmiref.DocChecker.UNSUPPORTED_COMMAND
            this.isBad(idx)=true;

        case rmiref.DocChecker.UNRESOLVED_MODEL
            this.isBad(idx)=true;
            this.badModel(idx)=true;

        case rmiref.DocChecker.UNRESOLVED_OBJECT
            this.isBad(idx)=true;
            this.badObject(idx)=true;

        case ''
            [missingMdl,missingObj,pathFxd,labelFxd]=thisLink.checkInSimulink();
            if missingMdl||missingObj
                this.isBad(idx)=true;
                if missingMdl
                    thisLink.override(rmiref.DocChecker.UNRESOLVED_MODEL,'missing_model',this.sessionId);
                    this.badModel(idx)=true;
                else
                    if~isempty(pathFxd)
                        this.pathFixed(idx)=true;
                        thisLink.details=strrep([pathFxd,' -> ',thisLink.model],'\','/');
                    end
                    thisLink.override(rmiref.DocChecker.UNRESOLVED_OBJECT,'missing_component',this.sessionId);
                    this.badObject(idx)=true;
                end
            elseif~isempty(pathFxd)
                this.pathFixed(idx)=true;
                thisLink.details=strrep([pathFxd,' -> ',thisLink.model],'\','/');
            elseif~isempty(labelFxd)
                this.labelFixed(idx)=true;
                thisLink.details=[labelFxd,' -> ',thisLink.label];
            end

        otherwise
            error(message('Slvnv:reqmgt:checkLinks:UnrecognizedIssueType',issue));
        end

    end
    number_of_problems=length(find(this.isBad));
end
