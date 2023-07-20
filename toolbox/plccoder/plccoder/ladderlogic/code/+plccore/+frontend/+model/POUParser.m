classdef POUParser<handle








    properties(Access=private)

        PouPath(1,:)char;

        Ctx(1,1)plccore.common.Context;
        LadderDiagramBlk(1,:)char;
        Pou(1,1);
        Debug(1,:)logical;
    end

    methods
        function obj=POUParser(pouPath,ctx)

            obj.PouPath=pouPath;
            obj.Ctx=ctx;
            obj.Debug=plcfeature('PLCLadderDebug');
            obj.LadderDiagramBlk=obj.getLadderDiagramBlk;

        end

        function out=startParsing(obj)
            obj.generateIR;
            out=obj.Pou;
        end
    end

    methods(Access=private)

        function generateIR(obj)
            [tf,pou]=obj.doesPOUDataDefExist();
            if~tf
                obj.createNewPOU();
                obj.generateDataIRForPOU();
            else
                obj.Pou=pou;
            end
            obj.generateRoutines();
        end

        function tf=createNewPOU(obj)
            import plccore.frontend.ModelParser;
            [isLadderBlock,ladderInfo]=ModelParser.isLadderBlock(obj.PouPath);

            ldBlockName=get_param(obj.PouPath,'name');
            assert(isLadderBlock,['Invalid ladder block : ',ldBlockName]);

            [tf,pou]=obj.doesPOUDataDefExist;
            if~tf
                switch lower(ladderInfo.PLCPOUType)


                case 'program'
                    obj.Pou=obj.Ctx.configuration.createProgram(ldBlockName);
                case 'plc controller'


                    obj.Pou=obj.Ctx.configuration.createProgram('MainProgram');
                case 'function block'
                    obj.Pou=obj.Ctx.configuration.createFunctionBlock(ladderInfo.PLCPOUName);
                otherwise
                    assert(false,['Invalid ladder block : ',ldBlockName]);
                end
                if obj.Debug
                    fprintf('Created new POU : %s\n',obj.Pou.name);
                end
            else
                obj.Pou=pou;
            end
        end

        function generateDataIRForPOU(obj)
            import plccore.frontend.ModelParser;
            pouInfo=slplc.api.getPOU(obj.PouPath);
            pouVars=pouInfo.VariableList;
            ModelParser.generateDataIR(pouVars,obj.Ctx,obj.Pou);
            if obj.Debug
                fprintf('Generated vars for : %s\n',obj.Pou.name);
            end
        end

        function generateRoutines(obj)


            import plccore.frontend.ModelParser;
            import plccore.ladder.LadderDiagram;
            import plccore.frontend.model.RoutineParser;
            if ModelParser.isProgramBlk(obj.PouPath)
                routineBlk=getPOUBlockRoutinePath(obj,obj.PouPath);

                routineIR=obj.Pou.createRoutine('MainRoutine');
                routineParser=RoutineParser(routineBlk,obj.Ctx,obj.Pou,routineIR);
                routineParser.startParsing;
                obj.Pou.setMainRoutineName('MainRoutine');
            elseif ModelParser.isAOIBlk(obj.PouPath)
                logicBlk=obj.getPOUBlockRoutinePath(obj.PouPath,plccore.util.RoutineTypes.logic);
                prescanBlk=obj.getPOUBlockRoutinePath(obj.PouPath,plccore.util.RoutineTypes.prescan);
                enableInFalseBlk=obj.getPOUBlockRoutinePath(obj.PouPath,plccore.util.RoutineTypes.enableInFalse);

                routineIR=obj.Pou.createRoutine('Logic');
                routineParser=RoutineParser(logicBlk,obj.Ctx,obj.Pou,routineIR);
                routineParser.startParsing;

                if~isempty(prescanBlk)
                    routineIR=obj.Pou.createRoutine('Prescan');
                    routineParser=RoutineParser(prescanBlk,obj.Ctx,obj.Pou,routineIR);
                    routineParser.startParsing;
                end

                if~isempty(enableInFalseBlk)
                    routineIR=obj.Pou.createRoutine('EnableInFalse');
                    routineParser=RoutineParser(enableInFalseBlk,obj.Ctx,obj.Pou,routineIR);
                    routineParser.startParsing;
                end
            elseif ModelParser.isControllerBlk(obj.PouPath)

            end
        end

        function routineBlk=getPOUBlockRoutinePath(obj,pou_blk,routineType)%#ok<INUSL>
            routineBlk=[];
            if nargin==2
                routineBlk=slplc.utils.getInternalBlockPath(pou_blk,'Logic');
                return;
            end
            switch routineType
            case plccore.util.RoutineTypes.logic
                routineBlk=slplc.utils.getInternalBlockPath(pou_blk,'Logic');
            case plccore.util.RoutineTypes.prescan

                if strcmpi(get_param(pou_blk,'PLCAllowPrescan'),'on')
                    routineBlk=slplc.utils.getInternalBlockPath(pou_blk,'Prescan');
                end
            case plccore.util.RoutineTypes.enableInFalse
                if strcmpi(get_param(pou_blk,'PLCAllowEnableInFalse'),'on')
                    routineBlk=slplc.utils.getInternalBlockPath(pou_blk,'EnableInFalse');
                end
            otherwise
                assert(false,'Rockwell targets only permit ''Logic'', ''EnableInFalse'', ''Prescan'' routines for AOIs');
            end
        end


        function[tf,pou]=doesPOUDataDefExist(obj)
            pou=[];
            import plccore.frontend.ModelParser;
            [isLadderBlock,ladderInfo]=ModelParser.isLadderBlock(obj.PouPath);
            if isLadderBlock&&...
                strcmpi(ladderInfo.PLCPOUType,'function block')
                tf=obj.Ctx.configuration.globalScope.hasSymbol(ladderInfo.PLCPOUName);
                if tf
                    pou=obj.Ctx.configuration.globalScope.getSymbol(ladderInfo.PLCPOUName);
                end
            else
                tf=false;
            end
        end

    end

    methods(Access=private)
        function hdl=getLadderDiagramBlk(obj)
            pou=slplc.api.getPOU(obj.PouPath);
            hdl=pou.LogicBlock;
        end
    end

end





