function outStr=printCompInputs(hC)
    hInputSignals=hC.PirInputSignals;
    noRefNum=false;
    if~ishandle(hInputSignals)
        noRefNum=true;
        hInputSignals=hC.PirInputPorts;
    end
    outStr=[];
    numInputs=length(hInputSignals);
    if numInputs==0
        outStr='[]';
    elseif numInputs>1
        outStr='[';
    end
    for jj=1:numInputs
        hS=hInputSignals(jj);
        sigName=matlab.lang.makeValidName(hS.Name);
        if~noRefNum
            sigName=[sigName,'_',hS.RefNum];
        end
        if jj==numInputs
            if numInputs>1
                suffix=']';
            else
                suffix='';
            end
        elseif mod(jj,6)==0
            suffix=',...\n\t\t ';
        else
            suffix=',';
        end
        outStr=[outStr,sigName,suffix];%#ok<*AGROW>
    end
end
