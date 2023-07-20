classdef IMAQPreferencePanel




    properties


UIFigure
    end

    properties(Access=private)
Controller
    end

    methods
        function obj=IMAQPreferencePanel()
            obj.UIFigure=uifigure();

            view=matlab.ui.internal.preferences.preferencePanels.imaq.IMAQPreferencePanelView(obj.UIFigure);
            model=matlab.ui.internal.preferences.preferencePanels.imaq.IMAQPreferencesModel();
            obj.Controller=matlab.ui.internal.preferences.preferencePanels.imaq.IMAQPreferencePanelController(view,model);
        end

        function delete(obj)
            delete(obj.Controller);
            delete(obj.UIFigure);
        end

        function result=commit(obj)
            result=obj.Controller.commit();
        end
    end

    methods(Static)



        function result=shouldShow()


            import matlab.internal.lang.capability.Capability;
            result=Capability.isSupported(Capability.LocalClient);
        end
    end
end

