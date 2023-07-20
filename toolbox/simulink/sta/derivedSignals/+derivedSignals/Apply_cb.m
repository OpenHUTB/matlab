function Apply_cb(hndl,signals,outputSignal)







    set_param(hndl,'ApplyFlag',num2str(0));


    if~isequal(derivedSignals.util.SerializeSubsystem(hndl),signals)

        derivedSignals.util.ApplySignals(hndl,(regexp(signals,'#','split'))',outputSignal);
    end
end
