



classdef StateflowInputDatatypeConstraint<slci.compatibility.Constraint

    methods(Access=private)

        function out=CheckPorts(aObj,aPortDatatype,aAsts)%#ok
            out=false;
            assert(numel(aPortDatatype)>=numel(aAsts));
            for i=1:numel(aAsts)
                astChild=aAsts{i};

                expectedDatatype=aPortDatatype(i);

                actualDatatype=astChild.getDataType();
                if~strcmpi(actualDatatype,expectedDatatype)
                    out=true;
                    return;
                end
            end
        end



        function out=CheckMultiOutputFunctionCall(aObj,aAst)





            inportDatatype=aObj.getInportDatatype(aAst);
            outportDatatype=aObj.getOutportDatatype(aAst);


            astChildren=aAst.getChildren();

            assert(numel(astChildren)<=...
            (numel(inportDatatype)+numel(outportDatatype)));

            nAstChildren=numel(astChildren);
            nInputs=numel(inportDatatype);
            nOutputs=nAstChildren-nInputs;

            out=false;
            if nOutputs

                out=aObj.CheckPorts(outportDatatype,astChildren(1:nOutputs));
            end

            if~out&&nInputs

                out=aObj.CheckPorts(inportDatatype,astChildren(nOutputs+1:end));
            end
        end



        function out=CheckUserFunction(aObj,aAst)
            astChildren=aAst.getChildren();

            inportDatatype=aObj.getInportDatatype(aAst);
            assert(numel(astChildren)==numel(inportDatatype));


            out=aObj.CheckPorts(inportDatatype,astChildren);
        end


        function out=IsDatatypeMismatch(aObj,aAst)
            out=false;
            if(isa(aAst,'slci.ast.SFAstMultiOutputFunctionCall')...
                &&((isa(aObj,'slci.compatibility.StateflowSimulinkFunctionInputDatatypeConstraint')...
                &&aAst.isSFSLFunction())...
                ||(isa(aObj,'slci.compatibility.StateflowGraphicalFunctionInputDatatypeConstraint')...
                &&aAst.IsGraphicalFunction())...
                ||(isa(aObj,'slci.compatibility.StateflowTruthTableInputDatatypeConstraint')...
                &&aAst.IsTruthTable())))


                out=aObj.CheckMultiOutputFunctionCall(aAst);
            elseif(isa(aAst,'slci.ast.SFAstUserFunction')...
                &&((isa(aObj,'slci.compatibility.StateflowSimulinkFunctionInputDatatypeConstraint')...
                &&aAst.isSFSLFunction())...
                ||(isa(aObj,'slci.compatibility.StateflowGraphicalFunctionInputDatatypeConstraint')...
                &&aAst.IsGraphicalFunction())...
                ||(isa(aObj,'slci.compatibility.StateflowTruthTableInputDatatypeConstraint')...
                &&aAst.IsTruthTable())))

                out=aObj.CheckUserFunction(aAst);
            end
        end



        function out=ContainsDatatypeMismatch(aObj,aAst)
            out=aObj.IsDatatypeMismatch(aAst);
            if~out
                asts=aAst.getChildren();
                for i=1:numel(asts)
                    ast=asts{i};
                    if aObj.ContainsDatatypeMismatch(ast)
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
                if aObj.ContainsDatatypeMismatch(ast)
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