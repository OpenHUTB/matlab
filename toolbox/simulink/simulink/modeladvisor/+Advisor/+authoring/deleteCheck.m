function deleteCheck(checkDef,customizationFilePathString)


    if exist(customizationFilePathString,'file')~=2
        DAStudio.error('Advisor:engine:CCUnableLocateSlCustomizationFile',customizationFilePathString);
    end



    fid=fopen(customizationFilePathString,'r');

    if fid==-1
        DAStudio.error('Advisor:engine:CCUnableReadSlCustomizationFile',customizationFilePathString);
    end

    mcode=fread(fid,'*char')';
    fclose(fid);


    mcode=loc_deleteCheckDefFunctionCall(mcode,checkDef,customizationFilePathString);



    IndexStart=strfind(mcode,getCheckDefintion(checkDef));
    if isempty(IndexStart)
        DAStudio.error('Advisor:engine:CCUnableToDeleteCheck',customizationFilePathString);
    end
    mcode=strrep(mcode,getCheckDefintion(checkDef),'');



    IndexStart=strfind(mcode,getCheckCallback(checkDef));
    if isempty(IndexStart)
        DAStudio.error('Advisor:engine:CCUnableToDeleteCheck',customizationFilePathString);
    end
    mcode=strrep(mcode,getCheckCallback(checkDef),'');


    mcode=loc_deleteTaskDefinition(mcode,checkDef,customizationFilePathString);




    if loc_isSlCustomizationEmpty(mcode)

        selection=questdlg(DAStudio.message('Advisor:engine:CCDeleteSlCustomizationWarning',customizationFilePathString,checkDef.ID),...
        DAStudio.message('Advisor:engine:CCDeleteSlCustomizationHeading'),...
        DAStudio.message('Simulink:tools:MAYes'),DAStudio.message('Simulink:tools:MANo'),DAStudio.message('Simulink:tools:MAYes'));
        if isempty(selection)||strcmpi(selection,DAStudio.message('Simulink:tools:MANo'))

            fid=fopen(customizationFilePathString,'w+');
            fprintf(fid,'%s',mcode);
            fclose(fid);
        else
            delete(customizationFilePathString);
        end
    else

        fid=fopen(customizationFilePathString,'w+');
        fprintf(fid,'%s',mcode);
        fclose(fid);
    end
end


function mcode=loc_deleteCheckDefFunctionCall(mcode,checkDef,customizationFilePathString)

    autoGenStartComment='% THE FOLLOWING CODE IS AUTO GENERATED AND MAY NOT WORK IF MODIFIED';
    autoGenEndComment='% END OF AUTO GENERATED CODE';


    [IndexStart,IndexEnd]=regexp(mcode,...
    [autoGenStartComment,'\nfunction defineModelAdvisorCustomChecks\(\).*?end\n',autoGenEndComment],...
    'start','end','once');
    if isempty(IndexStart)
        DAStudio.error('Advisor:engine:CCUnableToDeleteCheck',customizationFilePathString);
    end

    if~isempty(strfind(mcode(IndexStart:IndexEnd),getCheckDefintionFctCall(checkDef)))
        temp=strrep(mcode(IndexStart:IndexEnd),getCheckDefintionFctCall(checkDef),'');
        mcode=[mcode(1:IndexStart-1),temp,mcode(IndexEnd+1:end)];
    else
        DAStudio.error('Advisor:engine:CCUnableToDeleteCheck',customizationFilePathString);
    end



    fctContent=regexp(mcode,'function defineModelAdvisorCustomChecks\(\)(.*?)end','tokens');

    fctContent=strtrim(fctContent{1}{1});

    if isempty(fctContent)

        [IndexStart,IndexEnd]=regexp(mcode,...
        [autoGenStartComment,'\nfunction defineModelAdvisorCustomChecks\(\).*?end\n\n?',autoGenEndComment],...
        'start','end','once');
        mcode=[mcode(1:IndexStart-1),mcode(IndexEnd+1:end)];


        mcode=regexprep(mcode,[autoGenStartComment,'\n(% register custom checks\n)?\tcm\.addModelAdvisorCheckFcn\(@defineModelAdvisorCustomChecks\);\n',autoGenEndComment,'\n'],'');
    end
end


function mcode=loc_deleteTaskDefinition(mcode,checkDef,customizationFilePathString)
    autoGenStartComment='% THE FOLLOWING CODE IS AUTO GENERATED AND MAY NOT WORK IF MODIFIED';
    autoGenEndComment='% END OF AUTO GENERATED CODE';


    [IndexStart,IndexEnd]=regexp(mcode,'function defineCustomCheckTasks\(\).*?end','start','end','once');
    if isempty(IndexStart)
        DAStudio.error('Advisor:engine:CCUnableToDeleteCheck',customizationFilePathString);
    end

    if~isempty(strfind(mcode(IndexStart:IndexEnd),getTaskDef(checkDef)))
        temp=strrep(mcode(IndexStart:IndexEnd),getTaskDef(checkDef),'');
        mcode=[mcode(1:IndexStart-1),temp,mcode(IndexEnd+1:end)];
    end



    [IndexStart,IndexEnd]=regexp(mcode,'function defineCustomCheckTasks\(\).*?end','start','end','once');
    fctContent=regexp(mcode(IndexStart:IndexEnd),'MAT(.*?) = ModelAdvisor\.Task\(''.*?''\);','start');

    if isempty(fctContent)

        [IndexStart,IndexEnd]=regexp(mcode,...
        [autoGenStartComment,'\nfunction defineCustomCheckTasks\(\).*?end\n\n?',autoGenEndComment],...
        'start','end','once');
        mcode=[mcode(1:IndexStart-1),mcode(IndexEnd+1:end)];


        mcode=regexprep(mcode,[autoGenStartComment,'\n\tcm\.addModelAdvisorTaskAdvisorFcn\(@defineCustomCheckTasks\);\n',autoGenEndComment,'\n'],'');
    end
end

function status=loc_isSlCustomizationEmpty(mcode)
    autoGenStartComment='% THE FOLLOWING CODE IS AUTO GENERATED AND MAY NOT WORK IF MODIFIED';
    autoGenEndComment='% END OF AUTO GENERATED CODE';

    status=false;


    [IndexStart,IndexEnd,tokens]=regexp(mcode,...
    [autoGenStartComment,'\n',...
    'function sl_customization\(cm\)\n',...
    '% SL_CUSTOMIZATION - register authored custom checks\n',...
    '% created on [0-9]{1,2}-[A-Za-z]{3,3}-[0-9]{4,4} [0-9]{2,2}:[0-9]{2,2}:[0-9]{2,2}\n',...
    '(.*?)',...
    'end\n',...
    autoGenEndComment,'\n'],...
    'start','end','tokens','once');

    if~isempty(IndexStart)


        fctContent=tokens{1};

        localFunctionIdx=regexp([mcode(1:IndexStart),mcode(IndexEnd:end)],...
        'function','once');

        if isempty(regexp(fctContent,'\w','once'))&&isempty(localFunctionIdx)
            status=true;
        end
    end
end