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
        if strcmpi(tgtinfo.mem.bank(i).contents,'Code')
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
    stackfound=0;
    for i=1:tgtinfo.mem.compiler.numSections
        page=['PAGE = ',int2str(strcmpi(tgtinfo.mem.compiler.section(i).contents,'Data'))];
        switch(tgtinfo.mem.compiler.section(i).name)
        case '.reset'
            fprintf(fid,'    %s:\t > %s, %s, TYPE = DSECT\n',tgtinfo.mem.compiler.section(i).name,...
            tgtinfo.mem.compiler.section(i).placement{1},page);
        otherwise
            fprintf(fid,'    %s:\t > %s, %s\n',tgtinfo.mem.compiler.section(i).name,...
            tgtinfo.mem.compiler.section(i).placement{1},page);
        end
        if strcmp(tgtinfo.mem.compiler.section(i).name,'.stack')
            stackfound=1;
        end
    end



    if~stackfound
        datamembank=createDataMemList(tgtinfo.mem);
        fprintf(fid,'    %s:\t > %s\n','.stack',datamembank{1});
    end


    for i=1:tgtinfo.mem.custom.numSections
        fprintf(fid,'    %s:\t > %s\n',tgtinfo.mem.custom.section(i).name,...
        tgtinfo.mem.custom.section(i).placement{1});
    end
    for i=1:mdlinfo.numBoundMemorySections
        sectionName=mdlinfo.boundSectionName{i};
        for j=1:tgtinfo.mem.custom.numSections
            if strcmpi(sectionName,tgtinfo.mem.custom.section(j).name)
                fclose(fid);
                error(message('ERRORHANDLER:tgtpref:CustomMemorySectionAlreadyBound',sectionName));
            end
        end
        fprintf(fid,'    %s:\tload = 0x%s\n',sectionName,...
        dec2hex(mdlinfo.boundSectionStartAddress{i}));
    end
    fprintf(fid,'}\n');

    if~isfield(mdlinfo,'DoNotIncludePeripheralCmdFile')||(~mdlinfo.DoNotIncludePeripheralCmdFile)
        file=fullfile(codertarget.tic2000.internal.getSpPkgRootDir(),'src','c281xPeripherals.cmd');
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


