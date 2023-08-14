






classdef SFAstWRef<slci.ast.SFAstMatlabDirective

    methods


        function aObj=SFAstWRef(aAstObj,args,aParent)
            assert(isa(aAstObj,'mtree'),...
            DAStudio.message('Slci:slci:NotMtreeNode',...
            'SFAstWRef'));
            aObj=aObj@slci.ast.SFAstMatlabDirective(aAstObj,...
            aParent);
            assert(numel(args)==1);
            argNode=args{1};
            [isAstNeeded,cObj]=slci.matlab.astTranslator.createAst(...
            argNode,aObj);
            assert(isAstNeeded&&~isempty(cObj));
            aObj.fChildren{1}=cObj;
        end


        function ComputeDataType(aObj)%#ok

        end


        function ComputeDataDim(aObj)%#ok

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