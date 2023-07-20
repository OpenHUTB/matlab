





function sigNameGrpNameConsistencyCheck(data,sigNames,grpNames)

    if iscell(data)
        [sigCnt,grpCnt]=size(data);
    else
        sigCnt=1;
        grpCnt=1;
    end


    if~isempty(sigNames)
        if sigCnt>1&&~iscell(sigNames)
            DAStudio.error('Sigbldr:sigsuite:StringOrCellSigGroupNames','SIGNAMES');
        elseif iscell(sigNames)
            if~iscellstr(sigNames)
                DAStudio.error(...
                'Sigbldr:sigsuite:StringOrCellSigGroupNames',...
                'SIGNAMES');
            end
        end



        if(sigCnt>1||iscell(sigNames))&&length(sigNames)~=sigCnt
            DAStudio.error('Sigbldr:sigsuite:SignalDataMismatch',...
            length(sigNames),sigCnt);
        end



        if sigCnt==1&&~iscell(sigNames)&&~ischar(sigNames)
            DAStudio.error('Sigbldr:sigsuite:StringOrCellSigGroupNames','SIGNAMES');
        end


    end

    if~isempty(grpNames)
        if grpCnt>1&&~iscell(grpNames)
            DAStudio.error('Sigbldr:sigsuite:StringOrCellSigGroupNames','GROUPNAMES');
        elseif iscell(grpNames)


            if any(cellfun('isempty',grpNames))||...
                ~iscellstr(grpNames)
                DAStudio.error(...
                'Sigbldr:sigsuite:StringOrCellSigGroupNames',...
                'SIGNAMES');
            end
        end

        if(grpCnt>1||iscell(grpNames))&&length(grpNames)~=grpCnt
            DAStudio.error('Sigbldr:sigsuite:GroupDataMismatch',...
            length(grpNames),grpCnt);
        end

        if grpCnt==1&&~iscell(grpNames)&&~ischar(grpNames)
            DAStudio.error('Sigbldr:sigsuite:StringOrCellSigGroupNames','GROUPNAMES');
        end
    end
end