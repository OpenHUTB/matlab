classdef BlockedImageTab<handle




    events

ReadNextBlock

ReadPreviousBlock

ReadBlockByIndex

MarkBlockComplete

MoveCurrentBlock

    end


    properties(SetAccess=protected,Hidden,Transient)

Tab

    end


    properties(Transient,SetAccess=protected,GetAccess={...
        ?images.uitest.factory.Tester,...
        ?uitest.factory.Tester,...
        ?medical.internal.app.home.labeler.display.toolstrip.BlockedImageTab})

        Next matlab.ui.internal.toolstrip.SplitButton
        X matlab.ui.internal.toolstrip.Spinner
        Y matlab.ui.internal.toolstrip.Spinner
        Z matlab.ui.internal.toolstrip.Spinner
        Apply matlab.ui.internal.toolstrip.Button
        MarkComplete matlab.ui.internal.toolstrip.ToggleButton
        PercentageLabel matlab.ui.internal.toolstrip.Label
        Percentage matlab.ui.internal.toolstrip.Label
        BlockSize matlab.ui.internal.toolstrip.ListItem
        Size matlab.ui.internal.toolstrip.ListItem
        SizeInBlocks matlab.ui.internal.toolstrip.ListItem
        Adapter matlab.ui.internal.toolstrip.ListItem
        ClassUnderlying matlab.ui.internal.toolstrip.ListItem
        Source matlab.ui.internal.toolstrip.ListItem
        Metadata matlab.ui.internal.toolstrip.DropDownButton

    end


    properties(Access=protected,Transient)

        ElligibleToReadBlock(1,1)logical=false;

        Timer images.internal.app.utilities.eventCoalescer.Delayed

        ShowProperties(1,1)logical=false;

    end


    methods




        function self=BlockedImageTab(useWebVersion)

            self.Tab=matlab.ui.internal.toolstrip.Tab(getString(message('images:segmenter:blockedImageTab')));
            self.Tab.Tag='BlockedImageTab';

            self.Timer=images.internal.app.utilities.eventCoalescer.Delayed();

            addlistener(self.Timer,'DelayedEventTriggered',@(~,~)timerCallback(self));

            self.ShowProperties=useWebVersion;

            createTab(self);

        end




        function updateBlockIndex(self,idx,sz)

            self.ElligibleToReadBlock=false;
            self.Apply.Enabled=false;

            self.X.Value=idx(2);
            self.Y.Value=idx(1);
            self.Z.Value=idx(3);

            self.X.Limits=[1,sz(2)];
            self.Y.Limits=[1,sz(1)];
            self.Z.Limits=[1,sz(3)];

        end




        function enable(self)

            self.X.Enabled=true;
            self.Y.Enabled=true;
            self.Z.Enabled=true;
            self.Next.Enabled=true;
            self.Apply.Enabled=self.ElligibleToReadBlock;
            self.MarkComplete.Enabled=true;
            if self.ShowProperties
                self.Metadata.Enabled=true;
            end

        end




        function disable(self)

            self.X.Enabled=false;
            self.Y.Enabled=false;
            self.Z.Enabled=false;
            self.Next.Enabled=false;
            self.Apply.Enabled=false;
            self.MarkComplete.Enabled=false;
            if self.ShowProperties
                self.Metadata.Enabled=false;
            end

        end




        function markBlockAsComplete(self,TF)

            self.MarkComplete.Value=TF;

        end




        function delete(self)
            delete(self.Timer);
        end




        function updateCompletionPercentage(self,pct)

            self.Percentage.Text=[num2str(pct*100),'%'];

        end




        function updateBlockMetadata(self,evt)

            if self.ShowProperties
                self.Size.Description=evt.Size;
                self.BlockSize.Description=evt.BlockSize;
                self.SizeInBlocks.Description=evt.SizeInBlocks;
                self.Source.Description=evt.DataSource;
                self.ClassUnderlying.Description=evt.ClassUnderlying;
                self.Adapter.Description=evt.Adapter;
            end

        end

    end


    methods(Access=protected)


        function triggerTimer(self)

            if~self.ElligibleToReadBlock
                self.ElligibleToReadBlock=true;
                self.Apply.Enabled=true;
            end

            trigger(self.Timer);

        end


        function timerCallback(self)

            if~isvalid(self)
                return;
            end

            notify(self,'MoveCurrentBlock',images.internal.app.segmenter.volume.events.BlockIndexChangedEventData(...
            [self.Y.Value,self.X.Value,self.Z.Value],[],[]));

        end


        function readSpecifiedBlock(self)



            drawnow;
            notify(self,'ReadBlockByIndex',images.internal.app.segmenter.volume.events.BlockIndexChangedEventData(...
            [self.Y.Value,self.X.Value,self.Z.Value],[],[]));

        end

    end


    methods(Access=protected)


        function createTab(self)

            createNavigateSection(self);
            createCompleteSection(self);

            disable(self);

        end

        function createNavigateSection(self)


            section=addSection(self.Tab,getString(message('images:segmenter:navigate')));
            column=section.addColumn();


            xLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:volumeViewer:xAxisLabel')));
            xLabel.Tag="XLabel";
            column.add(xLabel);

            yLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:volumeViewer:yAxisLabel')));
            yLabel.Tag="YLabel";
            column.add(yLabel);

            zLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:volumeViewer:zAxisLabel')));
            zLabel.Tag="ZLabel";
            column.add(zLabel);

            column=section.addColumn('Width',70);


            self.X=matlab.ui.internal.toolstrip.Spinner();
            self.X.Description=getString(message('images:segmenter:xBlockTooltip'));
            self.X.Value=1;
            self.X.Tag='XIndex';
            column.add(self.X);

            self.Y=matlab.ui.internal.toolstrip.Spinner();
            self.Y.Description=getString(message('images:segmenter:yBlockTooltip'));
            self.Y.Value=1;
            self.Y.Tag='YIndex';
            column.add(self.Y);

            self.Z=matlab.ui.internal.toolstrip.Spinner();
            self.Z.Description=getString(message('images:segmenter:zBlockTooltip'));
            self.Z.Value=1;
            self.Z.Tag='ZIndex';
            column.add(self.Z);

            column=section.addColumn();


            self.Apply=matlab.ui.internal.toolstrip.Button(getString(message('images:segmenter:applyBlock')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_ReadBlock_24.png')));
            self.Apply.Tag='ReadBlock';
            self.Apply.Description=getString(message('images:segmenter:applyBlockTooltip'));
            column.add(self.Apply);


            addlistener(self.X,'ValueChanged',@(~,~)triggerTimer(self));
            addlistener(self.Y,'ValueChanged',@(~,~)triggerTimer(self));
            addlistener(self.Z,'ValueChanged',@(~,~)triggerTimer(self));
            addlistener(self.Apply,'ButtonPushed',@(~,~)readSpecifiedBlock(self));

        end

        function createCompleteSection(self)


            section=addSection(self.Tab,getString(message('images:segmenter:complete')));
            column=section.addColumn();


            self.MarkComplete=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:segmenter:markComplete')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_MarkComplete_24.png')));
            self.MarkComplete.Tag='MarkComplete';
            self.MarkComplete.Description=getString(message('images:segmenter:markCompleteTooltip'));
            column.add(self.MarkComplete);

            column=section.addColumn();


            nextBlock=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:nextBlockLong')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_NextBlock_16.png')));
            nextBlock.ShowDescription=false;
            nextBlock.Tag='NextBlockItem';
            addlistener(nextBlock,'ItemPushed',@(~,~)notify(self,'ReadNextBlock'));

            previousBlock=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:previousBlock')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_PreviousBlock_16.png')));
            previousBlock.ShowDescription=false;
            previousBlock.Tag='PreviousBlockItem';
            addlistener(previousBlock,'ItemPushed',@(~,~)notify(self,'ReadPreviousBlock'));

            popup=matlab.ui.internal.toolstrip.PopupList();
            add(popup,nextBlock);
            add(popup,previousBlock);

            self.Next=matlab.ui.internal.toolstrip.SplitButton(getString(message('images:segmenter:nextBlock')),...
            matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_NextBlock_24.png')));
            self.Next.Tag='NextBlock';
            self.Next.Description=getString(message('images:segmenter:nextBlockTooltip'));
            self.Next.Popup=popup;
            column.add(self.Next);

            column=section.addColumn('HorizontalAlignment','center');

            self.PercentageLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:segmenter:percentComplete')));
            self.PercentageLabel.Tag='PercentCompleteLabel';
            self.PercentageLabel.Description=getString(message('images:segmenter:percentCompleteTooltip'));
            column.add(self.PercentageLabel);

            self.Percentage=matlab.ui.internal.toolstrip.Label('0%');
            self.Percentage.Tag='PercentComplete';
            self.Percentage.Description=getString(message('images:segmenter:percentCompleteTooltip'));
            column.add(self.Percentage);

            if self.ShowProperties
                section=addSection(self.Tab,getString(message('images:segmenter:info')));
                column=section.addColumn('HorizontalAlignment','right');

                self.Size=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:sizeTitle')));
                self.Size.Tag='SizeLabel';
                self.BlockSize=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:blockSizeTitle')));
                self.BlockSize.Tag='BlockSizeLabel';
                self.SizeInBlocks=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:sizeInBlocksTitle')));
                self.SizeInBlocks.Tag='SizeInBlocksLabel';
                self.Source=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:sourceTitle')));
                self.Source.Tag='SourceLabel';
                self.Adapter=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:adapterTitle')));
                self.Adapter.Tag='AdapterLabel';
                self.ClassUnderlying=matlab.ui.internal.toolstrip.ListItem(getString(message('images:segmenter:classUnderlyingTitle')));
                self.ClassUnderlying.Tag='ClassUnderlyingLabel';

                popup=matlab.ui.internal.toolstrip.PopupList();

                add(popup,self.Size);
                add(popup,self.BlockSize);
                add(popup,self.SizeInBlocks);
                add(popup,self.Source);
                add(popup,self.Adapter);
                add(popup,self.ClassUnderlying);

                self.Metadata=matlab.ui.internal.toolstrip.DropDownButton(getString(message('images:segmenter:viewInfo')),matlab.ui.internal.toolstrip.Icon.PROPERTIES_24);
                self.Metadata.Tag='Metadata';
                self.Metadata.Description=getString(message('images:segmenter:viewInfoTooltip'));
                self.Metadata.Popup=popup;
                column.add(self.Metadata);

            end


            addlistener(self.MarkComplete,'ValueChanged',@(src,evt)notify(self,'MarkBlockComplete',evt));
            addlistener(self.Next,'ButtonPushed',@(~,~)notify(self,'ReadNextBlock'));

        end

    end

end