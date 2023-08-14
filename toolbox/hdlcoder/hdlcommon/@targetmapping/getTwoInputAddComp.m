
function adderComp=getTwoInputAddComp(hN,hInSignals,hOutSignals,...
    rndMode,satMode,compName,accumType,inputSigns,desc,slbh,nfpOptions)
    newInputSigns=inputSigns;
    if strcmp(inputSigns,'-+')

        validInputSignals(1)=hInSignals(2);
        validInputSignals(2)=hInSignals(1);
        newInputSigns='+-';
    else
        validInputSignals=hInSignals;
    end

    adderComp=pircore.getAddComp(hN,validInputSignals,hOutSignals,...
    rndMode,satMode,compName,accumType,newInputSigns,desc,slbh,nfpOptions);
end

