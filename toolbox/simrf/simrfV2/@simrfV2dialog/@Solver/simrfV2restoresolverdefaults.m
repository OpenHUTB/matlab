function unchanged_flag=simrfV2restoresolverdefaults(this)







    unchanged_flag=true;
    str=DAStudio.message('simrf:simrfV2solver:RestDefSolSetQ');


    answer=questdlg([' ',str,' '],...
    DAStudio.message('simrf:simrfV2solver:RestDefSolSetT'),...
    DAStudio.message('simrf:simrfV2solver:Yes'),...
    DAStudio.message('simrf:simrfV2solver:No'),...
    DAStudio.message('simrf:simrfV2solver:No'));

    if strcmp(answer,DAStudio.message('simrf:simrfV2solver:Yes'))
        blockName=this.getBlock.getFullName;
        set_param(blockName,'RelTol','1e-3');
        set_param(blockName,'AbsTol','1e-6');
        set_param(blockName,'MaxIter','10');
        set_param(blockName,'ErrorEstimationType',...
        '2-norm over all variables');
    end
end


