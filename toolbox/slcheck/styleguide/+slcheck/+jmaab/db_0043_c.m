classdef(Sealed)db_0043_c<slcheck.subcheck
%#ok<*AGROW>
    methods
        function obj=db_0043_c()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='db_0043_c';
        end

        function result=run(this)
            result=false;
            obj=this.getEntity();
            system=bdroot;
            if isempty(obj)||obj.isModelReference
                return
            end
            violations=[];
            modelAdvisorObject=Simulink.ModelAdvisor.getModelAdvisor(system);


            if isa(obj,'Stateflow.Object')
                if isa(obj,'Stateflow.Annotation')&&obj.IsImage
                    return;
                end

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

            if~isempty(violations)
                result=this.setResult(violations);
            end
        end
    end
end



function errFlag=checkInconssitentSfObjFormatting(sfObj,mdlObj)
    errFlag=false;
    chart=sfObj.Chart;

    defaultStateFont={chart.StateFont.Name,...
    chart.StateFont.Weight,chart.StateFont.Angle};


    if isa(sfObj,'Stateflow.Annotation')
        objFontFormat={sfObj.Font.Name,...
        sfObj.Font.Weight,sfObj.Font.Angle};
    else
        objFontFormat={defaultStateFont{1},...
        defaultStateFont{2},defaultStateFont{3}};
    end


    projectFontFormat=getProjectFontProperties(mdlObj,defaultStateFont);


    if~(any(strcmp(projectFontFormat{1},{'Arial','Helvetica'}))||...
        isequal(projectFontFormat{1},objFontFormat{1}))||...
        ~isequal(projectFontFormat{2},objFontFormat{2})||...
        ~isequal(projectFontFormat{3},objFontFormat{3})
        errFlag=true;
    end
end



function errFlag=checkInconssitentTransFormatting(transObj,mdlObj)
    chart=transObj.Chart;
    errFlag=false;


    objFontFormat={chart.TransitionFont.Name,...
    chart.TransitionFont.Weight,chart.TransitionFont.Angle};


    projectFontFormat=getProjectFontProperties(mdlObj,objFontFormat);


    if~(any(strcmp(projectFontFormat{1},{'Arial','Helvetica'}))||...
        isequal(projectFontFormat{1},objFontFormat{1}))||...
        ~isequal(projectFontFormat{2},objFontFormat{2})||...
        ~isequal(projectFontFormat{3},objFontFormat{3})
        errFlag=true;
    end

end


function projectFontFormat=getProjectFontProperties(modelAdvisorObject,defaultFont)


    inputParams=modelAdvisorObject.getInputParameters;


    if isequal(inputParams{8}.Value,'Default')
        projectFontName=defaultFont{1};
    else
        projectFontName=inputParams{8}.Value;
    end


    switch inputParams{9}.Value

    case 'BOLD'

        projectFontWeight='BOLD';
        projectFontAngle='NORMAL';

    case 'ITALIC'

        projectFontWeight='NORMAL';
        projectFontAngle='ITALIC';

    case 'BOLD ITALIC'

        projectFontWeight='BOLD';
        projectFontAngle='ITALIC';

    case 'Default'

        projectFontWeight=defaultFont{2};
        projectFontAngle=defaultFont{3};

    otherwise

        projectFontWeight='NORMAL';
        projectFontAngle='NORMAL';

    end

    projectFontFormat={projectFontName,projectFontWeight,projectFontAngle};
end
