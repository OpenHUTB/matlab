classdef Codesys2Emitter<plccore.visitor.BaseEmitter



    properties
TxtWriter
    end

    methods
        function obj=Codesys2Emitter(ctx)
            obj@plccore.visitor.BaseEmitter(ctx);
            obj.Kind='Codesys2Emitter';
            obj.TxtWriter=plccore.util.Codesys2TxtWriter;
            obj.analyzeContext;
        end

        function[ret_flag,ret_file_list]=generateCode(obj)
            obj.generateProgram;
            obj.generateFunctionBlock;
            obj.generateDataType;
            obj.generateGlobalVar;
            obj.TxtWriter.writeFile(obj.Context.getPLCConfigInfo.fileDir,...
            obj.Context.getPLCConfigInfo.fileName);
            ret_flag=true;
            ret_file_list={fullfile(obj.Context.getPLCConfigInfo.fileDir,filesep,...
            obj.Context.getPLCConfigInfo.fileName)};
        end
    end

    methods(Access=private)
        function generateDataType(obj)%#ok<MANU>

        end

        function generateGlobalVar(obj)
            obj.TxtWriter.beginGenGlobalVar;
            for i=1:numel(obj.GlobalVarList)
                var=obj.GlobalVarList{i};
                var.accept(obj,[]);
            end
            obj.TxtWriter.endGenGlobalVar;
        end

        function generateFunctionBlock(obj)
            for i=1:numel(obj.FunctionBlockList)
                fb=obj.FunctionBlockList{i};
                fb.accept(obj,[]);
            end
        end

        function generateProgram(obj)
            for i=1:numel(obj.ProgramList)
                fb=obj.ProgramList{i};
                fb.accept(obj,[]);
            end
        end
    end

    methods
        function ret=visitScope(obj,host,input)
            switch input
            case 'Input'
                obj.TxtWriter.beginVarDecl('VAR_INPUT');
            case 'Output'
                obj.TxtWriter.beginVarDecl('VAR_OUTPUT');
            case 'Local'
                obj.TxtWriter.beginVarDecl('VAR');
            end

            name_list=host.getSymbolNames;
            for i=1:numel(name_list)
                symbol=host.getSymbol(name_list{i});
                symbol.accept(obj,input);
            end

            obj.TxtWriter.endVarDecl;
            ret=[];
        end

        function ret=visitFunction(obj,host,input)%#ok<INUSD>

            ret=[];
        end

        function ret=visitFunctionBlock(obj,host,input)
            obj.TxtWriter.beginGenFB(host.name);
            host.inputScope.accept(obj,'Input');
            host.outputScope.accept(obj,'Output');
            host.localScope.accept(obj,'Local');
            host.impl.accept(obj,input);
            obj.TxtWriter.endGenFB;
            ret=[];
        end

        function ret=visitProgram(obj,host,input)
            obj.TxtWriter.beginGenProgram(host.name);
            host.inputScope.accept(obj,'Input');
            host.outputScope.accept(obj,'Output');
            host.localScope.accept(obj,'Local');
            host.impl.accept(obj,input);
            obj.TxtWriter.endGenProgram;
            ret=[];
        end

        function ret=visitVar(obj,host,input)%#ok<INUSD>
            obj.TxtWriter.genVarDecl(host);
            ret=[];
        end

        function ret=visitVarExpr(obj,host,input)%#ok<INUSD,INUSL>
            ret=host.var.name;
        end

        function ret=visitLadderDiagram(obj,host,input)%#ok<INUSD>
            rungs=host.rungs;
            num_rungs=numel(rungs);
            obj.TxtWriter.beginLadderBody(num_rungs);
            for i=1:num_rungs
                rung=rungs{i};
                rung.accept(obj,i);
            end
            ret=[];
        end

        function[input_ops,output_ops]=getRungInputOutput(obj,rungops)%#ok<INUSL>
            import plccore.visitor.Codesys2Emitter_RungOutputVisitor;
            rov=Codesys2Emitter_RungOutputVisitor;
            output_idx=0;
            for i=1:numel(rungops)
                rungop=rungops{i};
                is_output=rungop.accept(rov,[]);
                if is_output
                    output_idx=i;
                    break;
                end
            end
            if output_idx
                input_ops=rungops(1:output_idx-1);
                output_ops=rungops(output_idx:numel(rungops));
            else
                input_ops=rungops(1:numel(rungops));
                output_ops=[];
            end
        end

        function ret=visitLadderRung(obj,host,input)%#ok<INUSD>
            import plccore.ladder.RungOpSeq;
            obj.TxtWriter.beginRung;
            obj.TxtWriter.beginRungInputSection;
            rungops=host.rungOps;
            [input_ops,output_ops]=obj.getRungInputOutput(rungops);
            if~isempty(input_ops)
                if numel(input_ops)==1
                    rungop=input_ops{1};
                    rungop.accept(obj,[]);
                else
                    RungOpSeq(input_ops).accept(obj,[]);
                end
            else
                obj.TxtWriter.genRungInputEmpty;
            end
            obj.TxtWriter.endRungInputSection;
            obj.TxtWriter.genRungOutputSection(numel(output_ops));
            for i=1:numel(output_ops)
                rungop=output_ops{i};
                rungop.accept(obj,[]);
            end

            ret=[];
        end

        function ret=visitRungOpAtom(obj,host,input)%#ok<INUSD>
            host.instr.accept(obj,host);
            ret=[];
        end

        function ret=visitRungOpTimer(obj,host,input)%#ok<INUSD>
            obj.TxtWriter.genRungTimer(host);
            ret=[];
        end

        function ret=visitRungOpFBCall(obj,host,input)%#ok<INUSD>
            obj.TxtWriter.genRungFBCall(host);
            ret=[];
        end

        function ret=visitRungOpPar(obj,host,input)
            rungops=host.rungOps;
            obj.TxtWriter.beginRungPar(numel(rungops));
            for i=1:numel(rungops)
                rungop=rungops{i};
                rungop.accept(obj,input);
            end
            obj.TxtWriter.endRungSeqPar;
            ret=[];
        end

        function ret=visitRungOpSeq(obj,host,input)
            rungops=host.rungOps;
            obj.TxtWriter.beginRungSeq(numel(rungops));
            for i=1:numel(rungops)
                rungop=rungops{i};
                rungop.accept(obj,input);
            end
            obj.TxtWriter.endRungSeqPar;
            ret=[];
        end

        function ret=visitLadderInstruction(obj,host,input)%#ok<INUSD>
            assert(false,'Not supported');
            ret=[];
        end

        function ret=visitCoilInstr(obj,host,input)%#ok<INUSL>
            var_name=input.inputs{1}.accept(obj,[]);
            obj.TxtWriter.genRungCoil(var_name);
            ret=[];
        end

        function ret=visitNCCInstr(obj,host,input)%#ok<INUSL>
            var_name=input.inputs{1}.accept(obj,[]);
            obj.TxtWriter.genRungNegativeContact(var_name);
            ret=[];
        end

        function ret=visitNOCInstr(obj,host,input)%#ok<INUSL,>
            var_name=input.inputs{1}.accept(obj,[]);
            obj.TxtWriter.genRungPositiveContact(var_name);
            ret=[];
        end

        function ret=visitNTCInstr(obj,host,input)%#ok<INUSD>
            assert(false);
            ret=[];
        end

        function ret=visitNTCoilInstr(obj,host,input)%#ok<INUSD>
            assert(false);
            ret=[];
        end

        function ret=visitNegCoilInstr(obj,host,input)%#ok<INUSL>
            var_name=input.inputs{1}.accept(obj,[]);
            obj.TxtWriter.genRungResetCoil(var_name);
            ret=[];
        end

        function ret=visitPTCInstr(obj,host,input)%#ok<INUSD>
            assert(false);
            ret=[];
        end

        function ret=visitPTCoilInstr(obj,host,input)%#ok<INUSD>
            assert(false);
            ret=[];
        end

        function ret=visitResetCoilInstr(obj,host,input)%#ok<INUSL,>
            var_name=input.inputs{1}.accept(obj,[]);
            obj.TxtWriter.genRungResetCoil(var_name);
            ret=[];
        end

        function ret=visitSetCoilInstr(obj,host,input)%#ok<INUSL,>
            var_name=input.inputs{1}.accept(obj,[]);
            obj.TxtWriter.genRungSetCoil(var_name);
            ret=[];
        end

        function ret=visitConstFalse(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitConstTrue(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitConstValue(obj,host,input)%#ok<INUSD>
            ret=[];
        end

        function ret=visitTimeValue(obj,host,input)%#ok<INUSD>
            ret=[];
        end
    end
end


