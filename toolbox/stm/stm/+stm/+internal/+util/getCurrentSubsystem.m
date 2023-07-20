function subsys=getCurrentSubsystem()

    sys=gcb;
    subsys='';
    if~isempty(sys)
        try
            type=get_param(sys,'type');
        catch
            return;
        end

        if strcmpi(type,'block')
            try
                Simulink.harness.internal.validateOwnerHandle(bdroot,get_param(sys,'Handle'));
            catch
                return;
            end
            subsys=sys;
        end
    end
end