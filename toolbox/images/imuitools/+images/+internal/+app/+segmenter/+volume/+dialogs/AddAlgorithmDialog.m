classdef AddAlgorithmDialog<images.internal.app.utilities.OkCancelDialog




    properties(GetAccess=public,SetAccess=protected)

        FilePath char

EditField
Browse

    end

    methods




        function self=AddAlgorithmDialog(loc,dlgTitle)

            self=self@images.internal.app.utilities.OkCancelDialog(loc,dlgTitle);

            self.Size=[300,80];

            create(self);

        end




        function create(self)

            create@images.internal.app.utilities.OkCancelDialog(self);

            addEditField(self);
            addBrowse(self);

        end

    end

    methods(Access=protected)


        function okClicked(self)

            self.FilePath=self.EditField.Value;

            self.Canceled=false;
            close(self);

        end


        function addBrowse(self)

            self.Browse=uibutton('Parent',self.FigureHandle,...
            'ButtonPushedFcn',@(~,~)browseFiles(self),...
            'Position',[self.Size(1)-self.ButtonSpace-round(4*self.ButtonSize(2)),self.ButtonSize(2)+2*self.ButtonSpace,round(4*self.ButtonSize(2)),self.ButtonSize(2)],...
            'Icon',fullfile(matlabroot,'toolbox','shared','controllib','general','resources','toolstrip_icons','Open_16.png'),...
            'Tag','Browse',...
            'Text',getString(message('images:segmenter:browse')));

        end


        function addEditField(self)

            self.EditField=uieditfield('text',...
            'Parent',self.FigureHandle,...
            'Position',[self.ButtonSpace,self.ButtonSize(2)+2*self.ButtonSpace,self.Size(1)-(3*self.ButtonSpace)-round(4*self.ButtonSize(2)),self.ButtonSize(2)],...
            'FontSize',12,...
            'ValueChangedFcn',@(~,~)updateText(self),...
            'Value','');

        end


        function updateText(self)

            val=which(self.EditField.Value);

            if~isempty(val)
                self.EditField.Value=val;
            end

        end


        function browseFiles(self)

            [file,path]=uigetfile('*.m');

            if~isequal(file,0)
                self.EditField.Value=fullfile(path,file);
                okClicked(self);
            else
                figure(self.FigureHandle);
            end

        end

    end

end
