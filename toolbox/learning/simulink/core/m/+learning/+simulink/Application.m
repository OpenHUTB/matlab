

classdef Application<handle





    properties(Access=protected)
        mLearningMap=[];
        studioMgr=[];
        signalCheckListener=[];
        currentInteractionObj=[];
        messageServiceInterface=[];
        modelPosition=[];
        userHotParameterSetting=[];
        userFileGenControlConfig=[];
        useInternalMessage=false;
        portalUrlBuilderObj=[];
        taskPaneUrlBuilderObj=[];
        connectorPath='';
    end

    properties(Hidden,Access=protected)
        CEF_WINDOW_TITLE;
    end


    properties(Access=protected,Hidden)

        isDebugMode=false;
        fakeInteractionObjSender=[];


        isTestMode=false;
        TestContentDir='';

        messageMap=[];
    end

    properties(Constant,Access=public,Hidden)
        SL_ONRAMP_COURSE_CODE=learning.simulink.preferences.slacademyprefs.SimulinkOnrampCourseCode;
    end

    methods(Static,Access=public)

        function learningApp=getInstance()




            persistent sLearningAppSingle;
            if isempty(sLearningAppSingle)

                sLearningAppSingle=learning.simulink.Application;
            end
            learningApp=sLearningAppSingle;
        end
    end

    methods(Access=public)
        function setupSimulinkStudio(obj,courseCode,dataSrc)












            if~obj.isCourseOpen(courseCode)
                courseObj=learning.simulink.preferences.slacademyprefs.CourseMap;
                obj.CEF_WINDOW_TITLE=message(courseObj(courseCode).MessageCatalog).getString();

                obj.currentInteractionObj=obj.setupInteraction(courseCode,dataSrc);

                obj.studioMgr=obj.setupStudioManager(obj);
                studio=obj.studioMgr.getCurrentStudio();
                if~isempty(studio)
                    subscribeBlockDiagramCB(studio,...
                    'PostNameChange',...
                    @()obj.handlePostNameChanged(studio));
                    subscribeBlockDiagramCB(studio,...
                    'PreClose',...
                    @()obj.handlePreClose(studio));
                end




                MG2.Util.waitForGui;




                if~isempty(obj.currentInteractionObj.currentTaskObj.question)
                    obj.signalCheckListener=SignalCheckListener(learning.simulink.Application.getInstance().getModelName);
                end
                save_system(learning.simulink.Application.getInstance().getModelName)
            else

                open_system(learning.simulink.SimulinkAppInteractions.getModelToOpenFromCourseCode(courseCode));
            end

        end

        function setupTask(obj,taskNumber)





            if~isempty(obj.studioMgr)
                obj.studioMgr.setupTask(taskNumber);
            end
        end

        function updateAssessmentPane(obj)







            if~isempty(obj.studioMgr)
                obj.studioMgr.updateAssessmentPane;
                obj.signalCheckListener.openTask=obj.currentInteractionObj.currentTaskObj.courseObject.task;
            end
        end

        function sclOpenTask=getSclOpenTask(obj)


            sclOpenTask=obj.signalCheckListener.openTask;
        end

        function setSclOpenTask(obj,openTask)

            obj.signalCheckListener.openTask=openTask;
        end

        function modelName=getModelName(obj)


            modelName=[];
            assert(~isempty(obj));
            if isempty(obj.currentInteractionObj)
                return;
            end
            assert(~isempty(obj.currentInteractionObj.currentTaskObj));
            modelName=obj.currentInteractionObj.currentTaskObj.modelName;
        end

        function[pass,grader]=submitTask(obj)

            [pass,grader]=obj.studioMgr.submitTask;
        end

        function nTasks=getNumberOfTasks(obj)


            nTasks=numel(obj.currentInteractionObj.interactionContent.simulinkInteraction.questions);
        end

        function currentTask=getCurrentTask(obj)



            currentTask=obj.currentInteractionObj.currentTaskObj.courseObject.task;
        end

        function userHotParameterSetting=getUserHotParameterSetting(obj)
            userHotParameterSetting=obj.userHotParameterSetting;
        end

        function setUserHotParameterSetting(obj,userHotParameterSetting)
            obj.userHotParameterSetting=userHotParameterSetting;
        end

        function userFileGenControlConfig=getUserFileGenControlConfig(obj)
            userFileGenControlConfig=obj.userFileGenControlConfig;
        end

        function setUserFileGenControlConfig(obj,userFileGenControlConfig)
            obj.userFileGenControlConfig=userFileGenControlConfig;
        end

        function resetTask(obj)

            obj.studioMgr.resetTask;
        end

        function exitInteraction(obj)


            if~isempty(obj.studioMgr)
                obj.studioMgr.exitInteraction;
            end
        end

        function gotoTaskNumber(obj,taskNumber)
            obj.currentInteractionObj.currentTaskObj=...
            obj.currentInteractionObj.setToTaskN(taskNumber);
            obj.studioMgr.setCourseObject(obj.currentInteractionObj.currentTaskObj.courseObject);
        end

        function initializationCode=getInitCode(obj)
            initializationCode=obj.currentInteractionObj.initializationCode;
        end

        function modelPosition=getModelPosition(obj)
            modelPosition=obj.modelPosition;
        end

        function setModelPosition(obj,modelPosition)
            obj.modelPosition=modelPosition;
        end

        function isCourseOpen=isCourseOpen(obj,courseCode)
            isCourseOpen=false;
            modelName=obj.getModelName;
            expectedModelName=learning.simulink.SimulinkAppInteractions.getModelNameFromCourseCode(courseCode);
            if isequal(modelName,expectedModelName)&&bdIsLoaded(modelName)
                isCourseOpen=true;
            end
        end

        function[pass,requirements]=gradeStateflowTask(obj,block)
            [pass,requirements]=obj.studioMgr.gradeStateflowTask(block);
        end

        function course=getCurrentCourse(obj)
            course='';
            if~isempty(obj.studioMgr)
                course=obj.studioMgr.getCourse();
            end
        end

        function assessmentPaneWidth=getAssessmentPaneWidth(obj)
            assessmentPaneWidth=[];
            if~isempty(obj.studioMgr)
                assessmentPaneWidth=obj.studioMgr.getAssessmentPaneWidth();
            end
        end

        function taskPaneWidth=getTaskPaneWidth(obj)
            taskPaneWidth=[];
            if~isempty(obj.studioMgr)
                taskPaneWidth=obj.studioMgr.getTaskPaneWidth();
            end
        end

        function interactionContent=getInteractionContent(obj)
            interactionContent=obj.currentInteractionObj.getInteractionContent();
        end

        function interactionAssessments=getInteractionAssessments(obj)
            interactionAssessments=obj.currentInteractionObj.getInteractionAssessments();
        end

        function passStatus=getPassStatus(obj)
            passStatus=obj.studioMgr.getPassStatus();
        end
    end

    methods(Access=public,Hidden)
        function messageMap=getMessageMap(obj)
            messageMap=obj.messageMap;
        end

        function setMessageMap(obj,messageMap)
            obj.messageMap=messageMap;
        end



        function portalUrl=getPortalUrl(obj)
            if isempty(obj.portalUrlBuilderObj)
                obj.portalUrlBuilderObj=learning.simulink.internal.PortalUrlBuilder();
            end

            portalUrl=obj.portalUrlBuilderObj.getFullUrl();
        end

        function previousPortalUrl=setPortalUrl(obj,varargin)
            narginchk(0,2);
            if nargin==0
                courseCode='simulink';
            else
                courseParams=varargin{1};
                courseCode=char(courseParams.courseCode);
            end

            previousPortalUrl=obj.getPortalUrl();


            if~isKey(learning.simulink.preferences.slacademyprefs.CourseMap,courseCode)&&~isempty(courseCode)
                validCourseCodes=strcat('"',learning.simulink.preferences.slacademyprefs.CourseMap.keys,'"');
                validCourseCodes=strjoin(validCourseCodes,', ');
                error(message('learning:simulink:resources:InvalidArgs',validCourseCodes));
            end

            if~isempty(courseCode)||isempty(obj.portalUrlBuilderObj.courseCode)
                obj.portalUrlBuilderObj.setCourseCode(courseCode);
            end

            if~isempty(courseParams)&&~isempty(courseParams.chapter)&&courseParams.chapter>0
                obj.portalUrlBuilderObj.setLocationHash(courseParams.chapter,courseParams.lesson,courseParams.section);
            end
        end

        function addParamsToPortalUrl(obj,parameter,value)
            obj.portalUrlBuilderObj.addParamsToUrl(parameter,value);
        end

        function resetPortalUrl(obj)
            obj.portalUrlBuilderObj.resetUrl();
        end

        function clearPortalUrlBuilderObj(obj)
            if~obj.getTestMode
                obj.portalUrlBuilderObj=[];
            end
        end

        function resetTaskPaneUrl(obj)
            obj.clearTaskPaneUrlBuilderObj();
            obj.getTaskPaneUrl();
        end

        function clearTaskPaneUrlBuilderObj(obj)
            if~obj.getTestMode
                obj.taskPaneUrlBuilderObj=[];
            end
        end


        function taskPaneUrl=getTaskPaneUrl(obj)
            if isempty(obj.taskPaneUrlBuilderObj)
                obj.taskPaneUrlBuilderObj=learning.simulink.internal.TaskPaneUrlBuilder();
                if~isempty(obj.currentInteractionObj)


                    obj.taskPaneUrlBuilderObj.setCourseCode(obj.currentInteractionObj.currentTaskObj.courseObject.course);
                end
            end
            taskPaneUrl=obj.taskPaneUrlBuilderObj.getFullUrl();
        end

        function validateAndSetTaskPaneUrl(obj,courseCode)
            if isempty(obj.taskPaneUrlBuilderObj)
                obj.taskPaneUrlBuilderObj=learning.simulink.internal.TaskPaneUrlBuilder();
            end
            if~isempty(courseCode)
                obj.taskPaneUrlBuilderObj.setCourseCode(courseCode);
            end
        end
        function setConnectorPath(obj,connectorPath)
            obj.connectorPath=connectorPath;
            if isempty(obj.portalUrlBuilderObj)
                obj.portalUrlBuilderObj=learning.simulink.internal.PortalUrlBuilder();
            end
            obj.portalUrlBuilderObj.setConnectorPath(connectorPath);
            if isempty(obj.taskPaneUrlBuilderObj)
                obj.taskPaneUrlBuilderObj=learning.simulink.internal.TaskPaneUrlBuilder();
            end
            obj.taskPaneUrlBuilderObj.setConnectorPath(connectorPath);
        end

        function connectorPath=getConnectorPath(obj)
            connectorPath=obj.connectorPath;
        end

        function conceptSequence=getConceptSequence(obj)
            conceptSequence=obj.currentInteractionObj.currentTaskObj.getConceptSequence;
        end
    end

    methods(Static,Access=protected)


















        function interactionObject=setupInteraction(courseCode,dataSrc)



            interactionObject=learning.simulink.Interaction(courseCode,dataSrc);
        end

        function studioMgr=setupStudioManager(learningApp)


            studioMgr=learning.simulink.StudioMgr(learning.simulink.Application.getInstance().getModelName,...
            learningApp.currentInteractionObj.currentTaskObj.getCourseObject,...
            learningApp.currentInteractionObj.currentTaskObj.getConceptSequence);
        end
    end


    methods(Access={?OnrampTestInterface},Hidden)
        function setTestMode(obj,isTestMode)
            obj.isTestMode=isTestMode;
        end

        function setUseInternalMessage(obj,useInternalMessage)


            obj.useInternalMessage=useInternalMessage;
        end

        function useContentFromDir(obj,dir)
            obj.TestContentDir=dir;
        end

    end

    methods(Access=public,Hidden)
        function isTestMode=getTestMode(obj)
            isTestMode=obj.isTestMode;
        end

        function isDebugMode=getDebugMode(obj)
            isDebugMode=obj.isDebugMode;
        end

        function setDebugMode(obj,isDebugMode)
            if obj.isDebugMode==isDebugMode
                return;
            end
            if isDebugMode
                assert(~obj.isTestMode);
                addpath(slTrainingInstallHelper.getDebugAndTestToolPath());
                obj.fakeInteractionObjSender=InteractionObjectSender();
            else
                rmpath(slTrainingInstallHelper.getDebugAndTestToolPath());
                obj.fakeInteractionObjSender=[];
            end
            obj.isDebugMode=isDebugMode;
        end

        function useInternalMessage=getUseInternalMessage(obj)


            useInternalMessage=obj.useInternalMessage;
        end

        function clearStateflowBreakpoints(obj)
            sfStruct(1).name='Stateflow.Chart';
            sfStruct(1).fcn=@clearChartBreakpoints;
            sfStruct(2).name='Stateflow.State';
            sfStruct(2).fcn=@clearStateBreakpoints;
            sfStruct(3).name='Stateflow.Transition';
            sfStruct(3).fcn=@clearTransitionBreakpoints;
            sfStruct(4).name='Stateflow.Function';
            sfStruct(4).fcn=@clearFunctionBreakpoints;

            bd=get_param(obj.getModelName(),'Object');
            for idx=1:numel(sfStruct)
                sfObj=bd.find('-isa',sfStruct(idx).name);
                if~isempty(sfObj)
                    sfStruct(idx).fcn(sfObj);
                end
            end
        end

        function testContentDir=getTestContentDir(obj)
            testContentDir=obj.TestContentDir;
        end
    end


    methods(Static,Access=public,Hidden)
        function installSLOnramp()
            if~learning.simulink.Application.getInstance().getDebugMode()
                return;
            end
            learning.simulink.Application.installSLOnrampImpl();
        end

        function startDebugSLOnrampStudio(varargin)
            learningApp=learning.simulink.Application.getInstance();
            if~learningApp.getDebugMode()
                return;
            end
            learning.simulink.Application.installSLOnramp();

            learningApp.setupSimulinkStudio(learning.simulink.Application.SL_ONRAMP_COURSE_CODE,...
            InteractionObjectSender.getTestDataSrcStringFromJSONFile(varargin{:}));
        end

        function versionStr=getReleaseVersion()
            versionStr=version('-release');
        end

        function is18b=isReleaseVersion18b()
            is18b=strcmp(learning.simulink.Application.getReleaseVersion(),'2018b');
        end
    end


    methods(Static,Access={?OnrampTestInterface},Hidden)
        function installSLOnrampImpl()
            installHelper=slTrainingInstallHelper();

            connector.ensureServiceOn();
            connectorPath=connector.addStaticContentOnPath('sltraining',learning.simulink.preferences.slacademyprefs.webPath,'SkipCompatibilityList',true);

            learning.simulink.Application.getInstance().setConnectorPath([connectorPath(2:end),'/']);

            setupSlTraining();
        end
    end

    methods(Access=protected)
        function obj=Application()



            obj.mLearningMap=containers.Map;



            obj.messageServiceInterface=learning.simulink.MessageServiceInterface;

            obj.isDebugMode=false;
            obj.isTestMode=false;
            obj.useInternalMessage=learning.simulink.Application.isReleaseVersion18b();
        end

        function handlePostNameChanged(obj,studio)
            if~isempty(obj.studioMgr)
                obj.studioMgr.handlePostNameChanged(studio);
                obj.studioMgr.delete();
                obj.studioMgr=[];
            end

            obj.exitInteraction();
        end

        function handlePreClose(obj,studio)
            if~isempty(obj.studioMgr)
                obj.studioMgr.handlePreClose(studio);
                obj.studioMgr.delete();
                obj.studioMgr=[];
            end
            if~isempty(obj.currentInteractionObj)
                obj.currentInteractionObj.delete();
                obj.currentInteractionObj=[];
            end





            wm=matlab.internal.webwindowmanager.instance();
            appWindowID=strcmp({wm.windowList.Title},obj.CEF_WINDOW_TITLE);
            windowList=wm.windowList(appWindowID);
            if~isempty(windowList)
                windowList.bringToFront;
            end
        end
    end

