




classdef MatlabFunctionMixedDatatypeConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Binary operators may not have mixed data types';
        end


        function obj=MatlabFunctionMixedDatatypeConstraint
            obj.setEnum('MatlabFunctionMixedDatatype');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end


        function out=check(aObj)

            out=[];
            assert(isa(aObj.getOwner(),'slci.ast.SFAst'));

            ast=aObj.getOwner();
            if~slci.matlab.astTranslator.isUnsupportedMatlabAst(ast)&&...
                aObj.isHeterogenous(ast)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'MatlabFunctionMixedDatatype',...
                aObj.resolveBlockClassName,...
                aObj.ParentBlock().getName());
            end
        end


        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,varargin)
            status=varargin{1};
            id=strrep(class(aObj),'slci.compatibility.','');
            blk_class_name=aObj.resolveBlockClassName;
            if status
                StatusText=DAStudio.message(['Slci:compatibility:',id,'Pass'],blk_class_name);
            else
                StatusText=DAStudio.message(['Slci:compatibility:',id,'Warn']);
            end
            RecAction=DAStudio.message(['Slci:compatibility:',id,'RecAction'],blk_class_name);
            SubTitle=DAStudio.message(['Slci:compatibility:',id,'SubTitle'],blk_class_name);
            Information=DAStudio.message(['Slci:compatibility:',id,'Info'],blk_class_name);
        end

    end

    methods(Access=private)


        function flag=isHeterogenous(aObj,ast)


            flag=false;

            excludedClasses=...
            slci.compatibility.MatlabFunctionMixedDatatypeConstraint.getExcludedClasses();
            if~any(strcmpi(class(ast),excludedClasses))
                children=ast.getChildren();
                datatypes=cellfun(@getDataType,children,'UniformOutput',false);
                datatypes=unique(datatypes);

                datatypes(cellfun(@isempty,datatypes))=[];
                if numel(datatypes)>1

                    flag=true;
                end
            end

        end

    end

    methods(Static=true)


        function excludedClasses=getExcludedClasses()
















            otherExprs={'slci.ast.SFAstArray'};


            stmts={'slci.ast.SFAstCase',...
            'slci.ast.SFAstSwitch',...
            'slci.ast.SFAstOtherwise',...
            'slci.ast.SFAstCastFunction',...
            'slci.ast.SFAstExplicitTypeCast',...
            'slci.ast.SFAstElse',...
            'slci.ast.SFAstElseIf',...
            'slci.ast.SFAstIf',...
            'slci.ast.SFAstIfHead',...
            'slci.ast.SFAstMatlabFunctionDef',...
            'slci.ast.SFAstMatlabFunctionCall',...
            'slci.ast.SFAstReturn',...
            'slci.ast.SFAstComp',...
            };

            excludedClasses=[otherExprs,stmts];

        end

    end

end
