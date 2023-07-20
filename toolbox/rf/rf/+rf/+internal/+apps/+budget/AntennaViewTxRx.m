classdef AntennaViewTxRx<rf.internal.apps.budget.ElementView




    properties(Constant)
        Icon=...
        imread([fullfile('+rf','+internal','+apps','+budget')...
        ,filesep,'TransmitReceive_60.png'])
    end

    methods

        function self=AntennaViewTxRx(varargin)
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
            dlg.GainTx=elem.Gain(1);
            dlg.GainRx=elem.Gain(2);
            dlg.ZTx=elem.Z(1);
            dlg.ZRx=elem.Z(2);
            dlg.PathLoss=elem.PathLoss;
            if~isempty(elem.AntennaObject)
                if~isempty(elem.AntennaObject{1})
                    if ischar(elem.AntennaObject{1})
                        if self.Canvas.View.UseAppContainer
                            rf.internal.apps.budget.setValue(self,dlg,'TypePopupTx','Antenna Object')
                        else
                            dlg.TypePopupTx.Value=3;
                        end
                        dlg.WkSpcTxObj=elem.AntennaObject{1};
                    else
                        if self.Canvas.View.UseAppContainer
                            rf.internal.apps.budget.setValue(self,dlg,'TypePopupTx','Antenna Designer')
                        else
                            dlg.TypePopupTx.Value=2;
                        end
                        dlg.AntObjTx=elem.AntennaObject{1};
                    end
                    dlg.DirTx=elem.DirectionAngles(1:2);
                else
                    if self.Canvas.View.UseAppContainer
                        rf.internal.apps.budget.setValue(self,dlg,'TypePopupTx','Isotropic Radiator')
                    else
                        dlg.TypePopupTx.Value=1;
                    end
                end
                if~isempty(elem.AntennaObject{2})
                    if ischar(elem.AntennaObject{2})
                        if self.Canvas.View.UseAppContainer
                            rf.internal.apps.budget.setValue(self,dlg,'TypePopupRx','Antenna Object')
                        else
                            dlg.TypePopupRx.Value=3;
                        end
                        dlg.WkSpcRxObj=elem.AntennaObject{2};
                    else
                        if self.Canvas.View.UseAppContainer
                            rf.internal.apps.budget.setValue(self,dlg,'TypePopupRx','Antenna Designer')
                        else
                            dlg.TypePopupRx.Value=2;
                        end
                        dlg.AntObjRx=elem.AntennaObject{2};
                    end
                    dlg.DirRx=elem.DirectionAngles(3:4);
                else
                    if self.Canvas.View.UseAppContainer
                        rf.internal.apps.budget.setValue(self,dlg,'TypePopupRx','Isotropic Receiver')
                    else
                        dlg.TypePopupRx.Value=1;
                    end
                end
            else
                if self.Canvas.View.UseAppContainer
                    rf.internal.apps.budget.setValue(self,dlg,'TypePopupTx','Isotropic Radiator')
                    rf.internal.apps.budget.setValue(self,dlg,'TypePopupRx','Isotropic Receiver')
                else
                    dlg.TypePopupTx.Value=1;
                    dlg.TypePopupRx.Value=1;
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


