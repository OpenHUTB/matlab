function connectFromSigProp(model,isConnect,uuid)



    if~Simulink.scopes.LAScope.isLogicAnalyzerAvailable()
        return;
    end
    signal=[];

    lacosi=Simulink.scopes.LAScope.getLogicAnalyzer(model);

    instr_signals=get_param(model,'InstrumentedSignals');

    if(isempty(instr_signals)&&isConnect)
        return
    end
    if(isConnect)
        action='connect';





        sigIdx=instr_signals.Count;
        addedSignal=instr_signals.get(sigIdx).updatePortHandle;

        if(addedSignal.PortHandle~=-1)

            signal=addedSignal;
        end

    else
        action='disconnect';

        removedSigs.UUID=uuid;
        signal=removedSigs;
    end

    if strcmp(action,'connect')
        lacosi.updateBoundSignals(signal,[],false,false);
    else


        lacosi.updateBoundSignals([],signal);
    end
end

