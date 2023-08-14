function[gotExported,errMsg]=cb_Ok(State)





    sigIDs=squeeze(State.selectedSignals);


    aFactory=starepository.repositorysignal.Factory;


    if isequal(State.exportTo,'exMatFile')&&~isempty(State.matFile)

        [gotExported,errMsg]=Simulink.sta.exportdialog.exportToFile(sigIDs,State.matFile,true);

    else



        for kSig=1:length(sigIDs)


            concreteExtractor=aFactory.getSupportedExtractor(sigIDs(kSig));


            [dataValue,dataVarName]=concreteExtractor.extractValue(sigIDs(kSig));


            assignin('base',dataVarName,dataValue);
        end

        gotExported=true;
        errMsg='';
    end



end