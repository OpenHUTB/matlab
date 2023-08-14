classdef AOIEmitter<plccore.visitor.ModelEmitter



    properties(Constant)
        LadderLibAOIRunnerBlock='studio5000_plclib/AOI Runner'
    end

    properties(Access=protected)
TopAOIName
    end

    properties(Access=private)
    end

    methods
        function obj=AOIEmitter(ctx,top_aoi_name)
            obj@plccore.visitor.ModelEmitter(ctx);
            obj.Kind='AOIEmitter';
            obj.TopAOIName=top_aoi_name;
            obj.showDebugMsg;
        end

        function ret=topAOIName(obj)
            ret=obj.TopAOIName;
        end

        function ret=topAOI(obj)
            ret=obj.analyzer.topAOI;
        end
    end

    methods(Access=protected)
        function createAnalyzer(obj)
            import plccore.visitor.*;
            obj.analyzer=TopAOIAnalyzer(obj.ctx,obj.TopAOIName);
        end

        function generateModelInternal(obj)
            if obj.cfg.debug
                aoi=obj.topAOI;
                fprintf(1,'AOI IR:\n%s\n',aoi.toString);
            end
            obj.generateAOI;
            obj.generateAOIRunner;
        end

        function runConfigBeforeMdlCompile(obj)
            if obj.cfg.preserveAOIEnable
                add_param(obj.MainMdlName,plccore.common.PLCLadderMgr.PreserveAOIEnableParam,'On');
            end
        end

        function runConfigAfterMdlCompile(obj)
            add_param(obj.MainMdlName,plccore.common.PLCLadderMgr.L5XNameParam,obj.cfg.fileName);
            if obj.cfg.preserveAOIEnable
                delete_param(obj.MainMdlName,plccore.common.PLCLadderMgr.PreserveAOIEnableParam);
            end
        end
    end

    methods
    end

    methods(Access=private)
        function generateAOIRunner(obj)
            import plccore.visitor.*;
            set_param(obj.MainMdlName,'SolverType','Fixed-step');
            set_param(obj.MainMdlName,'Solver','FixedStepDiscrete');
            obj.activateSystem(obj.MainMdlName,false);
            runner_block=sprintf('%s/%s_runner',obj.MainMdlName,obj.topAOIName);
            runner_block=obj.addModelBlock(obj.LadderLibAOIRunnerBlock,runner_block);
            runner_path=obj.getPOUBlockRoutinePath(runner_block);
            obj.activateSystem(runner_path,false);
            aoi_block=sprintf('%s/%s',runner_path,obj.topAOIName);
            aoi_block=obj.addModelBlock(obj.AOIBlockMap(obj.topAOIName),aoi_block);
            set_param(aoi_block,'PLCPOUName',obj.topAOIName);
            slplc.utils.setTag(aoi_block,'PLCOperandTag',['i0_',obj.topAOIName]);
            plccore.frontend.model.makeBlockSizeElegant(aoi_block);
            openparent_blk=obj.getBlock(runner_path,'OpenParentPOU');
            [x0,y0,~,~]=ModelEmitter.blockPosition(openparent_blk);
            [parentpou_wd,parentPOU_ht]=ModelEmitter.blockSize(openparent_blk);
            [blk_wd,blk_ht]=ModelEmitter.blockSize(aoi_block);

            x0=x0+parentpou_wd/2-blk_wd/2;

            y0=y0+parentPOU_ht+2*ModelLayoutVisitor.StartYOffset;
            set_param(aoi_block,'Position',double([x0,y0,x0+blk_wd,y0+blk_ht]));
            set_param(runner_block,'Position',double([x0,y0,x0+blk_wd,y0+blk_ht]));
            obj.activateSystem(obj.MainMdlName,false);
        end
    end
end





