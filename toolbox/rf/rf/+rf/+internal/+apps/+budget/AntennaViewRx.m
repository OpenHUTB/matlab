classdef AntennaViewRx<rf.internal.apps.budget.ElementView

    properties(Constant)
        Icon=...
        imread([fullfile('+rf','+internal','+apps','+budget'),filesep,'rx_60.png'])
    end

    methods
        function self=AntennaViewRx(varargin)
            self=self@rf.internal.apps.budget.ElementView(varargin{:});
            self.LineIn.Visible='off';
        end

        function unselectElement(self)


            unselectElement@rf.internal.apps.budget.ElementView(self)
        end

        function selectElement(self,elem)


            selectElement@rf.internal.apps.budget.ElementView(self,elem)

            dlg=self.Canvas.View.Parameters.ElementDialog;
            if strcmpi(dlg.Type,'Isotropic Receiver')
                dlg.Name=elem.Name;
                dlg.Gain=elem.Gain;
                dlg.Z=elem.Z;
                dlg.TxEIRP=elem.TxEIRP;
                dlg.PathLoss=elem.PathLoss;
            elseif strcmpi(dlg.Type,'Antenna Designer')||strcmpi(dlg.Type,'Antenna Object')
                dlg.TxEIRP=elem.TxEIRP;
                dlg.PathLoss=elem.PathLoss;
            end
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
                dlg.TxEIRP=elem.TxEIRP;
                dlg.PathLoss=elem.PathLoss;
            else
                if self.Canvas.View.UseAppContainer
                    rf.internal.apps.budget.setValue(self,dlg,'TypePopup','Isotropic Receiver')
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
                rf.internal.apps.budget.ElementParameterChangedEventData(1,'ApplyTag','inactive'));
            end
            enableUIControls(dlg,true);
        end
    end
end
