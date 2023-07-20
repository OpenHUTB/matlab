function dpath=getCharacterizationPathAltera(family)




    cMap=containers.Map();
    tMap=containers.Map();
    tMap('gx')='6';
    tMap('gt')='6';
    tMap('e')='6';
    cMap('cyclone v')=struct('default','gx',...
    'part','5CGTFD9E5F35C7',...
    'partExpr','^5C(?<familyMinor>GX|GT|E).*(?<speed>\d)(N)?(ES)?$',...
    'speedMap',tMap);
    tMap=containers.Map();
    tMap('5sgt')='2';

    cMap('stratix v')=struct('default','5sgt',...
    'part','5SGTMC7K3F40C2',...
    'partExpr','^(?<familyMinor>5SGX|5SGS|5SGT|5SE).*(?<speed>\d)(N)?(ES)?$',...
    'speedMap',tMap);


    partNumber=hdlgetparameter('synthesisToolDeviceName');
    familyMajor=family;
    baseDir=fullfile(matlabroot,'toolbox/shared/hdlshared/@hdlshared/@Characterization');


    familyMajor_folder=lower(strrep(familyMajor,' ','_'));
    rexpr=cMap(familyMajor).partExpr;
    fStruct=cMap(familyMajor);

    if isempty(partNumber)
        partNumber=fStruct.part;
        warnObj=message('HDLShared:hdlshared:cpepartnotspecified',partNumber);
        warning(warnObj);
        slhdlcoder.HDLCoder.addCheckCurrentDriver('Warning',warnObj);
    end

    info=regexpi(lower(partNumber),rexpr,'names');

    if isempty(info)||isempty(info.familyMinor)||isempty(info.speed)
        warnObj=message('HDLShared:hdlshared:cpepartnotcharacterized',familyMajor,partNumber,fStruct.part);
        warning(warnObj);
        slhdlcoder.HDLCoder.addCheckCurrentDriver('Warning',warnObj);
        partNumber=fStruct.part;
        info=regexpi(lower(partNumber),rexpr,'names');
    end
    familyMinor=info.familyMinor;
    speed=regexprep(info.speed,'-','');

    if~exist(fullfile(baseDir,familyMajor_folder,familyMinor,speed),'dir')
        warnObj=message('HDLShared:hdlshared:cpepartnotcharacterized',familyMajor,partNumber,fStruct.part);
        warning(warnObj);
        slhdlcoder.HDLCoder.addCheckCurrentDriver('Warning',warnObj);
        partNumber=fStruct.part;
        info=regexpi(lower(partNumber),rexpr,'names');
        familyMinor=info.familyMinor;
        speed=regexprep(info.speed,'-','');
    end

    dpath=fullfile(baseDir,familyMajor_folder,familyMinor,speed);

end
