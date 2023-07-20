classdef(Sealed)db_0043_a<slcheck.subcheck
    methods
        function obj=db_0043_a()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='db_0043_a';
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

                    if checkInconssitentBlkFormatting(modelAdvisorObject,obj,system)
                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'SID',obj);
                        result=this.setResult(vObj);
                    end


                elseif~isempty(obj.Parent)&&(~(Stateflow.SLUtils.isStateflowBlock(obj.Parent)||...
                    Stateflow.SLUtils.isChildOfStateflowBlock(obj.Parent))&&isequal(obj.type,'line'))

                    if checkInconssitentLineFormatting(modelAdvisorObject,obj,system)
                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'Signal',obj.Handle);
                        result=this.setResult(vObj);
                    end
                end

            end
        end
    end
end



function errFlag=checkInconssitentBlkFormatting(mdlObj,obj,system)

    errFlag=false;


    if isa(obj,'Simulink.Annotation')
        defaultModelFont=getModelAnnotationFontProperties(system);
    else
        defaultModelFont=getModelBlkFontProperties(system);
    end

    objFontFormat=getObjectFontProperties(obj,defaultModelFont);


    projectFontFormat=getProjectFontProperties(mdlObj,defaultModelFont);

    if~(any(strcmp(projectFontFormat{1},{'Arial','Helvetica'}))||...
        isequal(projectFontFormat{1},objFontFormat{1}))||...
        ~isequal(projectFontFormat{2},objFontFormat{2})||...
        ~isequal(projectFontFormat{3},objFontFormat{3})

        errFlag=true;

    end
end



function errFlag=checkInconssitentLineFormatting(mdlObj,obj,system)

    errFlag=false;


    defaultModelFont=getModelLineFontProperties(system);


    objFontFormat=getObjectFontProperties(obj,defaultModelFont);


    projectFontFormat=getProjectFontProperties(mdlObj,defaultModelFont);

    if~(any(strcmp(projectFontFormat{1},{'Arial','Helvetica'}))||...
        isequal(projectFontFormat{1},objFontFormat{1}))||...
        ~isequal(projectFontFormat{2},objFontFormat{2})||...
        ~isequal(projectFontFormat{3},objFontFormat{3})

        errFlag=true;
    end
end


function defaultModelFont=getModelBlkFontProperties(system)

    defFont=get_param(system,'DefaultBlockFontName');
    defFontWeight=get_param(system,'DefaultBlockFontWeight');
    defFontAngle=get_param(system,'DefaultBlockFontAngle');
    defaultModelFont={defFont,defFontWeight,defFontAngle};

end


function defaultModelFont=getModelAnnotationFontProperties(system)

    defFont=get_param(system,'DefaultAnnotationFontName');
    defFontWeight=get_param(system,'DefaultAnnotationFontWeight');
    defFontAngle=get_param(system,'DefaultAnnotationFontAngle');
    defaultModelFont={defFont,defFontWeight,defFontAngle};

end


function defaultModelFont=getModelLineFontProperties(system)

    defFont=get_param(system,'DefaultLineFontName');
    defFontWeight=get_param(system,'DefaultLineFontWeight');
    defFontAngle=get_param(system,'DefaultLineFontAngle');
    defaultModelFont={defFont,defFontWeight,defFontAngle};

end


function objFonts=getObjectFontProperties(obj,defaultModelFont)





    if isequal(obj.FontName,'auto')
        objFont=defaultModelFont{1};
    else
        objFont=obj.FontName;
    end

    if isequal(obj.FontWeight,'auto')
        objFontWeight=defaultModelFont{2};
    else
        objFontWeight=obj.FontWeight;
    end

    if isequal(obj.FontAngle,'auto')
        objFontAngle=defaultModelFont{3};
    else
        objFontAngle=obj.FontAngle;
    end
    objFonts={objFont,objFontWeight,objFontAngle};
end


function projectFontFormat=getProjectFontProperties(mdlObj,defaultModelFont)


    inputParams=mdlObj.getInputParameters;


    if isequal(inputParams{5}.Value,'Default')
        projectFont=defaultModelFont{1};
    else
        projectFont=inputParams{5}.Value;
    end


    switch inputParams{6}.Value

    case 'bold'

        projectFontWeight='bold';
        projectFontAngle='normal';

    case 'italic'

        projectFontWeight='normal';
        projectFontAngle='italic';

    case 'bold italic'

        projectFontWeight='bold';
        projectFontAngle='italic';

    case 'Default'

        projectFontWeight=defaultModelFont{2};
        projectFontAngle=defaultModelFont{3};

    otherwise

        projectFontWeight='normal';
        projectFontAngle='normal';
    end

    projectFontFormat={projectFont,projectFontWeight,projectFontAngle};
end
