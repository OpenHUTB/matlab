classdef PrewarmingSuppressor<handle




    properties(Access=private)
        wasPreviouslyDisabled=[];
        hadTemporaryValueSet=false;
    end

    methods(Hidden)
        function obj=PrewarmingSuppressor()
            settingsObj=settings;
            obj.hadTemporaryValueSet=settingsObj.matlab.editor.SuppressPrewarming.hasTemporaryValue;
            obj.wasPreviouslyDisabled=settingsObj.matlab.editor.SuppressPrewarming.ActiveValue;
            settingsObj.matlab.editor.SuppressPrewarming.TemporaryValue=true;
        end

        function delete(obj)
            settingsObj=settings;
            if obj.hadTemporaryValueSet
                settingsObj.matlab.editor.SuppressPrewarming.TemporaryValue=obj.wasPreviouslyDisabled;
            else
                settingsObj.matlab.editor.SuppressPrewarming.clearTemporaryValue;
            end
        end
    end

    methods(Static)
        function flag=isPrewarmingSuppressed()
            flag=any(strcmpi(getenv('DISABLE_EDITOR_PREWARMING'),{'true','on','1'}));
            if flag

                return;
            end

            settingsObj=settings;
            flag=settingsObj.matlab.editor.SuppressPrewarming.ActiveValue;
        end
    end

end