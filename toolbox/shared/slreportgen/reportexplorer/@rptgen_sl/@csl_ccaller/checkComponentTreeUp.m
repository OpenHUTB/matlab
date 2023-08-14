function errMsg=checkComponentTreeUp(thisCCaller,thisCCallerParent)








    errMsg='';

    parent=thisCCallerParent;
    while~isa(parent,'RptgenML.CReport')&&~isa(parent,'RptgenML.CForm')
        switch class(parent)
        case 'rptgen_sl.csl_mdl_loop'
            return;
        case 'rptgen_sl.csl_sys_loop'
            return;
        case 'rptgen_sl.csl_blk_loop'
            return;
        otherwise
            parent=parent.up;
        end
    end

    errMsg=getString(message('RptgenSL:csl_ccaller:editCmpnContextErrorNotInLoop',thisCCaller.getName()));
