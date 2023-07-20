classdef ManageAlgorithmDialog<images.internal.app.utilities.OkCancelDialog




    properties(GetAccess=public,SetAccess=protected)

SliceLabel
SliceListBox
        SliceAlgorithms string
        SliceAlgorithmsDisplay string

VolumeLabel
VolumeListBox
        VolumeAlgorithms string
        VolumeAlgorithmsDisplay string

Remove

    end

    methods




        function self=ManageAlgorithmDialog(loc,dlgTitle)

            self=self@images.internal.app.utilities.OkCancelDialog(loc,dlgTitle);

            self.Size=[460,260];

            getAlgorithms(self);

            create(self);

        end




        function create(self)

            create@images.internal.app.utilities.OkCancelDialog(self);

            addSliceLabel(self);
            addSliceListBox(self);

            addVolumeLabel(self);
            addVolumeListBox(self);

            addRemove(self);

        end

    end

    methods(Access=protected)


        function okClicked(self)

            s=settings;
            s.images.VolumeSegmenter.SliceAlgorithmList.PersonalValue=self.SliceAlgorithms;
            s.images.VolumeSegmenter.VolumeAlgorithmList.PersonalValue=self.VolumeAlgorithms;

            self.Canceled=false;
            close(self);

        end


        function addSliceLabel(self)

            self.SliceLabel=uilabel(...
            'Parent',self.FigureHandle,...
            'Position',[self.ButtonSpace,(10*self.ButtonSize(2))+3*self.ButtonSpace,(self.Size(1)/2)-(3*self.ButtonSpace),self.ButtonSize(2)],...
            'FontSize',12,...
            'HorizontalAlignment','left',...
            'Text',getString(message('images:segmenter:sliceBySlice')));

        end


        function addVolumeLabel(self)

            self.VolumeLabel=uilabel(...
            'Parent',self.FigureHandle,...
            'Position',[(self.Size(1)/2)+(0.5*self.ButtonSpace),(10*self.ButtonSize(2))+3*self.ButtonSpace,(self.Size(1)/2)-(3*self.ButtonSpace),self.ButtonSize(2)],...
            'FontSize',12,...
            'HorizontalAlignment','left',...
            'Text',getString(message('images:segmenter:volumeBased')));

        end


        function addSliceListBox(self)

            self.SliceListBox=uilistbox('Parent',self.FigureHandle,...
            'Position',[self.ButtonSpace,(2*self.ButtonSize(2))+3*self.ButtonSpace,(self.Size(1)-(3*self.ButtonSpace))/2,8*self.ButtonSize(2)],...
            'Items',self.SliceAlgorithmsDisplay,...
            'FontSize',12,...
            'Value',{},...
            'MultiSelect','on',...
            'Tag','SliceList',...
            'ValueChangedFcn',@(~,~)selectFromList(self));

        end


        function addVolumeListBox(self)

            self.VolumeListBox=uilistbox('Parent',self.FigureHandle,...
            'Position',[(self.Size(1)/2)+(0.5*self.ButtonSpace),(2*self.ButtonSize(2))+3*self.ButtonSpace,(self.Size(1)-(3*self.ButtonSpace))/2,8*self.ButtonSize(2)],...
            'Items',self.VolumeAlgorithmsDisplay,...
            'FontSize',12,...
            'Value',{},...
            'MultiSelect','on',...
            'Tag','VolumeList',...
            'ValueChangedFcn',@(~,~)selectFromList(self));

        end


        function addRemove(self)

            self.Remove=uibutton('Parent',self.FigureHandle,...
            'ButtonPushedFcn',@(~,~)removeFromList(self),...
            'FontSize',12,...
            'Enable','off',...
            'Position',[self.ButtonSpace,(2*self.ButtonSpace)+self.ButtonSize(2),self.ButtonSize],...
            'Text',getString(message('images:segmenter:remove')),...
            'Tag','Remove');

        end


        function selectFromList(self)

            if isempty(self.SliceListBox.Value)&&isempty(self.VolumeListBox.Value)
                self.Remove.Enable='off';
            else
                self.Remove.Enable='on';
            end

        end

        function removeFromList(self)

            sliceIdx=true(size(self.SliceAlgorithms));
            volumeIdx=true(size(self.VolumeAlgorithms));

            if~isempty(self.SliceListBox.Value)

                for i=1:numel(self.SliceListBox.Value)

                    idx=strcmp(self.SliceListBox.Value{i},self.SliceListBox.Items);
                    sliceIdx(idx)=false;

                end

                self.SliceListBox.Items=self.SliceListBox.Items(sliceIdx);
                self.SliceAlgorithms=self.SliceAlgorithms(sliceIdx);

            end

            if~isempty(self.VolumeListBox.Value)

                for i=1:numel(self.VolumeListBox.Value)

                    idx=strcmp(self.VolumeListBox.Value{i},self.VolumeListBox.Items);
                    volumeIdx(idx)=false;

                end

                self.VolumeListBox.Items=self.VolumeListBox.Items(volumeIdx);
                self.VolumeAlgorithms=self.VolumeAlgorithms(volumeIdx);

            end

            self.SliceListBox.Value={};
            self.VolumeListBox.Value={};

            selectFromList(self);

        end


        function getAlgorithms(self)

            s=settings;

            self.SliceAlgorithms=s.images.VolumeSegmenter.SliceAlgorithmList.ActiveValue;
            algos=self.SliceAlgorithms;

            for idx=1:numel(algos)
                metaClass=meta.class.fromName(algos(idx));

                if~isempty(metaClass)
                    try %#ok<TRYNC>
                        algos(idx)=strrep(eval([metaClass.Name,'.Name']),newline," ");
                    end
                else
                    [~,algos(idx),~]=fileparts(algos(idx));
                end
            end

            self.SliceAlgorithmsDisplay=algos;

            self.VolumeAlgorithms=s.images.VolumeSegmenter.VolumeAlgorithmList.ActiveValue;
            algos=self.VolumeAlgorithms;

            for idx=1:numel(algos)
                metaClass=meta.class.fromName(algos(idx));

                if~isempty(metaClass)
                    try %#ok<TRYNC>
                        algos(idx)=strrep(eval([metaClass.Name,'.Name']),newline," ");
                    end
                else
                    [~,algos(idx),~]=fileparts(algos(idx));
                end
            end

            self.VolumeAlgorithmsDisplay=algos;

        end

    end

end
