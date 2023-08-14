function generateCacheFunctions(h,hPjt,modelname,tgtinfo)




    fid=fopen('MW_c5xxx_csl.c','a');

    if isICacheEnabled(h,tgtinfo)

        ramSet=tgtinfo.cache.cacheSize;
        icacheInfo=SetICache(h,ramSet);

        fprintf(fid,'/* Function: turnOn_ICache -----------------------------------\n');
        fprintf(fid,' *                                                            \n');
        fprintf(fid,' * Abstract:                                                  \n');
        fprintf(fid,' *      Turn on the Instruction Cache                         \n');
        fprintf(fid,' */                                                           \n');
        fprintf(fid,'void turnOn_ICache()            \n');
        fprintf(fid,'{                               \n');
        if icacheInfo.icacheSupported
            fprintf(fid,'%s                          \n',icacheInfo.cGenFxnEpilogue);
        end
        fprintf(fid,'}                               \n');
    end

    fclose(fid);


    function self=SetICache(h,ramSet)
        self.c55icache=1;
        self.ramsetMode=ramSet;
        self.r1addrVal='0';
        self.r2addrVal='0';
        self.chipType=GetChipType(h);

        if self.c55icache==1
            includeFile='csl_icache.h';
        else
            includeFile='';
        end


        if(strcmpi(self.chipType,'5510'))||(strcmpi(self.chipType,'5501'))||(strcmpi(self.chipType,'5502'))
            self.icacheSupported=true;
        else
            self.icacheSupported=false;
        end


        switch(self.ramsetMode)
        case '0RAMSet',
            self.ramsetValue=0;
        case '1RAMSet',
            self.ramsetValue=1;
        case '2RAMSet',
            self.ramsetValue=2;
        otherwise
        end

        self.rmodeStr=sprintf('\tICACHE_RSET(ICGC, ICACHE_ICGC_RMODE_%dRAMSET);\n',self.ramsetValue);
        self.icwcStr=sprintf('\tICACHE_FSET(ICWC, WINIT, ICACHE_ICWC_WINIT_WINIT);\n');
        self.icrc1Str=sprintf('\tICACHE_FSET(ICRC1, R1INIT, ICACHE_ICRC1_R1INIT_INIT);\n');
        self.icrc2Str=sprintf('\tICACHE_FSET(ICRC2, R2INIT, ICACHE_ICRC2_R2INIT_INIT);\n');
        self.enableStr=sprintf('\tICACHE_enable();\n');

        if self.ramsetValue==0;
            self.tagsStr=sprintf('');
        else
            if(self.ramsetValue==1)
                self.tagsStr=sprintf([...
                '\tICACHE_FSET(ICRTAG1, R1TAG, ((Uint16)((0x%s >> 12) & 0x0FFFu)));\n',...
                '\twhile(!ICACHE_FGET(ICRC1, R1TVALID));\n'],self.r1addrVal);
            else
                self.tagsStr=sprintf([...
                '\tICACHE_FSET(ICRTAG1, R1TAG, ((Uint16)((0x%s >> 12) & 0x0FFFu)));\n',...
                '\twhile(!ICACHE_FGET(ICRC1, R1TVALID));\n',...
                '\tICACHE_FSET(ICRTAG2, R2TAG, ((Uint16)((0x%s >> 12) & 0x0FFFu)));\n',...
                '\twhile(!ICACHE_FGET(ICRC2, R2TVALID));\n'],self.r1addrVal,self.r2addrVal);
            end
        end

        if(self.icacheSupported&&(self.c55icache==1))
            self.cGenFxnEpilogue=sprintf('%s%s%s%s%s%s\n',...
            self.rmodeStr,...
            self.icwcStr,...
            self.icrc1Str,...
            self.icrc2Str,...
            self.enableStr,...
            self.tagsStr);
        end

        self.icacheInclStr=sprintf('#include <%s>\n',includeFile);
        if(self.c55icache==1)
            self.cGenCPrologue=sprintf('%s\n',self.icacheInclStr);
        end


        function chipType=GetChipType(h)
            chipType=strrep(class(h),'CCSLinkTgtPkg.TMS320C','');





































