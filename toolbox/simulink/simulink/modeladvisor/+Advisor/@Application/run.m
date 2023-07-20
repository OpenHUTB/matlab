









function run(this,varargin)




















    this.checkLicense(this.Token);

    p=inputParser();
    p.addParameter('overwrite',true,@islogical);
    p.addParameter('resultsAvailableCallback',[],@(x)isa(x,'function_handle'));
    p.parse(varargin{:});
    inputs=p.Results;


    Advisor.Manager.getActiveApplicationObj(this);

    try
        if this.AnalyzeVariants
            variants=this.VariantManager.findVariants;
            if~isempty(variants)
                this.VariantManager.backupActiveVariant;
                for i=1:length(variants)
                    this.VariantManager.activateVariant(variants{i});
                    localRun(this,inputs);
                    this.VariantManager.saveActiveVariant;

                end
                this.VariantManager.restoreActiveVariant;
            else
                localRun(this,inputs);
            end
        else
            localRun(this,inputs);
        end
    catch E
        if this.UseTempDir&&~isempty(this.OriginalDir)
            cd(this.OriginalDir);
            rmpath(this.OriginalDir);
        end

        rethrow(E);
    end
end

function localRun(this,inputs)

    if this.SynchronizedExecution


        if~isempty(inputs.resultsAvailableCallback)
            DAStudio.error('Advisor:base:App_ResultCallbackWithSynchronousOp');
        end


        if this.UseTempDir
            this.OriginalDir=pwd;
            addpath(pwd);
            cd(this.TempDir);

            this.runSynchronous();
            cd(this.OriginalDir);
            rmpath(this.OriginalDir);
        else
            this.runSynchronous();
        end




        Simulink.DDUX.logData('CLI_ADVISORAPP','advisorapplication','advisorapplicationrun');
    else







    end
end