function simOut=collect(this,varargin)





    this.assertDEValid();


    narginchk(1,2);


    p=inputParser;
    validSettings=@(x)isa(x,'DataTypeWorkflow.CollectionSettings');
    addOptional(p,'CollectionSettings',DataTypeWorkflow.CollectionSettings,validSettings);
    parse(p,varargin{:});
    collectionSettings=p.Results.CollectionSettings;


    this.SystemSettings.captureSettings();


    cleanupShortcut=this.ShortcutManager.CleanupShortcut;
    this.createSettingsMapFromSystem(cleanupShortcut);



    cleanup=onCleanup(@()this.collectCleanup(cleanupShortcut));

    uniqueRunName='';
    scenarioRunNames={};

    try





        this.SystemSettings.turnOffFastRestart();


        shortcut=collectionSettings.ShortcutToApply;
        this.applySettingsFromShortcut(shortcut);


        this.SystemSettings.enableInstrumentation();


        this.SystemSettings.restoreFastRestart();


        this.SystemSettings.switchToNormalMode();


        userGivenRunName=collectionSettings.RunName;
        uniqueRunName=this.makeRunNameUnique(userGivenRunName);
        collectionSettings.RunName=uniqueRunName;
        this.CurrentRunName=uniqueRunName;


        collectionMode=collectionSettings.RangeCollectionMode;


        simOut=[];
        if collectionMode.isSimulation
            simulationScenarios=collectionSettings.SimulationScenarios;

            simOut=this.simulateSystem(simulationScenarios,...
            'ShowSimulationManager',collectionSettings.ProgressTrackingOptions.ShowSimulationManager,...
            'ShowProgress',collectionSettings.ProgressTrackingOptions.ShowProgress...
            );
        end


        scenarioRunNames=this.getMultiSimRunNames(uniqueRunName);


        if collectionMode.isDerived


            this.SystemSettings.turnOffFastRestart();


            this.deriveMinMax();
        end

    catch e


        this.deleteRuns(uniqueRunName,scenarioRunNames);

        throw(e);
    end

end

