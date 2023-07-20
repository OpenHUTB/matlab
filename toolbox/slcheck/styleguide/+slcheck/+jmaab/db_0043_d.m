classdef(Sealed)db_0043_d<slcheck.subcheck
%#ok<*AGROW>
    methods
        function obj=db_0043_d()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='db_0043_d';
        end

        function result=run(this)
            result=false;
            obj=this.getEntity();
            system=bdroot;
            if isempty(obj)||obj.isModelReference
                return
            end
            modelAdvisorObject=Simulink.ModelAdvisor.getModelAdvisor(system);


            if isa(obj,'Stateflow.Object')

                if~isa(obj,'Stateflow.Transition')
                    if checkInconssitentSfObjFormatting(obj,modelAdvisorObject)
                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'SID',obj);
                        result=this.setResult(vObj);
                    end
                else

                    if checkInconssitentTransFormatting(obj,modelAdvisorObject)
                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'SID',obj);
                        result=this.setResult(vObj);
                    end
                end
            end
        end
    end
end



function errFlag=checkInconssitentSfObjFormatting(sfObj,mdlObj)

    chart=sfObj.Chart;


    if~isa(sfObj,'Stateflow.Annotation')
        objFontSize=sfObj.FontSize;
        defFontSize=chart.StateFont.Size;
    else
        objFontSize=sfObj.Font.Size;
        defFontSize=sfObj.Font.Size;
    end


    projectFontSize=getProjectFontSize(mdlObj,defFontSize);


    errFlag=projectFontSize~=objFontSize;
end



function errFlag=checkInconssitentTransFormatting(transObj,mdlObj)



    objFontSize=transObj.FontSize;


    chart=transObj.Chart;
    defFontSize=chart.TransitionFont.Size;


    projectFontSize=getProjectFontSize(mdlObj,defFontSize);

    errFlag=projectFontSize~=objFontSize;

end


function projectFontSize=getProjectFontSize(modelAdvisorObject,defFontSize)


    inputParams=modelAdvisorObject.getInputParameters;

    if isa(inputParams{10}.Value,'char')
        if strcmpi(inputParams{10}.Value,'Default')
            projectFontSize=defFontSize;
            return;
        else
            fontsize=str2double(inputParams{10}.Value);
        end
    else
        fontsize=inputParams{10}.Value;
    end

    if isnan(fontsize)||fontsize<=0
        projectFontSize=defFontSize;
    else
        projectFontSize=fontsize;
    end

end
