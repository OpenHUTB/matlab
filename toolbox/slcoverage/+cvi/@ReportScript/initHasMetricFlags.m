function initHasMetricFlags(this,options)




    this.testCnt=length(this.cvstruct.tests);
    if this.testCnt>1
        if options.cumulativeReport
            this.columnCnt=this.testCnt;
            this.totalIdx=this.testCnt;
        else
            this.columnCnt=this.testCnt+1;
            this.totalIdx=this.testCnt+1;
        end
    else
        this.totalIdx=1;
        this.columnCnt=1;
    end
    this.hasDecisionInfo=any(strcmp(this.metricNames,'decision'));
    this.hasMcdcInfo=any(strcmp(this.metricNames,'mcdc'));
    this.hasConditionInfo=any(strcmp(this.metricNames,'condition'));
    this.hasTableExecInfo=any(strcmp(this.metricNames,'tableExec'));
    this.hasTestobjectiveInfo=~isempty(this.toMetricNames);
    this.uncovIdArray=list_leaf_uncovered(this.cvstruct);
    getTemplates(this,options);








    function uncovIdArray=list_leaf_uncovered(cvstruct)

        uncovIdArray=[];

        if isempty(cvstruct)||~isfield(cvstruct,'system')||isempty(cvstruct.system)
            return;
        end

        for i=1:length(cvstruct.system)
            sysEntry=cvstruct.system(i);

            if(sysEntry.flags.leafUncov==1)
                uncovIdArray=[uncovIdArray,sysEntry.cvId];%#ok<AGROW>
            end

            for blockI=sysEntry.blockIdx(:)'
                blkEntry=cvstruct.block(blockI);

                if(blkEntry.flags.leafUncov==1)
                    uncovIdArray=[uncovIdArray,blkEntry.cvId];%#ok<AGROW>
                end
            end
        end





