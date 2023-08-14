
function windowOpened=slTrainingLauncher(courseCode,chapter,lesson,section)
    import matlab.internal.lang.capability.Capability;
    persistent existingWindowHandle;
    mlock;

    windowOpened=false;
    validWindowExists=~isempty(existingWindowHandle)&&isvalid(existingWindowHandle)&&existingWindowHandle.isWindowValid;

    if validWindowExists

        currentCourse=learning.simulink.internal.util.CourseUtils.getCourseFromUrl(existingWindowHandle.URL);


        requestCourse=struct('courseCode',courseCode,'chapter',chapter,'lesson',lesson,'section',section);

        if~isequal(currentCourse.courseCode,courseCode)

            yesString=message('learning:simulink:resources:DialogExitTrue').getString();
            noString=message('learning:simulink:resources:DialogExitFalse').getString();
            msgString=message('learning:simulink:resources:WebwindowChangeCourseDialog').getString();
            confirmExit=questdlg(msgString,message('learning:simulink:resources:WebwindowExitTitle').getString(),...
            yesString,noString,noString);

            if isempty(confirmExit)||strcmp(confirmExit,noString)
                return
            end


            cleanupTrainingApp();
            existingWindowHandle.close();
            validWindowExists=false;

        elseif~isequaln(currentCourse,requestCourse)
            newUrl=getPortalUrl(courseCode,chapter,lesson,section);
            existingWindowHandle.URL=newUrl;
        end
    end

    if validWindowExists
        try %#ok<TRYNC>


            bringToFront(existingWindowHandle);
            windowOpened=true;
        end
    end

    if~windowOpened

        ss=get(0,'ScreenSize');
        sw=800;
        sh=min(900,ss(4)-50);
        sx=round(ss(3)/2)-round(sw/2);
        sy=round(ss(4)/2)-round(sh/2)-15;


        debugPort=0;
        if learning.simulink.Application.getInstance().getTestMode
            debugPort=matlab.internal.getDebugPort();
        end



        startUrl=getPortalUrl(courseCode,chapter,lesson,section);

        appWindow=matlab.internal.webwindow(...
        startUrl,...
        'WindowType','Standard',...
        'Position',[sx,sy,sw,sh],...
        'DebugPort',debugPort);

        appWindow.setMinSize([400,150]);
        courseObj=learning.simulink.preferences.slacademyprefs.CourseMap;
        appWindow.Title=message(courseObj(courseCode).MessageCatalog).getString();
        if sh<800
            maximize(appWindow);
        end
        show(appWindow);

        appWindow.CustomWindowClosingCallback=@handleWindowClosed;

        windowOpened=true;

        existingWindowHandle=appWindow;
    end
end

function handleWindowClosed(appWindow,~)
    import matlab.internal.lang.capability.Capability;

    if Capability.isSupported(Capability.LocalClient)


        yesStr=message('learning:simulink:resources:DialogExitTrue').getString();
        noStr=message('learning:simulink:resources:DialogExitFalse').getString();

        currentCourse=learning.simulink.internal.util.CourseUtils.getCourseFromUrl(appWindow.URL);
        msgStr=message('learning:simulink:resources:WebwindowExitDialog',...
        learning.simulink.preferences.slacademyprefs.CourseMap(currentCourse.courseCode).CourseName).getString();

        confirm_exit=questdlg(msgStr,message('learning:simulink:resources:WebwindowExitTitle').getString(),...
        yesStr,noStr,noStr);

        if isempty(confirm_exit)||strcmp(confirm_exit,noStr)
            return
        end
    end


    cleanupTrainingApp();


    set_param(0,'EditorSmartEditingHotParam',...
    learning.simulink.Application.getInstance().getUserHotParameterSetting());


    userCfg=learning.simulink.Application.getInstance().getUserFileGenControlConfig();
    Simulink.fileGenControl('setConfig','config',userCfg);


    learning.simulink.Application.getInstance().clearPortalUrlBuilderObj();

    rmpath(genpath(learning.simulink.preferences.slacademyprefs.Paths.SrcPath));

    appWindow.close();

end

function cleanupTrainingApp()



    open_models=find_system('SearchDepth',0);
    workspaces=get_param(open_models,'ModelWorkspace');
    for idx=1:numel(workspaces)
        if isa(workspaces{idx},'Simulink.ModelWorkspace')
            if workspaces{idx}.hasVariable('courseObject')
                close_system(open_models{idx});
            end
        end
    end
end

function portalUrl=getPortalUrl(courseCode,chapter,lesson,section)
    learningApp=learning.simulink.Application.getInstance();
    courseParams=struct('courseCode',courseCode,'chapter',chapter,'lesson',lesson,'section',section);
    learningApp.setPortalUrl(courseParams);
    portalUrl=learningApp.getPortalUrl();
    learningApp.validateAndSetTaskPaneUrl(courseCode);
end