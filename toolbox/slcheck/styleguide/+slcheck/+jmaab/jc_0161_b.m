classdef jc_0161_b<slcheck.subcheck

    methods
        function obj=jc_0161_b()
            obj.CompileMode='none';
            obj.Licenses={''};
            obj.ID='jc_0161_b';
        end

        function result=run(this)
            result=false;
            dataStoreMemory=this.getEntity();
            hObj=get_param(dataStoreMemory,'Object');
            hObj=hObj.DSReadWriteBlocks;
            if isempty(hObj)

                vObj=slcheck.setResultDefaults(this,ModelAdvisor.ResultDetail);
                ModelAdvisor.ResultDetail.setData(vObj,'SID',Simulink.ID.getSID(dataStoreMemory));
                result=this.setResult(vObj);
            end

        end
    end
end