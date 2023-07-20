classdef ChartSimplifier < handle
% Stateflow.Tools.ChartSimplifier
% Simplify Stateflow charts to identify Stateflow objects and semantics
% that caused an error.
%
% To get started, create a ChartSimplifier Object
%
% simplifier =
% Stateflow.Tools.ChartSimplifier(ChartPath=chartpath,ReproductionSteps=reproductionscript)
%
% Begin Chart simplification process by calling the simplify
% function on the ChartSimplifier object.
%
% simplify(simplifier)
%
%    Valid properties of the ChartSimplifier Class:
%
%    ChartPath - Path to your Stateflow chart, starting with the name of 
%    the Simulink model (for example, Model/Subsystem/Chart). The model file 
%    must be on your MATLAB path.
%
%    ReproductionSteps - Specifies built-in reproduction steps or custom 
%    script on your MATLAB path. The options for built-in reproduction steps 
%    include:
%
%        "CompileModel" - Reproduce a model compilation error.
%        "RunModel" - Reproduce a model simulation error (Normal mode simulation).
%        "BuildModel" - Reproduce a model code generation error (using 'slbuild').
%
%    IsCrashReproduction - If true, launch a no-desktop 
%    MATLAB session that reproduces crash issues using the specified 
%    reproduction steps and attempts to return a model that does not crash. 
%    If false (default), run the specified reproduction steps locally. 
%    Crash Reproduction is not supported on Windows.
%
%    LoggingMethod - Method for logging the progress of the transformation,
%    specified as one of these values:
%
%        "TOCONSOLE" (default) - Log progress to the command window.
%        "TOFILE" - log progress to the file specified by 'LogFilePath'.
%        "TOBOTH" = log progress to both the command window and
%        the file specified by 'LogFilePath'.
%        "NOLOG" - Do not log transformation progress.
%
%    LogFilePath - Path to a text file for logging the progress of the transformation.
%
%    Verbosity - Sets how much logging the Chart Simplifier will
%    do. Verbosity can have the following values:
%
%        "Low" (default) - Only log critical information
%        "Medium"        - Log more information
%        "High"          - Log all information
%
%    TransformationOrder - Path to a json file with a custom order of 
%    transformation stages for the chart simplification.
%
%    SimplificationMode - Simplification mode, specified as one of these
%    values:
%
%       "FastMode" (default) - Stop simplification when the source of the
%       error is identified. Return a simplified model that fails and a
%       simplified model that does not reproduce the failure.
%       "CompleteMode" - Run all chart transformations and return a
%       simplified model that reproduces the failure.
%
%    Config - Configuration of transformation stages. You can use the
%    following methods of the Configuration object:
%       -getStages() - Return the stages as a structure.
%       -enableStage(stageName) - Enable the specified stage
%       -disableStage(stageName) - Disable the specified stage
%       -getMaxIterations(stageName) - Return the maximum number of 
%        iterations for the specified stage.
%       -setMaxIterations(stageName,maxIterations) - Set the maximum number 
%        of iterations for the specified stage. Specify the maximum number 
%        of iterations as a positive integer or as "default".
%       -getStageOrder() - Return a cell array that contains the names of 
%        the stages in order.
%       -setStageOrder(stages) - Set the order of the stages as specified 
%        by a cell array that contains the names of stages in order. The 
%        cell array must list each existing stage once. 
%       -addStage(path,maxIterations) - Add a new stage with the given 
%        maximum number of iterations. Define the new stage in a MATLAB 
%        file given by the path. Specify the maximum number of iterations 
%        as a positive integer or as "default".
%       -removeStage(stageName) - Delete the specified stage.
%       -setStageDescription(stageName, description) - Set the description
%        for the stage.
%       -getNamesFromDescription(description) - Return a cell array of
%        names of stages that have that description and a cell array of
%        the indexes of those stages.
%       -resetStages() - Reset to the default configuration defined by the 
%        file TransformationOrder.json. This operation deletes any custom 
%        stages and enables all default stages.
%       -saveConfiguration(path) - Save the current configuration
%        of stages to a json file. Specify the path where you want 
%        to save the configuration file.
%       -loadConfiguration(filename) - Load the configure of stages from the 
%        specified json file. This operation is equivalent to setting the 
%        parameter 'TransformationOrder' of the ChartSimplifier object to the json file
%       -setReproductionSteps(text) - Set the reproduction steps for the 
%        simplifier. The options for text are the same as the options for
%        the ReproductionSteps property.
%
%    Example 1:
%        simplifier =
%        Stateflow.Tools.ChartSimplifier(ChartPath="Model/Chart",ReproductionSteps="CompileModel",LoggingMethod="TOCONSOLE",IsCrashReproduction=true,SimplificationMode="FastMode")
%        simplify(simplifier)
%
%        Call a series of transformations and check if MATLAB crashes 
%        when compiling "Model.slx".
%
%        Return a simplified model "Model_SimplifiedSuccesfulVersion.slx" 
%        when the crash behavior is removed or when all transformation stages 
%        are processed.
%
%        Return a simplified model "Model_SimplifiedFailingVersion.slx" 
%        that exhibits the crashing behavior.
%
%        Log all progress to the command window.
%  
%    Example 2:
%        simplifier =
%        Stateflow.Tools.ChartSimplifier(ChartPath="Model/Chart",ReproductionSteps="CUSTOMREPRODUCTIONSCRIPT")
%        simplify(simplifier)
%
%        Use the script CUSTOMREPRODUCTIONSCRIPT.m to reproduce the error 
%        behavior. For example, this script reproduces an error when the
%        model has a FixedStep size of 0.1:
%
%           model = "ErroringModel";
%           set_param(model,FixedStep=".1")
%           sim(model)
%   
%    Example 3:
%        simplifier =
%        Stateflow.Tools.ChartSimplifier(ChartPath="Model/Chart",ReproductionSteps="RunModel",TransformationOrder="CustomTransformationOrder.json")
%        simplify(simplifier)
%
%        Use the transformation stages in the json file CustomTransformationOrder.json 
%        to resolve a runtime error. For example, this json file specifies three transformation stages:
%
%    {
%       "RemoveLibraryLink" : {
%           "evaluate": "true",
%       },
%        "ChangeChartProperties": {
%                "evaluate": "true",
%        },
%        "CUSTOMSTAGE": {
%                "evaluate": "true",
%        }
%    }
%
%       In this example, the transformation stage 'CUSTOMSTAGE' is defined 
%       by the file CUSTOMSTAGE.m on your MATLAB path. This stage adds the suffix 
%       'Test' to the name of the Stateflow.Data objects in the chart:
%
%       classdef CUSTOMSTAGE < Stateflow.Tools.StateflowChartSimplifier.Stages.TransformationStage
% 
%           methods (Access = public)
% 
%               function obj = CUSTOMSTAGE(ChartPath)
%                   obj.ChartPath = ChartPath;
%               end
% 
%               function setupStage(obj)
%                   chart = obj.getHandleToChart;
%                   data = find(chart,"-isa","Stateflow.Data");
%                   IDs = zeros(length(data),1);
%                   for i = 1:length(data)
%                       IDs(i) = data(i).SSIdNumber;
%                   end
%                   obj.Target = IDs;
%                   obj.MaxNumberOfIterations = length(data);
%               end
% 
%               function executeTransformationStage(self)
%                   self.IsTransformationComplete = false;
%                   self.IterationNum = self.IterationNum + 1;
%                   dataID = self.Target(self.IterationNum);
%                   data = self.getObjectFromID(dataID);
%                   data.Name = [data.Name 'Test'];
%             
%                   if self.IterationNum >= self.MaxNumberOfIterations
%                       self.IsStageFinished = true;
%                   end
%                   self.IsTransformationComplete = true;
%               end
%           end
%       end
% 
%    Example 4: 
%          Using the Config API
%          simplifier = Stateflow.Tools.ChartSimplifier(ChartPath=chartpath,ReproductionSteps=reproductionscript); % Constructor as standard
%          simplifier.Config.resetStages(); % Resets all stages to the default stages and enables them all
%          simplifier.Config.disableStage('RemoveLibraryLink'); % Disables given stage (but does not remove it)
%          simplifier.Config.addStage('MyCustomStage.m', 2) % Adds given stage with given number of max iterations
%          simplifier.Config.setMaxIterations('ChangeChartProp', 5); % Changes max number of iterations for given stage
%          simplifier.simplify() 
%
%   Copyright 2021 The MathWorks, Inc.


    properties(Access = private)
        TargetType
        TargetStateFinder
        ModelManager
        Model
    end

    properties(Access = public, Hidden = true)
        OldReproSteps
    end

    properties(Access = public)
        LogFilePath
        Verbosity
        TransformationOrder
        IsCrashReproduction
        LoggingMethod
        Config
        SimplificationMode        
    end

    methods (Access = public)
        function self = ChartSimplifier(options)

            arguments
                options.ChartPath char
                options.LogFilePath char = ''
                options.LoggingMethod Stateflow.Tools.StateflowChartSimplifier.Logger.LoggerEnum = Stateflow.Tools.StateflowChartSimplifier.Logger.LoggerEnum.TOBOTH
                options.IsCrashReproduction logical = false;
                options.SimplificationMode Stateflow.Tools.StateflowChartSimplifier.ModeEnum = Stateflow.Tools.StateflowChartSimplifier.ModeEnum.Fast
                options.ReproductionSteps char
                options.TransformationOrder char = '';
                options.Verbosity Stateflow.Tools.StateflowChartSimplifier.Logger.VerbosityEnum = Stateflow.Tools.StateflowChartSimplifier.Logger.VerbosityEnum.Low;
            end
            
            if ~isempty(options.TransformationOrder) && ~endsWith(options.TransformationOrder, '.json')
                options.TransformationOrder = [convertStringsToChars(options.TransformationOrder) '.json'];
            end

            self.LogFilePath = options.LogFilePath;
            self.IsCrashReproduction = options.IsCrashReproduction;
            self.TransformationOrder = options.TransformationOrder;
            self.LoggingMethod = options.LoggingMethod;
            self.SimplificationMode = options.SimplificationMode;
            self.Verbosity = options.Verbosity;
            self.Config = Stateflow.Tools.StateflowChartSimplifier.Configuration();
            self.Config.initializeStages(options.TransformationOrder);
            self.Config.setChartPath(options.ChartPath);
            self.Config.setReproductionSteps(options.ReproductionSteps);
        end

        function simplify(self)
            self.createClassFromScript;
            self.createModelManager
            self.platformCheck;
            self.setLoggingType;
            
            Stateflow.Tools.StateflowChartSimplifier.Logger.LoggerController.getInstance('reset');
            Stateflow.Tools.StateflowChartSimplifier.Logger.LoggerController.enterSimplification(self, self.Config);

            open_system(self.Model);

            self.createTargetStateFinder;
            self.TargetStateFinder.setupTargetAndErrorStruct;

            target = self.getTargetStateFinder;
            self.updateModelManager;

            while ~target.SimplificationDone
                self.ModelManager.saveNewModel;
                target.processTransformationStages
            end
            self.ModelManager.saveFinalModel(self.TargetStateFinder.LastTransformationPassed);
            Stateflow.Tools.StateflowChartSimplifier.Logger.LoggerController.logSimplificationDone();
            self.cleanUpClassFromScript;
        end

        function target = getTargetStateFinder(self)
            target = self.TargetStateFinder;
        end

    end

    methods (Access = private)
        function setLoggingType(self)
            if isempty(self.LogFilePath)
                self.LoggingMethod = Stateflow.Tools.StateflowChartSimplifier.Logger.LoggerEnum.TOCONSOLE;
            end
            Stateflow.Tools.StateflowChartSimplifier.Logger.SimplificationLogger.setLoggingType(self.LoggingMethod,self.LogFilePath,self.Config.NewChartPath);
        end

        function createTargetStateFinder(self)
            if self.SimplificationMode == Stateflow.Tools.StateflowChartSimplifier.ModeEnum.Fast
                self.TargetStateFinder = Stateflow.Tools.StateflowChartSimplifier.TargetStateFinder.FastMode(self.Config,self.Model,self.LogFilePath,self.IsCrashReproduction);
            else
                self.TargetStateFinder = Stateflow.Tools.StateflowChartSimplifier.TargetStateFinder.CompleteMode(self.Config,self.Model,self.LogFilePath,self.IsCrashReproduction);
            end
        end

        function platformCheck(self)
            if self.IsCrashReproduction && ispc
                error(message('Stateflow:misc:CrashReproductionNotSupportedOnWindows'))
            end
        end

        function createModelManager(self)
            if self.SimplificationMode == Stateflow.Tools.StateflowChartSimplifier.ModeEnum.Fast
                self.ModelManager = Stateflow.Tools.StateflowChartSimplifier.ModelManager.FastMode(self.Config,self.Model);
            else
                self.ModelManager = Stateflow.Tools.StateflowChartSimplifier.ModelManager.CompleteMode(self.Config,self.Model);
            end
            self.ModelManager.createNewModel;
            self.Model = self.ModelManager.Model;
        end

        function updateModelManager(self)
            %call this method to check if
            %TargetStateFinder.setupTargetAndErrorStruct returned a model
            %with no reproducible error behavior.  If so, the ModelManager
            %implementation must change
            if self.TargetStateFinder.NoErrorFound
                self.ModelManager = Stateflow.Tools.StateflowChartSimplifier.ModelManager.NoErrorFoundMode(self.Config,self.Model);
            end
        end
    end

    methods (Access=public, Hidden=true)
        function createClassFromScript(self)
            reproSteps = self.Config.ReproductionSteps;
            self.OldReproSteps = reproSteps;

            % If a path, create a custom class definition and put the user
            % script in it, saving it to the model directory
            if ~strcmp(reproSteps, 'BuildModel') && ~strcmp(reproSteps, 'CompileModel') && ~strcmp(reproSteps, 'RunModel')
                
                % If file doesn't exist, throw an error
                if exist(which(reproSteps), 'file') ~= 2
                    error(message("Stateflow:misc:FileMustExistForConfig", reproSteps))
                end
   
                userScript = fileread(which(reproSteps));
                slash = strfind(self.Config.ChartPath,'/');
                model = self.Config.ChartPath(1:slash(1)-1);
                if self.IsCrashReproduction
                    newmodel = [model '_CrashTestModel'];
                else
                    newmodel = [model '_SFsimplify'];
                end
                userScript = strrep(userScript,model,newmodel);  

                [folder, name, ~] = fileparts(which(reproSteps));
                text = ...
                    "% This is an autogenerated file made by the Stateflow Chart Simplifier. It is safe to delete." + newline + ...
                    "classdef " + name + "_Custom < Stateflow.Tools.StateflowChartSimplifier.ReproductionSteps.Definition" + newline + ...
                    "    methods" + newline + ...
                    "        function execute(~)" + newline + ...
                    replace([blanks(12) userScript], newline, newline + "            ") + newline + ... % Just to make it look nice :)
                    "        end" + newline + ...
                    "    end" + newline + ...
                    "end" + newline;
                fid = fopen(fullfile(folder, name + "_Custom.m"),'w');
                fprintf(fid, "%s", text);
                fclose(fid);

                self.Config.ReproductionSteps = name + "_Custom";
            end
        end

        function cleanUpClassFromScript(self)
            % Delete custom class
            if (~strcmp(self.Config.ReproductionSteps, 'CompileModel') && ~strcmp(self.Config.ReproductionSteps, 'BuildModel') && ~strcmp(self.Config.ReproductionSteps, 'RunModel'))
                delete(which([convertStringsToChars(self.Config.ReproductionSteps) '.m']));
            end
            
            % Set repro steps back to original one
            self.Config.ReproductionSteps = self.OldReproSteps;
        end
    end

    methods (Static, Access=public, Hidden=true)
        function debugUI()
            connector.ensureServiceOn;
            connector.newNonce;
            url = connector.getUrl('toolbox/stateflow/stateflow/+Stateflow/+Tools/+StateflowChartSimplifier/UI/index-debug.html?test=false');
            web(url, '-browser');
        end
    end
end
