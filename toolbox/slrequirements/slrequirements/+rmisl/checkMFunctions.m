function[results,all_errors]=checkMFunctions(system,check,all_errors)




    results=cell(0,2);
    if rmidata.isExternal(bdroot(system))
        mfunctionSIDs=rmisl.getMFunctionSIDs(system);
        if~isempty(mfunctionSIDs)
            for i=1:length(mfunctionSIDs)
                oneSID=mfunctionSIDs{i};
                [countIssues,errors]=rmiml.checkLinks(oneSID,check);
                if countIssues>0
                    results(end+1,:)={countIssues,oneSID};%#ok<AGROW>
                    for j=1:length(errors)
                        if isempty(strfind(all_errors,errors{j}))
                            all_errors=[all_errors,'<li>',errors{j},'</li>'];%#ok<AGROW>
                        end
                    end
                end
            end
        end
    end
end

