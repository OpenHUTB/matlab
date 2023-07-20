function linkerCmdFile=generateLinkerCMDFile(h,modelname,tgtinfo,mdlinfo)




    linkerCmdFile=[modelname,'.cmd'];
    fid=fopen(linkerCmdFile,'w');
    fprintf(fid,'\n');
    fclose(fid);
