classdef Model<handle




    properties(Dependent,SetAccess=private)
Name
ImportedName
    end

    properties
FileName
        Warning=false;
    end

    properties(Dependent,SetAccess=private)
ImportedFileName
SummaryFileName
    end

    properties(SetAccess=private)
BlockDiagramType
InitialState
    end

    properties(Dependent)
State
    end

    properties
WorkingDirectory
OutputDirectory
        OutputDirectorySpecified=false
    end

    properties(Dependent,SetAccess=private)
MetricFile
    end

    properties(SetAccess=private)
        Dependencies(1,:)ee.internal.assistant.Model;
        LoggingStatus=false;
        SimulationStatus=false;
        SummaryStatus=false;
        ImportedStatus=false;
        ImportedSimulationStatus=false;
        ComparisonStatus=false;
        SimTime=nan;
        ImportedSimTime=nan;
Summary
    end

    methods
        function obj=Model(modelName)
            obj.FileName=which(modelName);
            obj.WorkingDirectory=pwd;
            obj.OutputDirectory=fileparts(obj.FileName);
            obj.InitialState=obj.State;
        end

        function closeModel(obj)
            obj.State='Closed';
        end

        function compareSimulinkTest(obj)



            obj.ComparisonStatus=false;
            if obj.Warning==true&&obj.ImportedStatus~=true
                disp('Before comparison, import model.');
            end


            sltest.testmanager.clear;sltest.testmanager.clearResults();
            tf=sltest.testmanager.TestFile(obj.Name);
            remove(getTestSuiteByName(tf,[getString(message('stm:objects:NewTestSuiteTitleTemplate')),' 1']));
            ts=createTestSuite(tf,'Import Assistant Test Suite');
            tc=createTestCase(ts,'baseline',obj.Name);


            setProperty(tc,'Model',obj.Name)

            open_system(obj.Name);
            obj.enableLogging;


            bc=captureBaselineCriteria(tc,['baseline_',obj.Name,'.mldatx'],true);
            sc=getSignalCriteria(bc);
            for sdx=1:numel(sc)
                sc(sdx).AbsTol=5e-3;
                sc(sdx).RelTol=1e-2;
                sc(sdx).LeadingTol=1e-3;
                sc(sdx).LaggingTol=1e-3;
            end
            bdclose(obj.Name);


            setProperty(tc,'Model',obj.ImportedName)
            open_system(obj.ImportedName);
            obj.enableLogging(obj.ImportedName);


            testresults=tc.run;
            sltest.testmanager.report(testresults,[obj.Name,'.pdf'],'IncludeTestResults',0,'IncludeComparisonSignalPlots',true);
            copyfile([obj.Name,'.pdf'],fullfile(qeLogDir,[obj.Name,'.pdf']));
            if isequal(testresults.Outcome,sltest.testmanager.TestResultOutcomes.Passed)
                obj.ComparisonStatus=true;
            end
        end

        function delete(obj)
            obj.State=obj.InitialState;
        end

        function enableSummary(obj)
            obj.SummaryStatus=ee.internal.assistant.utils.log('on');
        end

        function enableLogging(obj,modelName)
            if~exist('modelName','var')
                modelName=obj.Name;
            end
            obj.LoggingStatus=false;
            if~bdIsLoaded(modelName)
                load_system(obj.FileName);
            end
            set_param(modelName,'SignalLogging','on');



            scopes=find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Scope');
            scopes=[scopes;find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','SpectrumAnalyzer')];
            scopes=[scopes;find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Display')];
            if~isempty(scopes)
                for scopeIdx=1:length(scopes)
                    thisScope=scopes{scopeIdx};

                    lineHandles=get_param(thisScope,'LineHandles');
                    inportLines=lineHandles.Inport;
                    for inportLineIdx=1:length(inportLines)
                        thisInportLine=inportLines(inportLineIdx);
                        lineObject=get_param(thisInportLine,'object');

                        lineObject.DataLogging=1;
                    end
                end
                set_param(modelName,'SimscapeLogType','none');
                set_param(modelName,'SimscapeLogToSDI','off');
            else
                set_param(modelName,'SimscapeLogType','none');
                set_param(modelName,'SimscapeLogToSDI','off');
            end
            obj.LoggingStatus=true;
        end

        function value=findLibraries(obj,userOnly)
            if userOnly
                [files,missing]=dependencies.fileDependencyAnalysis(obj.FileName);
                if isempty(missing)

                    files=files(~strcmp(files,obj.FileName));

                    value=files(cellfun(@(x)~isempty(x),regexp(files,'\.slx$')));
                else
                    for missingIdx=1:numel(missing)
                        if exist(missing{missingIdx})==4

                            errorString=sprintf('%s\n',missing{missingIdx});
                            errorString=errorString(1:end-1);
                            error('physmod:ee:assistant:MissingLibraryDependencies','Model import failed. Missing library dependencies:\n%s',errorString);
                        end
                    end

                    files=files(~strcmp(files,obj.FileName));

                    value=files(cellfun(@(x)~isempty(x),regexp(files,'\.slx$')));
                end
            else
                obj.openModel;

                findOptions=Simulink.FindOptions(...
                'FollowLinks',false,...
                'IncludeCommented',false);

                blocks=Simulink.findBlocks(obj.Name,findOptions);

                referenceBlock=get_param(blocks,'ReferenceBlock');

                referenceBlock=referenceBlock(cellfun(@(x)~isempty(x),referenceBlock));

                librarySeparator='/';
                value=unique(strtok(referenceBlock,librarySeparator));
            end
            if~iscell(value)
                value={value};
            end
        end

        function value=get.ImportedFileName(obj)
            [~,~,fileExtension]=fileparts(obj.FileName);
            value=fullfile(obj.OutputDirectory,[obj.ImportedName,fileExtension]);
        end

        function value=get.ImportedName(obj)
            value=[obj.Name,'_simscape'];
        end

        function value=get.MetricFile(obj)
            value=fullfile(obj.WorkingDirectory,[obj.Name,'_metrics.mat']);
        end

        function value=get.Name(obj)
            [~,value,~]=fileparts(obj.FileName);
        end

        function value=get.State(obj)

            if~obj.isLoadedOrOpen

                value='Closed';
            else

                if strcmp('off',get_param(obj.Name,'Open'))

                    value='Loaded';
                else

                    value='Open';
                end
            end
        end

        function value=get.SummaryFileName(obj)
            value=fullfile(obj.OutputDirectory,[obj.ImportedName,'.html']);
        end

        function import(obj)

            bdclose('all');
            obj.openModel;

            obj.ImportedStatus=false;
            if obj.Warning==true&&obj.SimulationStatus~=true&&strcmp('model',get_param(obj.Name,'BlockDiagramType'))
                disp('Before import, update or simulate model.');
            end
            if~isempty(get_param(obj.Name,'InitFcn'))
                evalin('base',get_param(obj.Name,'InitFcn'));
            end
            status=elecassistant(obj.FileName,obj.ImportedFileName);
            if~logical(status)
                disp('Import status is false');
            end
            obj.ImportedStatus=status;

            if obj.SummaryStatus
                obj.Summary=ElecAssistantLog.getInstance();
            end


            if isempty(obj.Dependencies)
                obj.updateDependencies;
            end

            if~isempty(obj.Dependencies)
                obj.importDependencies;
                obj.updateLinks;
            end

            obj.updateNetwork;
            bdclose('all');
        end

        function importDependencies(obj)
            for dependencyIdx=1:length(obj.Dependencies)
                thisDependency=obj.Dependencies(dependencyIdx);
                thisDependency.openModel;
                if thisDependency.needsImport
                    thisDependency.import;
                    thisDependency.updateDependencies;
                    thisDependency.importDependencies;
                end
            end
        end

        function value=isImported(obj)

            value=exist(obj.ImportedFileName,'file')==4;
        end

        function value=isImportable(obj)

            userOnly=false;
            libraries=obj.findLibraries(userOnly);
            toggledLibraries=ee.internal.assistant.utils.getLibrariesToggled;
            value=false;

            for libraryIdx=1:length(libraries)
                thisLibrary=libraries{libraryIdx};
                if any(strcmp(thisLibrary,toggledLibraries))
                    value=true;
                    break
                end
            end
        end

        function loadModel(obj)
            obj.State='Loaded';
        end

        function value=needsImport(obj)


            if obj.isImported
                value=false;
            elseif obj.isImportable
                value=true;
            else
                value=false;
            end
        end

        function openImportedModel(obj)
            open_system(obj.ImportedFileName);
        end

        function openModel(obj)
            obj.State='Open';
        end

        function openSummary(obj)
            web(obj.SummaryFileName);
        end

        function printSummaryBlockName(obj)
            if obj.SummaryStatus
                obj.Summary.printLog('sortBlockName');
            end
        end

        function printSummaryImportResult(obj)
            if obj.SummaryStatus
                obj.Summary.printLog('sortImportResult');
            end
        end

        function publishSummary(obj)
            if obj.SummaryStatus
                obj.Summary.publish(obj.SummaryFileName);
            end
        end

        function set.State(obj,value)

            switch lower(value)
            case 'closed'
                if obj.isLoadedOrOpen
                    bdclose(obj.Name);
                end
            case 'loaded'
                if obj.isLoadedOrOpen

                    if strcmp(get_param(obj.Name,'Lock'),'off')
                        set_param(obj.Name,'Open','off');
                    else

                        bdclose(obj.Name);
                        load_system(obj.Name);
                    end
                else
                    load_system(obj.Name);
                end
            case 'open'
                open_system(obj.Name);
            otherwise

            end
        end

        function simulate(obj)


            obj.SimulationStatus=false;
            if obj.Warning==true&&obj.LoggingStatus~=true
                disp('Before simulating, enable logging.');
                return
            end
            if~bdIsLoaded(obj.Name)
                load_system(obj.Name);
            end
            tic;sim(obj.Name);obj.SimTime=toc;
            obj.SimulationStatus=true;
        end

        function simulateImported(obj)


            obj.ImportedSimulationStatus=false;
            if obj.Warning==true&&obj.ImportedStatus~=true
                disp('Before simulating imported model, import model.');
                return
            end

            load_system(obj.ImportedName);
            tic;sim(obj.ImportedName);obj.ImportedSimTime=toc;
            obj.ImportedSimulationStatus=true;
        end

        function updateDependencies(obj)
            userOnly=true;
            dependencies=obj.findLibraries(userOnly);
            obj.Dependencies=ee.internal.assistant.Model.empty;
            for dependencyIdx=1:length(dependencies)
                thisDependency=dependencies{dependencyIdx};
                obj.Dependencies(dependencyIdx)=ee.internal.assistant.Model(thisDependency);
                if obj.OutputDirectorySpecified
                    obj.Dependencies(dependencyIdx).OutputDirectory=obj.OutputDirectory;
                    obj.Dependencies(dependencyIdx).OutputDirectorySpecified=obj.OutputDirectorySpecified;
                end
                obj.Dependencies(dependencyIdx).updateDependencies;
            end
        end

        function updateLinks(obj)
            open_system(obj.ImportedName);

            if strcmp(get_param(obj.ImportedName,'Lock'),'on')
                set_param(obj.ImportedName,'Lock','off');
            end
            for dependencyIdx=1:length(obj.Dependencies)
                thisDependency=obj.Dependencies(dependencyIdx);
                if thisDependency.isImported


                    linkedBlocks=find_system(obj.ImportedName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'regexp','on','ReferenceBlock',['^',thisDependency.Name,'/']);
                    for linkedBlockIdx=1:length(linkedBlocks)
                        thisLinkedBlock=linkedBlocks{linkedBlockIdx};
                        oldReferenceBlock=get_param(thisLinkedBlock,'ReferenceBlock');
                        newReferenceBlock=regexprep(oldReferenceBlock,['^',thisDependency.Name,'/'],[thisDependency.ImportedName,'/']);
                        set_param(thisLinkedBlock,'ReferenceBlock',newReferenceBlock);
                    end
                end
            end
            if strcmp(get_param(obj.ImportedName,'Dirty'),'on')
                save_system(obj.ImportedName);
            end
            bdclose(obj.ImportedName);
        end

        function updateNetwork(obj)
            open_system(obj.ImportedName)
            switch get_param(obj.ImportedName,'BlockDiagramType')
            case 'model'
                set_param(obj.ImportedName,'Solver','ode23t');


                physicalNetworks=ee.internal.assistant.utils.findPhysicalNetwork(obj.ImportedName);


                try
                    unconnectedSolvers=ee.internal.assistant.utils.connectSolverConfig(obj.ImportedName,physicalNetworks);
                    ee.internal.assistant.utils.removeUnconnectedSolverConfiguration(unconnectedSolvers);
                catch
                    warning('physmod:ee:assistant:ConnectingSCFailed','Connecting solver configuration to the networks failed.');
                end


                try
                    ee.internal.assistant.utils.connectElecRef(physicalNetworks);
                catch
                    warning('physmod:ee:assistant:ConnectingERFailed','Connecting electrical reference to the networks failed.');
                end
                set_param(obj.ImportedName,'SaveWithParameterizedLinksMsg','none');
                save_system(obj.ImportedFileName);
            otherwise

            end
            bdclose(obj.ImportedFileName);
        end
    end

    methods(Access=private)
        function value=isLoadedOrOpen(obj)




            modelNames=get_param(Simulink.allBlockDiagrams('model'),'Name');
            if isempty(modelNames)
                value=false;
            else
                value=any(strcmp(obj.Name,modelNames));
            end
        end
    end
end
