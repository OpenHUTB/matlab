










classdef MatlabFunctionMixedDataDimConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Implicit Expansion is not supported in SLCI now. The dimensions of the inputs need to be uniform';
        end


        function obj=MatlabFunctionMixedDataDimConstraint
            obj.setEnum('MatlabFunctionMixedDataDim');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end


        function out=check(aObj)

            out=[];
            assert(isa(aObj.getOwner(),'slci.ast.SFAst'));

            ast=aObj.getOwner();

            if~slci.matlab.astTranslator.isUnsupportedMatlabAst(ast)&&...
                aObj.isIncluded(ast)&&...
                aObj.isHeterogenous(ast)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum(),...
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
            children=ast.getChildren();

            assert(numel(children)==2);
            datadims=cellfun(@getDataDim,children,'UniformOutput',false);

            scalar=false;
            for i=1:numel(children)
                if isscalar(datadims{i})||all(datadims{i}==1)
                    scalar=true;
                    break;
                end
            end

            if~scalar

                datadims=cellfun(@(x)num2str(x(:)'),datadims,'UniformOutput',false);
                datadims=unique(datadims);

                datadims(cellfun(@isempty,datadims))=[];
                if numel(datadims)>1


                    flag=true;
                end
            end
        end


        function flag=isIncluded(aObj,ast)









            flag=false;
            includedClasses={'slci.ast.SFAstPlus',...
            'slci.ast.SFAstMinus',...
            'slci.ast.SFAstTimes',...
            'slci.ast.SFAstLDiv',...
            'slci.ast.SFAstDotDiv',...
            'slci.ast.SFAstIsEqual',...
            'slci.ast.SFAstIsNotEqual',...
            'slci.ast.SFAstGreaterThan',...
            'slci.ast.SFAstGreaterThanOrEqual',...
            'slci.ast.SFAstLesserThan',...
            'slci.ast.SFAstLesserThanOrEqual',...
            'slci.ast.SFAstLogicalAnd',...
            'slci.ast.SFAstLogicalOr',...
            'slci.ast.SFAstBitAnd',...
            'slci.ast.SFAstBitOr',...
            'slci.ast.SFAstBitXor',...
            'slci.ast.SFAstMin',...
            'slci.ast.SFAstMax',...
            'slci.ast.SFAstDotPow',...
            };
            if any(strcmpi(class(ast),includedClasses))

                flag=true;
            elseif strcmpi(class(ast),'slci.ast.SFAstMathBuiltin')
                fnTypes={'mod',...
                'rem',...
                'hypot',...
                'atan2',...
                };
                if any(strcmpi(ast.getMathType,fnTypes))
                    flag=true;
                end
            end
        end

    end

end
