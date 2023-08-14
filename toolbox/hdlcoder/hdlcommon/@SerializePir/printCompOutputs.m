function outStr=printCompOutputs(hC)
    hOutputSignals=hC.PirOutputSignals;
    numOutputs=length(hOutputSignals);
    noRefNum=false;
    if~ishandle(hOutputSignals)
        noRefNum=true;
        hOutputSignals=hC.PirOutputPorts;
    end
    outStr=[];
    if numOutputs>1
        outStr='[';
    end
    for jj=1:numOutputs
        hS=hOutputSignals(jj);
        sigName=matlab.lang.makeValidName(hS.Name);
        if~noRefNum
            sigName=[sigName,'_',hS.RefNum];
        end
        if jj==numOutputs
            if numOutputs>1
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
