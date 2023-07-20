function DSPLevinDurbBlk(obj)




    if isR2007bOrEarlier(obj.ver)
        levd_bh=obj.findLibraryLinksTo('dspsolvers/Levinson-Durbin','coeffOutFcn','OBSOLETE');
        blks=levd_bh;
        for i=1:length(blks)
            blkTag=get_param(blks{i},'tag');
            set_param(blks{i},'tag','dspblks_tmp_paramsplit_forward_compat');

            puString=get_param(blks{i},'coeffOutFcnActive');
            set_param(blks{i},'coeffOutFcn',puString);

            set_param(blks{i},'tag',blkTag);

        end
    end
