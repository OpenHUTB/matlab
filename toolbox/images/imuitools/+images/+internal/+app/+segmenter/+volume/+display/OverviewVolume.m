classdef OverviewVolume<images.internal.app.segmenter.volume.display.Volume





    properties

        ShowCurrentBlock(1,1)logical=true;

        ShowBlockHistory(1,1)logical=true;

        ShowCompletedBlocks(1,1)logical=true;

SelectedBlock

    end


    properties(Access=private,Transient)

        ShowOverviewInternal(1,1)logical=false;

        SizeInBlocks(1,3)double=[1,1,1];

        ShowPrompt(1,1)logical=true;

    end


    methods




        function self=OverviewVolume(hfig,show3DDisplay)

            self@images.internal.app.segmenter.volume.display.Volume(hfig,show3DDisplay);

            if~show3DDisplay
                return;
            end

            self.TooltipText=getString(message('images:segmenter:overviewTooltip'));

        end




        function showOverview(self,TF)

            if self.Empty
                return;
            end

            self.VisibleInternal=TF;

            if TF
                markVolumeAsClean(self);
            elseif self.ShowPrompt
                self.ShowPrompt=false;
                markVolumeAsDirty(self);
            else


            end

        end




        function setBlockedImageOverview(self,vol,completedBlocks,blockHistory,idx,sz,cmap,amap,sizeInBlocks)

            if self.Empty
                return;
            end

            if isempty(vol)
                set(self.VolumeObject,'Data',[],'OverlayData',[]);
                return;
            end

            if self.ShowBlockHistory
                blockHistory=uint8(blockHistory);
            else
                blockHistory=zeros(size(blockHistory),'uint8');
            end

            if self.ShowCompletedBlocks
                blockHistory(completedBlocks)=2;
            end

            if self.ShowCurrentBlock
                if~isempty(self.SelectedBlock)
                    blockHistory(self.SelectedBlock(1),self.SelectedBlock(2),self.SelectedBlock(3))=3;
                else
                    blockHistory(idx(1),idx(2),idx(3))=3;
                end
            end

            if isscalar(blockHistory)
                labels=ones(size(blockHistory,1).*sz,'uint8')*blockHistory(1);
            elseif ismatrix(blockHistory)
                labels=uint8(imresize(blockHistory,size(blockHistory,1,2).*sz(1:2),'nearest'));
                labels=repmat(labels,[1,1,sz(3)]);
            else
                labels=uint8(imresize3(blockHistory,size(blockHistory,1,2,3).*sz,'nearest'));
            end

            volSize=size(vol);
            labels=labels(1:volSize(1),1:volSize(2),1:volSize(3));

            overlaycmap=[zeros([1,3]);1,1,0;0,1,0;1,0,0;zeros([252,3])];

            set(self.VolumeObject,'Data',vol,'OverlayData',labels,'Colormap',cmap,'Alphamap',amap,'OverlayColormap',overlaycmap,'OverlayAlphamap',0.75);

            sizeInBlocks=sizeInBlocks(1:3);

            if~isequal(self.SizeInBlocks,sizeInBlocks)
                self.SizeInBlocks=sizeInBlocks;
            end

            if self.ShowPrompt
                self.ShowPrompt=false;
                markVolumeAsDirty(self);
            else
                markVolumeAsClean(self);
            end

        end




        function clear(self)

            if self.Empty
                return;
            end

            self.SizeInBlocks=[1,1,1];

            set(self.VolumeObject,'Data',[],'OverlayData',[]);

        end




        function markVolumeAsDirty(self)

            if self.Empty
                return;
            end

            set(self.Viewer,'Tooltip',self.TooltipText);

        end

    end


end