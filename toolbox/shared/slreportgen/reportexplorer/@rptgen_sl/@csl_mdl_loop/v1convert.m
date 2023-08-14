function v1convert(cv2,cv1)








    if isa(cv1,'rptcp')
        cv1=struct(get(cv1,'UserData'));
    elseif isa(cv1,'rptcomponent')
        cv1=struct(cv1);
    elseif isa(cv1,'struct')&&isfield(cv1,'att')&&isfield(cv1,'comp')

    else
        error(message('rptgen:r_rptcomponent:conversionError'));
    end

    cv2.Active=logical(cv1.comp.Active);

    allMdl=cv1.att.([cv1.att.LoopType,'Models']);





    for i=1:length(allMdl)
        ov2=rptgen_sl.rpt_mdl_loop_options;
        ov2.v1convert(allMdl(i));
        cv2.addModel(ov2);
    end

