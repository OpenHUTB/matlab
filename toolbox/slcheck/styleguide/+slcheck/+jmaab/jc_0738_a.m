
classdef jc_0738_a<slcheck.subcheck
    properties(Constant,GetAccess=private)
















        fullExpr='(?<=(\/\*)).*?(?=(\*\/))';
    end

    methods
        function obj=jc_0738_a()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0738_a';
        end

        function run(this)
            currElement=this.getEntity();
            if slcheck.jmaab.jc_0738_internal.hasViolationNesting(...
                currElement.LabelString,this.fullExpr)
                this.setResult(slcheck.getResultDetailObj('SID',currElement));
            end
        end

    end
end