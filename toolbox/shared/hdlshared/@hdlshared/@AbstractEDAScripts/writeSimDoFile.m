function writeSimDoFile(this,varargin)


    if nargin==3
        epl=varargin{1};
        epl_out_ref=varargin{2};
    else
        [epl,epl_out_ref]=this.getPortList;
    end

    if this.GenerateTBCompileDoFile
        topname=this.TestBenchName;
    else
        topname=hdlentitytop;
    end

    fname=fullfile(this.CodeGenDirectory,[topname,this.SimDoFilePostFix]);
    fid=fopen(fname,'w');
    if fid==-1
        error(message('HDLShared:hdlshared:simopenfile'));
    end
    fprintf(fid,this.HdlSimInit);

    simCmd=this.HdlSimCmd;

    if~strcmpi(this.SimulationTool,'Custom')

        n_AddCodeCoverage('AddInstrumentation');
        if strcmpi(this.SimulationTool,'Mentor Graphics Modelsim')

            simCmd=this.getTargetSpecificSimCmd(simCmd);

            simCmd=insertXSGSimScripts(this,simCmd);
        end
    end


    if hdlgetparameter('isvhdl')
        libname=this.VhdlLibraryName;
    else
        libname=this.VerilogLibraryName;
        if~isempty(this.SubModelData)&&strcmpi(this.SimulationTool,'Mentor Graphics Modelsim')
            simCmd=insertSubModelLibraries(this,simCmd);
        end
    end

    if strcmpi(this.SimulationTool,'Cadence Incisive')

        fprintf(fid,simCmd,'',topname);
        HdlSimViewWaveRefPrefix='';
        HdlSimViewWavePrefix='';
    else
        fprintf(fid,simCmd,libname,topname);
        HdlSimViewWaveRefPrefix=sprintf('/%s/',this.TestBenchName);
        HdlSimViewWavePrefix=sprintf('/%s/%s%s%s/',this.TestBenchName,...
        hdlgetparameter('instance_prefix'),...
        char(this.TopLevelName),...
        hdlgetparameter('instance_postfix'));
    end


    tbref_postfix=hdlgetparameter('testbenchreferencepostfix');

    fprintf(fid,'%s\n',this.HdlSimViewWaveSetupCmd);
    for n=1:length(epl)
        fprintf(fid,this.HdlSimViewWaveCmd,...
        sprintf('%s%s',HdlSimViewWavePrefix,epl{n}));
        if~isempty(epl_out_ref{n})
            fprintf(fid,this.HdlSimViewWaveCmd,...
            sprintf('%s%s%s',HdlSimViewWaveRefPrefix,epl{n},tbref_postfix));
        end
    end


    inst_prefix=hdlgetparameter('instance_prefix');
    initScriptName=[this.TopLevelName,'_',hdlgetparameter('NoResetInitScript')];
    if strcmpi(hdlgetparameter('NoResetInitializationMode'),'Script')&&...
        exist(fullfile(this.CodeGenDirectory,initScriptName),'file')==2&&...
        strcmpi(this.SimulationTool,'Mentor Graphics Modelsim')
        dutFullPath=['/',this.TestBenchName,'/',inst_prefix];
        fprintf(fid,['set ::dut_prefix ',dutFullPath,'\n']);
        fprintf(fid,['do ',initScriptName,'\n']);
    end


    if strcmpi(hdlgetparameter('NoResetInitializationMode'),'Script')&&...
        hdlgetparameter('MinimizeGlobalResets')&&...
        ~strcmpi(this.SimulationTool,'Mentor Graphics Modelsim')
        warning(message('HDLShared:hdlshared:ScriptNoResetInitializationModeNotSupportedForNonModelsim'));
    end


    if~strcmpi(this.SimulationTool,'Custom')

        n_AddCodeCoverage('GenerateReport');
    end

    fprintf(fid,this.HdlSimTerm);
    fclose(fid);


    function n_AddCodeCoverage(Phase)
        if this.HDLCodeCoverage

            if~(builtin('license','checkout','EDA_Simulator_Link'))
                error(message('hdlcoder:hdlverifier:HDLVerifierNotAvailable','Code coverage'));
            end

            switch Phase
            case 'AddInstrumentation'
                [Cmd,Args]=strtok(simCmd);
                simCmd=[Cmd,' ',this.HdlCodeCoverageSimulationFlag,Args];
            case 'GenerateReport'
                this.HdlSimTerm=[this.HdlSimTerm,this.HdlCodeCoverageReportGen];
            end
        end
    end

end

function simCmd=insertSubModelLibraries(this,simCmd)
    if hdlgetparameter('use_single_library')
        simCmd=strrep(simCmd,'vsim','vsim -L work');
    else
        for ii=1:numel(this.SubModelData)
            libName=this.SubModelData(ii).LibName;
            if isempty(regexp(simCmd,['\s-L\s',libName,'\s'],'once'))
                simCmd=strrep(simCmd,'vsim',['vsim -L ',libName]);
            end



            simCmd=strrep(simCmd,'vsim','vsim -L work');
        end
    end
end
