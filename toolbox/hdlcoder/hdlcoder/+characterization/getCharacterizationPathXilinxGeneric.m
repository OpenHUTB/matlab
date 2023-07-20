function dpath=getCharacterizationPathXilinxGeneric(family,speed,pathStart,wFamilyNotChar,wSpeedNotChar,wSpeedNotSpecified)



    dpath='';

    family_org=lower(family);
    family=regexprep(family_org,'\s+','_');
    speed=lower(speed);

    if isequal(exist(fullfile(pathStart,family),'dir'),7)

    else

        warnObj=message(wFamilyNotChar,family_org,'virtex7','-1','adaptive pipelining');
        warning(warnObj);
        slhdlcoder.HDLCoder.addCheckCurrentDriver('Warning',warnObj);
        family='virtex7';
        speed='1';

    end

    speedPath=fullfile(pathStart,family);

    folderContent=dir(speedPath);
    dirFlags=[folderContent.isdir];
    subdirs=folderContent(dirFlags);
    speeds=sort(lower({subdirs.name}));
    speeds=speeds(cellfun(@(x)isempty(x),regexp(speeds,'^\.+$'),'UniformOutput',true));

    if isempty(speed)
        warnObj=message(wSpeedNotSpecified,speeds{1},'adaptive pipelining');
        warning(warnObj);
        slhdlcoder.HDLCoder.addCheckCurrentDriver('Warning',warnObj);
        speed=speeds{1};
    end
    speed=strrep(speed,'-','');

    if isequal(exist(fullfile(speedPath,speed),'dir'),7)
        dpath=fullfile(speedPath,speed);
        return;
    else
        warnObj=message(wSpeedNotChar,family,speed,speeds{1},'adaptive pipelining');
        warning(warnObj);
        slhdlcoder.HDLCoder.addCheckCurrentDriver('Warning',warnObj);
        dpath=fullfile(speedPath,speeds{1});
        return;
    end
end
