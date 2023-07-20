function[fid,mfparamsTempFile]=generateMegafunctionParamsFile




    currDir=pwd;
    hC=hdlcurrentdriver;
    targetDir=hC.hdlGetCodegendir;
    if~exist(targetDir,'dir')
        mkdir(targetDir);
    end
    cd(targetDir);
    mfparamsTempFile=sprintf('%s_megafunction_params.txt',tempname(pwd));
    cd(currDir);
    fid=fopen(mfparamsTempFile,'w');
    if fid==-1
        error(message('hdlcommon:targetcodegen:CurrentDirNotWritable'));
    end

    fprintf(fid,'clock=clock\n');

    fprintf(fid,'clk_en=clk_en\n');

    fprintf(fid,'aclr=aclr\n');

    deviceDetails=hdlgetdeviceinfo;
    deviceFamily=deviceDetails{1};
    fprintf(fid,'INTENDED_DEVICE_FAMILY="%s"\n',deviceFamily);
    if(isempty(deviceFamily))
        warning(message('hdlcommon:targetcodegen:DeviceNotSpecified'));
    end

