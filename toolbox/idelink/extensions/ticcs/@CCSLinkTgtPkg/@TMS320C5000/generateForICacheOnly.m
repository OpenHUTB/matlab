function generateForICacheOnly(h,modelname,tgtinfo)




    fid=fopen('MW_c5xxx_csl.c','a');

    if isICacheEnabled(h,tgtinfo)

        fprintf(fid,'void turnOn_ICache()\n');
        fprintf(fid,'{                                      \n');
        fprintf(fid,'   ICACHE_Config icacheCfg = {\n');
        fprintf(fid,'       0x0000, /* Global Control   */  \n');
        fprintf(fid,'       };                              \n');
        fprintf(fid,'   ICACHE_config(&icacheCfg);          \n');
        fprintf(fid,'   ICACHE_enable();                    \n');
        fprintf(fid,'}                                      \n');
    end

    fclose(fid);

