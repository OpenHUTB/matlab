function dpath=getAdaptivePipeliningDataPath()




    toolName=hdlgetparameter('synthesisTool');
    if isempty(toolName)
        toolName='xilinx vivado';
    end

    if(strcmp(toolName,'Altera Quartus II')||strcmp(toolName,'Intel QUARTUS PRO'))
        dpath=fullfile(matlabroot,'toolbox/shared/hdlshared/@hdlshared/@AdaptivePipelining','altera');
        return;





    else
        pathMethod=@characterization.getCharacterizationPathXilinxGeneric;
        defaultFamily='virtex7';
        defaultSpeed='1';
        speed=hdlgetparameter('synthesisToolSpeedValue');
    end


    family=hdlgetparameter('synthesisToolChipFamily');
    family=lower(family);

    if isempty(family)
        warnObj=message('HDLShared:hdlshared:genericfamilynotspecified',defaultFamily,defaultSpeed,'adaptive pipelining');
        warning(warnObj);
        slhdlcoder.HDLCoder.addCheckCurrentDriver('Warning',warnObj);
        family=defaultFamily;
        speed=defaultSpeed;
    end

    charDir=fullfile(matlabroot,'toolbox/shared/hdlshared/@hdlshared/@AdaptivePipelining');

    dpath=pathMethod(family,speed,fullfile(charDir,'xilinx'),'HDLShared:hdlshared:genericfamilynotcharacterized',...
    'HDLShared:hdlshared:genericspeednotcharacterized',...
    'HDLShared:hdlshared:genericspeednotspecified');

end
