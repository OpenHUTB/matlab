



classdef SampleAppContext<dig.CustomContext
    methods(Access=public)
        function this=SampleAppContext()
            app=dig.Configuration.get().getApp('sampleApp');
            this@dig.CustomContext(app);
        end
    end

    methods(Static)
        function[actionName,text,description]=getSystemSelectorConvertButtonProperties()
            actionName='testSystemSelectorAction';
            text='Convert Test';
            description='Convert Test Description';
        end

        function actionCallbackWithError(cbinfo)
            dig.tests.CallbackTester.signalCallback('MATLABTestCallbackWithError',cbinfo.UserData,cbinfo.EventData);
            a=b;%#ok<NASGU>            
        end
    end
end