classdef CodegenProfilerSentinel<handle














    properties(SetAccess=private)
        isEnabled(1,1)logical=false;
        options(1,1)struct;
        logdir(1,1)string="";
        savefolder(1,1)string="";
cgirDebug
    end
    properties(Access=private)
        cleanupFcns={};
    end
    methods
        function this=CodegenProfilerSentinel()
            [this.isEnabled,this.options,this.logdir,this.cgirDebug]=coder.internal.codegenProfiler();
            if~this.isEnabled
                return;
            end
            if~isfolder(this.logdir)
                mkdir(this.logdir);
            end
            this.savefolder=coder.internal.getNextSubDir(this.logdir);
            mkdir(this.savefolder);
        end

        function enablePerformanceTracer(this)



            if~this.isEnabled
                return
            end
            if this.options.PerformanceTracer
                PerfTools.Tracer.enable('MATLAB Coder',true);
                this.cleanupFcns{end+1}=@()this.disablePerformanceTracer();
            end
        end
        function enableCodegenProfileSettings(this,CC)






            if~this.isEnabled
                return
            end
            cgirDebugWasDisabled=isempty(this.cgirDebug.PrettyPrinter);


            if this.options.CGIRNamePrinter
                diary(fullfile(this.savefolder,'codegenDiary.txt'));
                this.cgirDebug.enable;
                origNamePrinterStatus=this.cgirDebug.NamePrinter.Enabled;
                this.cgirDebug.NamePrinter.Enabled=1;
                this.cleanupFcns{end+1}=@()this.disableCGIRNamePrinter(origNamePrinterStatus);
            end


            if this.options.MATLABProfiler
                profile clear;
                profile on;
                this.cleanupFcns{end+1}=@()this.disableMATLABProfiler();
            end


            if this.options.CGIRTransformProfiler
                tp=internal.cgir.TransformProfiler;
                tp.DumpDestination=fullfile(this.savefolder,'transformProfiler.txt');
                tp.RecordNumbering=1;
                tp.EnabledBefore=1;
                tp.EnabledAfter=1;
                tp.reset;
                this.cleanupFcns{end+1}=@()this.disableCGIRTransformProfiler;
            end


            if this.options.CGIRPoolHighWaterMark
                this.cgirDebug.enable;
                mem=internal.cgir.MemoryAnalyzer;
                mem.ResetHighWaterMark;
                orig=copyProperties(mem,struct());
                mem.EnabledBefore=1;
                mem.EnabledAfter=1;
                mem.PoolMemStats=1;
                mem.PoolSanityChecks=1;
                mem.CheckPoolLeaks=0;
                this.cleanupFcns{end+1}=@()this.disableCGIRPoolHighWaterMark(orig);
            end


            if this.options.InferenceProfiler~="off"
                CC.Project.FeatureControl.Profile=true;
                CC.Project.FeatureControl.ProfileMultiplier=1;
                CC.Project.FeatureControl.ProfilePrecision=4;
                if this.options.InferenceProfiler=="full"
                    CC.Project.FeatureControl.ProfileDetailLevel=2;
                    CC.Project.FeatureControl.ProfileAnalyses='';
                else
                    CC.Project.FeatureControl.ProfileDetailLevel=1;
                    CC.Project.FeatureControl.ProfileAnalyses='specialize:check:db4u';
                end

                CC.Project.FeatureControl.ProfileOutputFile=char(fullfile(this.savefolder,'inferenceProfile.txt'));
                this.cleanupFcns{end+1}=@()this.disableInferenceProfiler;
            end


            if cgirDebugWasDisabled
                this.cleanupFcns{end+1}=@()this.disableCgirDebug;
            end
        end
        function delete(this)
            for k=1:numel(this.cleanupFcns)
                fcn=this.cleanupFcns{k};
                try
                    fcn();
                catch ME
                    ME.getReport()
                end
            end
            if this.isEnabled
                fprintf("\ncodegen profile results written to: %s\n",this.savefolder);
            end
        end
    end
    methods(Access=private)
        function disablePerformanceTracer(this)
            if isempty(PerfTools.Tracer.getRawData())
                return;
            end
            PerfTools.Tracer.generateAggregateReport('htmlfile',fullfile(char(this.savefolder),'perfTracer.html'));
            PerfTools.Tracer.enable('MATLAB Coder',false);
            PerfTools.Tracer.enableGlobalLogging(false);
            PerfTools.Tracer.clearRawData();
        end

        function disableCGIRNamePrinter(this,orig)
            this.cgirDebug.NamePrinter.Enabled=orig;
            diary("off");
        end

        function disableMATLABProfiler(this)
            profinfo=profile("info");
            fcntable=struct2table(profinfo.FunctionTable);
            fcntable=fcntable(:,{'TotalTime','NumCalls','FunctionName','CompleteName'});
            fcntable=sortrows(fcntable,'TotalTime','descend');%#ok<NASGU>
            tablestr=evalc('disp(fcntable)');
            f=fopen(fullfile(this.savefolder,'profinfo.html'),'w');
            c=onCleanup(@()fclose(f));
            fprintf(f,"<html><body><pre>\n");
            fprintf(f,"%s\n",tablestr);
            fprintf(f,"\n</html></body></pre>\n");
            save(fullfile(this.savefolder,"profinfo.mat"),"profinfo");
        end

        function disableCGIRTransformProfiler(~)
            tp=internal.cgir.TransformProfiler;
            tp.dump();
            tp.reset;
            tp.DumpDestination='';
            tp.RecordNumbering=0;
            tp.EnabledBefore=0;
            tp.EnabledAfter=0;
        end

        function disableCGIRPoolHighWaterMark(this,orig)
            mem=internal.cgir.MemoryAnalyzer;
            memstr=getDisp(mem.PoolHighWaterMark);
            f=fopen(fullfile(this.savefolder,'cgirPoolHighWaterMark.txt'),'w');
            c=onCleanup(@()fclose(f));
            fprintf(f,"%s\n",memstr);
            mem.ResetHighWaterMark;
            copyProperties(orig,mem);
        end

        function disableInferenceProfiler(~)

        end

        function disableCgirDebug(this)
            this.cgirDebug.disable;
        end
    end
end


function str=getDisp(val)%#ok<INUSD>
    str=evalc("disp(val)");
end

function out=copyProperties(obj,out)
    if isobject(obj)
        props=properties(obj);
    else
        props=fieldnames(obj);
    end
    for k=1:numel(props)
        p=props{k};
        try
            out.(p)=obj.(p);
        catch
        end
    end
end
