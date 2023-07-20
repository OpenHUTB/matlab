function[candidateBlks,candidateSignals]=getInvalidNames(dut)





    candidateBlks=[];
    candidateSignals=[];

    blocks=hdlcoder.ModelChecker.find_system_MAWrapper(dut,'RegExp','On','Type','Block');
    invPattern=({'vdd','vss','gnd','vcc','vref'});
    for ii=1:numel(blocks)
        blk=blocks{ii};
        blkName=get_param(blk,'Name');
        if(contains(blkName,invPattern,'IgnoreCase',true))
            candidateBlks(end+1)=get_param(blk,'Handle');%#ok<AGROW>
        end
    end

    signals=hdlcoder.ModelChecker.find_system_MAWrapper(dut,'findall','on','RegExp','On','Type','line');

    for ii=1:numel(signals)
        sigH=signals(ii);
        sigName=get_param(sigH,'Name');
        if(contains(sigName,invPattern,'IgnoreCase',true))
            candidateSignals(end+1)=sigH;%#ok<AGROW>
        end
    end
end
