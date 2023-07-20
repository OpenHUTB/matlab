classdef AmplifierView<rf.internal.apps.budget.ElementView





    properties(Constant)
        Icon=...
        imread([fullfile('+rf','+internal','+apps','+budget')...
        ,filesep,'amp_60.png'])
    end

    properties
VarName
NewFileName
newNetData
    end

    methods

        function self=AmplifierView(varargin)


            self=self@rf.internal.apps.budget.ElementView(varargin{:});
        end

        function unselectElement(self)

            unselectElement@rf.internal.apps.budget.ElementView(self)
        end

        function selectElement(self,elem)


            selectElement@rf.internal.apps.budget.ElementView(self,elem)

            dlg=self.Canvas.View.Parameters.ElementDialog;

            if self.Canvas.View.UseAppContainer
                if elem.UseNetworkData
                    if~isempty(elem.FileName)
                        rf.internal.apps.budget.setValue(self,...
                        dlg,'UseNetworkDataPopup','Network Parameters');

                        rf.internal.apps.budget.setValue(self,...
                        dlg,'DataSourcePopup','File');
                        dlg.FileName=elem.FileName;
                    else
                        if isempty(dlg.WkSpcObj)


                            if isequal(self.newNetData,elem.NetworkData)
                                rf.internal.apps.budget.setValue(self,...
                                dlg,'UseNetworkDataPopup','Network Parameters');
                                rf.internal.apps.budget.setValue(self,...
                                dlg,'DataSourcePopup','File');
                                dlg.FileName=self.NewFileName;
                            else
                                rf.internal.apps.budget.setValue(self,...
                                dlg,'UseNetworkDataPopup','Network Parameters');

                                rf.internal.apps.budget.setValue(self,...
                                dlg,'DataSourcePopup','File');
                                name=elem.Name;
                                ObjName=sprintf('%s_%s.s2p',name,datestr(now,30));
                                self.newNetData=elem.NetworkData;
                                rfwrite(self.newNetData,ObjName);
                                dlg.FileName=ObjName;
                                self.NewFileName=dlg.FileName;
                            end
                        else
                            rf.internal.apps.budget.setValue(self,...
                            dlg,'UseNetworkDataPopup','Network Parameters');

                            rf.internal.apps.budget.setValue(self,...
                            dlg,'DataSourcePopup','Object');
                            dlg.SparametersObj=elem.NetworkData;
                            dlg.WkSpcObj=self.Canvas.SelectedElement.VarName;
                        end
                    end
                    dlg.Name=elem.Name;
                    dlg.NF=elem.NF;
                    dlg.OIP3=elem.OIP3;
                    dlg.OIP2=elem.OIP2;
                else
                    rf.internal.apps.budget.setValue(self,...
                    dlg,'UseNetworkDataPopup','Gain and Impedance');
                    dlg.Name=elem.Name;
                    dlg.Gain=elem.Gain;
                    dlg.NF=elem.NF;
                    dlg.OIP3=elem.OIP3;
                    dlg.OIP2=elem.OIP2;
                    dlg.Zin=elem.Zin;
                    dlg.Zout=elem.Zout;
                end
            else
                if elem.UseNetworkData
                    if~isempty(elem.FileName)
                        dlg.UseNetworkData=elem.UseNetworkData;
                        dlg.DataSourcePopup.Value=1;
                        dlg.Name=elem.Name;
                        dlg.FileName=elem.FileName;
                        dlg.DataSourcePopup.Value=1;
                    else
                        if isempty(dlg.WkSpcObj)
                            if isequal(self.newNetData,elem.NetworkData)
                                dlg.UseNetworkData=elem.UseNetworkData;
                                dlg.Name=elem.Name;
                                dlg.FileName=self.NewFileName;
                            else
                                dlg.UseNetworkData=elem.UseNetworkData;
                                dlg.Name=elem.Name;
                                dlg.DataSourcePopup.Value=1;
                                name=elem.Name;
                                ObjName=sprintf('%s_%s.s2p',name,datestr(now,30));
                                self.newNetData=elem.NetworkData;
                                rfwrite(self.newNetData,ObjName);
                                dlg.FileName=ObjName;
                                self.NewFileName=dlg.FileName;
                            end
                        else
                            dlg.DataSourcePopup.Value=2;
                            dlg.SparametersObj=elem.NetworkData;
                            dlg.WkSpcObj=self.Canvas.SelectedElement.VarName;
                        end
                    end
                    dlg.NF=elem.NF;
                    dlg.OIP3=elem.OIP3;
                    dlg.OIP2=elem.OIP2;
                else
                    dlg.UseNetworkData=elem.UseNetworkData;
                    dlg.Name=elem.Name;
                    dlg.Gain=elem.Gain;
                    dlg.NF=elem.NF;
                    dlg.OIP3=elem.OIP3;
                    dlg.OIP2=elem.OIP2;
                    dlg.Zin=elem.Zin;
                    dlg.Zout=elem.Zout;
                end
            end

            dlg.resetDialogAccess();
            setFigureKeyPress(dlg);
            if self.Canvas.View.UseAppContainer
                dlg.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(1,'ApplyButton','inactive'));
            else
                dlg.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(1,'ApplyTag','inactive'));
            end

            enableUIControls(dlg,true);
        end

    end
end


