classdef LCLadderView<rf.internal.apps.budget.ElementView




    properties
Icon
        Type='lowpasstee';
    end

    methods

        function self=LCLadderView(elem,varargin)
            self=self@rf.internal.apps.budget.ElementView(varargin{:});

            self.Type=elem.Topology;
            if~strcmpi(elem.Topology,'lowpasstee')
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
            dlg=self.Canvas.View.Parameters.ElementDialog;
            dlg.Parent.View.setStatusBarMsg('');
            dlg.Parent.notify('DisableCanvas',...
            rf.internal.apps.budget.ElementParameterChangedEventData(1,'ApplyTag','inactive'));
            unselectElement@rf.internal.apps.budget.ElementView(self)
        end


        function selectElement(self,elem)
            selectElement@rf.internal.apps.budget.ElementView(self,elem)

            dlg=self.Canvas.View.Parameters.ElementDialog;
            setListenersEnable(dlg,false)

            dlg.Name=elem.Name;
            dlg.Topology=elem.Topology;
            dlg.Inductances=elem.Inductances;
            dlg.Capacitances=elem.Capacitances;

            setListenersEnable(dlg,true)
            setFigureKeyPress(dlg);

            resetDialogAccess(dlg);
            dlg.Parent.notify('DisableCanvas',...
            rf.internal.apps.budget.ElementParameterChangedEventData(1,'ApplyTag','inactive'));

            enableUIControls(dlg,true);

        end
    end
end
