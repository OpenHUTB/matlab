function writeCompileDoFile(this,varargin)






    if this.GenerateTBCompileDoFile
        topname=this.TestBenchName;
    else
        topname=this.TopLevelName;
    end


    hdlnames=this.entityFileNames;
    hdltbnames=this.TestBenchFilesList;

    fname=fullfile(this.CodeGenDirectory,...
    [topname,this.CompileDoFilePostFix]);

    fid=fopen(fname,'w');

    if fid==-1
        error(message('HDLShared:hdlshared:compileopenfile'));
    end

    tlang=this.getDUTLanguage;

    if strcmpi(tlang,'vhdl')
        simcompilecmd=this.HdlCompileVhdlCmd;

        if strcmp(hdlgetparameter('vhdl_library_name'),'work')
            simflags=this.SimulatorFlags;
        else
            simflags=['-work ',hdlgetparameter('vhdl_library_name'),' ',this.SimulatorFlags];
        end
    else
        simcompilecmd=this.HdlCompileVerilogCmd;
        simflags=this.SimulatorFlags;
    end

    fprintf(fid,this.HdlCompileInit,hdlgetparameter('vhdl_library_name'));

    this.writeTargetCodeGenHeaders(fid);

    for n=1:length(hdlnames)
        fprintf(fid,simcompilecmd,...
        simflags,...
        hdlnames{n});
    end


    if this.GenerateTBCompileDoFile
        if this.IsVHDL
            simcompilecmd=this.HdlCompileVhdlCmd;
        else
            simcompilecmd=this.HdlCompileVerilogCmd;
        end


        for n=1:length(hdltbnames)
            fprintf(fid,simcompilecmd,...
            simflags,...
            hdltbnames{n});
        end

    end

    fprintf(fid,this.HdlCompileTerm);

    fclose(fid);
