classdef LoopingStatus<handle







    properties(Access=private)
        ModelName='';
        Looping=false;
        NextIsCompile=false;
        NextReference=[];
        NoChildren=false;
        AlreadyAnalyzed={};
    end

    methods(Access=public)
        function obj=LoopingStatus(modelName)
            obj.ModelName=modelName;
            if~obj.currentlyLooping
                w=warning('off','Simulink:Commands:LoadingOlderModel');
                c=onCleanup(@()warning(w));
                obj.initiateLooping;
                delete(c);
            end

            obj.determineStatus;
        end

        function b=isLooping(obj)
            b=obj.Looping;
        end

        function b=isNextACompileStep(obj)
            b=obj.NextIsCompile;
            if isempty(b)
                b=false;
            end
        end

        function b=isChildless(obj)
            b=obj.NoChildren;
        end

        function b=isNextSameModel(obj)
            if isempty(obj.NextReference)
                b=false;
                return
            end
            b=strcmp(obj.ModelName,obj.NextReference.name);
        end

        function htmlRefTree=getHTMLReferenceTree(~)
            looper=UpgradeAdvisor.UpgradeLooper;
            htmlRefTree=getHTMLReferenceTree(looper);
        end

        function nextReference=openSameBlockDiagramAsCompileCheckSuppressUI(obj)


            nextReference=openNextModelinSequence(obj,true,false,true);
        end

        function nextReference=openNextModelinSequenceSuppressUI(obj)
            nextReference=obj.openNextModelinSequence(true);
        end

        function nextReference=openNextModelNotLibraryinSequenceSuppressUI(obj)
            nextReference=obj.openNextModelinSequence(true,true);
        end

        function nextReference=openNextModelinSequence(obj,suppressUI,modelsOnly,oneLevelOnly)


            if nargin<3
                modelsOnly=false;
            end
            if nargin<4
                oneLevelOnly=false;
            end

            looper=UpgradeAdvisor.UpgradeLooper;
            if oneLevelOnly


                current=obj.ModelName;
                nextReference=looper.getNextModelToAnalyze;
                while~isempty(nextReference)&&~strcmp(current,nextReference.name)
                    looper.incrementReferenceLoopCount;
                    nextReference=looper.getNextModelToAnalyze;
                end
            else
                if modelsOnly
                    nextReference=looper.getNextModelToAnalyze;
                    while~isempty(nextReference)&&~nextReference.isModel&&~nextReference.isSubSystemReference
                        looper.incrementReferenceLoopCount;
                        if~isempty(nextReference)
                            nextReference=looper.getNextModelToAnalyze;
                        end
                    end
                else
                    nextReference=looper.getNextModelToAnalyze;
                end
            end

            if isempty(nextReference)

                return
            end

            if nargin<2
                suppressUI=false;
            end





            testHarnesses=looper.getTestHarnessesInCurrentSession;
            for jj=1:numel(testHarnesses)
                thisHarness=testHarnesses(jj);
                if isempty(thisHarness.internalHarnessPath)
                    if bdIsLoaded(thisHarness.name)
                        try
                            close_system(thisHarness.name)
                        catch E
                            warning(E.identifier,'%s',E.message)
                        end
                    end
                else
                    try
                        Simulink.harness.close(thisHarness.internalHarnessPath,thisHarness.name)
                    catch E
                        if~strcmp(E.identifier,'Simulink:Harness:CannotDeactivateInactiveHarness')
                            warning(E.identifier,'%s',E.message)
                        end
                    end
                end
            end


            [obj.NextReference,obj.NextIsCompile]=looper.getNextModelToAnalyze;
            looper.incrementReferenceLoopCount;
            if nextReference.isTestHarness
                UpgradeAdvisor.open(nextReference.name,obj.getCompileString,suppressUI,true,nextReference.fullpath);
            else
                UpgradeAdvisor.open(nextReference.name,obj.getCompileString,suppressUI,true);
            end
        end

    end


    methods(Access=private)
        function clearStatus(obj)
            obj.Looping=false;
            obj.NextIsCompile=false;
            obj.NoChildren=false;
        end

        function compileString=getCompileString(obj)
            if obj.NextIsCompile
                compileString='compile';
            else
                compileString='noncompile';
            end
        end

        function b=nextModelSameAsCurrent(obj)
            looper=UpgradeAdvisor.UpgradeLooper;
            nextReference=looper.getNextModelToAnalyze;
            b=strcmp(obj.ModelName,nextReference);
        end

        function amLooping=currentlyLooping(obj)

            looper=UpgradeAdvisor.UpgradeLooper;
            amLooping=false;
            if~isempty(looper.getCurrentModelName)&&...
                looper.isInCurrentSession(obj.ModelName)

                amLooping=true;
                if~strcmp(obj.ModelName,looper.getCurrentModelName)


                    MSLDiagnostic(...
                    'SimulinkUpgradeAdvisor:tasks:LooperUnexpectedChangeInSequence',...
                    looper.getCurrentModelName,obj.ModelName).reportAsWarning;
                    looper.setCurrentModel(obj.ModelName);
                end
            end
        end

        function initiateLooping(obj)

            UpgradeAdvisor.UpgradeLooper(obj.ModelName);
            searchModelHierarchy(obj,obj.ModelName)
        end

        function searchModelHierarchy(obj,parentModel)
            looper=UpgradeAdvisor.UpgradeLooper;
            try




                modelRefs=find_mdlrefs(bdroot(parentModel),...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'WarnForInvalidModelRefs',true,...
                'IgnoreVariantErrors',true);

                for jj=1:numel(modelRefs)
                    thisModel=modelRefs{jj};

                    if ismember(thisModel,obj.AlreadyAnalyzed)
                        continue
                    end
                    obj.AlreadyAnalyzed{end+1}=thisModel;
                    if~strcmp(thisModel,parentModel)



                        looper.addReference(thisModel);
                    end
                    if exist(thisModel,'file')
                        load_system(thisModel);

                        needsReset=UpgradeAdvisor.setModelUpgradeActive(thisModel);
                        if needsReset

                            oc=onCleanup(@()UpgradeAdvisor.clearModelUpgradeActive(thisModel));
                            looper.addCleanUp(oc);
                        end
                        i_add_libraries(looper,thisModel);
                        i_add_subsystem_references(looper,thisModel);
                        obj.analyzeTestHarness(thisModel)
                    end
                end
            catch E

                looper=UpgradeAdvisor.UpgradeLooper;
                looper.clear;
                DAStudio.error('SimulinkUpgradeAdvisor:tasks:LooperFindMdlRefsError',...
                obj.ModelName,[newline,E.message]);
            end
        end


        function determineStatus(obj)
            obj.clearStatus;

            looper=UpgradeAdvisor.UpgradeLooper;
            [obj.NextReference,obj.NextIsCompile]=looper.getNextModelToAnalyze;
            obj.NoChildren=(numel(looper.getModelNames)<2);
            obj.Looping=~isempty(obj.NextReference);
        end

        function analyzeTestHarness(obj,parentModel)
            testHarnesses=Simulink.harness.internal.getHarnessList(parentModel);
            for jj=1:numel(testHarnesses)
                thisHarness=testHarnesses(jj);
                try
                    Simulink.harness.load(thisHarness.ownerFullPath,thisHarness.name);
                catch E


                    warning('SimulinkUpgradeAdvisor:tasks:LooperOpenTestHarnessError',...
                    '%s',E.message)
                    continue
                end
                looper=UpgradeAdvisor.UpgradeLooper;
                if thisHarness.saveExternally&&exist(thisHarness.name,'file')
                    looper.addReference(thisHarness.name);
                else
                    looper.addReference(thisHarness.name,thisHarness.ownerFullPath);
                end
                searchModelHierarchy(obj,thisHarness.name)
                if~strcmp(thisHarness.name,obj.ModelName)



                    Simulink.harness.close(thisHarness.ownerFullPath,thisHarness.name);
                end
            end
        end

    end
end


function i_add_subsystem_references(looper,modelName)



    if isempty(modelName)||~exist(modelName,'file')
        return
    end
    load_system(modelName);
    refs=UpgradeAdvisor.internal.findSubsystemReferences(modelName);
    for kk=1:numel(refs)
        validRef=looper.addReference(refs{kk});


        i_add_subsystem_references(looper,validRef);
    end

end


function i_add_libraries(looper,modelName)



    if isempty(modelName)||~exist(modelName,'file')
        return
    end

    load_system(modelName);


    libs=libinfo(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
    for kk=1:numel(libs)
        validLibrary=looper.addReference(libs(kk).Library);

        i_add_libraries(looper,validLibrary);
    end

end


