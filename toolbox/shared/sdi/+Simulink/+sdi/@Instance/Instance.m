classdef Instance





    methods(Static)
        ret=isRepositoryCreated()
        setEngine(engine)
        sdiEngine=engine()
        isRecording=record(setVal)
        sdiGUI=gui(varargin)
        browser=offscreenBrowser(varargin)
        out=isSDIRunning()
        setUseSystemBrowser(useSystemBrowser)
        open(varargin)
        close(filename)
    end


    methods(Hidden=true,Static=true)
        eng=getSetEngine(obj)


        utils=getSetSAUtils(obj)
        gui=getSetGUI(obj)
        gui=getSetOffscreenBrowser(obj)
        gui=getSetTestGUI(obj)
        out=isTestOrSDIRunning()
        isOpening=getSetGUIOpenningFlag(val)
        dispNote=displayNotificationForModel(~,~)
        result=getMainGUI(varargin)
        onMATLABExit()
    end
end
