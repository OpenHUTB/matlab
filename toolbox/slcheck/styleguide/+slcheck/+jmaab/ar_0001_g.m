classdef ar_0001_g<slcheck.subcheck



    properties
        strValue;
    end
    methods
        function obj=ar_0001_g(initParam)
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID=initParam.CheckName;
        end

        function result=run(this)
            result=false;
            ents=this.getEntity();
            [~,inps]=fileparts(ents);
            [files,type]=which(inps,'-all');



            identicalFiles=[];
            for k=1:length(type)
                if~(contains(type{k},'method')||isempty(type{k}))
                    identicalFiles=[identicalFiles,files(k)];
                end
            end

            if(length(identicalFiles)>1)
                vObj=slcheck.setResultDefaults(this,ModelAdvisor.ResultDetail);
                ModelAdvisor.ResultDetail.setData(vObj,'FileName',ents);
                result=this.setResult(vObj);
            end

        end
    end
end
