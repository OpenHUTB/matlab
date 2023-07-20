
function simCmd=insertXSGSimScripts(this,origSimCmd)



    simCmd=origSimCmd;
    isVivadoXSG=targetcodegen.xilinxvivadosysgendriver.hasXSG;


    if isVivadoXSG
        [simCmd,simScriptDir]=extractSimCmdsFromVivadoPrj(this.CodeGenDirectory,this.TopLevelName,this.TestBenchName);

        if isempty(simCmd)
            simCmd=origSimCmd;
        end


        [~,~]=copyfile(fullfile(this.CodeGenDirectory,'*.dat'),simScriptDir);
        return
    end

    xsgCodeGenPath=targetcodegen.xilinxsysgendriver.getXSGCodeGenPath();
    if(~isempty(xsgCodeGenPath))
        if strcmpi(this.getDUTLanguage,'verilog')

            requiredLibs={'XilinxCoreLib_ver','unisims_ver','simprims_ver'};
            for i=1:length(requiredLibs)
                libName=requiredLibs{i};
                if(isempty(regexp(simCmd,['\s-L\s',libName,'\s'],'once')))
                    simCmd=strrep(simCmd,'vsim',['vsim -L ',libName]);
                end
            end


            for i=1:length(xsgCodeGenPath)
                libName=xsgCodeGenPath{i};
                simCmd=strrep(simCmd,'vsim',['vsim -L ',libName,' ',libName,'.glbl']);
            end
        end
    end
end

function[simCmd,simScriptDir]=extractSimCmdsFromVivadoPrj(codegendir,topname,tbname)
    simCmd='';






    vivadoSysgenQueryFlow=downstream.queryflowmodesenum.VIVADOSYSGEN;
    simPrjName=vivadoSysgenQueryFlow.getTclDirName;


    simScriptFileName=sprintf('%s_simulate.do',tbname);
    hdlsrcRelSimScriptDir=fullfile(simPrjName,sprintf('%s_vivado.sim',topname),'sim_1','behav');
    simScriptDir=fullfile(codegendir,hdlsrcRelSimScriptDir);
    simScriptFilePath=fullfile(simScriptDir,simScriptFileName);

    if exist(simScriptFilePath,'file')
        simScriptContent=fileread(simScriptFilePath);
        [extractedSimCmd,extractedSimCmdIdx]=regexp(simScriptContent,'(?<simCmd>vsim.[^\n]+)\n','names');






        if~isempty(extractedSimCmdIdx)&&isfield(extractedSimCmd,'simCmd')
            simCmd='\nset curDir [pwd]\n';
            simCmd=[simCmd,sprintf('cd %s\n',strrep(hdlsrcRelSimScriptDir,'\','/'))];
            simCmd=[simCmd,sprintf('%s\n',extractedSimCmd(end).simCmd)];
        end
    end

end



