classdef(Abstract)TableRow<handle




    properties(Access=public,Dependent)
Index
Preconditions
Postconditions
Summary
    end

    properties(Access=protected)
RowType
InternalRequirement
ChartId
        AllowRefreshUI=true
    end

    properties(Constant,Access=protected)
        ROW='normal'
        DEFAULT_ROW='default'
        ANY_CHILD_ACTIVE='anychildactive'
        ALL_CHILDREN_ACTIVE='allchildrenactive'
    end

    methods

        function out=get.Index(obj)
            out=obj.InternalRequirement.idString;
        end

        function set.Summary(obj,Summary)
            obj.InternalRequirement.summary=Summary;
            obj.refreshUI();
        end

        function out=get.Summary(obj)
            out=obj.InternalRequirement.summary;
        end

        function set.Preconditions(obj,preconditions)
            if strcmp(obj.RowType,obj.DEFAULT_ROW)||obj.isMultiLineLogic(obj.InternalRequirement)
                warning('Slvnv:reqmgt:specBlock:SetPreconditionNotAllowed',...
                DAStudio.message('Slvnv:reqmgt:specBlock:SetPreconditionNotAllowed',obj.RowType));
                return;
            end
            if isa(obj,'slreq.modeling.AssumptionRow')&&numel(preconditions)>1
                error('Slvnv:reqmgt:specBlock:InvalidNumberOfPreconditionsOrPostconditions',...
                DAStudio.message('Slvnv:reqmgt:specBlock:InvalidNumberOfPreconditionsOrPostconditions'));
            end
            [preconditions{:}]=convertStringsToChars(preconditions{:});

            if~iscellstr(preconditions)
                error('Slvnv:reqmgt:specBlock:InputMustBeCellOfStrings',...
                DAStudio.message('Slvnv:reqmgt:specBlock:InputMustBeCellOfStrings'));
            end

            obj.InternalRequirement.setPreconditions(preconditions);
            obj.refreshUI();
        end

        function out=get.Preconditions(obj)
            out=obj.InternalRequirement.getPreconditions();
        end

        function set.Postconditions(obj,postconditions)
            if~obj.canAddPostconditions()
                error('Slvnv:reqmgt:specBlock:SetPostconditionNotAllowed',...
                DAStudio.message('Slvnv:reqmgt:specBlock:SetPostconditionNotAllowed',obj.RowType));
            end
            if isa(obj,'slreq.modeling.AssumptionRow')&&numel(postconditions)>1
                error('Slvnv:reqmgt:specBlock:InvalidNumberOfPreconditionsOrPostconditions',...
                DAStudio.message('Slvnv:reqmgt:specBlock:InvalidNumberOfPreconditionsOrPostconditions'));
            end
            [postconditions{:}]=convertStringsToChars(postconditions{:});

            if~iscellstr(postconditions)
                error('Slvnv:reqmgt:specBlock:InputMustBeCellOfStrings',...
                DAStudio.message('Slvnv:reqmgt:specBlock:InputMustBeCellOfStrings'));
            end
            obj.InternalRequirement.setPostconditions(postconditions);
            obj.refreshUI();
        end

        function out=get.Postconditions(obj)
            out=obj.InternalRequirement.getPostconditions;
        end
    end

    methods(Hidden=true)
        function req=getInternalRequirement(obj)
            req=obj.InternalRequirement;
        end
    end

    methods(Access=protected)
        function tf=isRowTypeDependent(~,rowType)
            tf=strcmpi(rowType,'allchildrenActive')||...
            strcmpi(rowType,'anychildActive');
        end

        function tf=areAncestorsIndependent(obj,parent,parentClass)
            if isa(parent,parentClass)
                tf=true;
                return;
            end
            while~isempty(parent)
                if obj.isMultiLineLogic(parent)
                    tf=false;
                    return;
                end
                parent=parent.parent;
            end
            tf=true;
        end

        function tf=isMultiLineLogic(~,row)
            if isa(row,'sf.req.RequirementsTable')||isa(row,'sf.req.AssumptionsTable')
                tf=false;
            else
                tf=row.multipleLineLogic~=Stateflow.ReqTable.internal.TableManager.INDEPENDENT;
            end
        end

        function tf=isAllChildrenActiveRow(obj)
            if isempty(obj.InternalRequirement.parent)
                tf=false;
                return;
            end
            tf=obj.InternalRequirement.parent.multipleLineLogic==Stateflow.ReqTable.internal.TableManager.ALLCHILDRENACTIVE;
        end

        function tf=isAnyChildActiveRow(obj)
            if isempty(obj.InternalRequirement.parent)
                tf=false;
                return;
            end
            tf=obj.InternalRequirement.parent.multipleLineLogic==Stateflow.ReqTable.internal.TableManager.ANYCHILDACTIVE;
        end

        function tf=canAddPostconditions(obj)
            isAnyChildActive=obj.isAnyChildActiveRow();
            isAllChildrenActive=obj.isAllChildrenActiveRow();
            tf=~isAllChildrenActive&&~isAnyChildActive;
        end

        function setAllowRefreshUI(obj,newValue)
            obj.AllowRefreshUI=newValue;
        end

        function refreshUI(obj)
            if~obj.AllowRefreshUI
                return;
            end
            editor=StateflowDI.SFDomain.getLastActiveEditorForChart(obj.ChartId);
            if isempty(editor)
                return;
            end
            Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(obj.ChartId,'updateTable',{false,false,true},false);
        end

        function verifyCanAddChild(obj,rowType,tableType,parent)
            if~isa(parent,tableType)
                if parent.multipleLineLogic



                    if strcmp(rowType,'default')
                        error('Slvnv:reqmgt:specBlock:CannotAddDefaultRowToMLLHierarchy',...
                        DAStudio.message('Slvnv:reqmgt:specBlock:CannotAddDefaultRowToMLLHierarchy'));
                    end
                else



                    areAncestorsIndependent=obj.areAncestorsIndependent(parent,tableType);
                    if~areAncestorsIndependent
                        error('Slvnv:reqmgt:specBlock:CannotAddRowToDependentHierarchy',...
                        DAStudio.message('Slvnv:reqmgt:specBlock:CannotAddRowToDependentHierarchy'));
                    end
                end
            end
        end
    end
end


