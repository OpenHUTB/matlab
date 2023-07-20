





classdef SFAstNullCopy<slci.ast.SFAstMatlabDirective

    methods


        function aObj=SFAstNullCopy(aAstObj,args,aParent)
            assert(isa(aAstObj,'mtree'),...
            DAStudio.message('Slci:slci:NotMtreeNode',...
            'SFAstNullCopy'));
            aObj=aObj@slci.ast.SFAstMatlabDirective(aAstObj,...
            aParent);
            assert(numel(args)==1);
            argNode=args{1};
            [isAstNeeded,cObj]=slci.matlab.astTranslator.createAst(...
            argNode,aObj);
            assert(isAstNeeded&&~isempty(cObj));
            aObj.fChildren{1}=cObj;
        end


        function ComputeDataType(aObj)


            arg=aObj.getArg();
            aObj.setDataType(arg.getDataType());
        end


        function ComputeDataDim(aObj)
            arg=aObj.getArg();
            aObj.setDataDim(arg.getDataDim());
        end


        function arg=getArg(aObj)
            assert(numel(aObj.fChildren{1})==1);
            arg=aObj.fChildren{1};
        end

    end

    methods(Access=protected)


        function populateChildrenFromMtreeNode(~,~)

        end

    end


end
