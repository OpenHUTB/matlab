classdef VariableTypeWorkspaceDialog<images.internal.app.utilities.OkCancelDialog




    properties(GetAccess=public,SetAccess=protected)

QuestionLabel
LogicalRadio
CategoricalRadio

Label
EditField

        VariableName char='labels';
        IsLogical(1,1)logical=true;

    end

    methods




        function self=VariableTypeWorkspaceDialog(loc,dlgTitle)

            self=self@images.internal.app.utilities.OkCancelDialog(loc,dlgTitle);

            self.Size=[360,200];

            create(self);

        end




        function create(self)

            create@images.internal.app.utilities.OkCancelDialog(self);

            addQuestionLabel(self);
            addRadio(self);

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


        function addQuestionLabel(self)

            self.QuestionLabel=uilabel(...
            'Parent',self.FigureHandle,...
            'Position',[self.ButtonSpace,4*self.ButtonSize(2)+9*self.ButtonSpace,self.Size(1)-(2*self.ButtonSpace),self.ButtonSize(2)],...
            'FontSize',12,...
            'HorizontalAlignment','left',...
            'Text',getString(message('images:segmenter:saveAsLogicalMessage')));

        end


        function addRadio(self)

            buttonGroup=uibuttongroup(...
            'Parent',self.FigureHandle,...
            'Position',[self.ButtonSpace,2*self.ButtonSize(2)+5*self.ButtonSpace,self.Size(1)-(2*self.ButtonSpace),(2*self.ButtonSize(2)+(3*self.ButtonSpace))],...
            'SelectionChangedFcn',@(src,evt)updateRadioState(self,evt));

            self.LogicalRadio=uiradiobutton(...
            'Parent',buttonGroup,...
            'Position',[self.ButtonSpace,self.ButtonSize(2)+(2*self.ButtonSpace),buttonGroup.Position(3)-(2*self.ButtonSpace),self.ButtonSize(2)],...
            'FontSize',12,...
            'Text',getString(message('images:segmenter:logical')));

            self.CategoricalRadio=uiradiobutton(...
            'Parent',buttonGroup,...
            'Position',[self.ButtonSpace,self.ButtonSpace,buttonGroup.Position(3)-(2*self.ButtonSpace),self.ButtonSize(2)],...
            'FontSize',12,...
            'Text',getString(message('images:segmenter:categorical')));

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


        function updateRadioState(self,evt)
            self.IsLogical=evt.NewValue==self.LogicalRadio;
        end

    end

end
