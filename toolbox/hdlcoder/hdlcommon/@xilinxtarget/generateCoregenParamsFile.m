function[fid,mfparamsTempFile]=generateCoregenParamsFile(targetCompInventory,latency)




    currDir=pwd;
    hC=hdlcurrentdriver;
    targetDir=hC.hdlGetCodegendir;
    targetCompInventory.createDirIfNeeded(targetDir);
    cd(targetDir);
    mfparamsTempFile=sprintf('%s_xilinxcoregen_params.xco',tempname(pwd));
    cd(currDir);
    fid=fopen(mfparamsTempFile,'w');
    if fid==-1
        error(message('hdlcommon:targetcodegen:CurrentDirNotWritable'));
    end

    fprintf(fid,'# Setting a Project\n');
    fprintf(fid,'NEWPROJECT "%s"\n',targetCompInventory.getXilinxProjectPath(latency,false));


    fprintf(fid,'# BEGIN Project Options\n');
    targetLanguage=hdlgetparameter('target_language');
    if strcmpi(targetLanguage,'vhdl')
        lang='VHDL';
        fprintf(fid,'SET verilogsim = false\n');
        fprintf(fid,'SET vhdlsim = true\n');
    else
        lang='Verilog';
        fprintf(fid,'SET verilogsim = true\n');
        fprintf(fid,'SET vhdlsim = false\n');
    end
    fprintf(fid,'SET designentry = %s\n',lang);
    deviceDetails=hdlgetdeviceinfo;
    if(isempty(deviceDetails{1}))
        warning(message('hdlcommon:targetcodegen:DeviceNotSpecified'));
    end
    fprintf(fid,'SET devicefamily = %s\n',deviceDetails{1});
    fprintf(fid,'SET device = %s\n',deviceDetails{2});
    fprintf(fid,'SET package = %s\n',deviceDetails{3});
    fprintf(fid,'SET speedgrade = %s\n',deviceDetails{4});
    fprintf(fid,'SET implementationfiletype = Ngc\n');
    fprintf(fid,'SET simulationfiles = Structural\n');







    fprintf(fid,'# END Project Options\n');


    fprintf(fid,'# BEGIN Select\n');
    fprintf(fid,'SELECT Floating-point family Xilinx,_Inc. 5.0\n');
    fprintf(fid,'# END Select\n');





