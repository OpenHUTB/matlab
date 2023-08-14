function[prmNames,prmVals]=cachePortParameters(oPort)
    prmNames={};
    prmVals={};

    objPrm=get_param(oPort,'ObjectParameters');
    allPrmNames=fieldnames(objPrm);

    skipParams={'ShowPropagatedSignals'};
    allPrmNames=setdiff(allPrmNames,skipParams,'stable');

    for idx=1:length(allPrmNames)
        thisPrm=allPrmNames{idx};
        cmd=['objPrm.',thisPrm,'.Attributes'];
        attrib=eval(cmd);
        if any(strcmp('read-write',attrib))
            try







                val=get_param(oPort,thisPrm);
                set_param(oPort,thisPrm,val);

                prmNames{end+1}=thisPrm;%#ok<AGROW>
                prmVals{end+1}=val;%#ok<AGROW>
            catch
            end
        end
    end
end