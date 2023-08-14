



classdef SFAstCoderTarget<slci.ast.SFAstMatlabDirective

    properties(Access=private)
        fTarget='';
    end

    methods

        function aObj=SFAstCoderTarget(aAstObj,args,aParent)
            assert(isa(aAstObj,'mtree'),...
            DAStudio.message('Slci:slci:NotMtreeNode',...
            'SFAstCoderTarget'));
            aObj=aObj@slci.ast.SFAstMatlabDirective(aAstObj,...
            aParent);
            if~isempty(args)
                assert(numel(args)==1);
                aObj.setTarget(args);
            end
        end


        function ComputeDataType(aObj)

            if~isempty(aObj.getTarget)
                dtype='boolean';
            else
                dtype='string';
            end
            aObj.setDataType(dtype);
        end


        function ComputeDataDim(aObj)

            if~isempty(aObj.getTarget)
                aObj.setDataDim([1,1]);
            end
        end


        function out=getTarget(aObj)
            out=aObj.fTarget;
        end
    end

    methods(Access=protected)


        function populateChildrenFromMtreeNode(~,~)

        end


        function setTarget(aObj,args)
            assert(iscell(args));
            assert(numel(args)==1);
            arg=args{1};
            if strcmp(arg.kind,'CHARVECTOR')
                str=arg.string;

                tokens=regexp(str,'^('')(.*)('')$','tokens');
                assert(~isempty(tokens));
                arg=tokens{1}{2};
                aObj.fTarget=lower(arg);
            end
        end


        function addMatlabFunctionConstraints(aObj)

            newConstraints={...
            slci.compatibility.MatlabFunctionCoderTargetConstraint...
            };
            aObj.setConstraints(newConstraints);
        end

    end

end