



classdef MatlabFunctionMissingDatatypeConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Flag Ast node that does not have a valid data type ';
        end


        function obj=MatlabFunctionMissingDatatypeConstraint
            obj.setEnum('MatlabFunctionMissingDatatype');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function out=check(aObj)

            out=[];

            assert(isa(aObj.getOwner(),'slci.ast.SFAst')||...
            isa(aObj.getOwner(),'slci.matlab.EMData'));
            if~slci.matlab.astTranslator.isUnsupportedMatlabAst(aObj.getOwner())...
                &&isempty(aObj.getOwner.getDataType())...
                &&~aObj.isValidAst()
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'MatlabFunctionMissingDatatype',...
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

        function out=isValidAst(aObj)
            out=false;
            ast=aObj.getOwner();
            if isa(ast,'slci.ast.SFAstConcatenateLB')...
                &&ast.isEmptyBrackets()

                out=true;
            elseif isa(ast,'slci.ast.SFAstIdentifier')...
                &&isa(ast.getParent(),'slci.ast.SFAstIsTester')...
                &&strcmpi(ast.getParent().getFuncName(),'isempty')


                rootAst=ast.getRootAst();
                assert(isa(rootAst,'slci.ast.SFAstMatlabFunctionDef'));
                out=any(cellfun(@(x)strcmp(x.getIdentifier,...
                ast.getIdentifier),rootAst.getPersistentArgs));
            elseif isa(ast,'slci.ast.SFAstIdentifier')...
                &&isa(ast.getParent(),'slci.ast.SFAstDot')...
                &&Simulink.data.isSupportedEnumClass(ast.getParent.getDataType)

                out=true;
            elseif isa(ast,'slci.ast.SFAstIdentifier')...
                &&isa(ast.getParent,'slci.ast.SFAstSendFunction')

                out=true;
            end
        end
    end


end
