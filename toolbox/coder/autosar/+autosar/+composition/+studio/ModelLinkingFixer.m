classdef ModelLinkingFixer





    properties(Access=private)
RefModelName
IsUIMode
IsAdaptiveArch
CompositionHdl
CompBlkHdl
InterfaceDictMigrator
    end

    methods(Access=public)

        function obj=ModelLinkingFixer(compBlkHdl,...
            compositionHdl,refModelWithPath,isUIMode,isAdaptiveArch)
            obj.CompBlkHdl=compBlkHdl;
            obj.CompositionHdl=compositionHdl;
            [~,refModelName,~]=fileparts(refModelWithPath);
            obj.RefModelName=refModelName;
            obj.IsUIMode=isUIMode;
            obj.IsAdaptiveArch=isAdaptiveArch;
        end

        function revertFixes(obj)
            if~isempty(obj.InterfaceDictMigrator)
                obj.InterfaceDictMigrator.revert();
                obj.InterfaceDictMigrator.closeDictionaries(RevertDictionary=true);
            end
        end

        function applyFixes(obj,valMsgs)

            failedCheckNames=obj.getFailureNames(valMsgs);
            if~isempty(failedCheckNames)

                for i=1:length(failedCheckNames)
                    checkToFix=failedCheckNames{i};
                    switch checkToFix
                    case 'complianceFail'

                        if obj.IsAdaptiveArch
                            expSTF='autosar_adaptive.tlc';
                        else
                            expSTF='autosar.tlc';
                        end
                        obj.fixAUTOSARCompliance(expSTF);

                    case 'mappingFail'

                        silenceInterfaceDictPortAutomapWarning=...
                        ~isempty(valMsgs.warnings.InterfaceDictUnmappablePorts)||...
                        ~isempty(valMsgs.warnings.InterfaceDictUnconvertableSignalPorts);
                        obj.fixMapping(silenceInterfaceDictPortAutomapWarning);

                    case 'dictionaryMigrationCheckFail'

                        obj.resolveDictionaryConflicts(valMsgs.flags.InterfaceDictionaryMigrator,valMsgs.flags.IsLinkingAUTOSARModel,...
                        valMsgs.flags.HasLinkedArchitectureDictionary,valMsgs.flags.ConflictsBehavior);

                    case 'portsFail'

                        if~isempty(valMsgs.warnings.InterfaceDictUnconvertableSignalPorts)

                            continue
                        end
                        obj.fixBusPorts;

                    case 'solverTypeFail'

                        obj.fixSolverType;
                    end
                end
            end

            issuedWarningNames=obj.getWarningNames(valMsgs);
            if~isempty(issuedWarningNames)

                for i=1:length(issuedWarningNames)
                    checkToFix=issuedWarningNames{i};
                    switch checkToFix
                    case 'multiTaskWarn'
                        obj.fixMultiTasking;
                    end
                end
            end
        end
    end

    methods(Static)
        function failedCheckNames=getFailureNames(valMsgs)


            checkNames=fieldnames(valMsgs.failures);
            failedCheckNames=checkNames(~structfun(@isempty,valMsgs.failures));
        end

        function issuedWarnings=getWarningNames(valMsgs)

            warningNames=fieldnames(valMsgs.warnings);
            issuedWarnings=warningNames(~structfun(@isempty,valMsgs.warnings));
        end
    end

    methods(Access=public)
        function fixBusPorts(obj)

            backupModel=false;
            issueWarnings=false;
            autosar.simulink.bep.RefactorModelInterface.convertToBEPs(obj.RefModelName,backupModel,issueWarnings);
        end
    end

    methods(Access=private)
        function fixSolverType(obj)
            set_param(obj.RefModelName,'SolverType','Fixed-step');
        end

        function fixAUTOSARCompliance(obj,expSTF)
            autosar.composition.studio.CompBlockUtils.setParam(obj.RefModelName,'SystemTargetFile',expSTF);
        end

        function fixMapping(obj,silenceInterfaceDictPortAutoMapWarning)


            if silenceInterfaceDictPortAutoMapWarning


                unmappedItfDictPortsWarning=warning('off','autosarstandard:dictionary:InterfaceDictCannotAutoMapPorts');
                restoreUnmappedItfDictPortsWarning=onCleanup(@()warning(unmappedItfDictPortsWarning));
            end

            autosar.api.create(obj.RefModelName);
        end

        function resolveDictionaryConflicts(obj,migrator,isLinkingAUTOSARModel,hasLinkedArchitectureDictionary,conflictsBehavior)
            if~isLinkingAUTOSARModel&&hasLinkedArchitectureDictionary

                obj.InterfaceDictMigrator=migrator;
                obj.InterfaceDictMigrator.ConflictResolutionPolicy=conflictsBehavior;
                obj.InterfaceDictMigrator.apply();
            end
        end

        function fixMultiTasking(obj)
            rootCompositionName=get_param(obj.CompositionHdl,'Name');
            autosar.composition.studio.CompBlockUtils.setParam(...
            rootCompositionName,'EnableMultiTasking','on');
        end
    end
end


