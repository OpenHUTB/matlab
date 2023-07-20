classdef ar_0002_a<slcheck.subcheck



    properties
        regValue;
    end
    methods
        function obj=ar_0002_a(initParam)
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID=initParam.CheckName;
            obj.regValue=initParam.RegValue;
        end

        function result=run(this)
            result=false;
            ents=this.getEntity();
            [~,inps,ext]=fileparts(ents);





            inps=[inps,ext];

            allowPackage=this.getInputParamByName(DAStudio.message('ModelAdvisor:jmaab:ar_0002_input'));
            allowPackage=str2double(allowPackage);


            if allowPackage&&(inps(1)=='+'||inps(1)=='@')



                value=isempty(regexp(inps(2:end),this.regValue,'once'));
            else
                value=isempty(regexp(inps,this.regValue,'once'));
            end

            if~value
                vObj=slcheck.setResultDefaults(this,ModelAdvisor.ResultDetail);
                ModelAdvisor.ResultDetail.setData(vObj,'FileName',ents);
                result=this.setResult(vObj);
            end

        end
    end
end
