




classdef SFAstCInclude<slci.ast.SFAstMatlabDirective

    properties(Access=protected)

        fArg='';
    end

    methods


        function aObj=SFAstCInclude(aAstObj,args,aParent)
            aObj=aObj@slci.ast.SFAstMatlabDirective(aAstObj,...
            aParent);
            if~isempty(args)
                aObj.setArgs(args);
            end
            assert(isa(aAstObj,'mtree'));
        end


        function arg=getArg(aObj)
            arg=aObj.fArg;
        end

    end

    methods(Access=protected)


        function setArgs(aObj,args)
            assert(iscell(args));
            assert(numel(args)==1);
            arg=args{1};
            if strcmp(arg.kind,'CHARVECTOR')
                str=arg.string;

                tokens=regexp(str,'^('')(.*)('')$','tokens');
                assert(~isempty(tokens));
                arg=tokens{1}{2};
                aObj.fArg=arg;
            end
        end

        function populateChildrenFromMtreeNode(~,~)

        end


        function addMatlabFunctionConstraints(aObj)

        end
    end
end
