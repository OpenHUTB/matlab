function cs=loop_getContextString(c)






    if strcmp(c.LoopType,'list')
        cs='Blocks from manual list';
    else
        switch lower(getContextType(rptgen_sl.appdata_sl,c,logical(0)))
        case 'model'
            cs=getString(message('RptgenSL:rsl_csl_blk_loop:allReportedSystemBlockLabel'));
        case 'system';
            cs=getString(message('RptgenSL:rsl_csl_blk_loop:allSystemBlockLabel'));
        case 'signal'
            cs=getString(message('RptgenSL:rsl_csl_blk_loop:allCurrentSignalBlocksLabel'));
        case{'annotation','configset'}
            cs=getString(message('RptgenSL:rsl_csl_blk_loop:noneLabel'));
        case 'block'
            cs=getString(message('RptgenSL:rsl_csl_blk_loop:currentBlockLabel'));
        otherwise
            cs=getString(message('RptgenSL:rsl_csl_blk_loop:allModelsBlocksLabel'));
        end
    end
