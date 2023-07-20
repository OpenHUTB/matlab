classdef HDLTraceabilityDriver<handle


    properties(Access=public)
        TopModel;
    end

    methods
        function this=HDLTraceabilityDriver(model)
            this.TopModel=model;
        end

        createTOC(~,w,title,model);
        jsCmds=emitIOPortInfo(this,p,w,io_data,jsCmds);
        generateAdaptivePipeliningReport(this,adaptive_pipe_file,title,model,p,JavaScriptBody)
        generateFlatteningHierarchyReport(this,adaptive_pipe_file,title,model,p,JavaScriptBody)
        generateHDLNetworkReuseReport(this,adpative_pip_file,title,model,p,JavaScriptBody)
        generateInLineHDLCodeReport(this,adaptive_pipe_file,title,model,p,JavaScriptBody)
        generateBillOfMaterials(this,bom_content_file,title,model,p,tcgInventory,JavaScriptBody)
        generateClockSummary(~,clock_summary_file,title,model,JavaScriptBody)
        generateContents(this,contents_file,title,model)
        generateDutInfoReport(this,bom_content_file,title,model,p,tcgInventory,JavaScriptBody)
        generateNfpBillOfMaterials(this,bom_content_file,title,model,p,tcgInventory,JavaScriptBody)
        generateObfuscationReport(this,delay_balance_file,title,model,p,JavaScriptBody)
        generateRecommendationsDelayBalancing(this,delay_balance_file,title,model,p,JavaScriptBody)
        generateRecommendationsPipelining(this,dist_pipe_file,title,model,p,JavaScriptBody)
        generateRecommendationsSerialization(this,ser_file,title,model,p,JavaScriptBody)
        generateSummary(~,summary_file,title,model,JavaScriptBody,hasWebview)
        generateTargetCodeGenerationReport(this,tcg_content_file,title,model,p,JavaScriptBody)
        generateTargetResourceUsageReport(~,ru_content_file,title,model,tcgInventory,JavaScriptBody)
        generateTraceability(~,model,sourceSubsystem,hdlDir,hdlFileNames)
        atomicsubsystems=getAtomicSubsystems(~,hN)
        blocks=getNonzeroResetBlocks(~,path,hierarchical)
        publishGeneratedModelLink(~,w,genModel)
        publishValidationModelLink(~,w,valModel)
    end

    methods(Static,Access=public)
        [total_pin_count,io_data]=calcIOPinsForDut(gp)
        removeTraceabilityInfo(HDLCoder)
    end
end
