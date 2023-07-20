



classdef SampleApp2Context<dig.CustomContext
    methods(Access=public)
        function this=SampleApp2Context()
            app=dig.Configuration.get().getApp('sampleApp2');
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