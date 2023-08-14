function buildResult=codeProject(projectFile,codeGenWrapper,instrument,suppressHistogram,featureFlags)



    import com.mathworks.toolbox.coder.plugin.CodeGenResult;

    function doit()%#ok<DEFNU>
        fc=coder.internal.FeatureControl;
        copyFeatureFlags(featureFlags,fc);

        if instrument
            if suppressHistogram
                report=fixed.internal.buildInstrumentedMex(projectFile,...
                '--codeGenWrapper',codeGenWrapper,'-coder','-feature',fc);
            else
                report=fixed.internal.buildInstrumentedMex(projectFile,...
                '--codeGenWrapper',codeGenWrapper,'-coder','-histogram','-feature',fc);
            end
        else
            report=emlckernel('codegen',projectFile,...
            '--codeGenWrapper',codeGenWrapper,'-feature',fc);
        end
    end

    report=[];
    log=evalc('doit');
    if isempty(report)||~isfield(report,'summary')
        report.summary.passed=false;
        report.summary.mainhtml='';
    end
    summary=report.summary;
    if isfield(summary,'mainhtml')
        mainhtml=summary.mainhtml;
    else
        mainhtml='';
    end
    if isfield(summary,'passed')
        succeeded=logical(summary.passed);
    else
        succeeded=false;
    end

    buildResult=CodeGenResult(succeeded,log,mainhtml);

end

function copyFeatureFlags(featureFlags,fc)
    if numel(featureFlags)==1


        featureFlags=eval(featureFlags{1});
    end

    if~isempty(featureFlags)
        for i=1:2:numel(featureFlags)
            fc.(featureFlags{i})=featureFlags{i+1};
        end
    end
end