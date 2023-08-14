function pmsl_evalparams(blk)
















    blkH=get_param(blk,'Handle');




    if~strcmp(get_param(blkH,'Type'),'block')
        pm_error('physmod:pm_sli:pmsl_evalparams:InvalidObjectType');
    end




    parentH=get_param(get_param(blkH,'Parent'),'Handle');





    if~strcmp(get_param(parentH,'Type'),'block_diagram')
        blkH=parentH;
    end




    pmsl_evalparamsbi(blkH);
end
