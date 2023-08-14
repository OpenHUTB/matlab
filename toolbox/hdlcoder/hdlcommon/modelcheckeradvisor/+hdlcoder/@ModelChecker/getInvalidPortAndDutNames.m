function[candidateDUT,candidatePorts]=getInvalidPortAndDutNames(dut)





    candidateDUT=[];
    candidatePorts=[];

    toptype=get_param(dut,'Type');
    if strcmp(toptype,'block')
        blkType=get_param(dut,'BlockType');
        if strcmp(blkType,'SubSystem')
            dutName=get_param(dut,'Name');
            dutHandle=get_param(dut,'Handle');
            if mixedOrLong(dutName)
                candidateDUT=dutHandle;
            end
        end
    end

    ports=hdlcoder.ModelChecker.find_system_MAWrapper(dut,'SearchDepth','1','RegExp','On','BlockType','port');
    for ii=1:numel(ports)
        port=ports{ii};
        portName=get_param(port,'Name');
        portHandle=get_param(port,'Handle');
        if mixedOrLong(portName)
            candidatePorts(end+1)=portHandle;%#ok<AGROW>
        end
    end



    function val=mixedOrLong(name)
        val=false;

        lowerName=lower(name);
        upperName=upper(name);
        if~strcmp(lowerName,name)&&~strcmp(upperName,name)
            val=true;
        end
        len=strlength(name);
        if(len>16)
            val=true;
        end
    end
end
