function checkObj=getDefaultCheckObject(checkID,xmlstyle,hCallbackHandle,context)
















    parts=strsplit(checkID,'.');

    guidelineID=parts{3};
    standard=parts{2};

    if strcmp(standard,'maab')
        msgCatalog=['ModelAdvisor:styleguide:',guidelineID];
    else
        msgCatalog=['ModelAdvisor:',standard,':',guidelineID];
    end


    checkObj=ModelAdvisor.Check(checkID);
    checkObj.Title=DAStudio.message([msgCatalog,'_title']);
    checkObj.TitleTips=[DAStudio.message([msgCatalog,'_guideline']),newline,newline,DAStudio.message([msgCatalog,'_tip'])];
    if strcmp(standard,'jmaab')
        checkObj.CSHParameters.MapKey='ma.mw.jmaab';
    else
        checkObj.CSHParameters.MapKey=['ma.',standard];
    end
    checkObj.CSHParameters.TopicID=checkID;

    checkObj.SupportHighlighting=true;

    if xmlstyle
        context='None';

        [ST,~]=dbstack('-completenames',1);
        mypath=fileparts(ST(1).file);
        dataFilePath=fullfile(mypath,'..','..','private');

        checkObj.setCallbackFcn(@(system,checkobj,xmlfile)Advisor.authoring.CustomCheck.newStyleCheckCallback(system,checkobj,fullfile(dataFilePath,[guidelineID,'.xml'])),context,'DetailStyle');
        checkObj.setReportCallbackFcn(@Advisor.authoring.CustomCheck.newStyleReportCallback);


        act=ModelAdvisor.Action;
        act.setCallbackFcn(@(task)(Advisor.authoring.CustomCheck.actionCallback(task)));
        act.Name=DAStudio.message('Advisor:engine:CCModifyButton');
        act.Description=DAStudio.message('Advisor:engine:CCActionDescription');
        checkObj.setAction(act);

        checkObj.SupportExclusion=false;
        checkObj.Value=true;
        checkObj.SupportLibrary=false;

    else
        checkObj.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(system,checkObj,msgCatalog,hCallbackHandle),context,'DetailStyle');
        checkObj.SupportExclusion=true;
        if strcmp(context,'None')
            checkObj.Value=true;
            checkObj.SupportLibrary=true;
        else
            checkObj.Value=false;
            checkObj.SupportLibrary=false;
        end
    end

end

