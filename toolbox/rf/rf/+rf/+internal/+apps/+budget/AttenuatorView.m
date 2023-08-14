classdef AttenuatorView<rf.internal.apps.budget.ElementView




    properties(Constant)
        Icon=...
        imread([fullfile('+rf','+internal','+apps','+budget')...
        ,filesep,'Attenuator_60.png'])
    end

    methods

        function self=AttenuatorView(varargin)
            self=self@rf.internal.apps.budget.ElementView(varargin{:});
        end

        function unselectElement(self)


            unselectElement@rf.internal.apps.budget.ElementView(self)
        end

        function selectElement(self,elem)


            selectElement@rf.internal.apps.budget.ElementView(self,elem)
            dlg=self.Canvas.View.Parameters.ElementDialog;
            dlg.Name=elem.Name;
            dlg.Attenuation=elem.Attenuation;
            dlg.Zin=elem.Zin;
            dlg.Zout=elem.Zout;
            dlg.resetDialogAccess();
            setFigureKeyPress(dlg);
            if self.Canvas.View.UseAppContainer
                dlg.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(1,...
                'ApplyButton','inactive'));
            else
                dlg.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(1,...
                'ApplyTag','inactive'));
            end
            enableUIControls(dlg,true);
        end
    end
end


