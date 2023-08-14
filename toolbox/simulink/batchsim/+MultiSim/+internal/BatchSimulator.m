classdef BatchSimulator<handle







    properties
SimulationInputs
    end

    properties(Hidden=true,Dependent=true)
ModelName
    end

    properties(Access=private,Transient=true)
ParsimOptions
BatchOptions
UsingDefaults
BatchRunner
    end

    methods
        function obj=BatchSimulator(simInputs)



            if~MultiSim.internal.BatchSimulator.isPCTLicensed()
                error(message('Simulink:batchsim:PCTLicenseRequired'));
            end

            if~MultiSim.internal.BatchSimulator.isPCTInstalled()
                error(message('Simulink:batchsim:PCTInstallRequired'));
            end
            obj.SimulationInputs=simInputs;
        end

        function modelName=get.ModelName(obj)
            mgr=Simulink.SimulationManager(obj.SimulationInputs);
            modelName=mgr.ModelName;
        end

        function job=run(obj,varargin)


            load_system(obj.ModelName);


            p=MultiSim.internal.BatchsimInputParser;
            parse(p,varargin{:});

            parsimOptions=p.Results.ParsimOptions;
            batchOptions=p.Results.BatchOptions;


            cluster=obj.getClusterObject(batchOptions.Profile);


            batchOptions=rmfield(batchOptions,'Profile');

            runnerFactory=MultiSim.internal.BatchRunnerFactory.getInstance();
            obj.BatchRunner=runnerFactory.create(cluster,obj.SimulationInputs,...
            parsimOptions,batchOptions);
            job=obj.BatchRunner.run();
        end
    end

    methods(Static,Access=private)
        function tf=isPCTLicensed()

            tf=matlab.internal.parallel.isPCTLicensed();
        end

        function tf=isPCTInstalled()

            tf=matlab.internal.parallel.isPCTInstalled();
        end

        function cluster=getClusterObject(profile)




            if~isa(profile,'parallel.Cluster')
                cluster=parcluster(profile);
            else
                cluster=profile;
            end
        end
    end
end

