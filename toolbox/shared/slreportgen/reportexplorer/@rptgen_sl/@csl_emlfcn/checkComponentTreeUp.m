function errMsg=checkComponentTreeUp(thisMLFcn,thisMLFcnParent)








    errMsg='';

    parent=thisMLFcnParent;
    while~isa(parent,'RptgenML.CReport')
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

    errMsg=getString(message('RptgenSL:csl_emlfcn:EditCmpnContextErrorNotInLoop',thisMLFcn.getName()));



