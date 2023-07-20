classdef NportView<rf.internal.apps.budget.ElementView




    properties(Constant)
        Icon=...
        imread([fullfile('+rf','+internal','+apps','+budget')...
        ,filesep,'S_P_60.png'])
    end

    properties
VarName
NewFileName
newNetData
    end

    methods

        function self=NportView(varargin)


            self=self@rf.internal.apps.budget.ElementView(varargin{:});
        end

        function unselectElement(self)


            unselectElement@rf.internal.apps.budget.ElementView(self)
        end

        function selectElement(self,elem)


            selectElement@rf.internal.apps.budget.ElementView(self,elem)
            dlg=self.Canvas.View.Parameters.ElementDialog;
            if self.Canvas.View.UseAppContainer
                if~isempty(elem.FileName)
                    rf.internal.apps.budget.setValue(self,...
                    dlg,'DataSourcePopup','File');
                    dlg.FileName=elem.FileName;
                else
                    if strcmpi(dlg.WkSpcObj,'select variable')


                        if isequal(self.newNetData,elem.NetworkData)
                            rf.internal.apps.budget.setValue(self,...
                            dlg,'DataSourcePopup','File');
                            dlg.FileName=self.NewFileName;
                        else
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
                        dlg,'DataSourcePopup','Object');
                        dlg.SparametersObj=elem.NetworkData;
                        dlg.WkSpcObj=self.Canvas.SelectedElement.VarName;
                    end
                    dlg.Name=elem.Name;
                end
            else
                if~isempty(elem.FileName)
                    dlg.DataSourcePopup.Value=1;
                    dlg.Name=elem.Name;
                    dlg.FileName=elem.FileName;
                else
                    if isempty(dlg.WkSpcObj)
                        if isequal(self.newNetData,elem.NetworkData)
                            dlg.DataSourcePopup.Value=1;
                            dlg.Name=elem.Name;
                            dlg.FileName=self.NewFileName;
                        else
                            dlg.DataSourcePopup.Value=1;
                            name=elem.Name;
                            ObjName=sprintf('%s_%s.s2p',name,datestr(now,30));
                            self.newNetData=elem.NetworkData;
                            rfwrite(self.newNetData,ObjName);
                            dlg.FileName=ObjName;
                            dlg.Name=elem.Name;
                            self.NewFileName=dlg.FileName;
                        end
                    else
                        dlg.DataSourcePopup.Value=2;
                        dlg.Name=elem.Name;
                        dlg.SparametersObj=elem.NetworkData;
                        dlg.WkSpcObj=self.Canvas.SelectedElement.VarName;
                    end
                end
            end
            dlg.resetDialogAccess()
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


