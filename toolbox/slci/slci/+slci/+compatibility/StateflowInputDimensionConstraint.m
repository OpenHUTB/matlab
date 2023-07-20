



classdef StateflowInputDimensionConstraint<slci.compatibility.Constraint

    methods(Access=private)


        function out=CheckPorts(aObj,aPortDataDim,aAsts)%#ok
            out=false;
            assert(numel(aPortDataDim)>=numel(aAsts));
            for i=1:numel(aAsts)
                astChild=aAsts{i};

                if iscell(aPortDataDim(i))&&ischar(aPortDataDim{i})
                    try
                        dim=eval(aPortDataDim{i});
                        [flag,dim]=slci.internal.resolveDim(aObj.ParentModel.getHandle,dim);
                        if~flag
                            return;
                        end
                        expectedDataDim=prod(dim);
                    catch
                        expectedDataDim=0;
                    end
                else
                    assert(isnumeric(aPortDataDim(i)),...
                    'Compiled size is numerical');
                    dim=aPortDataDim(i);
                    [flag,dim]=slci.internal.resolveDim(aObj.ParentModel.getHandle,dim);
                    if~flag
                        return;
                    end
                    expectedDataDim=prod(dim);
                end

                dim=astChild.getDataDim;
                [flag,dim]=slci.internal.resolveDim(aObj.ParentModel.getHandle,dim);
                if~flag
                    return;
                end
                actualDataDim=prod(dim);

                if~isequal(actualDataDim,expectedDataDim)
                    out=true;
                    return;
                end
            end
        end



        function out=CheckMultiOutputFunctionCall(aObj,aAst)





            inportDataDim=aObj.getInportDimension(aAst);
            outportDataDim=aObj.getOutportDimension(aAst);


            astChildren=aAst.getChildren();

            assert(numel(astChildren)<=...
            (numel(inportDataDim)+numel(outportDataDim)));

            nAstChildren=numel(astChildren);
            nInputs=numel(inportDataDim);
            nOutputs=nAstChildren-nInputs;

            out=false;
            if nOutputs

                out=aObj.CheckPorts(outportDataDim,astChildren(1:nOutputs));
            end

            if~out&&nInputs

                out=aObj.CheckPorts(inportDataDim,astChildren(nOutputs+1:end));
            end
        end



        function out=CheckUserFunction(aObj,aAst)
            astChildren=aAst.getChildren();

            inportDataDim=aObj.getInportDimension(aAst);
            assert(numel(astChildren)==numel(inportDataDim));


            out=aObj.CheckPorts(inportDataDim,astChildren);
        end


        function out=IsDimensionMismatch(aObj,aAst)
            out=false;
            if(isa(aAst,'slci.ast.SFAstMultiOutputFunctionCall')...
                &&((isa(aObj,'slci.compatibility.StateflowSimulinkFunctionInputDimensionConstraint')...
                &&aAst.isSFSLFunction())...
                ||(isa(aObj,'slci.compatibility.StateflowGraphicalFunctionInputDimensionConstraint')...
                &&aAst.IsGraphicalFunction())...
                ||(isa(aObj,'slci.compatibility.StateflowTruthTableInputDimensionConstraint')...
                &&aAst.IsTruthTable())))

                out=aObj.CheckMultiOutputFunctionCall(aAst);
            elseif(isa(aAst,'slci.ast.SFAstUserFunction')...
                &&((isa(aObj,'slci.compatibility.StateflowSimulinkFunctionInputDimensionConstraint')...
                &&aAst.isSFSLFunction())...
                ||(isa(aObj,'slci.compatibility.StateflowGraphicalFunctionInputDimensionConstraint')...
                &&aAst.IsGraphicalFunction())...
                ||(isa(aObj,'slci.compatibility.StateflowTruthTableInputDimensionConstraint')...
                &&aAst.IsTruthTable())))

                out=aObj.CheckUserFunction(aAst);
            end
        end




        function out=ContainsDimensionMismatch(aObj,aAst)
            out=aObj.IsDimensionMismatch(aAst);
            if~out
                asts=aAst.getChildren();
                for i=1:numel(asts)
                    ast=asts{i};
                    if aObj.ContainsDimensionMismatch(ast)
                        out=true;
                        return;
                    end
                end
            end
        end
    end

    methods


        function out=check(aObj)
            out=[];
            asts=aObj.getOwner.getASTs();
            for i=1:numel(asts)
                ast=asts{i};
                if aObj.ContainsDimensionMismatch(ast)
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    aObj.getEnum(),...
                    aObj.ParentBlock().getName());
                    return;
                end
            end
        end


        function[SubTitle,Information,StatusText,RecAction]=...
            getSpecificMAStrings(aObj,status,varargin)
            enum=aObj.getEnum();
            classnames=aObj.getOwner.getClassNames;
            message_name=['Slci:compatibility:',enum,'Constraint'];
            if status
                status='Pass';
                StatusText=DAStudio.message([message_name,status]);
            else
                status='Warn';
                StatusText=DAStudio.message([message_name,status],classnames);
            end
            Information=DAStudio.message([message_name,'Info']);
            SubTitle=DAStudio.message([message_name,'SubTitle']);
            RecAction=DAStudio.message([message_name,'RecAction'],classnames);
        end
    end
end