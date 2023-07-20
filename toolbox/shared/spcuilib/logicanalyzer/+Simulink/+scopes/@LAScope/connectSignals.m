function connectSignals(model,action,signals)






    if~Simulink.scopes.LAScope.isLogicAnalyzerAvailable()
        return;
    end
    inModelLoad=false;
    isSF=false;
    sfSigs=[];
    if nargin==1
        inModelLoad=true;






        action='connect';
        [signals,sfSigs]=Simulink.scopes.LAScope.getInstrumentedSignals(model);

    elseif nargin>2&&slfeature('slLogicAnalyzerSFLogging')==1




        isSF=strcmp(action,'connectSF');
        if isSF
            action='connect';
            if~isempty(signals)
                sfSigs=getSigfromUUID(model,signals);
                signals=[];
            end
        end

    end

    if isempty(signals)&&isempty(sfSigs)
        return;
    end
    lacosi=Simulink.scopes.LAScope.getLogicAnalyzer(model);
    if strcmp(action,'connect')

        if~isempty(signals)
            lacosi.updateBoundSignals(signals,[],false,inModelLoad);
        end
        if~isempty(sfSigs)&&slfeature('slLogicAnalyzerSFLogging')==1
            lacosi.updateBoundSignals(sfSigs,[],false,inModelLoad,true);
        end
    else


        lacosi.updateBoundSignals([],signals);
    end
end
function sfsigs=getSigfromUUID(model,signals)
    instr_signals=get_param(model,'InstrumentedSignals');
    sfsigs=cell(1,length(signals));
    if~isempty(instr_signals)
        num_signals=instr_signals.Count;
        for kndx=1:num_signals
            k_signal=instr_signals.get(num_signals-kndx+1,true);
            if any(strcmp(signals,k_signal.UUID))
                sfsigs{kndx}=k_signal;
            end
        end
    end
    sfsigs=[sfsigs{:}];
end
