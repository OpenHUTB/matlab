classdef jc_0627_b<slcheck.subcheck
    methods
        function obj=jc_0627_b(InitParams)
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID=InitParams.CheckName;
        end

        function result=run(this)
            result=false;
            obj=this.getEntity();
            dtiObj=get_param(obj,'Object');
            vObj=[];


            if~strcmp(dtiObj.LimitOutput,'off')


                [isLParam,LParam]=isSLParam(dtiObj,'LowerSaturationLimit');



                if(isLParam&&~strcmp(LParam.DataType,'auto'))
                    tempObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(tempObj,...
                    'Block',obj,...
                    'Parameter','LowerSaturationLimit',...
                    'CurrentValue',['DataType:',LParam.DataType],...
                    'RecommendedValue','DataType:auto');
                    vObj=[vObj;tempObj];
                end


                [isUParam,UParam]=isSLParam(dtiObj,'UpperSaturationLimit');



                if(isUParam&&~strcmp(UParam.DataType,'auto'))
                    tempObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(tempObj,...
                    'Block',obj,...
                    'Parameter','UpperSaturationLimit',...
                    'CurrentValue',['DataType:',UParam.DataType],...
                    'RecommendedValue','DataType:auto');
                    vObj=[vObj;tempObj];
                end
            end

            if~isempty(vObj)
                result=this.setResult(vObj);
            end
        end
    end
end
function[bResult,param]=isSLParam(obj,limitType)

    bResult=false;
    param=[];


    value=get_param(obj.handle,limitType);


    if~isnan(str2double(value))
        return;
    end

    param=Advisor.Utils.safeEvalinGlobalScope(bdroot,value);

    if isempty(param)

        mws=get_param(bdroot,'modelworkspace');
        try
            param=evalin(mws,value);
        catch
            param=[];
        end
    end


    bResult=isa(param,'Simulink.Parameter')||isa(param,'mpt.Parameter');
end