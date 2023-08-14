function[candidatePorts,candidateSignals]=getInvalidPortSignalNames(sys)





    candidatePorts=[];
    candidateSignals=[];


    ports=hdlcoder.ModelChecker.find_system_MAWrapper(sys,'RegExp','On','BlockType','port');
    for ii=1:numel(ports)
        port=ports{ii};
        portName=get_param(port,'Name');
        portHandle=get_param(port,'Handle');
        if invalidLength(portName)
            candidatePorts(end+1)=portHandle;%#ok<AGROW>
        end
    end


    signals=hdlcoder.ModelChecker.find_system_MAWrapper(sys,'findall','on','RegExp','On','Type','line');
    for ii=1:numel(signals)
        sigH=signals(ii);
        sigName=get_param(sigH,'Name');
        if invalidLength(sigName)
            candidateSignals(end+1)=sigH;%#ok<AGROW>
        end
    end



    function val=invalidLength(name)
        val=false;

        if isempty(name)
            return;
        end
        len=strlength(name);
        if(len<2)
            val=true;
        elseif(len>40)
            val=true;
        end
    end
end
