



classdef MatlabFunctionUnsupportedAstConstraint<slci.compatibility.Constraint

    methods(Access=public)


        function out=getDescription(aObj,aTextOrObj)%#ok
            out='Unsupported Matlab code will be flagged as incompatible.';
        end

    end

    methods


        function obj=MatlabFunctionUnsupportedAstConstraint()

            obj=obj@slci.compatibility.Constraint();
            obj.setEnum('MatlabFunctionUnsupportedAst');
            obj.setFatal(false);

        end


        function out=check(aObj)

            out=[];
            if slci.matlab.astTranslator.isUnsupportedMatlabAst(aObj.getOwner())
                out=slci.compatibility.Incompatibility(...
                aObj,'MatlabFunctionUnsupportedAst',...
                aObj.resolveBlockClassName);
            end

        end


        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,varargin)
            status=varargin{1};
            id=strrep(class(aObj),'slci.compatibility.','');
            if status
                status='Pass';
            else
                status='Warn';
            end
            blk_class_name=aObj.resolveBlockClassName;
            StatusText=DAStudio.message(['Slci:compatibility:',id,status],blk_class_name);
            RecAction=DAStudio.message(['Slci:compatibility:',id,'RecAction'],blk_class_name);
            SubTitle=DAStudio.message(['Slci:compatibility:',id,'SubTitle'],blk_class_name);
            Information=DAStudio.message(['Slci:compatibility:',id,'Info'],blk_class_name);
        end

    end

    methods(Access=protected)


        function blk_class_name=resolveBlockClassName(aObj)
            if isa(aObj.ParentBlock,'slci.simulink.MatlabFunctionBlock')
                blk_class_name='MATLAB function';
            elseif isa(aObj.ParentBlock,'slci.simulink.StateflowBlock')
                if isa(aObj.getOwner.getRootAstOwner,'slci.stateflow.Transition')
                    blk_class_name=['Stateflow ',DAStudio.message('Slci:compatibility:ClassNameTransition')];
                elseif isa(aObj.getOwner.getRootAstOwner,'slci.stateflow.SFState')
                    blk_class_name=['Stateflow ',DAStudio.message('Slci:compatibility:ClassNameState')];
                else
                    assert(isa(aObj.getOwner.getRootAstOwner,'slci.stateflow.TruthTable'));
                    blk_class_name=['Stateflow ',DAStudio.message('Slci:compatibility:ClassNameTruthTable')];
                end
            else
                assert(false,'This line should not be reached.');
            end
        end

    end


end
