function contextType=getContextType(adSL,c,excludeEmpty)









    if(nargin<3)
        excludeEmpty=false;
    end

    contextType=adSL.Context;
    if isempty(contextType)
        classList={
'rptgen_sl.csl_ws_var_loop'
'rptgen_sl.csl_data_dict_loop'
'rptgen_sl.csl_blk_loop'
'rptgen_sl.csl_sig_loop'
'rptgen_sl.CAnnotationLoop'
'rptgen_sl.csl_sys_loop'
'rptgen_sl.csl_mdl_loop'
        };
        contextList={
'WorkspaceVar'
'DataDictionary'
'Block'
'Signal'
'Annotation'
'System'
'Model'
        };
        contextType=rptgen.loopContext(classList,contextList,c,excludeEmpty);

    elseif excludeEmpty&&strcmp(contextType,'None')
        contextType='Model';
    end
