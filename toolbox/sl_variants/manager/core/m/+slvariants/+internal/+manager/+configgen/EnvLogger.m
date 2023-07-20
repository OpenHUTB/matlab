classdef(Sealed,Hidden)EnvLogger<handle




    methods

        function obj=EnvLogger(inputArgs)
            if slfeature('VMgrSnapShot')<1
                return
            end
            obj.ParsedInputArgs=inputArgs;
            obj.logEnv();
        end

        function setConfigGenOutput(obj,output)
            if slfeature('VMgrSnapShot')<1
                return
            end
            obj.ConfigGenOutput=output;
        end

        function delete(obj)
            if slfeature('VMgrSnapShot')<1
                return
            end
            storeResult(obj);
        end
    end

    methods(Access=private)
        function logEnv(obj)
            obj.SnapshotDir=slvariants.internal.manager.configgen.createSnapshot(obj.ParsedInputArgs.ModelName);

            if isempty(obj.SnapshotDir)
                return;
            end
            obj.saveConfigGenLog();
        end

        function saveConfigGenLog(obj)
            import slvariants.internal.manager.configgen.ConfigGenConstants;
            obj.FileWriter=slvariants.internal.manager.ui.config.FileWriter();
            logFile=[obj.SnapshotDir,filesep,ConfigGenConstants.LogFileName];
            obj.FileWriter.createFileWriter(logFile);
            headerText=getString(message('Simulink:Variants:MATLABTimeStampEng',datestr(now),version));
            obj.FileWriter.write(headerText);

            info=message('Simulink:VariantManager:AutoGenConfigLogMsg',obj.ParsedInputArgs.ModelName).getString();
            obj.FileWriter.write(info);
            obj.FileWriter.appendLines(1);

            cautionMsg=message('Simulink:VariantManager:AutoGenConfigLogCautionMsg').getString();
            obj.FileWriter.write(cautionMsg);
            obj.FileWriter.appendLines(2);

            genConfigMsg=message('Simulink:VariantManager:AutoGenConfigLogGenCmdMsg').getString();
            obj.FileWriter.write(genConfigMsg);
            obj.FileWriter.appendLines(1);

            cmd=slvariants.internal.manager.configgen.getConfigGenCmd(obj.ParsedInputArgs);
            obj.FileWriter.write(cmd);
            obj.FileWriter.appendLines(2);
        end

        function storeResult(obj)
            if isempty(obj.SnapshotDir)
                return;
            end
            import slvariants.internal.manager.ui.config.VMgrConstants;
            import slvariants.internal.manager.configgen.ConfigGenConstants;
            if~isempty(obj.ConfigGenOutput)
                outMatFile=[obj.SnapshotDir,filesep,ConfigGenConstants.OutputFileName];
                outData=obj.ConfigGenOutput;
                save(outMatFile,'-struct','outData');
                successMsg=message('Simulink:VariantManager:AutoGenConfigLogSuccessMsg',outMatFile).getString();
                obj.FileWriter.write(successMsg);
            else
                failureMsg=message('Simulink:VariantManager:AutoGenConfigLogFailureMsg').getString();
                obj.FileWriter.write(failureMsg);
            end
            snapshotInfo=MException(message('Simulink:VariantManager:AutoGenConfigSnapshotLogMsg',obj.SnapshotDir));
            sldiagviewer.reportInfo(snapshotInfo,'Component',VMgrConstants.DiagComponentName,'Category',VMgrConstants.DiagAutoGenConfigCategory);
        end
    end

    properties(Access=private)

        ParsedInputArgs;

        ConfigGenOutput;

        SnapshotDir(1,:)char;

        FileWriter slvariants.internal.manager.ui.config.FileWriter;

    end

end
