

classdef jc_0738_b<slcheck.subcheck

    properties(Constant,GetAccess=private)























        fullExpr='^((?<!\/\/).)*?\/\*.*?(?<!\*\/)\n';
    end

    methods
        function obj=jc_0738_b()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0738_b';
        end

        function result=run(this)
            currElement=this.getEntity();

            result=slcheck.jmaab.jc_0738_internal.hasViolationNewline(...
            currElement.LabelString,this.fullExpr);
            if result
                this.setResult(slcheck.getResultDetailObj('SID',currElement));
            end
        end
    end
end