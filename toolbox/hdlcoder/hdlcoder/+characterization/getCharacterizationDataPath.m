function timingdbPath=getCharacterizationDataPath(suppressWarning)






    timingdbPath=hdlgetparameter('TimingDatabaseDirectory');
    if~isempty(timingdbPath)
        allDetails=what(timingdbPath);
        allMatFiles=allDetails.mat;
        if numel(allMatFiles)>0
            return;
        else
            warning(message("HDLShared:hdlshared:tdbinvalidcustomdir",timingdbPath));
        end
    end

    cMap=containers.Map();


    cMap('virtex7')=@characterization.getCharacterizationPathXilinx;
    cMap('zynq')=@characterization.getCharacterizationPathXilinx;
    cMap('zynq ultrascale+')=@characterization.getCharacterizationPathXilinx;
    cMap('kintexu')=@characterization.getCharacterizationPathXilinx;
    cMap('kintex7')=@characterization.getCharacterizationPathXilinx;
    cMap('artix7')=@characterization.getCharacterizationPathXilinx;

    cMap('cyclone v')=@characterization.getCharacterizationPathAltera;
    cMap('stratix v')=@characterization.getCharacterizationPathAltera;


    family=hdlgetparameter('synthesisToolChipFamily');
    family=lower(family);


    synthesisTool=hdlgetparameter('synthesisTool');






    if(strcmp(synthesisTool,'Altera Quartus II')||strcmp(synthesisTool,'Intel QUARTUS PRO'))
        defaultFamily='stratix v';
    else
        defaultFamily='virtex7';
    end
    if isempty(family)
        warnObj=message('HDLShared:hdlshared:cpefamilynotspecified');
        if~suppressWarning
            warning(warnObj);
            slhdlcoder.HDLCoder.addCheckCurrentDriver('Warning',warnObj);
        end
        family=defaultFamily;
    end

    if~cMap.isKey(family)
        warnObj=message('HDLShared:hdlshared:cpefamilynotcharacterized',family,defaultFamily);
        if~suppressWarning
            warning(warnObj);
            slhdlcoder.HDLCoder.addCheckCurrentDriver('Warning',warnObj);
        end
        family=defaultFamily;
    end

    hFunc=cMap(family);
    timingdbPath=hFunc(family);

end
