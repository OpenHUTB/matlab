function dpath=getCharacterizationPathXilinx(family)





    origFamily=family;

    familySpeedMap=containers.Map();
    familySpeedMap('virtex7')='-1';
    familySpeedMap('zynq')='-1';
    familySpeedMap('zynq_ultrascale+')='-1';
    familySpeedMap('kintexu')='-1';
    familySpeedMap('kintex7')='-1';
    familySpeedMap('artix7')='-1';
    speed=hdlgetparameter('synthesisToolSpeedValue');
    deviceName=hdlgetparameter('SynthesisToolDeviceName');
    baseDir=fullfile(matlabroot,'toolbox/shared/hdlshared/@hdlshared/@Characterization');
    pFamily=strrep(family,' ','_');
    familyPath=fullfile(baseDir,pFamily);
    deviceNameContainsSpeedFamily=["kintex_ultrascale+","kintex7","kintexu","spartan7",...
    "virtex_ultrascale+","virtex_ultrascale+_58g","virtex_ultrascale+_hbm","virtexu",...
    "zynq_ultrascale+","zynq_ultrascale+_rfsoc","versal_ai_core"];
    deviceNameContainsSpeed=contains(deviceNameContainsSpeedFamily,pFamily);
    if(~isempty(find(deviceNameContainsSpeed,1))&&(~isempty(deviceName))&&isempty(speed))
        deviceName=split(deviceName,"-");
        if strcmp(pFamily,'kintex7')
            if strcmp(deviceName{1},'xa7k160tffg676')
                speed=strcat('-',deviceName{2});
            end
        elseif strcmp(pFamily,'spartan7')
            speed=strcat('-',deviceName{2});




        else
            speed=strcat('-',deviceName{3});
        end
    end
    origSpeed=speed;



    defaultFamily='artix7';
    if~exist(familyPath,'dir')||~familySpeedMap.isKey(pFamily)
        pFamily=defaultFamily;
        speed=familySpeedMap(pFamily);
        warnObj=message('HDLShared:hdlshared:cpefamilynotcharacterized',origFamily,pFamily);
        warning(warnObj);
        slhdlcoder.HDLCoder.addCheckCurrentDriver('Warning',warnObj);
    end


    if isempty(speed)
        speed=familySpeedMap(pFamily);
        warnObj=message('HDLShared:hdlshared:cpespeednotspecified',speed);
        warning(warnObj);
        slhdlcoder.HDLCoder.addCheckCurrentDriver('Warning',warnObj);
    end


    speed=lower(strrep(speed,'-',''));
    fullPath=fullfile(baseDir,pFamily,speed);



    if~exist(fullPath,'dir')
        speed=lower(strrep(familySpeedMap(pFamily),'-',''));
        warnObj=message('HDLShared:hdlshared:cpespeednotcharacterized',pFamily,origSpeed,speed);
        warning(warnObj);
        slhdlcoder.HDLCoder.addCheckCurrentDriver('Warning',warnObj);
    end

    fullPath=fullfile(baseDir,pFamily,speed);
    dpath=fullPath;
end
