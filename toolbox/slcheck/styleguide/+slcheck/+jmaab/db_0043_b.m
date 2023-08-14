classdef(Sealed)db_0043_b<slcheck.subcheck
    methods
        function obj=db_0043_b()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='db_0043_b';
        end
        function result=run(this)
            result=false;
            obj=this.getEntity();

            system=bdroot;


            if isempty(obj)||obj.isModelReference
                return
            end
            modelAdvisorObject=Simulink.ModelAdvisor.getModelAdvisor(system);



            if~isa(obj,'Stateflow.Object')

                if strcmp(obj.type,'block')||strcmp(obj.type,'annotation')
                    if checkInconssitentBlkFormatting(system,obj,modelAdvisorObject)
                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'SID',obj);
                        result=this.setResult(vObj);
                    end


                elseif~isempty(obj.Parent)&&~(Stateflow.SLUtils.isStateflowBlock(obj.Parent)||...
                    Stateflow.SLUtils.isChildOfStateflowBlock(obj.Parent))&&isequal(obj.type,'line')
                    if checkInconssitentLineFormatting(system,obj,modelAdvisorObject)
                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'Signal',obj.Handle);
                        result=this.setResult(vObj);
                    end

                end
            end
        end
    end
end



function errFlag=checkInconssitentBlkFormatting(system,obj,mdlObj)


    if isa(obj,'Simulink.Annotation')
        defaultModelFontSize=get_param(system,'DefaultAnnotationFontSize');
    else
        defaultModelFontSize=get_param(system,'DefaultBlockFontSize');
    end

    if ischar(defaultModelFontSize)
        defaultModelFontSize=str2double(defaultModelFontSize);
    end


    objFontSize=getObjectFontSize(obj,defaultModelFontSize);


    projectFontSize=getProjectFontSize(mdlObj,defaultModelFontSize);

    errFlag=projectFontSize~=objFontSize;

end



function errFlag=checkInconssitentLineFormatting(system,obj,mdlObj)


    defaultModelFontSize=get_param(system,'DefaultLineFontSize');
    if ischar(defaultModelFontSize)
        defaultModelFontSize=str2double(defaultModelFontSize);
    end


    objFontSize=getObjectFontSize(obj,defaultModelFontSize);


    projectFontSize=getProjectFontSize(mdlObj,defaultModelFontSize);

    errFlag=projectFontSize~=objFontSize;

end


function objFontSize=getObjectFontSize(obj,defaultModelFontSize)


    fontSize=obj.FontSize;


    if isnumeric(fontSize)&&(fontSize==-1)
        objFontSize=defaultModelFontSize;


    elseif ischar(fontSize)&&strcmp(fontSize,'auto')
        objFontSize=defaultModelFontSize;

    else
        if ischar(fontSize)
            objFontSize=str2double(fontSize);
        else
            objFontSize=fontSize;
        end
    end

end


function projectFontSize=getProjectFontSize(modelAdvisorObject,defaultModelFontSize)


    inputParams=modelAdvisorObject.getInputParameters;
    if isa(inputParams{7}.Value,'char')
        if strcmpi(inputParams{7}.Value,'Default')
            projectFontSize=defaultModelFontSize;
            return;
        else
            fontsize=str2double(inputParams{7}.Value);
        end
    else
        fontsize=inputParams{7}.Value;
    end

    if isnan(fontsize)||fontsize<=0
        projectFontSize=defaultModelFontSize;
    else
        projectFontSize=fontsize;
    end
end
