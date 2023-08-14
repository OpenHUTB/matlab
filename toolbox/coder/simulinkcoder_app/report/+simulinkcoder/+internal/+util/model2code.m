function model2code(mdl,blockhandles)


    try
        sids=Simulink.ID.getSID(blockhandles);
    catch
    end

    if~iscell(sids)
        sids={sids};
    end

    cr=simulinkcoder.internal.Report.getInstance;
    cr.publish(mdl,'m2c',sids);








