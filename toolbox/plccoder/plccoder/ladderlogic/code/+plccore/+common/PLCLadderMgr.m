classdef(Sealed)PLCLadderMgr<plccore.common.Object




    properties(Constant)
        SkipLadderParam='PLC_SKIP_LADDER'
        AOIListParam='PLC_LADDER_AOI_LIST'
        UDTListParam='PLC_LADDER_UDT_LIST'
        PreserveAOIEnableParam='PLC_LADDER_PRESERVE_ENABLE'
        L5XNameParam='PLC_LADDER_L5X_NAME'
    end

    properties(Hidden,Access=private)
ctx
    end

    methods(Static)
        function[generatedModel,generatedModelLib,generatedBusScript,out]=importL5X(filePath,args)
            import plccore.common.*;
            mgr=PLCLadderMgr;
            try
                [generatedModel,generatedModelLib,generatedBusScript,out]=mgr.import(filePath,args);
            catch ex
                mgr.handleError(ex);
            end
        end

        function tb_code=generateRunnerTB(runner_blk)
            import plccore.common.*;
            mgr=PLCLadderMgr;
            try
                tb_code=mgr.genRunnerTB(runner_blk);
            catch ex
                mgr.handleError(ex);
            end
        end

        function ctx=generateIR(filePath)
            import plccore.common.*;
            mgr=PLCLadderMgr;
            ctx=mgr.genIR(filePath);
        end

        function filelist=generateL5X(emitter,ctx)%#ok<INUSD>
            import plccore.common.*;
            mgr=PLCLadderMgr;
            try
                [~,filelist]=emitter.generateCode;
            catch ex
                mgr.handleError(ex);
            end
        end

        function ret=generateLadderTB(blkH)
            import plccore.common.*;
            mgr=PLCLadderMgr;
            try
                ret=mgr.genLadderTB(blkH);
            catch ex
                mgr.handleError(ex);
            end
        end

        function resetMdl(mdl_name,mdl_state,is_mdl_dirty)
            import plccore.common.*;
            delete_param(mdl_name,PLCLadderMgr.SkipLadderParam);
            delete_param(mdl_name,PLCLadderMgr.AOIListParam);
            delete_param(mdl_name,PLCLadderMgr.UDTListParam);
            cgmgr=PLCCoder.PLCCGMgr.getInstance;
            cgmgr.setLadderDoc([]);


            if isfield(mdl_state,'configobj')
                configobj=mdl_state.configobj;
                set(configobj,'TargetIDE',mdl_state.configobj_ide);
                set(configobj,'OutputDir',mdl_state.configobj_outdir);
                set(configobj,'GenerateTestbench',mdl_state.configobj_gentb);
            end
            set_param(mdl_name,'PLC_GenerateLadderTB',mdl_state.mdl_genldtb);
            set_param(mdl_name,'PLC_LadderFilePath',mdl_state.mdl_ldpath);
            set_param(mdl_name,'PLC_LadderFilePOU',mdl_state.mdl_ldpou);

            if~is_mdl_dirty
                mdlFileName=get_param(mdl_name,'FileName');
                [status,mdlAttributes]=fileattrib(mdlFileName);


                if status==1&&mdlAttributes.UserWrite==1
                    save_system(mdl_name);
                end
            end
        end

        function checkCleanLadderParams(mdl_name)
            import plccore.common.*;
            mgr=PLCLadderMgr;
            mgr.cleanUpLadderParams(mdl_name);
        end
    end

    methods
        function obj=PLCLadderMgr
            obj.Kind='PLCLadderMgr';
            obj.ctx=[];
        end

        function[generatedModel,generatedModelLib,generatedBusScript,out]=import(obj,filePath,args)
            import plccore.frontend.*;
            import plccore.visitor.*;
            import plccore.common.*;

            obj.parseL5X(filePath,args);
            if obj.cfg.generateAOIModel
                emitter=AOIEmitter(obj.ctx,obj.cfg.topAOIName);
            else
                obj.checkEmptyController;
                emitter=ModelEmitter(obj.ctx);
            end

            generatedModel=emitter.generateModel;
            generatedModelLib=emitter.modelLibraryName;
            generatedBusScript=emitter.busDefineScriptName;
            out=struct('GeneratedModel',generatedModel,...
            'GeneratedModelLib',emitter.modelLibraryName,...
            'GeneratedBusScript',generatedBusScript,...
            'UnsupportedInstructions',emitter.unsupportedInstructions);
        end

        function tb_code=genRunnerTB(obj,runner_blk)
            import plccore.common.*;
            blkInfo=slplc.api.getPOU(runner_blk);
            if isempty(blkInfo.PLCBlockType)||...
                ~strcmp(blkInfo.PLCBlockType,'AOIRunner')
                plccore.common.plcThrowError(...
                'plccoder:plccore:MdlBlockNotAOIRunner',...
                plccore.util.Msg(getfullname(runner_blk)));
            end

            aoi_name=obj.getAOIName(runner_blk);
            mdl_name=bdroot(runner_blk);
            try
                fname_main=get_param(mdl_name,plccore.common.PLCLadderMgr.L5XNameParam);
            catch
                plccore.common.plcThrowError(...
                'plccoder:plccore:SourceL5XNotFoundAOIRunner',...
                mdl_name);
            end

            mdl_path=which(mdl_name);
            [file_dir,fname_runner,fname_ext]=fileparts(mdl_path);%#ok<ASGLU>
            l5x_path=fullfile(file_dir,fname_main);
            if exist(l5x_path,'file')~=2
                plccore.common.plcThrowError(...
                'plccoder:plccore:AOIRunnerModelL5XFileNotFound',...
                plccore.util.Msg(l5x_path));
            end
            is_mdl_dirty=bdIsDirty(mdl_name);
            mdl_state=obj.setupMdlRunnerTB(mdl_name,runner_blk,l5x_path,aoi_name,file_dir);


            obj.checkTBFBDataType(aoi_name,obj.genIR(l5x_path));

            try
                tb_code=plcgeneratecode(runner_blk);
            catch me
                PLCLadderMgr.resetMdl(mdl_name,mdl_state,is_mdl_dirty);
                rethrow(me);
            end
            PLCLadderMgr.resetMdl(mdl_name,mdl_state,is_mdl_dirty);
            obj.handleFBCallExprsInTB(tb_code,runner_blk);
        end

        function ctx=genIR(obj,file_path)
            obj.parseL5X(file_path,{});
            ctx=obj.ctx;
        end

        function ret=genLadderTB(obj,blk)
            import plccore.common.*;
            blk_info=slplc.api.getPOU(blk);
            if isempty(blk_info.PLCBlockType)||...
                (~strcmp(blk_info.PLCBlockType,'AOIRunner'))
                plccore.common.plcThrowError(...
                'plccoder:plccore:TBBlockNotAOIRunner',...
                plccore.util.Msg(getfullname(blk)));
            end
            assert(strcmp(blk_info.PLCBlockType,'AOIRunner'));
            aoi_name=obj.getAOIName(blk);
            mdl_name=bdroot(blk);
            cfg=PLCConfigInfo;
            PLCCoder.PLCUtils.show_code_gen_status_update(blk,'plccoder:plccg:StatusMessageCodeGenBegin','studio5000',getfullname(bdroot(blk)));
            mdl_parser=plccore.frontend.ModelParser(getfullname(blk),cfg);
            mdl_parser.doit;


            obj.checkTBFBDataType(aoi_name,mdl_parser.ctx);

            PLCCoder.PLCUtils.show_code_gen_status_update(blk,'plccoder:plccg:StatusMessageCodeGenEmitToFile');
            emitter=plccore.visitor.RockwellTopAOIEmitter(mdl_parser.ctx,aoi_name);
            aoi_info=emitter.generateCode;
            is_mdl_dirty=bdIsDirty(mdl_name);
            mdl_state=obj.setupMdlLadderTB(mdl_name,aoi_info);
            try
                ret=plcprivate('plc_builder','generate_plc_code',get_param(blk,'handle'));
            catch me
                PLCLadderMgr.resetMdl(mdl_name,mdl_state,is_mdl_dirty);
                rethrow(me);
            end
            PLCLadderMgr.resetMdl(mdl_name,mdl_state,is_mdl_dirty);
            obj.handleFBCallExprsInTB(ret,blk);
        end
    end

    methods(Access=private)
        function mdl_state=setupMdlRunnerTB(obj,mdl_name,runner_blk,l5x_path,aoi_name,file_dir)
            import plccore.frontend.*;
            import plccore.visitor.*;
            import plccore.common.*;

            plcprivate('plc_configcomp_attach',mdl_name,runner_blk);
            configobj=plcprivate('plc_options',mdl_name);


            mdl_state=struct;
            mdl_state.configobj=configobj;
            mdl_state.configobj_ide=get(configobj,'TargetIDE');
            mdl_state.configobj_outdir=get(configobj,'OutputDir');
            mdl_state.configobj_gentb=get(configobj,'GenerateTestbench');
            mdl_state.mdl_genldtb=get_param(mdl_name,'PLC_GenerateLadderTB');
            mdl_state.mdl_ldpath=get_param(mdl_name,'PLC_LadderFilePath');
            mdl_state.mdl_ldpou=get_param(mdl_name,'PLC_LadderFilePOU');

            set(configobj,'TargetIDE','studio5000');
            set(configobj,'OutputDir',file_dir);
            set(configobj,'GenerateTestbench','on');
            set_param(mdl_name,'PLC_GenerateLadderTB','on');
            set_param(mdl_name,'PLC_LadderFilePath',l5x_path);
            set_param(mdl_name,'PLC_LadderFilePOU',aoi_name);

            cfg=PLCConfigInfo;
            cfg.parse(l5x_path,{'TopAOI',aoi_name});

            if exist(cfg.UDTAOIListFcnName,'file')~=2
                plccore.common.plcThrowError(...
                'plccoder:plccore:AOIRunnerUDTAOIListFileNotFound',...
                plccore.util.Msg(cfg.UDTAOIListFcnName));
            end

            if exist(cfg.AOIBlockListFcnName,'file')~=2
                plccore.common.plcThrowError(...
                'plccoder:plccore:AOIRunnerAOIBlockListFileNotFound',...
                plccore.util.Msg(cfg.AOIBlockListFcnName));
            end
            udt_aoi_list=feval(cfg.UDTAOIListFcnName);
            [aoi_list,~]=feval(cfg.AOIBlockListFcnName);
            udt_list=setdiff(udt_aoi_list,aoi_list);
            obj.cleanUpLadderParams(mdl_name);
            add_param(mdl_name,obj.SkipLadderParam,'on');
            add_param(mdl_name,obj.AOIListParam,strjoin(aoi_list,','));
            add_param(mdl_name,obj.UDTListParam,strjoin(udt_list,','));
        end

        function mdl_state=setupMdlLadderTB(obj,mdl_name,aoi_info)
            import plccore.frontend.*;
            import plccore.visitor.*;
            import plccore.common.*;

            mdl_state=struct;
            mdl_state.mdl_genldtb=get_param(mdl_name,'PLC_GenerateLadderTB');
            mdl_state.mdl_ldpath=get_param(mdl_name,'PLC_LadderFilePath');
            mdl_state.mdl_ldpou=get_param(mdl_name,'PLC_LadderFilePOU');

            set_param(mdl_name,'PLC_GenerateLadderTB','on');
            set_param(mdl_name,'PLC_LadderFilePath','');
            set_param(mdl_name,'PLC_LadderFilePOU',aoi_info.aoi_name);

            obj.cleanUpLadderParams(mdl_name);

            add_param(mdl_name,obj.SkipLadderParam,'on');
            add_param(mdl_name,obj.AOIListParam,strjoin(aoi_info.aoi_list,','));
            add_param(mdl_name,obj.UDTListParam,strjoin(aoi_info.udt_list,','));

            cgmgr=PLCCoder.PLCCGMgr.getInstance;
            cgmgr.setLadderDoc(aoi_info.doc);
        end

        function parseL5X(obj,filePath,args)
            import plccore.frontend.*;
            import plccore.common.*;

            filePath=convertStringsToChars(filePath);
            cfg=PLCConfigInfo;
            cfg.parse(filePath,args);

            if cfg.useCtx
                obj.ctx=cfg.ctx;



                obj.ctx.setPLCConfigInfo(cfg);
            else
                parser=LadderL5XParser(cfg.filePath,cfg);
                obj.ctx=parser.ctx;
            end

        end

        function ret=cfg(obj)
            ret=obj.ctx.getPLCConfigInfo;
        end

        function ret=getAOIName(obj,runner_blk)%#ok<INUSL>
            pou_type='Function Block';
            blks=plc_find_system(runner_blk,'SearchDepth',2,'LookUnderMasks','all',...
            'PLCPOUType',pou_type);
            if length(blks)~=1
                import plccore.common.plcThrowError;
                plcThrowError('plccoder:plccore:MultipleAOIInsideAOIRunner',...
                getfullname(runner_blk));
            end
            ret=get_param(blks{1},'PLCPOUName');
        end

        function checkEmptyController(obj)
            if isempty(obj.ctx.configuration.taskList)
                plccore.common.plcThrowError(...
                'plccoder:plccore:EmptyControllerImport',...
                obj.cfg.fileName);
            end
        end

        function handleError(obj,ex)%#ok<INUSL>
            if plccore.util.IsLadderException(ex)
                msg=sprintf('Error: %s\n',ex.msg);
                msgId=ex.id;
                ME=plccore.common.PLCCoreException(msgId,msg);
                throwAsCaller(ME);
            end

            rethrow(ex);
        end

        function checkTBFBDataType(obj,fb_name,ctx)



            fb=ctx.configuration.globalScope.getSymbol(fb_name);
            assert(isa(fb,'plccore.common.FunctionBlock'));
            obj.checkFBDataType(fb,@(v)obj.checkSingleElementArrayType(fb_name,v));
            obj.checkFBDataType(fb,@(v)obj.checkNDimArrayType(fb_name,v));
        end

        function checkFBDataType(obj,fb,fcn)%#ok<INUSL>
            import plccore.util.*;
            ApplyListFcn(fb.inputScope.varList,fcn);
            ApplyListFcn(fb.inOutScope.varList,fcn);
            ApplyListFcn(fb.outputScope.varList,fcn);
        end

        function checkSingleElementArrayType(obj,fb_name,var)%#ok<INUSL>
            import plccore.visitor.CheckFBSingleElementArrayTypeVisitor;
            v=CheckFBSingleElementArrayTypeVisitor;
            if var.type.accept(v,[])
                plccore.common.plcThrowError(...
                'plccoder:plccore:TBFBSingleElementArray',...
                var.name,fb_name);
            end
        end

        function checkNDimArrayType(obj,fb_name,var)%#ok<INUSL>
            import plccore.visitor.CheckFBNDimArrayTypeVisitor;
            v=CheckFBNDimArrayTypeVisitor;
            result=var.type.accept(v,[]);
            if~isempty(result)&&result(1)
                plccore.common.plcThrowError(...
                'plccoder:plccore:TBFBNDimArray',...
                var.name,fb_name);
            end
        end

        function cleanUpMdlParam(obj,mdl_name,param_name)%#ok<INUSL>
            try
                get_param(mdl_name,param_name);
                delete_param(mdl_name,param_name);
            catch
            end
        end

        function cleanUpLadderParams(obj,mdl_name)
            obj.cleanUpMdlParam(mdl_name,obj.SkipLadderParam);
            obj.cleanUpMdlParam(mdl_name,obj.AOIListParam);
            obj.cleanUpMdlParam(mdl_name,obj.UDTListParam);
        end

        function handleFBCallExprsInTB(obj,fileNames,blk)
            aoi_name=obj.getAOIName(blk);

            fb_blks=plc_find_system(blk,'SearchDepth',2,'LookUnderMasks','all','PLCPOUName',aoi_name);
            inPortNames=get_param(plc_find_system(fb_blks{1},'LookUnderMasks','on','SearchDepth',1,'BlockType','Inport'),'Name');
            outPortNames=get_param(plc_find_system(fb_blks{1},'LookUnderMasks','on','SearchDepth',1,'BlockType','Outport'),'Name');
            varNamesNoOrder=[inPortNames',outPortNames'];
            varNamesNoOrder=varNamesNoOrder(~strcmp(varNamesNoOrder,'RungIn')&~strcmp(varNamesNoOrder,'RungOut'));

            fb_var_list=slplc.utils.getVariableList(fb_blks{1});
            fb_var_list=fb_var_list(~strcmpi({fb_var_list.Scope},'Local'));
            fb_var_list=fb_var_list(~strcmpi({fb_var_list.Name},'EnableIn')&~strcmpi({fb_var_list.Name},'EnableOut'));
            fb_var_list=fb_var_list(~strcmpi({fb_var_list.PortType},'Hidden'));

            [~,sortIdx]=ismember({fb_var_list.Name},varNamesNoOrder);
            if isequal(sortIdx,1:numel(sortIdx))
                return;
            end

            str=fileread(fileNames{1});
            tokenNames=regexp(str,['(?<aoi>',aoi_name,')\((?<instance>.*?), (?<args>.*?)\);'],'names');
            for i=1:numel(tokenNames)
                args=strsplit(tokenNames(i).args,', ');
                sorted_args=args(sortIdx);
                new_arg_list=strjoin(sorted_args,', ');
                str=strrep(str,tokenNames(i).args,new_arg_list);
            end
            sfprivate('str2file',str,fileNames{1});
        end
    end
end



