function errmsg=validateChanges(h)







    if~(h.isOutputPrdState||h.isOutputPrdMeasure||h.isOutputPrdError...
        ||h.isOutputEstState||h.isOutputEstMeasure||h.isOutputEstError)
        errmsg='You must select at least one output check box.';
        return;
    end

    errmsgid=dspblkkalman('check_param',h.Block.Handle,false,...
    h.sourceMeasure,h.num_targets,h.A,h.H,h.X,h.P,h.R,h.Q);
    if isempty(errmsgid)
        errmsg='';
    else
        errmsg=errmsgid.message;
    end


