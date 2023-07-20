classdef PhaseshiftView<rf.internal.apps.budget.ElementView




    properties(Constant)
        Icon=...
        imread([fullfile('+rf','+internal','+apps','+budget'),filesep,'phaseshift_60.png'])
    end

    methods
        function self=PhaseshiftView(varargin)
            self=self@rf.internal.apps.budget.ElementView(varargin{:});
        end

        function unselectElement(self)
            unselectElement@rf.internal.apps.budget.ElementView(self)
        end

        function selectElement(self,elem)
            selectElement@rf.internal.apps.budget.ElementView(self,elem)

            dlg=self.Canvas.View.Parameters.ElementDialog;
            dlg.Name=elem.Name;
            dlg.PhaseShift=elem.PhaseShift;
            dlg.resetDialogAccess();
            setFigureKeyPress(dlg);
            dlg.Parent.notify('DisableCanvas',...
            rf.internal.apps.budget.ElementParameterChangedEventData(1,'ApplyTag','inactive'));

            enableUIControls(dlg,true);
        end
    end
end
