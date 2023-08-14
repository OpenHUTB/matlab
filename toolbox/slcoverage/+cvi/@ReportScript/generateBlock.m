
function htmlStr=generateBlock(this,cvId,options)



    htmlStr='';
    this.generateString=true;

    this.cvstruct.testLabels={''};
    this.htmlStr='';
    if~isempty(this.metricNames)||~isempty(this.toMetricNames)
        idx=find(arrayfun(@(x)(isequal(x.cvId,cvId)),this.cvstruct.block),1);
        if~isempty(idx)
            blkEntry=this.cvstruct.block(idx);
            initHasMetricFlags(this,options);
            dumpBlockDetails(this,[],blkEntry,true,options);
            htmlStr=this.htmlStr;
        else
            idx=find(arrayfun(@(x)(isequal(x.cvId,cvId)),this.cvstruct.system),1);
            if~isempty(idx)
                blkEntry=this.cvstruct.system(idx);
                initHasMetricFlags(this,options);
                dumpSubsystemSummary(this,blkEntry,idx,true,options);
                htmlStr=this.htmlStr;
            end
        end

    end

