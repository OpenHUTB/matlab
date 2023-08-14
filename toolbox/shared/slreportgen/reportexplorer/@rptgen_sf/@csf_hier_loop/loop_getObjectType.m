function oType=loop_getObjectType(c,obj,ps)










    if nargin<2
        oType=getString(message('RptgenSL:rsf_csf_hier_loop:stateflowLabel'));
    else
        if nargin<3
            ps=cLoop.loop_getPropSrc;
        end
        oType=ps.getObjectType(obj);
    end
