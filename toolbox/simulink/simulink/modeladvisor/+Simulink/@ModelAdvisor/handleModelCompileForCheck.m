function[CompileFailed,CGIRFailed,CoverageCompileStatus,SLDVCompileFailed,compileerrormsg]...
    =handleModelCompileForCheck(this,CheckObj,CompileFailed,...
    CGIRFailed,CoverageCompileStatus,SLDVCompileFailed,waitbarLength)




    compileerrormsg='';
    cmdLineRun=this.CmdLine;


    if strcmpi(CheckObj.CallbackContext,'PostCompile')&&~this.HasCompiled
        if this.HasCompiledForCodegen

            compileerrormsg=modeladvisorprivate('modeladvisorutil2','TerminateModelCompile',this);
        end
        if CompileFailed
            if isa(CheckObj,'ModelAdvisor.Check')
                CheckObj.Success=false;
                CheckObj.ErrorSeverity=100;
            end
        else
            PerfTools.Tracer.logMATLABData('MAGroup','Compile Model - Normal Mode',true);
            try
                if~cmdLineRun&&desktop('-inuse')&&this.ShowProgressbar&&ishandle(this.Waitbar)
                    waitbar(waitbarLength,this.Waitbar,DAStudio.message('Simulink:tools:MACompilingModel'));
                end
                if this.parallel
                    this.Database.overwriteLatestData('ParallelInfo','status',{DAStudio.message('Simulink:tools:MACompilingModel')});
                end

                modeladvisorprivate('modeladvisorutil2',...
                'CompileModel',this);
            catch E
                CompileFailed=true;
                compileerrormsg=constructCompilerErrorMsg(E,'CompileModel',cmdLineRun);
                if isa(CheckObj,'ModelAdvisor.Check')
                    CheckObj.Success=false;
                    CheckObj.ErrorSeverity=100;
                end
            end
            PerfTools.Tracer.logMATLABData('MAGroup','Compile Model - Normal Mode',false);
        end
    elseif strcmpi(CheckObj.CallbackContext,'SLDV')&&~this.HasSLDVCompiled

        if this.HasCompiled||this.HasCompiledForCodegen

            compileerrormsg=modeladvisorprivate('modeladvisorutil2','TerminateModelCompile',this);
        end

        if SLDVCompileFailed

            if isa(CheckObj,'ModelAdvisor.Check')
                CheckObj.Success=false;
                CheckObj.ErrorSeverity=100;
            end

        else

            PerfTools.Tracer.logMATLABData('MAGroup','Compile Model - SLDV Mode',true);
            try

                if~cmdLineRun&&desktop('-inuse')&&this.ShowProgressbar&&ishandle(this.Waitbar)
                    waitbar(waitbarLength,this.Waitbar,DAStudio.message('ModelAdvisor:engine:MADeepAnalysis'));
                end

                sldvsvc=Advisor.SLDVCompileService.getInstance;

                if~isempty(this.ConfigFileOptions)...
                    &&isfield(this.ConfigFileOptions,'overrideSLDVTimeoutCB')...
                    &&isfield(this.ConfigFileOptions,'SLDVTimeOut')...
                    &&this.ConfigFileOptions.overrideSLDVTimeoutCB



                    sldvsvc.setSLDVTimeout(this.ConfigFileOptions.SLDVTimeOut)

                end




                this.HasSLDVCompiled=Advisor.SLDVCompileService.runSLDV(this.System);

            catch E

                SLDVCompileFailed=true;
                this.HasSLDVCompiled=false;

                compileerrormsg=constructCompilerErrorMsg(E,'SLDV',cmdLineRun);

                if isa(CheckObj,'ModelAdvisor.Check')
                    CheckObj.Success=false;
                    CheckObj.ErrorSeverity=100;
                end
            end
            PerfTools.Tracer.logMATLABData('MAGroup','Compile Model - SLDV Mode',false);
        end

    elseif strcmpi(CheckObj.CallbackContext,'PostCompileForCodegen')&&~this.HasCompiledForCodegen
        if this.HasCompiled

            compileerrormsg=modeladvisorprivate('modeladvisorutil2','TerminateModelCompile',this);
        end
        if CompileFailed
            if isa(CheckObj,'ModelAdvisor.Check')
                CheckObj.Success=false;
                CheckObj.ErrorSeverity=100;
            end
        else
            PerfTools.Tracer.logMATLABData('MAGroup','Compile Model - Codegen Mode',true);
            try
                if~cmdLineRun&&desktop('-inuse')&&this.ShowProgressbar&&ishandle(this.Waitbar)
                    waitbar(waitbarLength,this.Waitbar,DAStudio.message('Simulink:tools:MACompilingModelForCodegen'));
                end
                if this.parallel
                    this.Database.overwriteLatestData('ParallelInfo','status',{DAStudio.message('Simulink:tools:MACompilingModelForCodegen')});
                end

                modeladvisorprivate('modeladvisorutil2',...
                'CompileModelForCodegen',this);
            catch E
                CompileFailed=true;
                compileerrormsg=constructCompilerErrorMsg(E,'CompileModelForCodegen',cmdLineRun);
                if isa(CheckObj,'ModelAdvisor.Check')
                    CheckObj.Success=false;
                    CheckObj.ErrorSeverity=100;
                end
            end
            PerfTools.Tracer.logMATLABData('MAGroup','Compile Model - Codegen Mode',false);
        end


    elseif strcmpi(CheckObj.CallbackContext,'DIY')&&(this.HasCompiled||this.HasCompiledForCodegen)

        compileerrormsg=modeladvisorprivate('modeladvisorutil2','TerminateModelCompile',this);
    elseif strcmpi(CheckObj.CallbackContext,'CGIR')&&~this.HasCGIRed
        if this.HasCompiled||this.HasCompiledForCodegen

            compileerrormsg=modeladvisorprivate('modeladvisorutil2','TerminateModelCompile',this);
        end
        if CGIRFailed
            if isa(CheckObj,'ModelAdvisor.Check')
                CheckObj.Success=false;
                CheckObj.ErrorSeverity=100;
            end
        else
            PerfTools.Tracer.logMATLABData('MAGroup','Compile Model - CGIR Mode',true);
            try
                if~cmdLineRun&&desktop('-inuse')&&this.ShowProgressbar&&ishandle(this.Waitbar)
                    waitbar(waitbarLength,this.Waitbar,DAStudio.message('Simulink:tools:MACompilingModel'));
                end

                if this.parallel
                    this.Database.overwriteLatestData('ParallelInfo','status',{DAStudio.message('Simulink:tools:MACompilingModel')});
                end
                modeladvisorprivate('modeladvisorutil2',...
                'CGIRModel',this);
            catch E

                CGIRFailed=true;
                compileerrormsg=constructCompilerErrorMsg(E,'CGIR',cmdLineRun);

                if isa(CheckObj,'ModelAdvisor.Check')
                    CheckObj.Success=false;
                    CheckObj.ErrorSeverity=100;
                end
            end
            PerfTools.Tracer.logMATLABData('MAGroup','Compile Model - CGIR Mode',false);
        end
    elseif strcmpi(CheckObj.CallbackContext,'Coverage')&&CoverageCompileStatus~=1
        if this.HasCompiled||this.HasCompiledForCodegen

            compileerrormsg=modeladvisorprivate('modeladvisorutil2','TerminateModelCompile',this);
        end

        if CoverageCompileStatus==-1
            if isa(CheckObj,'ModelAdvisor.Check')
                CheckObj.Success=false;
                CheckObj.ErrorSeverity=100;
            end
        else
            PerfTools.Tracer.logMATLABData('MAGroup','Compile Model - Coverage Mode',true);
            model=bdroot(this.SystemName);
            modelDirtyFlag=get_param(model,'Dirty');

            persistedModelSettings={
            'CovEnable',get_param(model,'CovEnable');...
            'CovForceBlockReductionOff',get_param(model,'CovForceBlockReductionOff');...
            'CovFilter',get_param(model,'CovFilter');...
            'CovIncludeTopModel',get_param(model,'CovIncludeTopModel');...
            'CovIncludeRefModels',get_param(model,'CovIncludeRefModels');...
            'CovPath',get_param(model,'CovPath');...
            };




            cs=getActiveConfigSet(model);
            if isa(cs,'Simulink.ConfigSetRef')
                cs=cs.getRefConfigSet();
            end


            cs.set_param('CovEnable','on');


            cs.set_param('CovForceBlockReductionOff','off');


            cs.set_param('CovFilter','');

            cs.set_param('CovIncludeTopModel','on');
            cs.set_param('CovIncludeRefModels','off');
            cs.set_param('CovPath','/');

            try
                if~cmdLineRun&&desktop('-inuse')&&this.ShowProgressbar&&ishandle(this.Waitbar)
                    waitbar(waitbarLength,this.Waitbar,DAStudio.message('Simulink:tools:MACompilingModel'));
                end


                SlCov.CoverageAPI.compileForCoverage(model);
                CoverageCompileStatus=1;

            catch E
                compileerrormsg=constructCompilerErrorMsg(E,'CompileModel',cmdLineRun);
                CoverageCompileStatus=-1;

                if isa(CheckObj,'ModelAdvisor.Check')
                    CheckObj.Success=false;
                    CheckObj.ErrorSeverity=100;
                end
            end


            for N=size(persistedModelSettings,2):-1:1
                cs.set_param(persistedModelSettings{N,1},persistedModelSettings{N,2});
            end

            set_param(model,'Dirty',modelDirtyFlag);

            PerfTools.Tracer.logMATLABData('MAGroup','Compile Model - Coverage Mode',false);
        end
    end
end


function compileerrormsg=constructCompilerErrorMsg(E,compileMode,~)

    errmsgs=Simulink.ModelAdvisor.getErrorMessage(E);

    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;



    compileerrormsg=errmsgs;




    disp(strrep(compileerrormsg,'<br />',''));




    if contains(compileerrormsg,'opentoline')
        compileerrormsgLineBreakIndex=strfind(compileerrormsg,newline);
        if~isempty(compileerrormsgLineBreakIndex)
            compileerrormsg=compileerrormsg(compileerrormsgLineBreakIndex(1):end);
        end
    end
    if strcmp(compileMode,'CGIR')&&~strcmp(mdladvObj.ActiveCheck.ID,'mathworks.design.StowawayDoubles')
        additionalCGIRFailMsg=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:additionalCGIRFailMsg'));
        additionalCGIRFailMsg.setColor('Fail');
        compileerrormsg=[additionalCGIRFailMsg.emitHTML,'<br/><br/>',compileerrormsg];
    end
    compileerrormsg=strrep(compileerrormsg,newline,'<br />');
end


