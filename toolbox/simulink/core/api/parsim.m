




















































function out=parsim(simInputs,varargin)
    if nargin>1

        [varargin{:}]=convertStringsToChars(varargin{:});
    end
    p=inputParser;
    addParameter(p,'ShowSimulationManager','off',@(x)any(validatestring(x,{'on','off'})));
    addParameter(p,'ThrowAsCaller',true,@islogical);
    p.KeepUnmatched=true;
    parse(p,varargin{:},'AllowParallelSimulations',true);


    job=[];
    try
        simMgr=Simulink.SimulationManager(simInputs);
        options=p.Unmatched;

        simMgr.Options=options;
        simMgr.Options.UseParallel=true;

        if strcmpi(p.Results.ShowSimulationManager,'on')

            multiSimMgr=MultiSim.internal.MultiSimManager.getMultiSimManager;
            jobViewer=multiSimMgr.addJob(simMgr);
            job=jobViewer.Job;
            simMgr.Options.ShowSimulationManager=true;
        end
        out=simMgr.run();
    catch ME
        if~isempty(job)
            job.publishAlert(ME.message);
        end

        if p.Results.ThrowAsCaller
            throwAsCaller(ME)
        else
            rethrow(ME);
        end
    end
end