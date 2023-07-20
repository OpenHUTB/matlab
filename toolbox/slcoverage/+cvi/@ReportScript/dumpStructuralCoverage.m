function dumpStructuralCoverage(this,options)







    initHasMetricFlags(this,options);

    dumpSummary(this,options);
    if options.summaryMode==0
        dumpDetails(this,options);
    end








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





