function uvmbuild(dut,seq,scr,varargin)
































    dut=convertStringsToChars(dut);
    seq=convertStringsToChars(seq);
    scr=convertStringsToChars(scr);

    if nargin>3
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    p=inputParser;
    p.addRequired('dut',@(x)l_validateSLHandles(x,'dut'));
    p.addRequired('sequence',@(x)l_validateSLHandles(x,'sequence'));
    p.addRequired('scoreboard',@(x)l_validateSLHandles(x,'scoreboard'));
    p.addParameter('driver','',@(x)l_validateSLHandles(x,'driver'));
    p.addParameter('monitor','',@(x)l_validateSLHandles(x,'monitor'));
    p.addParameter('predictor','',@(x)l_validateSLHandles(x,'predictor'));
    p.addParameter('config',uvmcodegen.uvmconfig(),@(x)assert(isa(x,'uvmcodegen.uvmconfig'),message('HDLLink:uvmgenerator:InvalidConfigObj')));

    p.addParameter('GenerateTop','on',@(x)any(validatestring(x,{'on','off'})));
    p.parse(dut,seq,scr,varargin{:});
    dut=getfullname(p.Results.dut);
    seq=getfullname(p.Results.sequence);
    scr=getfullname(p.Results.scoreboard);

    if isempty(p.Results.driver)
        drv=p.Results.driver;
    else
        drv=getfullname(p.Results.driver);
    end

    if isempty(p.Results.monitor)
        mon=p.Results.monitor;
    else
        mon=getfullname(p.Results.monitor);
    end

    if isempty(p.Results.predictor)
        pred=p.Results.predictor;
    else
        pred=getfullname(p.Results.predictor);
    end
    OptionalComponent={drv,mon,pred};
    OptionalComponent=OptionalComponent(cellfun(@(x)~isempty(x),OptionalComponent));
    UVM_SubSystems=[{seq,dut,scr},OptionalComponent];

    assert(numel(unique(UVM_SubSystems))==numel(UVM_SubSystems),...
    message('HDLLink:uvmgenerator:DuplicateSubSys'));




















    ss_names=cellfun(@(x)get_param(x,'Name'),UVM_SubSystems,'UniformOutput',false);
    cg_names=cellfun(@(x)uvmcodegen.getSLC_MdlName(x),ss_names,'UniformOutput',false);
    nameDiffs=find(~strcmp(ss_names,cg_names));
    if~isempty(nameDiffs)
        fstr=arrayfun(@(x)(sprintf('%s --> %s\n',ss_names{x},cg_names{x})),nameDiffs,'UniformOutput',false);
        error(message('HDLLink:uvmgenerator:CompNameNotValidIdentifier',...
        sprintf('%s',fstr{:})));
    end

    GenerateTop=p.Results.GenerateTop;%#ok<NASGU>


    top_model=bdroot(dut);


    MsgCtlgId={'stf','interface','toolchain','customization','dpigentb','runerrorchecks','templatetype'};

    CfgPropName={'SystemTargetFile','DPIPortConnection','Toolchain','DPICustomizeSystemVerilogCode','DPIGenerateTestBench','DPIReportRunTimeError','DPIComponentTemplateType'};


    action_ids=char(join(MsgCtlgId(not(cellfun(@(x)l_IsConfigParameterValid(top_model,x),CfgPropName))),','));
    if~isempty(action_ids)

        throw(MSLException(message('HDLLink:uvmgenerator:INVALID_CONFIG',action_ids,top_model)));
    end

    if strcmp('ModelReference',get_param(dut,'BlockType'))


        dut_top_name=get_param(dut,'ModelName');
        dut_action_ids=char(join(MsgCtlgId(not(cellfun(@(x)l_IsConfigParameterValid(dut_top_name,x),CfgPropName))),','));
        if~isempty(dut_action_ids)

            throw(MSLException(message('HDLLink:uvmgenerator:INVALID_CONFIG',dut_action_ids,dut_top_name)));
        end

        if~strcmp(get_param(top_model,'DPIScalarizePorts'),get_param(dut_top_name,'DPIScalarizePorts'))
            throw(MSLException(message('HDLLink:uvmgenerator:MdlRefConfigNotMatchTopMdl','scalarizeports',dut_top_name,get_param(top_model,'DPIScalarizePorts'),top_model)));
        end

        if~strcmp(get_param(top_model,'DPICompositeDataType'),get_param(dut_top_name,'DPICompositeDataType'))
            throw(MSLException(message('HDLLink:uvmgenerator:MdlRefConfigNotMatchTopMdl','compositedatatype',dut_top_name,get_param(top_model,'DPICompositeDataType'),top_model)));
        end
    end

    cfgProps=p.Results.config;
    uvm_build_path=[top_model,'_uvm_testbench'];
    dpi_build_path=[top_model,'_dpi_components'];


    abs_build_path_uvm=fullfile(cfgProps.buildDirectory,uvm_build_path);
    abs_build_path_dpi=fullfile(cfgProps.buildDirectory,dpi_build_path);

    currdir=pwd;
    c=onCleanup(@()cd(currdir));

    mkdir(abs_build_path_dpi);

    mcfg=uvmcodegen.mwconfig(dut,'build_path',dpi_build_path,'abs_build_path',abs_build_path_dpi);

    ucfg=p.Results.config;
    ucfg.CreateUVMDirHierarchy(abs_build_path_uvm,[~isempty(drv),~isempty(mon),~isempty(pred)])


    dpigenerator_disp('Starting DPI subsystem generation for UVM test bench');


    cfg=Simulink.fileGenControl('getConfig');
    cfg.CodeGenFolder=fullfile(abs_build_path_dpi);
    cfg.CacheFolder=fullfile(currdir);

    Simulink.fileGenControl('setConfig','config',cfg);


    c_simulink=onCleanup(@()(restoreCodegenConfig()));


    sluvm=uvmcodegen.SimulinkUVM('mwcfg',mcfg,'ucfg',ucfg,'seqblk_path',seq,'scrblk_path',scr,'drvblk_path',drv,'monblk_path',mon,'gldblk_path',pred);
    uvmbfm=uvmcodegen.uvm_component('mwcfg',mcfg,'ucfg',ucfg,'mwpath',mcfg.sldut_path,'IsDUTBuild',true,'UVMComponent','DPI_dut','uvmobj_type','uvm_transaction');
    uvmseq=uvmcodegen.uvm_sequence('mwcfg',mcfg,'ucfg',ucfg,'mwpath',sluvm.seqblk_path,'UVMComponent','sequence');
    svif=uvmcodegen.sv_interface('mwcfg',mcfg,'ucfg',ucfg,'dut_codeinfo',uvmbfm.mwblkUVMVCodeInfo,'UVMComponent','uvm_artifacts');
    uvmdrv=uvmcodegen.uvm_driver('mwcfg',mcfg,'ucfg',ucfg,'mwpath',sluvm.drvblk_path,'seq_handle',uvmseq,'dut_handle',uvmbfm,'vif_handle',svif,'UVMComponent',l_getDrvUVMComp(l_getDrvMode(drv,mon)),'DrvMode',l_getDrvMode(drv,mon));
    uvmmon=uvmcodegen.uvm_monitor('mwcfg',mcfg,'ucfg',ucfg,'mwpath',sluvm.monblk_path,'dut_handle',uvmbfm,'vif_handle',svif,'UVMComponent',l_getMonUVMComp(l_getMonMode(drv,mon)),'MonMode',l_getMonMode(drv,mon));
    uvmagt=uvmcodegen.uvm_agent('mwcfg',mcfg,'ucfg',ucfg,'dut_handle',uvmbfm,'seq_handle',uvmseq,'drv_handle',uvmdrv,'mon_handle',uvmmon,'UVMComponent','uvm_artifacts');
    uvmscr=uvmcodegen.uvm_scoreboard('mwcfg',mcfg,'ucfg',ucfg,'mwpath',sluvm.scrblk_path,'src',uvmagt,'UVMComponent','scoreboard');

    uvmscr_cfg=uvmcodegen.uvm_scoreboard_cfg_obj('mwcfg',mcfg,'ucfg',ucfg,'scr',uvmscr,'UVMComponent','scoreboard','uvmobj_type','uvm_transaction');
    uvmscr.set_uvmscr_cfg(uvmscr_cfg);

    uvmpred=uvmcodegen.uvm_predictor('mwcfg',mcfg,'ucfg',ucfg,'mwpath',sluvm.gldblk_path,'src',uvmagt,'dst',uvmscr,'UVMComponent',l_getPrdUVMComp(pred),'uvmobj_type','uvm_transaction');
    uvmenv=uvmcodegen.uvm_env('mwcfg',mcfg,'ucfg',ucfg,'scr',uvmscr,'gld',uvmpred,'UVMComponent','uvm_artifacts');

    uvmtst=uvmcodegen.uvm_test('mwcfg',mcfg,'ucfg',ucfg,'env',uvmenv,'seq',uvmseq,'scr_cfg_obj',uvmscr_cfg,'UVMComponent','uvm_artifacts');
    uvmtop=uvmcodegen.uvm_top('mwcfg',mcfg,'ucfg',ucfg,'dut_handle',uvmbfm,'vif_handle',svif,'agt_handle',uvmagt,'UVMComponent','top');

    uvmscripts=uvmcodegen.uvm_scripts('mwcfg',mcfg,'ucfg',ucfg,'top_handle',uvmtop,'UVMComponent','top');


    mcfg.CheckSTCntr4DrvAndMon();


    cd(currdir);


    uvmcodegen.common_dpi_pkg('mwcfg',mcfg,'ucfg',ucfg);


    dpigenerator_disp(['Starting UVM test bench generation for model: ',top_model]);

    fid1=fopen(uvmbfm.get_uvmobj_name_fileLoc(),'w');
    c1=onCleanup(@()fclose(fid1));
    fprintf(fid1,uvmbfm.prtuvmobj(sluvm.scrblk_path));
    fid10=fopen(svif.get_sv_ifnam_fileLoc(),'w');
    c10=onCleanup(@()fclose(fid10));
    fprintf(fid10,svif.prtsvinf);
    fid2=fopen(uvmseq.get_uvmcmp_name_fileLoc(),'w');
    c2=onCleanup(@()fclose(fid2));
    fprintf(fid2,uvmseq.prtuvmcmp,uvmseq.FormatSequence{:});
    fidsqr=fopen(uvmseq.get_uvmsqr_name_fileLoc(),'w');
    c2=onCleanup(@()fclose(fidsqr));
    fprintf(fidsqr,uvmseq.prtuvmcmp('Sequencer',true));
    fid3=fopen(uvmseq.get_uvmobj_name_fileLoc(),'w');
    c3=onCleanup(@()fclose(fid3));
    fprintf(fid3,uvmseq.prtuvmobj);
    fid4=fopen(uvmdrv.get_uvmcmp_name_fileLoc(),'w');
    c4=onCleanup(@()fclose(fid4));
    fprintf(fid4,uvmdrv.prtuvmcmp,uvmdrv.FormatSequence{:});
    fid5=fopen(uvmmon.get_uvmcmp_name_fileLoc(),'w');
    c5=onCleanup(@()fclose(fid5));
    fprintf(fid5,uvmmon.prtuvmcmp,uvmmon.FormatSequence{:});




    if uvmmon.Seq2ScrConnection()||uvmmon.Seq2GldConnection()
        fid5_input=fopen(uvmmon.get_uvmcmp_name_fileLoc_input(),'w');
        c5_input=onCleanup(@()fclose(fid5_input));
        fprintf(fid5_input,uvmmon.prtuvmcmp('MonitorInput',true));
    end

    if uvmpred.IsPredObjPresent()
        fid_pred=fopen(uvmpred.get_uvmcmp_name_fileLoc(),'w');
        c_ref=onCleanup(@()fclose(fid_pred));
        fprintf(fid_pred,uvmpred.prtuvmcmp);
        fid_pred_tran=fopen(uvmpred.get_uvmobj_name_fileLoc(),'w');
        c_ref_tran=onCleanup(@()fclose(fid_pred_tran));
        fprintf(fid_pred_tran,uvmpred.prtuvmobj);
    end

    fid6=fopen(uvmagt.get_uvmcmp_name_fileLoc(),'w');
    c6=onCleanup(@()fclose(fid6));
    fprintf(fid6,uvmagt.prtuvmcmp);
    scr_expansion=uvmscr.prtuvmcmp;
    scr_tmp_f=l_StrFormatting(scr_expansion);
    fid7=fopen(uvmscr.get_uvmcmp_name_fileLoc(),'w');
    c7=onCleanup(@()fclose(fid7));
    fprintf(fid7,scr_expansion,scr_tmp_f{:});



    if uvmscr_cfg.IsCfgObjPresent()
        fid7_1=fopen(uvmscr_cfg.get_uvmcmp_name_fileLoc(),'w');
        c7_1=onCleanup(@()fclose(fid7_1));
        fprintf(fid7_1,uvmscr_cfg.prtuvmcmp,uvmscr_cfg.FormatSequence{:});
    end
    fid8=fopen(uvmenv.get_uvmcmp_name_fileLoc(),'w');
    c8=onCleanup(@()fclose(fid8));
    fprintf(fid8,uvmenv.prtuvmcmp);
    fid9=fopen(uvmtst.get_uvmcmp_name_fileLoc(),'w');
    c9=onCleanup(@()fclose(fid9));
    fprintf(fid9,uvmtst.prtuvmcmp);
    fid11=fopen(uvmtop.get_uvmcmp_name_fileLoc(),'w');
    c11=onCleanup(@()fclose(fid11));
    fprintf(fid11,uvmtop.prtuvmcmp);

    test_pkg_fileLoc=replace(fullfile(ucfg.component_paths('top'),[bdroot(mcfg.sldut_path),'_pkg.sv']),'\','/');
    fid12=fopen(test_pkg_fileLoc,'w');c12=onCleanup(@()fclose(fid12));

    dpigenerator_disp(['Generating UVM test package ',dpigenerator_getfilelink(test_pkg_fileLoc)]);

    uvm_pkg_start=sprintf(['%s\n',...
    '`include "uvm_macros.svh"\n',...
    'package %s;\n',...
    'import uvm_pkg::*;\n'],...
    ucfg.getTopPkgHeader(test_pkg_fileLoc,bdroot(mcfg.sldut_path)),...
    [bdroot(mcfg.sldut_path),'_pkg']);

    Seq=sprintf(['//Sequence item, Sequence and Sequencer\n',...
    '`include "%s"\n',...
    '`include "%s"\n',...
    '`include "%s"\n'],uvmseq.get_uvmobj_name_fileRelLoc(),uvmseq.get_uvmsqr_name_fileRelLoc(),uvmseq.get_uvmcmp_name_fileRelLoc());



    if uvmmon.Seq2ScrConnection()||uvmmon.Seq2GldConnection()
        UVM_core=sprintf(['//Driver, monitor and agent\n',...
        '`include "%s"\n',...
        '`include "%s"\n',...
        '`include "%s"\n',...
        '`include "%s"\n'],...
        uvmdrv.get_uvmcmp_name_fileRelLoc(),...
        uvmmon.get_uvmcmp_name_fileRelLoc(),...
        uvmmon.get_uvmcmp_name_fileRelLoc_input(),...
        uvmagt.get_uvmcmp_name_fileRelLoc());
    else
        UVM_core=sprintf(['//Driver, monitor and agent\n',...
        '`include "%s"\n',...
        '`include "%s"\n',...
        '`include "%s"\n'],...
        uvmdrv.get_uvmcmp_name_fileRelLoc(),...
        uvmmon.get_uvmcmp_name_fileRelLoc(),...
        uvmagt.get_uvmcmp_name_fileRelLoc());
    end


    if uvmpred.IsPredObjPresent()
        UVM_Predictor=sprintf(['//Reference model\n',...
        '`include "%s"\n',...
        '`include "%s"\n'],...
        uvmpred.get_uvmobj_name_fileRelLoc(),...
        uvmpred.get_uvmcmp_name_fileRelLoc());
    else
        UVM_Predictor=sprintf(newline);
    end


    if uvmscr_cfg.IsCfgObjPresent()
        UVM_Scoreboard_cfg_obj=sprintf(['//Scoreboard configuration object\n',...
        '`include "%s"\n'],uvmscr_cfg.get_uvmcmp_name_fileRelLoc());
    else
        UVM_Scoreboard_cfg_obj='';
    end

    UVM_Scoreboard=sprintf(['//Scoreboard\n',...
    '`include "%s"\n',...
    '`include "%s"\n'],...
    uvmbfm.get_uvmobj_name_fileRelLoc(),...
    uvmscr.get_uvmcmp_name_fileRelLoc());


    UVM_env_test=sprintf(['//UVM environment and test\n',...
    '`include "%s"\n',...
    '`include "%s"\n'],...
    uvmenv.get_uvmcmp_name_fileRelLoc(),...
    uvmtst.get_uvmcmp_name_fileRelLoc());


    uvm_pkg_end=sprintf('endpackage: %s',[bdroot(mcfg.sldut_path),'_pkg']);

    fprintf(fid12,[uvm_pkg_start,...
    Seq,...
    UVM_Scoreboard_cfg_obj,...
    UVM_Scoreboard,...
    UVM_Predictor,...
    UVM_core,...
    UVM_env_test,...
    uvm_pkg_end]);



    fid13=fopen(uvmscripts.get_mq_script_name_fileLoc(),'w');
    c13=onCleanup(@()fclose(fid13));
    fprintf(fid13,uvmscripts.prt_mq_script);
    if isunix()

        fid14=fopen(uvmscripts.get_xcelium_script_name_fileLoc(),'w');c14=onCleanup(@()fclose(fid14));
        fprintf(fid14,uvmscripts.prt_xrun_script);
        fileattrib(uvmscripts.get_xcelium_script_name_fileLoc(),'+x','u');

        fid15=fopen(uvmscripts.get_vcs_script_name_fileLoc(),'w');c15=onCleanup(@()fclose(fid15));
        fprintf(fid15,uvmscripts.prt_vcs_script);
        fileattrib(uvmscripts.get_vcs_script_name_fileLoc(),'+x','u');
    end

end

function l_validateSLHandles(mdl,UVM_t)
    if~coder.internal.validateModelParam(mdl,true)
        if Simulink.harness.internal.isInstalled()&&...
            getSimulinkBlockHandle(mdl)~=-1&&...
            strcmp('ModelReference',get_param(mdl,'BlockType'))&&...
            strcmp(UVM_t,'dut')&&...
            ~isempty(sltest.harness.find(get_param(mdl,'ModelName'),'Name',bdroot(mdl)))
            assert(strcmp(get_param(mdl,'Name'),get_param(mdl,'ModelName')),message('HDLLink:uvmgenerator:THMdlRefMustMatchDUTName',get_param(mdl,'Name'),get_param(mdl,'ModelName')));
            return;
        end
        error(message('HDLLink:uvmgenerator:ArgIsNotValidSLHandle',UVM_t));
    end
end

function tmp_f=l_StrFormatting(str)


    tmp_f=split((repmat('%s ',1,count(str,'%s'))))';
    tmp_f=tmp_f(1:end-1);
end

function Valid=l_IsConfigParameterValid(modelName,CfgName)


    IsDPISTF=any(strcmp(get_param(modelName,'SystemTargetFile'),{'systemverilog_dpi_grt.tlc','systemverilog_dpi_ert.tlc'}));

    if IsDPISTF

        CfgValue=get_param(modelName,CfgName);
        switch CfgName
        case 'SystemTargetFile'
            Valid=true;
        case 'DPIPortConnection'
            Valid=strcmp(CfgValue,'Port list');
        case 'Toolchain'
            Valid=any(strcmp(CfgValue,{'Automatically locate an installed toolchain','GNU gcc/g++ | gmake (64-bit Linux)'}));
        case 'DPICustomizeSystemVerilogCode'
            Valid=strcmp(CfgValue,'off');
        case 'DPIGenerateTestBench'
            Valid=strcmp(CfgValue,'off');
        case 'DPIComponentTemplateType'
            Valid=strcmp(CfgValue,'Sequential');
        case 'DPIReportRunTimeError'
            Valid=true;
            if strcmp(get_param(modelName,'SystemTargetFile'),'systemverilog_dpi_ert.tlc')&&strcmp(get_param(modelName,'SuppressErrorStatus'),'on')
                Valid=strcmp(CfgValue,'off');
            end
        otherwise

            error('Invalid configuration parameter property.');
        end
    else


        switch CfgName
        case 'SystemTargetFile'
            Valid=false;
        case 'Toolchain'
            Valid=any(strcmp(get_param(modelName,CfgName),{'Automatically locate an installed toolchain','GNU gcc/g++ | gmake (64-bit Linux)'}));
        otherwise


            Valid=true;
        end
    end

end

function uvmcp=l_getMonUVMComp(MonMode)
    if MonMode==uvmcodegen.ConvertorMode.DPISUB
        uvmcp='monitor';
    else
        uvmcp='uvm_artifacts';
    end
end

function uvmcp=l_getDrvUVMComp(DrvMode)
    if DrvMode==uvmcodegen.ConvertorMode.DPISUB
        uvmcp='driver';
    else
        uvmcp='uvm_artifacts';
    end
end

function MonMode=l_getMonMode(Drv,Mon)
    if~isempty(Mon)
        MonMode='DPISUB';
    elseif~isempty(Drv)
        MonMode='PTWD';
    else
        MonMode='PT';
    end
end

function DrvMode=l_getDrvMode(Drv,Mon)
    if~isempty(Drv)
        DrvMode='DPISUB';
    elseif~isempty(Mon)
        DrvMode='PTWD';
    else
        DrvMode='PT';
    end
end

function uvmcp=l_getPrdUVMComp(gld)
    if~isempty(gld)
        uvmcp='predictor';
    else
        uvmcp='scoreboard';
    end
end


function restoreCodegenConfig()
    Simulink.fileGenControl('reset');
end






