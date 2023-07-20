function appendToLog(this,str)





    str=strrep(str,sprintf('\n'),sprintf('<br>\n'));
    this.Log=[this.Log,str];

    if~isempty(this.testComp)&&~this.closed
        try
            widgetForProgessDialog=DAStudio.imDialog.getIMWidgets(this.dialogH);

            progressDialogLogarea=find(widgetForProgessDialog,'Tag','logarea');
            objectivesDisplayed=this.browserparam1(5);
            isDeadLogicDetection=(strcmp(this.testComp.activeSettings.Mode,...
            'DesignErrorDetection')&&...
            strcmp(this.testComp.activeSettings.DetectDeadLogic,'on'));







            isDialogToBeRefreshed=(etime(clock,this.lastRefresh)>5)||...
            (objectivesDisplayed<5)||isDeadLogicDetection;

            if~this.closed&&isDialogToBeRefreshed
                progressDialogLogarea.text=this.Log;
                this.lastRefresh=clock;
            end
        catch Mex %#ok<NASGU>
        end
    end
