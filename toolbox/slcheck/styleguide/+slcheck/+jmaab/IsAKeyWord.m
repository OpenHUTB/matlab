classdef IsAKeyWord<slcheck.subcheck

    properties
        strValue;
    end
    methods
        function obj=IsAKeyWord(initParam)
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID=initParam.CheckName;
        end

        function result=run(this)
            result=false;
            isViolation=false;
            isBus=false;

            objHandle=this.getEntity();
            if isnumeric(objHandle)
                resultType='SID';
                isBusElementPort=isprop(objHandle,'IsBusElementPort')&&...
                strcmp(get_param(objHandle,'IsBusElementPort'),'on');

                if isequal(get_param(objHandle,'Type'),'line')
                    resultType='Signal';
                    inps=get_param(objHandle,'Name');
                elseif~isempty(regexp(get_param(objHandle,'BlockType'),...
                    '(Inport)|(Outport)|InportShadow)','once'))&&...
isBusElementPort

                    isBus=true;
                    if((strcmp(get_param(objHandle,'ShowName'),'on')&&...
                        Advisor.Utils.isaKeyword(get_param(objHandle,'Name')))||...
                        Advisor.Utils.isaKeyword(get_param(objHandle,'PortName'))||...
                        Advisor.Utils.isaKeyword(get_param(objHandle,'Element')))

                        isViolation=true;
                    end
                else
                    inps=get_param(objHandle,'Name');
                end
            elseif isa(objHandle,'Stateflow.Data')||isa(objHandle,'Simulink.VariableUsage')
                resultType='SID';
                inps=objHandle.Name;
            else
                resultType='FileName';
                inps=objHandle;
            end

            if contains(this.ID,'ar_0001')


                [~,inps,~]=fileparts(objHandle);
            end

            if contains(this.ID,'ar_0002')


                [~,inps,ext]=fileparts(objHandle);




                inps=[inps,ext];
            end

            if(isBus&&isViolation)||(~isBus&&Advisor.Utils.isaKeyword(inps))
                vObj=slcheck.setResultDefaults(this,ModelAdvisor.ResultDetail);
                ModelAdvisor.ResultDetail.setData(vObj,resultType,objHandle);
                result=this.setResult(vObj);
            end

        end
    end
end