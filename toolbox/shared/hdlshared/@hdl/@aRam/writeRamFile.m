function writeRamFile(this,str)






    fid=fopen(this.fullFileName,'w');
    fprintf(fid,str);
    fclose(fid);
