classdef Instruction2IR





    properties
        Ctx(1,1)plccore.common.Context;
        POU(1,1);

        expr(1,:)char;
        debug;
    end

    methods
        function this=Instruction2IR(Ctx,POU,expr,debug)
            this.Ctx=Ctx;
            this.POU=POU;
            this.expr=expr;
            this.debug=debug;
        end

        function ir=getIRforInstruction(this,ladderInstrName,instrOperands)

            import plccore.ladder.RungOpAtom;
            import plccore.ladder.RungOpTimer;
            import plccore.common.plcThrowError;

            assert(ischar(ladderInstrName),'Input should be char array for instruction name');
            assert(iscell(instrOperands),'Input should be cell array of operand names');

            issupported=this.isSupportedLadderInstruction(ladderInstrName);
            if~issupported
                if~this.Ctx.getPLCConfigInfo.supportUnknownInstruction
                    plccore.common.plcThrowError('plccoder:plccore:UnknownInstrNotSupported',ladderInstrName,this.POU.name);
                end
            end

            operandExprs=this.getOperandExpr(instrOperands,ladderInstrName,issupported);
            switch(lower(ladderInstrName))
            case{'jsr','jmp','lbl'}

                ir=this.createBuiltInInstruction(ladderInstrName,operandExprs);
            otherwise


                if this.isTargetInstruction(ladderInstrName)
                    ir=this.createTargetInstruction(ladderInstrName,operandExprs);
                elseif this.isFunctionBlock(ladderInstrName)
                    ir=this.createFunctionBlockInstruction(ladderInstrName,operandExprs);
                else
                    ir=this.createUnknownInstruction(ladderInstrName,operandExprs);
                end
            end
        end

        function tf=isSupportedLadderInstruction(this,instrName)
            tf=this.isTargetInstruction(instrName)||...
            ismember(lower(instrName),{'jsr','jmp','lbl'})||...
            this.isFunctionBlock(instrName);
        end

        function ir=createBuiltInInstruction(this,instrName,operandExprs)
            builtinInstr=this.getBuiltInInstructionSymbol(instrName);
            [inputOperands,~]=this.getInputOutputExprs(builtinInstr,operandExprs);
            import plccore.ladder.RungOpAtom;
            ir=RungOpAtom(builtinInstr,inputOperands,{});
        end

        function symbol=getBuiltInInstructionSymbol(this,instrName)
            switch lower(instrName)
            case 'xic'
                symbol=this.Ctx.NOC;
            case 'xio'
                symbol=this.Ctx.NCC;
            case 'ote'
                symbol=this.Ctx.Coil;
            case 'otu'
                symbol=this.Ctx.ResetCoil;
            case 'otl'
                symbol=this.Ctx.SetCoil;
            case 'jsr'
                symbol=this.Ctx.JSR;
            case 'jmp'
                symbol=this.Ctx.JMP;
            case 'lbl'
                symbol=this.Ctx.LBL;
            end
        end

        function tf=isTargetInstruction(this,instrName)
            symNames=this.Ctx.builtinScope.getSymbolNames;
            targetInstr=[];
            if ismember(instrName,symNames)
                targetInstr=this.Ctx.builtinScope.getSymbol(instrName);
            end

            if isa(targetInstr,'plccore.ladder.TargetInstruction')
                tf=true;
            else
                tf=false;
            end
        end

        function ir=createTargetInstruction(this,instrName,operandExprs)
            targetInstr=this.Ctx.builtinScope.getSymbol(instrName);
            [inputOperands,outputOperands]=this.getInputOutputExprs(targetInstr,operandExprs);

            import plccore.ladder.RungOpAtom;
            ir=RungOpAtom(targetInstr,inputOperands,outputOperands);
        end

        function tf=isFunctionBlock(this,instrName)
            tf=false;
            existsInGlobalScope=this.Ctx.configuration.globalScope.hasSymbol(instrName);
            if existsInGlobalScope
                instrObj=this.Ctx.configuration.globalScope.getSymbol(instrName);

                if isa(instrObj,'plccore.common.FunctionBlock')
                    tf=true;
                end
            end
        end

        function ir=createFunctionBlockInstruction(this,instrName,operandExprs)
            instrObj=this.Ctx.configuration.globalScope.getSymbol(instrName);
            import plccore.ladder.RungOpFBCall;
            instanceIndex=1;
            pouInst=operandExprs{instanceIndex};
            import plccore.common.Utils;


            arglist=instrObj.argList;
            for ii=2:length(operandExprs)
                if isa(operandExprs{ii},'plccore.expr.ConstExpr')
                    assert(~isempty(arglist{ii-1}),['argument list empty in call : ',instrName]);
                    pouInputVar=plccore.common.Utils.getVarInstance(arglist{ii-1},this.Ctx,instrObj);
                    value=operandExprs{ii}.value.value;
                    type=pouInputVar.type;
                    import plccore.expr.ConstExpr;
                    import plccore.common.ConstValue;
                    if isa(type,'plccore.type.BOOLType')
                        assert(isa(value,'char'),['Const value should be of type char but was ',class(value)]);
                        if strcmpi(value,'1')
                            operandExprs{ii}=ConstExpr(plccore.common.ConstTrue);
                        elseif strcmpi(value,'0')
                            operandExprs{ii}=ConstExpr(plccore.common.ConstFalse);
                        else
                            assert(false,['Const value should be 0 or 1 but was ',value]);
                        end
                    else
                        operandExprs{ii}=ConstExpr(ConstValue(type,value));
                    end
                end
            end
            ir=RungOpFBCall(instrObj,pouInst,operandExprs(2:end));

        end

        function[inputOperands,outputOperands]=getInputOutputExprs(this,instrIR,operandExprs)%#ok<INUSL>

            if isa(instrIR,'plccore.ladder.TargetInstruction')
                import plccore.frontend.L5X.Instruction2IR;
                operandCount=length(operandExprs);

                if operandCount~=instrIR.getNumInput+instrIR.getNumOutput&&...
                    instrIR.getNumInput+instrIR.getNumOutput~=0

                    assert(false,['Number of Input and Output does not match. No matching IR instruction found for :',instrIR.name]);
                end

                if operandCount>0
                    inputOperands=operandExprs(1:instrIR.getNumInput);
                    outputOperands=operandExprs(instrIR.getNumInput+1:end);
                else
                    inputOperands={};
                    outputOperands={};
                end
            else
                if~isa(instrIR,'plccore.ladder.JSRInstr')

                    assert(length(operandExprs)==1,...
                    ['Number of Input and Output does not match. No matching IR instruction found for :',instrIR.name]);
                end

                if~isempty(operandExprs)
                    inputOperands=operandExprs(:);
                    outputOperands={};
                else
                    inputOperands={};
                    outputOperands={};
                end
            end
        end

        function ir=createUnknownInstruction(this,instrName,operandExprs)%#ok<INUSL>
            import plccore.ladder.*;
            instr=UnknownInstr(instrName);

            import plccore.ladder.RungOpAtom;
            if isempty(operandExprs)
                ir=RungOpAtom(instr,{},{});
            else
                ir=RungOpAtom(instr,operandExprs(:),{});
            end
        end

        function operandExprs=getOperandExpr(this,operandList,instrName,issupported)
            import plccore.expr.VarExpr;
            import plccore.expr.StructRefExpr;
            import plccore.expr.ArrayRefExpr;
            import plccore.expr.IntegerBitRefExpr;

            operandExprs=cell(1,length(operandList));
            delete_idx=[];
            for ii=1:length(operandList)

                operand=operandList{ii};

                if~issupported
                    operandExprs{ii}=plccore.expr.UnknownExpr(operand);
                    continue;
                end

                if ismember(instrName,{'CPT'})
                    if ii~=1
                        operandExprs{ii}=plccore.expr.StringExpr(operand);
                        continue;
                    end
                end

                if ismember(instrName,{'CMP'})
                    operandExprs{ii}=plccore.expr.StringExpr(operand);
                    continue;
                end

                if strcmp(operand,'?')
                    operandExprs{ii}=plccore.expr.WildCardExpr(operand);
                    continue;
                end

                if strcmpi(operand,'true')
                    operand='1';
                end

                if strcmpi(operand,'false')
                    operand='0';
                end

                if ismember(':',operand)
                    operandExprs{ii}=plccore.expr.UnknownExpr(operand);
                    continue;
                end


                if strcmp(instrName,'GSV')&&(ii==1||ii==2||ii==3)
                    operandExprs{ii}=plccore.expr.UnknownExpr(operand);
                    continue;
                end

                if strcmp(instrName,'JSR')
                    if strcmp(operand,'0')
                        delete_idx(end+1)=ii;%#ok<AGROW>
                        continue;
                    elseif length(operandList)>2
                        plccore.common.plcThrowError('plccoder:plccore:JSRInputOutput',[instrName,'(',strjoin(operandList,','),')']);
                    end
                    routine=this.POU.localScope.getSymbol(operand);
                    assert(isa(routine,'plccore.common.Routine'));
                    operandExprs{ii}=plccore.expr.RoutineExpr(routine);
                    continue;
                end

                if strcmp(instrName,'JMP')||strcmp(instrName,'LBL')...
                    ||strcmp(instrName,'EVENT')

                    operandExprs{ii}=plccore.expr.StringExpr(operand);
                    continue;
                end

                import plccore.frontend.L5X.Instruction2IR;
                aliasVarsGlobalMap=this.Ctx.configuration.getAliasVarsMap;
                aliasVarsPOUMap=this.POU.getAliasVarsMap;

                operandWithoutAlias=operand;
                if~isempty(aliasVarsGlobalMap)||~isempty(aliasVarsPOUMap)
                    operandWithoutAlias=Instruction2IR.replaceAlias(operand,aliasVarsPOUMap);
                    if strcmp(operandWithoutAlias,operand)
                        operandWithoutAlias=Instruction2IR.replaceAlias(operand,aliasVarsGlobalMap);
                    end

                    if this.debug==10
                        disp(['Alias : ''',operand,''' converted to direct expression : ''',operandWithoutAlias,'''']);
                    end
                end
                operandExprs{ii}=plccore.frontend.L5X.util.getLadderExpr(this.Ctx,this.POU,this.expr,operandWithoutAlias);
            end

            for j=1:length(delete_idx)
                idx=delete_idx(j);
                operandExprs(idx)=[];
            end
        end
    end

    methods(Static,Access=private)
        function out=replaceAlias(instrArg,aliasVarsMap)
            import plccore.frontend.L5X.Instruction2IR;
            import plccore.common.Utils;
            out=instrArg;
            if isempty(aliasVarsMap)
                return;
            end
            aliasName=Utils.getSubTextTillDotOrBrace(instrArg);

            if aliasVarsMap.isKey(aliasName)
                aliasRef=aliasVarsMap(aliasName);
                aliasRef_aliasName=Utils.getSubTextTillDotOrBrace(aliasRef);
                if aliasVarsMap.isKey(aliasRef_aliasName)
                    aliasRef=Instruction2IR.replaceAlias(aliasRef,aliasVarsMap);
                end

                if ismember(':',aliasRef)
                    return;
                end
                out=regexprep(instrArg,['^',aliasName],aliasRef);

            end

        end
    end
end



