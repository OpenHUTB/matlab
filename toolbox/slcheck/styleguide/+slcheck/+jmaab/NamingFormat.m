classdef NamingFormat<slcheck.subcheck

    properties
        regValue;
        strValue;
    end
    methods
        function obj=NamingFormat(initParam)
            if isfield(initParam,'CompileMode')
                obj.CompileMode=initParam.CompileMode;
            else
                obj.CompileMode='None';
            end
            obj.Licenses={''};
            obj.ID=initParam.CheckName;
            obj.regValue=initParam.RegValue;
        end

        function result=run(this)
            result=false;

            objHandle=this.getEntity();
            isViolation=false;
            isBus=false;
            if isnumeric(objHandle)
                resultType='SID';

                isBusElementPort=isprop(objHandle,'IsBusElementPort')&&...
                strcmp(get_param(objHandle,'IsBusElementPort'),'on');

                if isequal(get_param(objHandle,'Type'),'line')
                    resultType='Signal';
                    inps=get_param(objHandle,'Name');
                elseif~isempty(regexp(get_param(objHandle,'BlockType'),...
                    '(Inport)|(Outport)|InportShadow)','once'))...
                    &&isBusElementPort

                    isBus=true;




                    if strcmp(this.ID,'jc_0211_a')
                        this.regValue='[^a-z_A-Z_0-9.]';
                    end
                    if((strcmp(get_param(objHandle,'ShowName'),'on')&&...
                        ~isempty(regexp(get_param(objHandle,'Name'),this.regValue,'once')))||...
                        ~isempty(regexp(get_param(objHandle,'PortName'),this.regValue,'once'))||...
                        ~isempty(regexp(get_param(objHandle,'Element'),this.regValue,'once')))

                        isViolation=true;
                    end
                else
                    inps=get_param(objHandle,'Name');
                end
            elseif isa(objHandle,'Simulink.VariableUsage')
                resultType='SID';
                inps=objHandle.Name;
            elseif isa(objHandle,'Stateflow.Data')
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


            if(isBus&&isViolation)||(~isBus&&~isempty(regexp(inps,this.regValue,'once')))


                vObj=slcheck.setResultDefaults(this,ModelAdvisor.ResultDetail);
                ModelAdvisor.ResultDetail.setData(vObj,resultType,objHandle);
                result=this.setResult(vObj);
            end
        end
    end
end