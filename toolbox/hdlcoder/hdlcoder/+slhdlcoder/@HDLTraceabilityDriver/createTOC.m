


function createTOC(~,w,title,model)




    hDrv=hdlcurrentdriver;
    isTopModel=hDrv.mdlIdx==numel(hDrv.AllModels);
    traceability=hdlgetparameter('traceability');
    billOfMaterials=hdlgetparameter('resourceReport');
    TargetCodeGenBOM=targetcodegen.targetCodeGenerationUtils.isAlteraMode()||targetcodegen.targetCodeGenerationUtils.isXilinxMode();
    NFPbillOfMaterials=targetcodegen.targetCodeGenerationUtils.isNFPMode();
    recommendations=hdlgetparameter('optimizationReport');
    obfuscationReport=hdlgetparameter('ObfuscateGeneratedHDLCode');
    cpereport=hdlgetparameter('CriticalPathEstimation');
    staticlatencyreport=hdlgetparameter('StaticLatencyPathAnalysis');
    ipcoreReport=hdlgetparameter('ipcoreReport');
    codeReuseReport=~strcmp(hdlgetparameter('subsystemreuse'),'off');


    sectionsToAdd=cell(0);


    fontSection=w.createSection(title,'font');
    fontSection.setAttribute('color','#000000');
    boldSection=w.createSection(fontSection.getHTML,'b');
    sectionsToAdd{end+1}=boldSection.getHTML;%#ok<*NASGU>

    sectionsToAdd{end+1}=createTOCSection(w,model,'summary','survey','rtwIdSummaryPage');

    if isTopModel

        sectionsToAdd{end+1}=...
        createTOCSection(w,model,'clock_summary_stub','clock','rtwIdClockPage');
    end


    sectionsToAdd{end+1}=...
    createTOCSection(w,model,'coder_interface_report_stub','dut_information','rtwIdDUTInformationRepor');

    if billOfMaterials||cpereport||staticlatencyreport

        sectionsToAdd{end+1}=MSG('timing_and_area_report_stub');
    end

    if billOfMaterials

        sectionsToAdd{end+1}=...
        createIndentedTOCSection(w,model,'high_level_res_report_stub','bill_of_materials','rtwIdBillOfMaterials');

        if TargetCodeGenBOM

            sectionsToAdd{end+1}=...
            createIndentedTOCSection(w,model,'targ_specific_report_stub','target_resource_usage','rtwIdTargetResourceUsage');
        end

        if NFPbillOfMaterials


            sectionsToAdd{end+1}=...
            createIndentedTOCSection(w,model,'nfp_res_report_stub','nfp_bill_of_materials','rtwIdTargetResourceUsage');
        end
    end

    if cpereport
        sectionsToAdd{end+1}=...
        createIndentedTOCSection(w,model,'crit_path_est_stub','criticalpathestimationsummary','rtwIdCPE');
    end

    if staticlatencyreport
        sectionsToAdd{end+1}=...
        createIndentedTOCSection(w,model,'static_lat_path_ana_stub','staticlatencypathanalysissummary','rtwIdStaticLatency');
    end

    if recommendations
        sectionsToAdd{end+1}=MSG('optim_report_stub');


        sectionsToAdd{end+1}=...
        createIndentedTOCSection(w,model,'distr_pipeline_stub','distributed_pipelining','rtwIdDistPipe');


        sectionsToAdd{end+1}=...
        createIndentedTOCSection(w,model,'stream_share_stub','serialization','rtwIdSerialization');


        sectionsToAdd{end+1}=...
        createIndentedTOCSection(w,model,'delay_balancing_stub','delay_balancing','rtwIdDelayBalancing');


        sectionsToAdd{end+1}=...
        createIndentedTOCSection(w,model,'adaptive_pipelining_stub','adaptive_pipelining','rtwIdAdaptivePipelining');


        sectionsToAdd{end+1}=...
        createIndentedTOCSection(w,model,'FlattenHierarchy_stub','flatten_hierarchy','rtwIdFlattenHierarchy');


        sectionsToAdd{end+1}=...
        createIndentedTOCSection(w,model,'tgt_codegen_stub','targetcodegeneration','rtwIdTargetCodeGeneration');

        if codeReuseReport

            sectionsToAdd{end+1}=...
            createIndentedTOCSection(w,model,'HDLNetworkReuse_stub','hdl_network_reuse','rtwIdHDLNetworkReuse');
        end
    end

    if ipcoreReport&&isTopModel


        sectionsToAdd{end+1}=...
        createTOCSection(w,model,'ip_coregen_stub','ip_core_report','rtwIdIPCoreReport');
    end

    if traceability

        sectionsToAdd{end+1}=...
        createTOCSection(w,model,'traceability_report_stub','trace','rtwIdTraceability');
    end

    if obfuscationReport

        sectionsToAdd{end+1}=...
        createTOCSection(w,model,'ObfuscationReportStub','obfuscation_report','rtwIdObfuscation');
    end


    table=w.createTable(numel(sectionsToAdd),1,'',false);
    table.setBorder(0);
    table.setAttribute('cellspacing','0');
    table.setAttribute('cellpadding','1');
    table.setAttribute('width','100%');
    table.setAttribute('bgcolor','#ffffff');


    for ii=1:numel(sectionsToAdd)
        table.createEntry(ii,1,sectionsToAdd{ii});
    end

    w.commitTable(table);
end

function html=createIndentedTOCSection(w,modelname,title,ref_html,id)
    html=['&nbsp&nbsp&nbsp',createTOCSection(w,modelname,title,ref_html,id)];
end

function html=createTOCSection(w,modelname,title,ref_html,id)
    section=w.createSection(MSG(title),'a');
    section.setAttribute('href',[modelname,'_',ref_html,'.html']);
    section.setAttribute('target','rtwreport_document_frame');
    section.setAttribute('id',id);
    section.setAttribute('onclick','if (top) if (top.tocHiliteMe) top.tocHiliteMe(window, this, true);');
    section.setAttribute('name','TOC_List');
    html=section.getHTML;
end

function str=MSG(key,varargin)
    str=message(['hdlcoder:report:',key],varargin{:}).getString();
end




