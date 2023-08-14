classdef CreateStaticExpr<optim.internal.problemdef.ast.DefaultVisitor





    properties

PropertiesVisitor
    end


    properties


        InputValues={};

        CurrentInput=0;

        Initializations={};

        InitializedLHS=optim.internal.problemdef.ast.ASTVariable.empty;
    end


    properties


        Outputs=optim.internal.problemdef.ast.ASTVariable.empty;
    end


    properties
        ForLoopLevel=0;
        LoopVariables=optim.internal.problemdef.ast.ASTVariable.empty;
    end

    methods


        function obj=CreateStaticExpr(inputValues)


            obj.InputValues=inputValues;
            obj.PropertiesVisitor=optim.internal.problemdef.visitor.ComputeStaticProperties();
        end

        function outList=getOutputs(interp,stmt,nOutputs)
            [stmtWrapper,stmtASTVar]=getData(stmt);


            [initLHSExprList,hasInit]=arrayfun(@(ast)retrieveInit(ast,interp),...
            stmtASTVar,'UniformOutput',false);

            initLHSExprList=initLHSExprList([hasInit{:}]);
            addInitializations(stmtWrapper,initLHSExprList);

            initExprList=interp.Initializations;
            if~isempty(initExprList)
                newLHS=interp.InitializedLHS;
                if~isempty(newLHS)
                    stmtASTVar=unique([stmtASTVar,newLHS]);
                    newStmtLHSImpl=arrayfun(@(astVar)astVar.LHSImpl,stmtASTVar,'UniformOutput',false);
                    addLHSImpl(stmtWrapper,newStmtLHSImpl);
                end

                addInitializations(stmtWrapper,initExprList);
            end

            [type,vars]=interp.PropertiesVisitor.getOutputs(stmtWrapper);

            outList=arrayfun(@getValue,...
            interp.Outputs,'UniformOutput',false);
            for n=1:nOutputs
                outList{n}=createStaticExpression(outList{n},stmtWrapper,type,vars);
            end

            loopVariables=interp.LoopVariables;
            arrayfun(@resetLHSImpl,loopVariables);

            arrayfun(@resetLHSImpl,stmtASTVar);
            function ASTVar=resetLHSImpl(ASTVar)
                ASTVar.LHSImpl.Value=[];
            end
        end

    end


    methods


        function result=handleAssignment(interp,lhsVar,rhsVar)
            if isa(lhsVar,'optim.internal.problemdef.ast.ParenExpression')


                subscripts=lhsVar.Subscripts;

                lhsVar=lhsVar.ASTVar;

                outVar=createStaticSubsasgn(lhsVar.Value,subscripts,rhsVar,interp.PropertiesVisitor);
            else

                outVar=createStaticAssign(lhsVar.Value,rhsVar,interp.PropertiesVisitor);
            end



            rhsIsOptimExpr=isa(rhsVar,'optim.problemdef.OptimizationExpression');
            OutIsOptimExpr=lhsVar.IsOptimExpr||rhsIsOptimExpr;
            if~OutIsOptimExpr



                lhsVar.InitialValue=outVar;
                result=[];
            else



                if~lhsVar.IsOptimExpr&&~isempty(lhsVar.InitialValue)

                    addInitialization(interp,lhsVar);
                end
                result=optim.internal.problemdef.ast.Statement(lhsVar,outVar);
            end
            lhsVar.IsOptimExpr=OutIsOptimExpr;
        end


        function result=handleColonIndex(~)
            result=':';
        end


        function constVar=handleConstant(~,constVar)
        end


        function const=handleDefineConstant(~,const)


        end


        function astVar=handleDefineInputVariable(interp,variableName)

            currentInput=interp.CurrentInput+1;
            inputValue=interp.InputValues{currentInput};

            interp.CurrentInput=currentInput;

            astVar=optim.internal.problemdef.ast.ASTVariable(variableName,inputValue);

            if astVar.IsOptimExpr&&~isa(inputValue,'optim.problemdef.OptimizationVariable')...
                &&~isNumeric(inputValue)
                createLHSVariable(astVar,interp.PropertiesVisitor);
                addInitialization(interp,astVar);
            end
        end




        function addInitialization(interp,astVar)

            interp.InitializedLHS(end+1)=astVar;
            interp.Initializations{end+1}=astVar.InitialValue;


            astVar.InitialValue=[];
        end


        function astVar=handleDefineOutputVariable(interp,variableName,astVar)
            if nargin<3

                astVar=handleDefineVariable(interp,variableName);
            end

            interp.Outputs(end+1)=astVar;


            astVar=handleLHSVariable(interp,astVar);
            astVar.IsOptimExpr=true;
        end



        function astVar=handleDefineVariable(~,variableName)

            astVar=optim.internal.problemdef.ast.ASTVariable(variableName);
        end


        function result=handleEndIndex(~)
            result=optim.problemdef.OptimizationExpression.createEndIndex();
        end





        function result=handleForLoop(interp,loopVariable,loopRange,evalLoopBody)






            loopRangeImpl=optim.internal.problemdef.ForLoopWrapper.getLoopRange(loopRange);


            loopVariable.IsOptimExpr=true;




            loopRun=false;
            for ival=getValue(loopRangeImpl,interp.PropertiesVisitor)
                loopRun=true;
                break;
            end
            createStaticAssign(loopVariable.Value,ival,interp.PropertiesVisitor);

            interp.LoopVariables(end+1)=loopVariable;

            if loopRun

                loopLevel=interp.ForLoopLevel+1;
                interp.ForLoopLevel=loopLevel;

                if loopLevel==1


                    vis=optim.internal.problemdef.ast.LHSVisitor(interp.PropertiesVisitor);
                    evalLoopBody(vis);
                end


                loopBody=evalLoopBody(interp);




                [loopBodyWrapper,uniqueLhsASTVar]=getData(loopBody);

                ForLoopBody=createForLoop(loopVariable.Value,...
                loopRangeImpl,loopBodyWrapper,loopLevel,...
                interp.PropertiesVisitor);

                result=optim.internal.problemdef.ast.Statement(uniqueLhsASTVar,ForLoopBody);


                interp.ForLoopLevel=interp.ForLoopLevel-1;
            else


                result=[];
            end

        end


        function out=handleFunctionCall(interp,functionName,varargin)
            try

                out=feval(functionName,varargin{:});
            catch




                nOutputs=1;
                out=optim.internal.problemdef.ast.createFunctionOfData(...
                str2func(functionName),nOutputs,varargin,interp.PropertiesVisitor);
                out=out{1};
            end
        end



        function astVar=handleLHSVariable(interp,astVar)
            if~isLHSVariable(astVar)



                createLHSVariable(astVar,interp.PropertiesVisitor);
            end
        end


        function result=handleParenIndexOperation(interp,variable,varargin)

            if(isa(variable,'optim.internal.problemdef.ast.ASTVariable'))

                result=optim.internal.problemdef.ast.ParenExpression(variable,varargin);
                return;
            end


            if interp.ForLoopLevel>0

                if isa(variable,'optim.problemdef.OptimizationExpression')||...
                    containsExpression(varargin)



                    variable=optim.problemdef.OptimizationExpression.wrapData(variable);
                    result=createStaticSubsref(variable,varargin);
                    return;
                end
            end




            IndexingOp=optim.internal.problemdef.operator.StaticSubsref(variable,varargin);
            subs=IndexingOp.getSubStruct(size(variable),interp.PropertiesVisitor);
            result=subsref(variable,subs);
        end


        function result=handleStatements(~,varargin)
            stmtIdx=cellfun(@(input)isa(input,'optim.internal.problemdef.ast.Statement'),varargin);
            [stmtList,lhsVar]=cellfun(@getData,varargin(stmtIdx),'UniformOutput',false);
            uniquelhsVar=unique([lhsVar{:}]);
            uniquelhsImpl=arrayfun(@(lhsASTVar)lhsASTVar.LHSImpl,uniquelhsVar,...
            'UniformOutput',false);
            stmtWrapper=optim.internal.problemdef.StatementWrapper(uniquelhsImpl,stmtList);
            result=optim.internal.problemdef.ast.Statement(uniquelhsVar,stmtWrapper);
        end


        function varVal=handleVariable(~,astVar)
            varVal=getValue(astVar);
        end

    end
end



function hasOptimExpr=containsExpression(input)
    hasOptimExpr=false;
    for i=1:numel(input)
        if isa(input{i},'optim.problemdef.OptimizationExpression')
            hasOptimExpr=true;
            break;
        end
    end
end