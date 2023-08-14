



classdef SampleApp4Context<dig.CustomContext
    methods(Access=public)
        function this=SampleApp4Context()
            app=dig.Configuration.get().getApp('sampleApp4');
            this@dig.CustomContext(app);
        end
    end

    methods(Static)
        function[actionName,text,description]=getSystemSelectorConvertButtonProperties()
            actionName='testSystemSelectorAction';
            text='Convert Test';
            description='Convert Test Description';
        end
    end
end