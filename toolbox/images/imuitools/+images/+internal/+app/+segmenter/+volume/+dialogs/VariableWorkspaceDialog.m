classdef VariableWorkspaceDialog<images.internal.app.utilities.OkCancelDialog




    properties(GetAccess=public,SetAccess=protected)

Label
EditField

        VariableName char='labels';

    end

    methods




        function self=VariableWorkspaceDialog(loc,dlgTitle)

            self=self@images.internal.app.utilities.OkCancelDialog(loc,dlgTitle);

            self.Size=[360,100];

            create(self);

        end




        function create(self)

            create@images.internal.app.utilities.OkCancelDialog(self);

            addLabel(self);
            addEditField(self);

        end

    end

    methods(Access=protected)


        function okClicked(self)

            if~isempty(self.VariableName)
                self.Canceled=false;
                close(self);
            end

        end


        function addLabel(self)

            self.Label=uilabel(...
            'Parent',self.FigureHandle,...
            'Position',[self.ButtonSpace,self.ButtonSize(2)+3*self.ButtonSpace,(self.Size(1)/2)-round(1.5*self.ButtonSpace),self.ButtonSize(2)],...
            'FontSize',12,...
            'HorizontalAlignment','right',...
            'Text',getString(message('images:segmenter:variableName')));

        end


        function addEditField(self)

            self.EditField=uieditfield('text',...
            'Parent',self.FigureHandle,...
            'Position',[(self.Size(1)/2)+(0.5*self.ButtonSpace),self.ButtonSize(2)+3*self.ButtonSpace,(self.Size(1)/2)-round(1.5*self.ButtonSpace),self.ButtonSize(2)],...
            'FontSize',12,...
            'Value','labels',...
            'ValueChangingFcn',@(src,evt)validateVariableName(self,evt.Value));

        end


        function validateVariableName(self,val)

            if isempty(val)
                self.VariableName='';
                self.EditField.FontColor=[0,0,0];
                self.Ok.Enable='off';
            elseif isvarname(val)
                self.VariableName=val;
                self.EditField.FontColor=[0,0,0];
                self.Ok.Enable='on';
            else
                self.VariableName='';
                self.EditField.FontColor=[1,0,0];
                self.Ok.Enable='off';
            end

        end


    end

end
