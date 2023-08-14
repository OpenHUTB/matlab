


classdef L5XRung2IR<handle



    properties
        Ctx(1,1)plccore.common.Context;
        POU(1,1);


        expr(1,:)char;



        ir;


        timerCounterMAP;

debug
    end

    properties(Access=private)
        isValid;
instruction2IR
    end

    methods
        function[this]=L5XRung2IR(Ctx,POU,expr,timerCounterMAP)
            import plccore.frontend.L5X.Instruction2IR;
            this.expr=expr;
            this.Ctx=Ctx;
            this.POU=POU;
            this.timerCounterMAP=timerCounterMAP;
            this.debug=plcfeature('PLCLadderDebug');
            this.instruction2IR=Instruction2IR(Ctx,POU,expr,this.debug);




            this.isValid=true;
            ir=this.parseexpr(this.expr);

            if this.isValid
                this.ir=ir;
            else
                warning(['Issue in Expression : ',this.expr,'. Possibly invalid L5X file']);
            end
        end
    end

    methods(Access=private)
        function ir=parseexpr(this,expr)
            import plccore.frontend.L5X.L5XRung2IR;
            import plccore.frontend.L5X.RungLexer;

            lex=RungLexer(expr);
            lex.process;
            tokens_raw=lex.out;


            tokens=L5XRung2IR.getNonEmptyCells(tokens_raw);
            ir=parseTokens(this,tokens,1);
        end

        function[ir,tokenIndexEnd]=parseTokens(this,tokens,tokenIndex)





            insideInstr=false;
            currentInstr={};

            currentChain=[];
            paralleChain=[];
            isOR=false;

            index=tokenIndex;
            while index<=length(tokens)
                currentToken=tokens{index};

                switch currentToken
                case '['
                    [ir,bracketCloseIndex]=parseTokens(this,tokens,index+1);
                    if isOR

                        paralleChain=this.create_and(paralleChain,ir);
                    else
                        currentChain=this.create_and(currentChain,ir);
                    end
                    index=bracketCloseIndex;
                case ']'
                    if isOR
                        currentChain=this.create_or(currentChain,paralleChain);
                    end
                    ir=currentChain;
                    tokenIndexEnd=index;
                    return;
                case ','
                    if~insideInstr
                        if isOR
                            currentChain=this.create_or(currentChain,paralleChain);
                            paralleChain=[];
                        else
                            isOR=true;
                        end
                    end
                case '('
                    if~insideInstr
                        insideInstr=true;
                        currentInstr{end+1}=tokens{index-1};%#ok<AGROW> % 'XIC', '(', 'A' , ')'
                    else
                        assert(false,'invalid token found');
                    end
                case ')'
                    if insideInstr
                        instrName=currentInstr{1};
                        instrOperands={currentInstr{2:end}};%#ok<CCAT1>
                        instrIR=this.instruction2IR.getIRforInstruction(instrName,instrOperands);
                        if isOR
                            paralleChain=this.create_and(paralleChain,instrIR);
                        else
                            currentChain=this.create_and(currentChain,instrIR);
                        end
                        insideInstr=false;
                        currentInstr={};
                    else
                        assert(false);
                    end
                otherwise
                    if insideInstr
                        instrOperand=currentToken;
                        currentInstr{end+1}=instrOperand;%#ok<AGROW>
                    end
                end
                index=index+1;
            end

            if isOR
                currentChain=this.create_or(currentChain,paralleChain);
            end

            ir=currentChain;

        end
    end

    methods(Static,Access=private)


        function cellarr=getNonEmptyCells(cellarr)
            cellarr=cellfun(@strtrim,cellarr,'UniformOutput',false);
            indices=cellfun(@isempty,cellarr);
            cellarr(indices)=[];
        end

        function newChain=create_and(existingChain,blockIR)



            import plccore.ladder.RungOpSeq;
            if~isempty(existingChain)
                if isa(existingChain,'plccore.ladder.RungOpSeq')
                    newChain=RungOpSeq([existingChain.rungOps,{blockIR}]);
                else
                    newChain=RungOpSeq({existingChain,blockIR});
                end
            else
                newChain=blockIR;
            end
        end

        function newChain=create_or(parallelBranchFirst,parallelBranchRemaining)




            import plccore.ladder.RungOpPar;

            rungOpsList={};
            if isa(parallelBranchFirst,'plccore.ladder.RungOpPar')
                rungOpsList=[rungOpsList,parallelBranchFirst.rungOps];
            elseif isempty(parallelBranchFirst)

            else
                rungOpsList{end+1}=parallelBranchFirst;
            end

            if isa(parallelBranchRemaining,'plccore.ladder.RungOpPar')
                rungOpsList=[rungOpsList,parallelBranchRemaining.rungOps];
            elseif isempty(parallelBranchRemaining)

            else
                rungOpsList{end+1}=parallelBranchRemaining;
            end

            newChain=RungOpPar(rungOpsList);

        end
    end
end



