classdef VariableTypeDialog<images.internal.app.utilities.OkCancelDialog




    properties(GetAccess=public,SetAccess=protected)

QuestionLabel
LogicalRadio
CategoricalRadio

        IsLogical(1,1)logical=true;

    end

    methods




        function self=VariableTypeDialog(loc,dlgTitle)

            self=self@images.internal.app.utilities.OkCancelDialog(loc,dlgTitle);

            self.Size=[360,160];

            create(self);

        end




        function create(self)

            create@images.internal.app.utilities.OkCancelDialog(self);

            addQuestionLabel(self);
            addRadio(self);

        end

    end

    methods(Access=protected)


        function okClicked(self)

            self.Canceled=false;
            close(self);

        end


        function addQuestionLabel(self)

            self.QuestionLabel=uilabel(...
            'Parent',self.FigureHandle,...
            'Position',[self.ButtonSpace,3*self.ButtonSize(2)+7*self.ButtonSpace,self.Size(1)-(2*self.ButtonSpace),self.ButtonSize(2)],...
            'FontSize',12,...
            'HorizontalAlignment','left',...
            'Text',getString(message('images:segmenter:saveAsLogicalMessage')));

        end


        function addRadio(self)

            buttonGroup=uibuttongroup(...
            'Parent',self.FigureHandle,...
            'Position',[self.ButtonSpace,self.ButtonSize(2)+3*self.ButtonSpace,self.Size(1)-(2*self.ButtonSpace),(2*self.ButtonSize(2)+(3*self.ButtonSpace))],...
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


        function updateRadioState(self,evt)
            self.IsLogical=evt.NewValue==self.LogicalRadio;
        end

    end

end