end




function subscribeBlockDiagramCB(studio,serviceName,cbFunc)
    if isempty(studio)
        return;
    end

    handle=studio.App.blockDiagramHandle;
    obj=get_param(handle,'Object');
    callbackID=getStudioId(studio);
    if~obj.hasCallback(serviceName,callbackID)
        Simulink.addBlockDiagramCallback(handle,serviceName,callbackID,cbFunc);
    end
end

function unSubscribeBlockDiagramCB(studio,serviceName)
    if isempty(studio)
        return;
    end

    handle=studio.App.blockDiagramHandle;
    obj=get_param(handle,'Object');
    callbackID=getStudioId(studio);
    if obj.hasCallback(serviceName,callbackID)
        Simulink.removeBlockDiagramCallback(handle,serviceName,callbackID);
    end
end

function id=getStudioId(studio)
    id=[studio.getStudioTag,'_SLOnramp'];
end

function clearChartBreakpoints(sfObj)
    assert(isa(sfObj,'Stateflow.Chart'));
    for i=1:length(sfObj)
        sfObj(i).Debug.Breakpoints.OnEntry=0;
    end
end

function clearStateBreakpoints(sfObj)
    assert(isa(sfObj,'Stateflow.State'));
    for i=1:length(sfObj)
        sfObj(i).Debug.Breakpoints.OnEntry=0;
        sfObj(i).Debug.Breakpoints.OnDuring=0;
        sfObj(i).Debug.Breakpoints.OnExit=0;
    end
end

function clearTransitionBreakpoints(sfObj)
    assert(isa(sfObj,'Stateflow.Transition'));
    for i=1:length(sfObj)
        sfObj(i).Debug.Breakpoints.WhenTested=0;
        sfObj(i).Debug.Breakpoints.WhenValid=0;
    end
end

function clearFunctionBreakpoints(sfObj)
    assert(isa(sfObj,'Stateflow.Function'));
    for i=1:length(sfObj)
        sfObj(i).Debug.Breakpoints.OnDuring=0;
    end
end
