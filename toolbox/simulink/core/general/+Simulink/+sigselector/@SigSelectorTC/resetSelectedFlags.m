function outsigs=resetSelectedFlags(~,insigs)










    outsigs=insigs;
    for ct=1:numel(outsigs)

        if strcmp(class(outsigs{ct}),'Simulink.sigselector.SignalItem')

            outsigs{ct}.Selected=false;
        elseif strcmp(class(outsigs{ct}),'Simulink.sigselector.BusItem')

            hier=outsigs{ct}.Hierarchy;
            for ctc=1:numel(hier)
                hier(ctc).Selected=false;

                hier(ctc).Children=LocalBus(hier(ctc).Children);
            end

            outsigs{ct}.Hierarchy=hier;
        else

            DAStudio.error('Simulink:sigselector:TCInvalidSignals');
        end
    end
    function input=LocalBus(input)
        for ct=1:numel(input)
            input(ct).Selected=false;
            if~isempty(input(ct).Children)
                input(ct).Children=LocalBus(input(ct).Children);
            end
        end


