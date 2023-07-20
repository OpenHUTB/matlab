function linkerCmdFile=generateLinkerCMDFile(~,modelname,tgtinfo,mdlinfo)



    tgtinfo.mem.custom=convertPlacementsToCell(tgtinfo.mem.custom);
    tgtinfo.mem.compiler=convertPlacementsToCell(tgtinfo.mem.compiler);
    linkerCmdFile=[modelname,'.cmd'];

    fid=fopen(linkerCmdFile,'w');

    hPM=linkfoundation.pjtgenerator.getProjectManager(modelname);

    if~isempty(hPM)
        linkerFileFullPath=fullfile(pwd,linkerCmdFile);
        hPM.mProjectBuildInfo.markForRemovalFromLibPjt(linkerFileFullPath);
        hPM.mProjectBuildInfo.markForPILPjt(linkerFileFullPath);
    end

    if mdlinfo.RTDXIntNeeded
        fprintf(fid,'_RTDX_interrupt_mask = ~0x000000008; /* int used by RTDX */\n');
    end

    fprintf(fid,'MEMORY\n');
    fprintf(fid,'{\n');
    fprintf(fid,'PAGE 0:\n');
    for i=1:tgtinfo.mem.numBanks
        if(strcmpi(tgtinfo.mem.bank(i).contents,'Code')||...
            strcmpi(tgtinfo.mem.bank(i).contents,'Code & Data'))
            fprintf(fid,'    %s:\t origin=0x%x, length=0x%x\n',tgtinfo.mem.bank(i).name,...
            tgtinfo.mem.bank(i).addr,...
            tgtinfo.mem.bank(i).size);
        end
    end
    fprintf(fid,'PAGE 1:\n');
    for i=1:tgtinfo.mem.numBanks
        if strcmpi(tgtinfo.mem.bank(i).contents,'Data')
            fprintf(fid,'    %s:\t origin=0x%x, length=0x%x\n',tgtinfo.mem.bank(i).name,...
            tgtinfo.mem.bank(i).addr,...
            tgtinfo.mem.bank(i).size);
        end
    end
    fprintf(fid,'}\n');

    fprintf(fid,'SECTIONS\n');
    fprintf(fid,'{\n');
    fprintf(fid,'    .vectors:\t load = 0x000000000\n');
    flashfound=false;
    for i=1:tgtinfo.mem.compiler.numSections
        if strcmp(tgtinfo.mem.compiler.section(i).placement{1},'FLASH')
            flashfound=true;
        end
    end


    if isSimulator(modelname)
        loadstr='';
    else
        loadstr=', TYPE = NOLOAD';
    end
    for i=1:tgtinfo.mem.compiler.numSections
        for j=1:tgtinfo.mem.numBanks
            if strcmp(tgtinfo.mem.compiler.section(i).placement{1},tgtinfo.mem.bank(j).name)
                page=['PAGE = ',int2str(strcmpi(tgtinfo.mem.bank(j).contents,'Data'))];
            end
        end
        switch(tgtinfo.mem.compiler.section(i).name)
        case '.reset'
            fprintf(fid,'    %s:\t > %s, %s, TYPE = DSECT\n',tgtinfo.mem.compiler.section(i).name,...
            tgtinfo.mem.compiler.section(i).placement{1},page);
        case '.adc_cal'
            if~strcmpi(tgtinfo.mem.compiler.section(i).placement{1},'ADC_CAL')
                fprintf(fid,'    %s:\t > %s, %s\n',tgtinfo.mem.compiler.section(i).name,...
                tgtinfo.mem.compiler.section(i).placement{1},page);
            elseif isempty(loadstr)
                fprintf(fid,'    %s:\t > %s, %s\n',tgtinfo.mem.compiler.section(i).name,...
                'RAMM0',page);
            else
                fprintf(fid,'    %s:\t > %s, %s %s\n',tgtinfo.mem.compiler.section(i).name,...
                tgtinfo.mem.compiler.section(i).placement{1},page,loadstr);
            end
        case 'ramfuncs'
            if(flashfound)
                fprintf(fid,'    %s:\t %s,\n\t\t%s%s,\n\t\t%s,\n\t\t%s,\n\t\t%s,\n\t\t%s\n',...
                tgtinfo.mem.compiler.section(i).name,...
                'LOAD = FLASH',...
                'RUN = ',tgtinfo.mem.compiler.section(i).placement{1},...
                'LOAD_START(_RamfuncsLoadStart)',...
                'LOAD_END(_RamfuncsLoadEnd)',...
                'RUN_START(_RamfuncsRunStart)',...
                'PAGE = 0');
            else
                fprintf(fid,'    %s:\t > %s, %s\n',tgtinfo.mem.compiler.section(i).name,...
                tgtinfo.mem.compiler.section(i).placement{1},page);
            end
        otherwise
            fprintf(fid,'    %s:\t > %s, %s\n',tgtinfo.mem.compiler.section(i).name,...
            tgtinfo.mem.compiler.section(i).placement{1},page);
        end
    end

    fprintf(fid,'    %s:\t > %s, PAGE = 0 %s\n','IQmathTables','IQTABLES',loadstr);
    fprintf(fid,'    %s:\t > %s, PAGE = 0 %s\n','IQmathTables2','IQTABLES2',loadstr);
    fprintf(fid,'    %s:\t > %s, PAGE = 0 %s\n','FPUmathTables','FPUTABLES',loadstr);

    for i=1:tgtinfo.mem.custom.numSections
        fprintf(fid,'    %s:\t > %s\n',tgtinfo.mem.custom.section(i).name,...
        tgtinfo.mem.custom.section(i).placement{1});
    end
    for i=1:mdlinfo.numBoundMemorySections
        sectionName=mdlinfo.boundSectionName{i};
        for j=1:tgtinfo.mem.custom.numSections
            if strcmpi(sectionName,tgtinfo.mem.custom.section(j).name)
                fclose(fid);
                error(message('ERRORHANDLER:tgtpref:CustomMemorySectionAlreadyBound',...
                sectionName));
            end
        end
        fprintf(fid,'    %s:\tload = 0x%s\n',sectionName,...
        dec2hex(mdlinfo.boundSectionStartAddress{i}));
    end
    if mdlinfo.numADCs>0
        [isfound,bankidx]=ismember('RAML4L7',{tgtinfo.mem.bank.name});
        if isfound
            sectaddr=hex2dec('FFFC');
        else
            [isfound,bankidx]=ismember('RAML3L5',{tgtinfo.mem.bank.name});
            sectaddr=hex2dec('DFFC');
        end
        pagenum=strcmpi(tgtinfo.mem.bank(bankidx).contents,'Data');
    end
    for i=1:mdlinfo.numADCs
        if mdlinfo.ADC{i}.DMACH>0
            if~isequal(mdlinfo.ADC{i}.useModule,'B')
                bufsize=2*str2num(mdlinfo.ADC{i}.numch_A);
                if isequal(mdlinfo.ADC{i}.useMode,'Simultaneous'),bufsize=bufsize*2;end
                sectaddr=sectaddr-bufsize;
                sectname='DMA_SEC_A';
            else
                bufsize=2*str2num(mdlinfo.ADC{i}.numch_B);
                sectaddr=sectaddr-bufsize;
                sectname='DMA_SEC_B';
            end
            fprintf(fid,'    %s:\tload = 0x%s, PAGE = %d\n',sectname,...
            dec2hex(sectaddr),pagenum);
        end
    end
    fprintf(fid,'}\n');

    if~isfield(mdlinfo,'DoNotIncludePeripheralCmdFile')||(~mdlinfo.DoNotIncludePeripheralCmdFile)
        file=fullfile(codertarget.tic2000.internal.getSpPkgRootDir(),'src','c2833xPeripherals.cmd');
        fprintf(fid,'-l "%s"\n',file);
    end

    fclose(fid);


    function memList=createDataMemList(mem)
        memList={};
        for i=1:mem.numBanks,
            if~strcmpi(mem.bank(i).contents,'Code')
                memList={memList{:},mem.bank(i).name};
            end
        end


        function obj=convertPlacementsToCell(obj)
            for i=1:obj.numSections
                val=obj.section(i).placement;
                if ischar(val)
                    obj.section(i).placement={val};
                end
            end


            function isSim=isSimulator(modelname)

                isSim=false;
                PM=linkfoundation.pjtgenerator.getProjectManager(modelname);
                try
                    if~isempty(PM.mAutomationHandle)
                        info=PM.mAutomationHandle.info;
                        isSim=isfield(info,'targettype')&&strcmpi(info.targettype,'simulator');
                    end
                catch
                end


