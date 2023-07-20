classdef ShowLabelsDialog<images.internal.app.utilities.OkCancelDialog




    properties(GetAccess=public,SetAccess=protected)

Table

Labels
Visibility

    end

    methods




        function self=ShowLabelsDialog(loc,dlgTitle,labels,alpha)

            self=self@images.internal.app.utilities.OkCancelDialog(loc,dlgTitle);

            self.Size=[260,300];

            self.Labels=labels;
            self.Visibility=logical(alpha);

            create(self);

            set(self.Table,'Visible','on');

        end




        function create(self)

            create@images.internal.app.utilities.OkCancelDialog(self);

            addTable(self);

        end

    end

    methods(Access=protected)


        function okClicked(self)

            self.Visibility=table2array(self.Table.Data(:,2));
            self.Canceled=false;
            close(self);

        end


        function addTable(self)

            data=table(self.Labels,self.Visibility,'VariableNames',{getString(message('images:segmenter:labelName')),getString(message('images:segmenter:labelVisible'))});

            self.Table=uitable(...
            'Parent',self.FigureHandle,...
            'Position',[self.ButtonSpace,self.ButtonSize(2)+(2*self.ButtonSpace),self.Size(1)-(2*self.ButtonSpace),self.Size(2)-(3*self.ButtonSpace)-self.ButtonSize(2)],...
            'FontSize',12,...
            'Enable','on',...
            'RowName',{},...
            'Visible','off',...
            'ColumnEditable',[false,true],...
            'Data',data);

        end

    end

end
