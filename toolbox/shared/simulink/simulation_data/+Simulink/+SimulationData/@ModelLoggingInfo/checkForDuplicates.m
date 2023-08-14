function[sigs,bInvalidSignals]=checkForDuplicates(sigs,invalidAction)






    len=length(sigs);
    lastElCell=cell(len,1);
    for idx=1:len
        lastElCell{idx}=sigs(idx).BlockPath.getLastPath();
    end



    [~,uniqueLeafBpIdxs,dupLeafBpIdxs]=unique(lastElCell,'stable');
    if length(uniqueLeafBpIdxs)==length(dupLeafBpIdxs)

        bInvalidSignals=false;
        return;
    end

    idxToRemove=[];




















    for idx=1:length(uniqueLeafBpIdxs)



        dupidxs=find(dupLeafBpIdxs==idx);
        for idx2=1:length(dupidxs)-1
            for idx3=idx2+1:length(dupidxs)
                if signalIsDuplicate(sigs(dupidxs(idx2)),sigs(dupidxs(idx3)))




                    if~strcmpi(invalidAction,'remove')
                        DAStudio.warning(...
                        'Simulink:Logging:MdlLogInfoDupSignal',...
                        dupidxs(idx2),dupidxs(idx3));
                    end



                    idxToRemove=[idxToRemove,dupidxs(idx3)];%#ok<AGROW>
                end
            end
        end

    end


    if~isempty(idxToRemove)
        bInvalidSignals=true;
        sigs(idxToRemove)=[];
    else
        bInvalidSignals=false;
    end
end


