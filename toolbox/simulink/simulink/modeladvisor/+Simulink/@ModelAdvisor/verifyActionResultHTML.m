function[success,message]=verifyActionResultHTML(this,checkID,htmlName)





    success=false;
    message='';


    notFound=true;
    for i=1:length(this.CheckCellArray)
        if strcmp(this.CheckCellArray{i}.ID,checkID)
            notFound=false;
            break;
        end
    end

    if notFound
        newID=ModelAdvisor.convertCheckID(checkID);
        if~isempty(newID)
            for i=1:length(this.CheckCellArray)
                if strcmp(this.CheckCellArray{i}.ID,newID)
                    notFound=false;
                    break;
                end
            end
        end
    end
    if notFound
        success=false;
        message=DAStudio.message('ModelAdvisor:engine:NoMatchCheckFound');
        return
    else
        actionCheck=this.CheckCellArray{i};
    end


    if this.BaselineMode
        f=fopen(htmlName,'w','n','utf-8');

        fprintf(f,'%s',actionCheck.Action.ResultInHTML);
        fclose(f);
        return
    end


    if~exist(htmlName,'file')
        message=DAStudio.message('ModelAdvisor:engine:CannotFindHTMLFile');
        success=false;
        return
    end


    current_rptContents=actionCheck.Action.ResultInHTML;
    current_rptContents=modeladvisorprivate('modeladvisorutil2','shuffleReport',current_rptContents);

    saved_rptContents=modeladvisorprivate('modeladvisorutil2','filereadutf8',htmlName);
    saved_rptContents=modeladvisorprivate('modeladvisorutil2','shuffleReport',saved_rptContents);


    current_rptContents_oLineBreaks=regexprep(current_rptContents,'\n','');
    saved_rptContents_oLineBreaks=regexprep(saved_rptContents,'\n','');

    if~strcmp(current_rptContents_oLineBreaks,saved_rptContents_oLineBreaks)
        message=DAStudio.message('ModelAdvisor:engine:MismatchBaselinePromptMsg');
        success=false;
    else
        success=true;
    end



