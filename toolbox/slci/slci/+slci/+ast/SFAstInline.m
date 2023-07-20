



classdef SFAstInline<slci.ast.SFAstMatlabDirective

    properties(Access=protected)


        fArg=slci.compatibility.CoderInlineEnum.Unknown;
    end

    methods


        function aObj=SFAstInline(aAstObj,args,aParent)
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
                argName=lower(arg);
                switch argName
                case 'default'
                    aObj.fArg=slci.compatibility.CoderInlineEnum.Default;
                case 'always'
                    aObj.fArg=slci.compatibility.CoderInlineEnum.Always;
                case 'never'
                    aObj.fArg=slci.compatibility.CoderInlineEnum.Never;
                otherwise
                    assert(false,['Invalid coder.inline argument ',argName]);
                end
            end
        end


        function populateChildrenFromMtreeNode(~,~)

        end

    end


end
