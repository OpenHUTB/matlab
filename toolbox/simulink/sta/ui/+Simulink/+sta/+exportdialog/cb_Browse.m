function[isFileNameGood,fullfilename]=cb_Browse(State,sigIds)





    titleString=getString(message('sl_web_widgets:exportdialog:ExportDataTitle'));

    aSigCell=cell(1,length(sigIds));
    for kSig=1:length(sigIds)




        if iscell(sigIds)
            loopSig=sigIds{kSig};
        else
            loopSig=sigIds(kSig);
        end

        if strcmpi(loopSig.parent,'input')

            aSigCell{kSig}=loopSig;

        end

    end

    aSigCell(cellfun(@isempty,aSigCell))=[];


    [fullfilename]=Simulink.sta.util.browseForFile(false,titleString,aSigCell);

    State.exportTo='exMatFile';
    State.matFile=fullfilename;

    if~isempty(fullfilename)
        isFileNameGood=Simulink.sta.exportdialog.cb_FileNameTyped(State);
    else
        isFileNameGood=false;
    end

end

