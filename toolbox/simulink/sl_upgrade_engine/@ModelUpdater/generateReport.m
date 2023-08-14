function[out,cmdLineText]=generateReport(h)








    cmdLineText='';
    if doUpdate(h)

        indentFmt='  %s\n';
        cr=sprintf('\n');
        buf=cr;

        if~isempty(h.UpdateMsgs)
            for i=1:length(h.UpdateMsgs)
                configFmt=DAStudio.message(...
                'SimulinkUpgradeEngine:engine:configFormat',...
                h.UpdateMsgs(i).name,h.UpdateMsgs(i).msg);

                buf=[buf,configFmt];%#ok
            end
        end



        buf=[buf,cr];
        if isempty(h.Transactions)||all(cellfun('isempty',[h.Transactions.functionSet]))
            noBlksFmt=DAStudio.message('SimulinkUpgradeEngine:engine:noBlocksFormat',h.MyModel);
            buf=[buf,noBlksFmt];
        else
            chgBlksFmt=DAStudio.message('SimulinkUpgradeEngine:engine:changedBlocksFormat',h.MyModel);
            buf=[buf,chgBlksFmt];
            for i=1:length(h.Transactions)
                if~isempty(h.Transactions(i).functionSet)
                    buf=[buf,sprintf(indentFmt,h.Transactions(i).name)];%#ok
                end
            end
            buf=[buf,cr];
        end


        if any(cellfun('isempty',{h.Transactions.functionSet}))
            warnBlksFmt=DAStudio.message('SimulinkUpgradeEngine:engine:unchagedBlocksFormat',h.MyModel);
            buf=[buf,warnBlksFmt];

            [~,sortedIdx]=sort({h.Transactions.reason});
            currentReason='';

            for i=1:length(sortedIdx)
                if isempty(h.Transactions(sortedIdx(i)).functionSet)
                    if strcmp(currentReason,h.Transactions(sortedIdx(i)).reason)
                        buf=[buf,sprintf(indentFmt,h.Transactions(i).name)];%#ok<AGROW>
                    else
                        currentReason=h.Transactions(sortedIdx(i)).reason;
                        buf=[buf,currentReason,cr,sprintf(indentFmt,h.Transactions(sortedIdx(i)).name)];%#ok<AGROW>
                    end
                end
            end
            buf=[buf,cr];
        end















        if~isempty(buf)
            cmdLineText=buf;

        end

        out={};
    else
        out=genAnalysisReport(h);
    end

end
