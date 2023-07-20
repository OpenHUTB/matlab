function writeCompileDoFile(this,varargin)


    if this.GenerateTBCompileDoFile
        topname=this.TestBenchName;
    else
        topname=this.TopLevelName;
    end

    fname=fullfile(this.CodeGenDirectory,[topname,this.CompileDoFilePostFix]);
    fid=fopen(fname,'w');
    c=onCleanup(@()fclose(fid));
    if fid==-1
        error(message('HDLShared:hdlshared:compileopenfile'));
    end







    blackList={'.xdc','.sdc','.ucf'};


    hasVivadoSysgenIslands=targetcodegen.xilinxvivadosysgendriver.hasXSG;


    n_CheckForThirdPartyLibraries();


    if hasVivadoSysgenIslands
        insertVivadoXSGCompileScripts(this,fid,topname);
        return
    end



    hdlnames=this.entityFileNames;




    if this.IsVHDL

        topLevelLibName=hdlgetparameter('top_level_vhdl_library_name');
        simcompilecmd=this.HdlCompileVhdlCmd;
    else
        topLevelLibName='work';
        simcompilecmd=this.HdlCompileVerilogCmd;
    end




    simCompileflags=this.SimulatorFlags;

    hdlnamesStartIdx=1;

    if strcmpi(this.SimulationTool,'Mentor Graphics Modelsim')
        hD=hdlcurrentdriver;


        n_ModelsimScriptSetup();

        simelaborationcmd='';
        simElaborationflags='';

        n_AddCodeCoverage();
    elseif strcmpi(this.SimulationTool,'Cadence Incisive')


        n_IncisiveScriptSetup();


        simelaborationcmd=this.HdlElaborationCmd;
        simElaborationflags=this.HdlElaborationFlags;

        n_AddCodeCoverage();
    else


        if this.HDLCodeCoverage
            warning(message('hdlcoder:hdlverifier:CodeCoverageNotAvailableForCustomTool'));
        end



        simelaborationcmd='';
        simElaborationflags='';
        fprintf(fid,this.HdlCompileInit,topLevelLibName);
    end

    for n=hdlnamesStartIdx:length(hdlnames)

        [~,~,ext]=fileparts(hdlnames{n});
        if~ismember(ext,blackList)
            fprintf(fid,simcompilecmd,simCompileflags,hdlnames{n});
        end

        if~this.GenerateTBCompileDoFile&&n==length(hdlnames)











            if~this.IsTopModel&&isempty(this.SubModelData)||...
                ~isempty(this.SubModelData)&&~this.IsTopModel
                fprintf(fid,simelaborationcmd,simElaborationflags,strtok(hdlnames{n},'.'));
            else
                fprintf(fid,simelaborationcmd,simElaborationflags,topname);
            end
        end
    end


    if this.GenerateTBCompileDoFile

        hdltbnames=this.TestBenchFilesList;
        for n=1:length(hdltbnames)
            fprintf(fid,simcompilecmd,simCompileflags,hdltbnames{n});

            if n==length(hdltbnames)

                fprintf(fid,simelaborationcmd,simElaborationflags,topname);
            end
        end
    end

    fprintf(fid,this.HdlCompileTerm);




    function n_ModelsimScriptSetup()

        [singleLib,libname,~,~,relPath]=l_getSimulatorIndependentVars(this);

        if this.IsVHDL

            if singleLib
                if strcmp(topLevelLibName,'work')
                    simCompileflags=this.SimulatorFlags;
                else
                    simCompileflags=sprintf('-work %s %s',topLevelLibName,this.SimulatorFlags);
                end
            else
                if strcmp(libname,'work')
                    simCompileflags=this.SimulatorFlags;
                else
                    simCompileflags=sprintf('-work %s %s',libname,this.SimulatorFlags);
                end
            end
        else
            simCompileflags=this.SimulatorFlags;
        end

        vmap_cEmitted=false;

        if~isempty(this.SubModelData)||this.IsTopModel


            if(~singleLib&&~isempty(this.SubModelData))||(singleLib&&this.IsTopModel)
                fprintf(fid,'vmap -c\n');
                vmap_cEmitted=true;
            end



            if this.IsTopModel
                fprintf(fid,this.HdlCompileInit,topLevelLibName);
            end



            if singleLib
                fprintf(fid,'vmap %s%s\n\n',topLevelLibName,[relPath,topLevelLibName]);
                if this.IsVHDL
                    pkgSuffix=hD.getParameter('package_suffix');
                    vhdlFileExt=hD.getParameter('vhdl_file_ext');
                    if regexp(hdlnames{1},[pkgSuffix,vhdlFileExt,'$'])
                        fprintf(fid,simcompilecmd,simCompileflags,hdlnames{1});
                        hdlnamesStartIdx=2;
                    end
                end
            end

            for ii=1:numel(this.SubModelData)
                if this.IsTopModel

                    fprintf(fid,'cd %s\n',this.SubModelData(ii).ModelName);
                    fprintf(fid,'do %s_compile.do\n',this.SubModelData(ii).ModelName);
                    fprintf(fid,'cd ..\n');
                end



                if~singleLib
                    if this.IsVHDL
                        subLibName=this.SubModelData(ii).LibName;
                    else
                        subLibName='work';
                    end
                    fprintf(fid,'vmap %s%s\n',this.SubModelData(ii).LibName,...
                    [relPath,this.SubModelData(ii).ModelName,'/',subLibName]);
                end
            end
        end



        if~singleLib&&~this.IsTopModel
            if~strcmpi(topLevelLibName,'work')
                fprintf(fid,this.HdlCompileInit,libname);
                fprintf(fid,'vmap %s%s\n',topLevelLibName,[relPath,topLevelLibName]);
            else
                fprintf(fid,this.HdlCompileInit,libname);
            end
        elseif singleLib&&isempty(this.SubModelData)
            fprintf(fid,'vmap %s%s\n',topLevelLibName,[relPath,topLevelLibName]);
        end

        if this.GenerateTargetCodegenFile
            if~vmap_cEmitted
                fprintf(fid,'vmap -c\n');
                vmap_cEmitted=true;
            end
            this.writeTargetCodeGenHeaders(fid);
        end
        vmap_cEmitted=this.insertIseXSGCompileScripts(fid,vmap_cEmitted);%#ok<NASGU>
        vmap_cEmitted=this.insertDSPBACompileScripts(fid,vmap_cEmitted);%#ok<NASGU>
    end


    function n_IncisiveScriptSetup()

        [IsSingleLib,libname,CurrModeRelPath,CreateLocalLib,ChildModelsRelPath]=l_getSimulatorIndependentVars(this);

        IsModelRef=~isempty(this.SubModelData);

        IsSingleLib=IsSingleLib&&this.IsVHDL;



        if CreateLocalLib

            CompileInit=sprintf('%s%s',this.HdlCompileInit,'mkdir %s\n');
        else

            CompileInit=this.HdlCompileInit;
            libname=topLevelLibName;
        end



        if~this.IsVHDL
            libname=this.VhdlLibraryName;
        end

        if strcmpi(this.TargetLanguage,'SystemVerilog')

            simCompileflags=sprintf([simCompileflags,'\t%s'],'-sv');
        end


        AuxiliaryFiles=containers.Map({'cds.lib','hdl.var'},...
        {'softinclude $INSTALL_DIR/tools/inca/files/cds.lib\n',...
        'softinclude $INSTALL_DIR/tools/inca/files/hdl.var\n'});

        if IsModelRef
            if IsSingleLib


                AuxiliaryFiles('cds.lib')=sprintf([AuxiliaryFiles('cds.lib'),'%s\n'],['DEFINE ',libname,CurrModeRelPath,libname]);

                simCompileflags=sprintf([simCompileflags,'\t%s\t%s'],'-work',libname);


                if this.IsTopModel
                    for idx=1:numel(this.SubModelData)
                        CompileInit=sprintf('%s%s',CompileInit,...
                        sprintf('cd %s\nsh %s_compile.sh\ncd ..\n',...
                        this.SubModelData(idx).ModelName,this.SubModelData(idx).ModelName));
                    end
                end

                fprintf(fid,CompileInit,libname);
            else

                for idx=1:numel(this.SubModelData)



                    AuxiliaryFiles('cds.lib')=sprintf([AuxiliaryFiles('cds.lib'),'%s\n'],...
                    ['DEFINE ',...
                    this.SubModelData(idx).LibName,...
                    [ChildModelsRelPath,this.SubModelData(idx).ModelName,'/',this.SubModelData(idx).LibName]]);


                    if this.IsTopModel
                        CompileInit=sprintf('%s%s',CompileInit,...
                        sprintf('cd %s\n sh %s_compile.sh\n cd ..\n',...
                        this.SubModelData(idx).ModelName,this.SubModelData(idx).ModelName));
                    end

                end


                AuxiliaryFiles('cds.lib')=sprintf([AuxiliaryFiles('cds.lib'),'%s\n'],['DEFINE ',libname,CurrModeRelPath,libname]);

                if~this.IsTopModel
                    AuxiliaryFiles('cds.lib')=sprintf([AuxiliaryFiles('cds.lib'),'%s\n'],['DEFINE ',topLevelLibName,ChildModelsRelPath,topLevelLibName]);
                end


                fprintf(fid,CompileInit,libname);

                simCompileflags=sprintf([simCompileflags,'\t%s\t%s'],'-work',libname);
            end
        else

            AuxiliaryFiles('cds.lib')=sprintf([AuxiliaryFiles('cds.lib'),'%s\n'],['DEFINE ',libname,CurrModeRelPath,libname]);

            if~this.IsTopModel&&~IsSingleLib
                AuxiliaryFiles('cds.lib')=sprintf([AuxiliaryFiles('cds.lib'),'%s\n'],['DEFINE ',topLevelLibName,' ../',topLevelLibName]);
            end


            fprintf(fid,CompileInit,libname);

            simCompileflags=sprintf([simCompileflags,'\t%s\t%s'],'-work',libname);
        end
        l_writeAuxiliaryFiles(this,AuxiliaryFiles);
    end

    function n_AddCodeCoverage()
        if this.HDLCodeCoverage

            if~(builtin('license','checkout','EDA_Simulator_Link'))
                error(message('hdlcoder:hdlverifier:HDLVerifierNotAvailable','Code coverage'));
            end
            simCompileflags=sprintf('%s %s',simCompileflags,this.HdlCodeCoverageCompilationFlag);
            simElaborationflags=sprintf('%s %s',simElaborationflags,this.HdlCodeCoverageElaborationFlag);
        end
    end

    function n_CheckForThirdPartyLibraries()
        IsSimToolModelSim=strcmpi(this.SimulationTool,'Mentor Graphics Modelsim');



        VivadoSysgenBlockAllowed=IsSimToolModelSim||~hasVivadoSysgenIslands;
        assert(VivadoSysgenBlockAllowed,message('HDLShared:hdlshared:NonModelsimScriptsNotSupportedForThirdPartyLibs','Vivado Sysgen'));




        xsgCodeGenPath=targetcodegen.xilinxsysgendriver.getXSGCodeGenPath();
        XilinxSysGenAllowed=IsSimToolModelSim||isempty(xsgCodeGenPath);
        assert(XilinxSysGenAllowed,message('HDLShared:hdlshared:NonModelsimScriptsNotSupportedForThirdPartyLibs','Xilinx Sysgen'));




        dspbaCodeGenPath=targetcodegen.alteradspbadriver.getDSPBACodeGenPath();
        AlteraDSPGenAllowed=IsSimToolModelSim||isempty(dspbaCodeGenPath);
        assert(AlteraDSPGenAllowed,message('HDLShared:hdlshared:NonModelsimScriptsNotSupportedForThirdPartyLibs','Altera DSP libraries'));


        IsAlteraFPUsed=isTargetFloatingPointMode&&~(isNativeFloatingPointMode()||hdlgetparameter('nativefloatingpoint'));
        AlteraFPGenAllowed=IsSimToolModelSim||~IsAlteraFPUsed;
        assert(AlteraFPGenAllowed,message('HDLShared:hdlshared:NonModelsimScriptsNotSupportedForThirdPartyLibs','Altera floating point libraries'));
    end
end

function l_writeAuxiliaryFiles(this,AuxiliaryFilesContent)
    for idx=keys(AuxiliaryFilesContent)
        AuxiliaryFileName=idx{1};
        fname=fullfile(this.CodeGenDirectory,AuxiliaryFileName);
        fid=fopen(fname,'w');
        if fid==-1
            error(message('HDLShared:hdlshared:compileopenfile'));
        end
        fprintf(fid,AuxiliaryFilesContent(AuxiliaryFileName));
        fclose(fid);
    end
end

function[singleLib,libname,CurrModelRelPath,CreateLocalLib,ChildModelsRelPath]=l_getSimulatorIndependentVars(this)










    singleLib=hdlgetparameter('use_single_library');


    if this.IsVHDL
        libname=this.VhdlLibraryName;
    else
        libname=this.VerilogLibraryName;
    end













    ChildModelsRelPath=' ';
    if this.IsTopModel
        CurrModelRelPath=' ';
    else

        ChildModelsRelPath=' ../';
        if singleLib
            CurrModelRelPath=' ../';
        else
            CurrModelRelPath=' ';
        end
    end






    if~this.IsTopModel&&singleLib
        CreateLocalLib=false;
    else
        CreateLocalLib=true;
    end

end


