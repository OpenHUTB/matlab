
classdef(Sealed)PLCLadderCGMgr<handle
    properties(Hidden,Access=private)
        fSubsysH;
        fSubsysName;
        fSubsysPath;
        fModelH;
        fMdlName;
        fMdlOption;
        fUseGUIMsg;
        fDiagViewer;
    end

    methods(Static)
        function flag=isLadderTarget(name)
            flag=strcmp(name,'codesys23')...
            ||strcmp(name,'rslogix5000')...
            ||strcmp(name,'studio5000');
        end
    end

    methods
        function obj=PLCLadderCGMgr(subsysH)
            obj.fSubsysH=subsysH;
            obj.fSubsysName=get_param(obj.fSubsysH,'Name');
            obj.fSubsysPath=getfullname(obj.fSubsysH);
            obj.fModelH=bdroot(obj.fSubsysH);
            obj.fMdlName=get_param(obj.fModelH,'Name');
            obj.fMdlOption=plcprivate('plc_options',obj.fSubsysH);
            obj.fUseGUIMsg=PLCCoder.PLCCGMgr.getInstance.getReportGUIMsg;
        end

        function ret=generateCode(obj)
            ret=[];
            obj.showCGStartMessage;
            try
                obj.performCompatibilityChecks;
                ret_file_list=obj.runIRCodegen;
                obj.showCGResult(ret_file_list);
                ret=ret_file_list;
            catch ex
                obj.handleError(ex);
            end
        end

        function ret=checkCompatibility(obj)
            ret=[];
            obj.showCheckLadderStartMessage;
            try
                obj.performCompatibilityChecks;
                obj.showCheckLadderResult(true);
            catch ex
                obj.handleError(ex);
                obj.showCheckLadderResult(false);
            end
        end

        function performCompatibilityChecks(obj)
            obj.checkOutputDir;
            obj.checkTargetIDE;
            obj.checkLadderBlock;
            obj.checkAOIRunnerNDimInterface;
            obj.checkLadderTimers;
            obj.checkDuplicateLabels;
            obj.checkMultipleContinousTasks;
            obj.checkVariableNameCaseMismatch;
        end

        function ret=plcOption(obj)
            ret=obj.fMdlOption;
        end

        function ret=target(obj)
            ret=obj.plcOption.TargetIDE;
        end

        function ret=outputDir(obj)
            ret=obj.plcOption.OutputDir;
        end
    end

    methods(Access=private)

        function showCGStartMessage(obj)
            msg=sprintf('PLC Coder Generate Code for Ladder Model');
            obj.fDiagViewer=Simulink.output.Stage(msg,'ModelName',obj.fMdlName,'UIMode',obj.fUseGUIMsg);
            if obj.fUseGUIMsg
                slmsgviewer.Instance.show;
            end
            PLCCoder.PLCUtils.show_code_gen_status_update(obj.fSubsysH,'plccoder:plccg:StatusMessageCodeGenStarted',getfullname(obj.fSubsysH));
            PLCCoder.PLCUtils.show_code_gen_status_update(obj.fSubsysH,'plccoder:plccg:UsingConfigSet',getfullname(bdroot(obj.fSubsysH)));
        end

        function showCheckLadderStartMessage(obj)
            msg=sprintf('PLC Coder Check Ladder Code Compatibility');
            obj.fDiagViewer=Simulink.output.Stage(msg,'ModelName',obj.fMdlName,'UIMode',obj.fUseGUIMsg);
            if obj.fUseGUIMsg
                slmsgviewer.Instance.show;
            end
        end

        function reportError(obj,msg)%#ok<INUSL>
            sldiagviewer.reportError(msg,'Component','PLC Coder',...
            'Category','PLC Coder ladder code generation');
        end

        function reportInfo(obj,msg)%#ok<INUSL>
            sldiagviewer.reportInfo(['### ',msg],'Component','PLC Coder',...
            'Category','PLC Coder ladder code generation');
        end

        function showCGResult(obj,generatedFiles)
            if isempty(generatedFiles)
                return;
            end
            txt=sprintf('PLC ladder code generation successful for ''%s''.\n\n### Generated ladder files:\n',obj.fSubsysPath);
            for i=1:length(generatedFiles)
                txt=sprintf('%s<a href="matlab: edit(''%s'')">%s</a>\n',txt,generatedFiles{i},generatedFiles{i});
            end
            obj.reportInfo(txt);
        end

        function showCheckLadderResult(obj,check_result)
            if check_result
                txt=sprintf('PLC ladder code compatibility check passed for ''%s''.\n',obj.fSubsysPath);
                obj.reportInfo(txt);
            else
                txt=sprintf('PLC ladder code compatibility check failed for ''%s''.\n',obj.fSubsysPath);
                obj.reportError(txt);
            end
        end

        function checkOutputDir(obj)
            import plccore.common.*;
            out_dir=obj.outputDir;
            out_dir_valid=strtrim(out_dir);
            out_dir_valid=strrep(out_dir_valid,'/',filesep);
            out_dir_valid=strrep(out_dir_valid,'\',filesep);
            if isempty(out_dir_valid)
                filegen=Simulink.fileGenControl('GetConfig');
                out_dir_valid=fullfile(filegen.CodeGenFolder,'plcsrc');
            end
            [dir_create_ok,~,~]=mkdir(out_dir_valid);
            [dir_exist,fattr]=fileattrib(out_dir_valid);
            if dir_exist
                if isnan(fattr.UserWrite)
                    userwrite=false;
                else
                    userwrite=fattr.UserWrite;
                end
                if isnan(fattr.archive)
                    isarchive=false;
                else
                    isarchive=fattr.archive;
                end
                replace_out_dir=false;
                if out_dir_valid(1)==filesep
                    replace_out_dir=true;
                end
                if contains(out_dir_valid,':')
                    replace_out_dir=true;
                end
                if replace_out_dir
                    out_dir_valid=fattr.Name;
                end
            end

            if~dir_create_ok||~dir_exist
                plcThrowError('plccoder:plccore:CreateOutputDirError',out_dir);
            elseif isarchive||~userwrite
                plcThrowError('plccoder:plccore:OutputDirPermissionError',out_dir);
            else
                obj.fMdlOption.OutputDir=out_dir_valid;
            end
        end

        function checkTargetIDE(obj)
            import plccore.common.*;
            switch obj.target
            case{'rslogix5000','studio5000'}
                return;
            end

            plcThrowError('plccoder:plccore:UnsupportedTargetIDE',obj.target);
        end

        function checkLadderTimers(obj)
            import plccore.frontend.ModelParser;
            if ModelParser.isTBEnabled(obj.fMdlName,obj.fSubsysName)
                tonblocks=plc_find_system(getfullname(obj.fSubsysH),'LookUnderMasks','on','PLCBlockType','TON');
                tofblocks=plc_find_system(getfullname(obj.fSubsysH),'LookUnderMasks','on','PLCBlockType','TOF');
                allTONTOF=[strjoin(tonblocks,newline),strjoin(tofblocks,newline)];

                if~isempty(allTONTOF)
                    import plccore.common.plcThrowError;
                    plcThrowError('plccoder:plccore:TimersNotSupportedwithTB',allTONTOF);

                end
            end

        end


        function checkAOIRunnerNDimInterface(obj)
            import plccore.frontend.ModelParser;

            blkPath=getfullname(obj.fSubsysH);
            [isLadder,ldBlkInfo]=ModelParser.isLadderBlock(obj.fSubsysH);
            if isLadder

                if ModelParser.isTBEnabled(obj.fMdlName,obj.fSubsysName)&&...
                    strcmpi(ldBlkInfo.PLCBlockType,ModelParser.LadderAOIRunnerPOUType)



                    obj.checkInterfaceVariablesAreNDims(ldBlkInfo.VariableList,blkPath);

                end
            end
        end

        function checkInterfaceVariablesAreNDims(~,variableList,blkPath)
            for ii=1:length(variableList)
                var=variableList(ii);
                [varSize,convOk]=str2num(var.Size);%#ok<ST2NM>
                assert(convOk,['str2num failed for aoi runner variable size property. Variable name : ',var.Name]);
                if length(varSize)>1
                    import plccore.common.plcThrowError;
                    plcThrowError('plccoder:plccore:TBGenerationNDArrayInterface',blkPath,var.Name,var.Size);
                end
            end
        end


        function checkLadderBlock(obj)
            import plccore.common.*;
            import plccore.common.plcThrowError;
            import plccore.frontend.ModelParser;


            blkPath=getfullname(obj.fSubsysH);
            [isLadder,ldBlkInfo]=ModelParser.isLadderBlock(obj.fSubsysH);
            if isLadder

                if ModelParser.isTBEnabled(obj.fMdlName,obj.fSubsysName)&&...
                    ~strcmpi(ldBlkInfo.PLCBlockType,ModelParser.LadderAOIRunnerPOUType)
                    plcThrowError('plccoder:plccore:InvalidLadderTestBenchGenBlock',ModelParser.LadderAOIRunnerPOUType,blkPath);
                end

                if isempty(ldBlkInfo.PLCPOUType)
                    plcThrowError('plccoder:plccore:InvalidLadderCodeGenBlock',ldBlkInfo.PLCBlockType,blkPath,...
                    ModelParser.LadderControllerPOUType,ModelParser.LadderAOIRunnerPOUType,ModelParser.LadderAOIPOUType);
                end


                if strcmpi(ldBlkInfo.PLCPOUType,ModelParser.LadderControllerPOUType)||...
                    strcmpi(ldBlkInfo.PLCPOUType,ModelParser.LadderAOIPOUType)
                    return;
                end

                if strcmpi(ldBlkInfo.PLCPOUType,ModelParser.LadderProgramPOUType)
                    if~strcmpi(ldBlkInfo.PLCBlockType,ModelParser.LadderAOIRunnerPOUType)
                        plcThrowError('plccoder:plccore:InvalidLadderCodeGenBlock',ModelParser.LadderProgramPOUType,blkPath,...
                        ModelParser.LadderControllerPOUType,ModelParser.LadderAOIRunnerPOUType,ModelParser.LadderAOIPOUType);
                    end
                else
                    blkType=ldBlkInfo.PLCBlockType;
                    plcThrowError('plccoder:plccore:InvalidLadderCodeGenBlock',blkType,blkPath,...
                    ModelParser.LadderControllerPOUType,ModelParser.LadderAOIRunnerPOUType,ModelParser.LadderAOIPOUType);
                end
            else
                blkType=ModelParser.getBlockType(obj.fSubsysH);
                plcThrowError('plccoder:plccore:InvalidLadderCodeGenBlock',blkType,blkPath,...
                ModelParser.LadderControllerPOUType,ModelParser.LadderAOIRunnerPOUType,ModelParser.LadderAOIPOUType);
            end

        end


        function checkMultipleContinousTasks(obj)
            import plccore.frontend.ModelParser;
            taskBlks=plc_find_system(obj.fSubsysPath,'LookUnderMasks','on','FollowLinks','on','PLCPOUType',ModelParser.LadderTaskPOUType);

            continuousTasks={};
            for taskIndex=1:length(taskBlks)
                if isContinuousTask(obj,taskBlks{taskIndex})
                    continuousTasks{end+1}=taskBlks{taskIndex};%#ok<AGROW>
                    if length(continuousTasks)>1
                        import plccore.common.plcThrowError;
                        plcThrowError('plccoder:plccore:MultipleContinuousTasks',strjoin(continuousTasks,', '));
                    end
                end
            end

        end

        function tf=isContinuousTask(~,taskBlk)

            task_rate=get_param(taskBlk,'SystemSampleTime');
            if isempty(task_rate)||strcmpi(task_rate,'-1')
                tf=true;
            else
                tf=false;
            end
        end









        function checkVariableNameCaseMismatch(obj)
            import plccore.frontend.ModelParser;
            import plccore.common.plcThrowError;

            blkPath=getfullname(obj.fSubsysH);
            [isLadder,ldBlkInfo]=ModelParser.isLadderBlock(obj.fSubsysH);
            assert(isLadder,[blkPath,' should be a valid ladder block']);


            if strcmpi(ldBlkInfo.PLCPOUType,ModelParser.LadderControllerPOUType)
                obj.checkCaseMismatch(obj.fSubsysH);
            end


            programBlks=plc_find_system(obj.fSubsysPath,'LookUnderMasks','on','FollowLinks','on','PLCPOUType',ModelParser.LadderProgramPOUType);
            for progIndex=1:length(programBlks)
                programBlk=programBlks{progIndex};
                obj.checkCaseMismatch(programBlk);
            end


            fbBlks=plc_find_system(obj.fSubsysPath,'LookUnderMasks','on','FollowLinks','on','PLCPOUType',ModelParser.LadderAOIPOUType);
            for fbIndex=1:length(fbBlks)
                fbBlk=fbBlks{fbIndex};
                obj.checkCaseMismatch(fbBlk);
            end

        end

        function checkCaseMismatch(~,ladderBlock)
            import plccore.frontend.ModelParser;
            import plccore.common.plcThrowError;

            varNames={};
            blkPath=getfullname(ladderBlock);

            [isLadder,ldBlkInfo]=ModelParser.isLadderBlock(blkPath);
            assert(isLadder,[blkPath,' should be a valid ladder block']);

            for cntrlrVarIndex=1:length(ldBlkInfo.VariableList)
                varName=ldBlkInfo.VariableList(cntrlrVarIndex).Name;
                varScope=ldBlkInfo.VariableList(cntrlrVarIndex).Scope;

                if strcmpi(varScope,'External')
                    continue;
                end

                if ismember(lower(varName),varNames)
                    plcThrowError('plccoder:plccore:VarNamesDifferingOnlyInCase',varName,blkPath);
                else
                    varNames{end+1}=lower(varName);%#ok<AGROW>
                end
            end

        end


        function checkDuplicateLabels(obj)
            import plccore.frontend.ModelParser;
            programBlks=plc_find_system(obj.fSubsysPath,'LookUnderMasks','on','FollowLinks','on','PLCPOUType',ModelParser.LadderProgramPOUType);
            fbBlks=plc_find_system(obj.fSubsysPath,'LookUnderMasks','on','FollowLinks','on','PLCPOUType',ModelParser.LadderAOIPOUType);
            subRoutineBlks=plc_find_system(obj.fSubsysPath,'LookUnderMasks','on','FollowLinks','on','PLCPOUType',ModelParser.LadderSubroutinePOUType);

            for progIndex=1:length(programBlks)
                obj.checkProgramForDuplicateLabels(programBlks{progIndex});
            end

            for fbIndex=1:length(fbBlks)
                obj.checkFunctionBlockForDuplicateLabels(fbBlks{fbIndex});
            end

            for srIndex=1:length(subRoutineBlks)
                obj.checkSubroutineForDuplicateLabels(subRoutineBlks{srIndex});
            end
        end

        function checkProgramForDuplicateLabels(obj,programBlk)
            pou=slplc.api.getPOU(programBlk);
            assert(~isempty(pou)&&~isempty(pou.LogicBlock),'Logic Block should not be empty');
            logicBlk=pou.LogicBlock;
            obj.checkRungsForDuplicateLabels(logicBlk);
        end

        function checkFunctionBlockForDuplicateLabels(obj,fbBlk)
            aoi=slplc.api.getPOU(fbBlk);
            assert(~isempty(aoi)&&~isempty(aoi.LogicBlock),'Logic Block should not be empty');
            logicBlk=aoi.LogicBlock;
            obj.checkRungsForDuplicateLabels(logicBlk);
            if strcmpi(aoi.PLCAllowPrescan,'on')
                prescanBlk=aoi.PrescanBlock;
                obj.checkRungsForDuplicateLabels(prescanBlk);
            end
            if strcmpi(aoi.PLCAllowEnableInFalse,'on')
                enableInFalseBlk=aoi.EnableInFalseBlock;
                obj.checkRungsForDuplicateLabels(enableInFalseBlk);
            end
        end

        function checkSubroutineForDuplicateLabels(obj,subroutineBlk)
            subroutine=slplc.api.getPOU(subroutineBlk);
            assert(~isempty(subroutine)&&~isempty(subroutine.LogicBlock),'Logic Block should not be empty');
            logicBlk=subroutine.LogicBlock;
            obj.checkRungsForDuplicateLabels(logicBlk);
        end

        function checkRungsForDuplicateLabels(~,routineBlk)
            lblBlocks=plc_find_system(routineBlk,'LookUnderMasks','on','FollowLinks','on','SearchDepth',1,'PLCBlockType','LBL');
            lblNames=get_param(lblBlocks,'PLCLabelTag');
            uniqueNames=unique(lblNames);
            if length(lblNames)~=length(uniqueNames)
                allLblNames=strjoin(lblNames,',');
                import plccore.common.plcThrowError;
                plcThrowError('plccoder:plccore:DuplicateLableBlocks',routineBlk,allLblNames);
            end
        end


        function handleError(obj,ex)
            if plcfeature('PLCLadderDebug')
                fprintf(2,'----------Dump error trace begins:\n');
                fprintf(2,'%s\n',getReport(ex,'extended'));
                fprintf(2,'----------Dump error trace ends.\n\n');
            end

            if isa(ex,'plccore.common.PLCCoreException')
                msg=sprintf('%s\n',ex.msg);
            else
                msg=ex.message;
            end
            if(obj.fUseGUIMsg)
                obj.reportError(msg);
            else
                if plccore.util.IsLadderException(ex)
                    rethrow(ex);
                end
                msgId=ex.identifier;
                ME=PLCCoder.PLCException(msgId,msg);
                throwAsCaller(ME);
            end
        end

        function file_name=getLadderFileName(obj)
            switch obj.target
            case 'codesys23'
                file_name=sprintf('%s.exp',obj.fMdlName);
            case{'rslogix5000','studio5000'}
                file_name=sprintf('%s.L5X',obj.fMdlName);
            otherwise
                assert(false,'Unexpected internal error');
            end
        end

        function ret_file_list=runIRCodegen(obj)
            if strcmpi(obj.fMdlOption.GenerateTestbench,'on')
                PLCCoder.PLCUtils.show_code_gen_status_update(obj.fSubsysPath,'plccoder:plccg:StatusMessageCodeGenGatherTBVectors');
                ret_file_list=plcprivate('plc_generate_ladder_tb',obj.fSubsysPath);
                return;
            end

            PLCCoder.PLCUtils.show_code_gen_status_update(obj.fSubsysPath,'plccoder:plccg:StatusMessageCodeGenBegin',obj.target,getfullname(bdroot(obj.fSubsysPath)));
            import plccore.frontend.*
            import plccore.util.*
            import plccore.common.*
            import plccore.visitor.*
            config=PLCConfigInfo(obj.outputDir,obj.getLadderFileName);
            parser=ModelParser(obj.fSubsysPath,config);
            parser.doit;
            ctx=parser.ctx;

            PLCCoder.PLCUtils.show_code_gen_status_update(obj.fSubsysPath,'plccoder:plccg:StatusMessageCodeGenEmitToFile');
            switch obj.target
            case{'studio5000','rslogix5000'}
                emitter=RockwellEmitter(ctx);
            case 'codesys23'
                emitter=Codesys2Emitter(ctx);
            end
            ret_file_list=plccore.common.PLCLadderMgr.generateL5X(emitter,ctx);

        end
    end
end



