classdef OverviewVolumeToolgroup<images.internal.app.segmenter.volume.display.VolumeToolgroup





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




        function self=OverviewVolumeToolgroup(hfig,pos,show3DDisplay)

            self@images.internal.app.segmenter.volume.display.VolumeToolgroup(hfig,pos,show3DDisplay);

            if~show3DDisplay
                return;
            end

            self.Panel.Tag='OverviewPanel';
            self.DirtyPanel.Tag='DirtyOverviewPanel';
            set(self.DirtyPanel,'ButtonDownFcn',@(~,~)markVolumeAsClean(self));
            set(self.Datatip,'String',getString(message('images:segmenter:overviewTooltip')));

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
                self.Panel.Visible='off';
                self.DirtyPanel.Visible='on';
            end

        end




        function setBlockedImageOverview(self,vol,completedBlocks,blockHistory,idx,sz,cmap,amap,sizeInBlocks)

            if self.Empty
                return;
            end

            if isempty(vol)
                vol=zeros(3,3,3,'uint8');
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

            [vol,cmap,amap]=merge(self,vol,labels,ones([256,1],'single'),cmap,amap);

            self.Primitive.Data=permute(vol,[2,1,3]);

            labelAlpha=0.5;

            amap=[amap(1);amap(2:2:end);1;labelAlpha;labelAlpha;1;ones([self.DataMax-self.MergedVolumeBuffer-3,1])];
            cmap=[cmap(1,:);cmap(2:2:end,:);0,0,0;1,1,0;0,1,0;1,0,0;zeros([self.DataMax-self.MergedVolumeBuffer-3,3])];

            sizeInBlocks=sizeInBlocks(1:3);

            if~isequal(self.SizeInBlocks,sizeInBlocks)
                self.SizeInBlocks=sizeInBlocks;
                sizeInBlocks=sizeInBlocks./volSize(1:3);
                sizeInBlocks=sizeInBlocks./min(sizeInBlocks);
                tform=self.Transform;
                tform(1,1)=tform(1,1)*sizeInBlocks(1);
                tform(2,2)=tform(2,2)*sizeInBlocks(2);
                tform(3,3)=tform(3,3)*sizeInBlocks(3);
                self.Transform=tform;
            end



            self.Primitive.TransferFunction=im2uint8(double([cmap,amap]'));

            drawnow;

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

            self.Primitive.Data=zeros(3,3,3,'uint8');
            self.LabelPrimitive.Data=zeros(3,3,3,'uint8');
            updateDataLimits(self,3,3,3);

            self.Panel.Visible='off';
            self.DirtyPanel.Visible='off';
            self.Datatip.Visible='off';

        end

    end


end