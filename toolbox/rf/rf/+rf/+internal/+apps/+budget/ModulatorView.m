classdef ModulatorView<rf.internal.apps.budget.ElementView






    properties
Icon
        Type='modulator';
    end

    methods

        function self=ModulatorView(elem,varargin)


            self=self@rf.internal.apps.budget.ElementView(varargin{:});
            if strcmpi(elem.ConverterType,'Up')
                self.Type='modulator';
            else
                self.Type='demodulator';
            end
            if~strcmpi(self.Type,'modulator')
                if self.Canvas.View.UseAppContainer
                    self.Picture.Block.ImageSource=self.Icon;
                else
                    self.Picture.Block.CData=self.Icon;
                end
            end
        end

        function val=get.Icon(self)
            val=imread([fullfile('+rf','+internal','+apps','+budget')...
            ,filesep,lower(self.Type),'_60.png']);
        end

        function unselectElement(self)


            unselectElement@rf.internal.apps.budget.ElementView(self)
        end

        function selectElement(self,elem)


            selectElement@rf.internal.apps.budget.ElementView(self,elem)
            dlg=self.Canvas.View.Parameters.ElementDialog;
            dlg.Name=elem.Name;
            dlg.Gain=elem.Gain;
            dlg.NF=elem.NF;
            dlg.OIP3=elem.OIP3;
            dlg.OIP2=elem.OIP2;
            dlg.LO=elem.LO;
            dlg.ConverterType=elem.ConverterType;
            dlg.Zin=elem.Zin;
            dlg.Zout=elem.Zout;
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


