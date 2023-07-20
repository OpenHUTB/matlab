classdef MixerIMTView<rf.internal.apps.budget.ElementView





    properties(Constant)
        Icon=...
        imread([fullfile('+rf','+internal','+apps','+budget')...
        ,filesep,'mixerIMT_60.png'])
    end

    methods

        function self=MixerIMTView(varargin)


            self=self@rf.internal.apps.budget.ElementView(varargin{:});
        end

        function unselectElement(self)


            unselectElement@rf.internal.apps.budget.ElementView(self)
        end

        function selectElement(self,elem)


            selectElement@rf.internal.apps.budget.ElementView(self,elem)
            dlg=self.Canvas.View.Parameters.ElementDialog;

            if self.Canvas.View.UseAppContainer
                if elem.UseDataFile
                    setValue(self,dlg,'UseDataFileCheckBox',1);
                    dlg.Name=elem.Name;
                    dlg.FileName=elem.FileName;
                    dlg.ReferenceInputPower=elem.ReferenceInputPower;
                    dlg.NominalOutputPower=elem.NominalOutputPower;
                else
                    setValue(self,dlg,'UseDataFileCheckBox',0);
                    dlg.Name=elem.Name;
                    dlg.ReferenceInputPower=elem.ReferenceInputPower;
                    dlg.NominalOutputPower=elem.NominalOutputPower;
                    if strcmpi(elem.ConverterType,'Up')
                        setValue(self,dlg,'ConverterTypePopup','Up');
                    else
                        setValue(self,dlg,'ConverterTypePopup','Down');
                    end
                    dlg.NF=elem.NF;
                    dlg.LO=elem.LO;
                    dlg.Zin=elem.Zin;
                    dlg.Zout=elem.Zout;
                    dlg.IMT=elem.IMT;
                end
            else
                if elem.UseDataFile
                    dlg.UseDataFile=elem.UseDataFile;
                    dlg.Name=elem.Name;
                    dlg.FileName=elem.FileName;
                    dlg.ReferenceInputPower=elem.ReferenceInputPower;
                    dlg.NominalOutputPower=elem.NominalOutputPower;

                else
                    dlg.UseDataFile=elem.UseDataFile;
                    dlg.Name=elem.Name;
                    dlg.ReferenceInputPower=elem.ReferenceInputPower;
                    dlg.NominalOutputPower=elem.NominalOutputPower;
                    dlg.NF=elem.NF;
                    dlg.ConverterType=elem.ConverterType;
                    dlg.LO=elem.LO;
                    dlg.Zin=elem.Zin;
                    dlg.Zout=elem.Zout;
                    dlg.IMT=elem.IMT;
                end
            end

            resetDialogAccess(dlg);
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

        function setValue(self,dlg,fieldName,Value)
            dlg.(fieldName).Value=Value;
            e.EventName='ValueChanged';
            e.Source=dlg.(fieldName);
            e.Source.Tag=dlg.(fieldName).Tag;
            dlg.(fieldName).ValueChangedFcn(self,e);
        end
    end
end

