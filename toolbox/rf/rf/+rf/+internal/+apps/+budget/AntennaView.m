classdef AntennaView<rf.internal.apps.budget.ElementView




    properties(Constant)
        Icon=...
        imread([fullfile('+rf','+internal','+apps','+budget')...
        ,filesep,'antenna_60.png'])
    end

    methods

        function self=AntennaView(varargin)
            self=self@rf.internal.apps.budget.ElementView(varargin{:});
            self.LineOut.Visible='off';
        end

        function unselectElement(self)


            unselectElement@rf.internal.apps.budget.ElementView(self)
        end

        function selectElement(self,elem)


            selectElement@rf.internal.apps.budget.ElementView(self,elem)
            dlg=self.Canvas.View.Parameters.ElementDialog;
            dlg.Name=elem.Name;
            dlg.Gain=elem.Gain;
            dlg.Z=elem.Z;
            if~isempty(elem.AntennaObject)
                if ischar(elem.AntennaObject)
                    if self.Canvas.View.UseAppContainer
                        rf.internal.apps.budget.setValue(self,dlg,'TypePopup','Antenna Object')
                    else
                        dlg.TypePopup.Value=3;
                    end
                    dlg.WkSpcObj=elem.AntennaObject;
                else
                    if self.Canvas.View.UseAppContainer
                        rf.internal.apps.budget.setValue(self,dlg,'TypePopup','Antenna Designer')
                    else
                        dlg.TypePopup.Value=2;
                    end
                    dlg.AntObj=elem.AntennaObject;
                end
                dlg.Dir=elem.DirectionAngles;
            else
                if self.Canvas.View.UseAppContainer
                    rf.internal.apps.budget.setValue(self,dlg,'TypePopup','Isotropic Radiator')
                else
                    dlg.TypePopup.Value=1;
                end
            end
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


