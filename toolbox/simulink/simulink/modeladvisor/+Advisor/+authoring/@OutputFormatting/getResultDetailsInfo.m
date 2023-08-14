


function[Description,Status,RecAction]=getResultDetailsInfo(this)


    if isempty(this.Description)
        dataFileLink=this.createLinkToDataFile();
        Description=DAStudio.message('Advisor:engine:CCOFModelParamCheckText',dataFileLink.emitHTML);
    else
        Description=this.Description;
    end


    if strcmp(this.CheckStatus,'Pass')
        if isempty(this.ResultDescriptionPass)
            Status=DAStudio.message('Advisor:engine:CCOFModelParamPass');
        else
            Status=this.ResultDescriptionPass;
        end
    else
        if isempty(this.ResultDescriptionFail)
            Status=DAStudio.message('Advisor:engine:CCOFModelParamFail');
        else
            Status=this.ResultDescriptionFail;
        end
    end


    if isempty(this.RecommendedActions)
        RecAction=DAStudio.message('Advisor:engine:CCOFModelParamRecAct');
    else
        RecAction=this.RecommendedActions;
    end
end