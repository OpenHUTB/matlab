classdef SaveDialog<images.internal.app.utilities.OkCancelDialog




    properties

        SaveToValue(1,1)string="";

    end

    properties(Access=protected)
SaveToUI
    end

    methods




        function self=SaveDialog(loc,dlgTitle,labelMsg)

            self=self@images.internal.app.utilities.OkCancelDialog(loc,dlgTitle);

            self.Size=[300,120];

            self.create();
            self.layoutDialog(labelMsg);

        end

        function create(self)

            create@images.internal.app.utilities.OkCancelDialog(self);

            self.Ok.Enable='off';

        end

    end

    methods(Access=protected)

        function okClicked(self)


            self.Canceled=false;
            close(self);

        end


        function cancelClicked(self)

            self.SaveToValue="";
            close(self);

        end

        function keyPress(self,evt)

            if~validateKeyPressSupport(self,evt)
                return;
            end

            switch(evt.Key)
            case{'return'}
                okClicked(self);
            case 'escape'
                cancelClicked(self);
            end

        end

    end

    methods(Access=protected)

        function layoutDialog(self,msg)

            border=5;
            topBorder=10;
            controlSize=self.ButtonSize(2)+5;

            bottomStart=self.Ok.Position(2)+self.Ok.Position(4)+border;

            pos=[border,...
            bottomStart,...
            self.FigureHandle.Position(3)-2*border,...
            self.FigureHandle.Position(4)-bottomStart-topBorder];
            panel=uipanel('Parent',self.FigureHandle,...
            'Position',pos,...
            'BorderType','none',...
            'HandleVisibility','off');

            grid=uigridlayout('Parent',panel,...
            'RowHeight',{controlSize,controlSize},...
            'ColumnWidth',{'1x'},...
            'Padding',0,...
            'RowSpacing',5,...
            'ColumnSpacing',0);

            labelMsg=uilabel('Parent',grid,...
            'Text',msg,...
            'Tag','LabelMessage',...
            'HandleVisibility','off',...
            'Enable','on',...
            'HorizontalAlignment','left');
            labelMsg.Layout.Row=1;
            labelMsg.Layout.Column=1;

            self.SaveToUI=uieditfield('Parent',grid,...
            'Value','',...
            'HandleVisibility','off',...
            'Enable','on',...
            'Editable','on',...
            'Tag','SaveName',...
            'HorizontalAlignment','left',...
            'ValueChangingFcn',@(src,evt)self.saveToValueChanged(evt.Value));
            self.SaveToUI.Layout.Row=2;
            self.SaveToUI.Layout.Column=1;

        end

        function saveToValueChanged(self,val)

            if isempty(val)
                self.Ok.Enable='off';
            else
                self.Ok.Enable='on';
                self.SaveToValue=string(val);
            end

        end

    end

end
