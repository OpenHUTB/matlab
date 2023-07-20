





classdef StateflowGraphicalFunctionUnusedOutputConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Unassigned Graphical Function outputs';
        end


        function obj=StateflowGraphicalFunctionUnusedOutputConstraint()
            obj.setEnum('StateflowGraphicalFunctionUnusedOutput');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end



        function out=check(aObj)
            out=[];
            asts=aObj.getOwner.getASTs();

            if aObj.hasUnusedOutputs(asts)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum(),...
                aObj.ParentBlock().getName());
            end
        end



        function out=hasUnusedOutputs(aObj,aAst)
            out=false;
            if(iscell(aAst))
                for i=1:numel(aAst)
                    out=aObj.hasUnusedOutputs(aAst{i});
                    if(out)
                        return;
                    end
                end
            else
                if(isa(aAst,'slci.ast.SFAstUserFunction')&&aAst.IsGraphicalFunction())
                    gfnObj=aAst.ParentChart.getGraphicalFunctionObject(aAst.fSfId);
                    if(gfnObj.getNumOutputs()>1)
                        out=true;
                        parent=aAst.getParent;
                        if isa(parent,'slci.ast.SFAstEqualAssignment')
                            lhs=parent.getChildren{1};
                            if isa(lhs,'slci.ast.SFAstMatlabFunctionCallOutput')
                                out=(gfnObj.getNumOutputs~=numel(lhs.getChildren));
                            end
                        end
                    end
                elseif(isa(aAst,'slci.ast.SFAstMultiOutputFunctionCall')&&aAst.IsGraphicalFunction())
                    gfnObj=aAst.ParentChart.getGraphicalFunctionObject(aAst.fSfId);
                    if(numel(aAst.getChildren())~=...
                        (gfnObj.getNumInputs()+gfnObj.getNumOutputs()))
                        out=true;
                    end
                else
                    asts=aAst.getChildren();
                    for i=1:numel(asts)
                        out=aObj.hasUnusedOutputs(asts{i});
                        if(out)
                            return;
                        end
                    end
                end
            end
        end


        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
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
