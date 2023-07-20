classdef BlockedImage<handle




    events




ShowBlockedImageDisplay




OverviewUpdated



BlockIndexChanged



ErrorThrown



CategoriesDetected

BlockReadStarted

BlockReadFinished

CompletionPercentageUpdated

CompatibleAdapterRequired

BlockMetadataUpdated

    end


    properties

        Empty(1,1)logical=true;

    end


    properties(Dependent)


Colormap


Alphamap


CurrentIndex

    end


    properties(SetAccess=private,Transient)

BlockedImageFile

WritableBlockedLabelFile

ReadableBlockedLabelFile

OverviewBlockSize

        Overview(:,:,:,:)uint8

        HistoryOfSeenBlocks(:,:,:)logical

        CompletedBlocks(:,:,:)logical

        CurrentBlockIndex(1,3)double{mustBePositive}=[1,1,1];

        LabelPath char='';

        VariableName char='';

        SkipCompletedBlocks(1,1)logical=true;

        IsRGB(1,1)logical=false;

        SizeInBlocks(1,3)double

BlockMap

    end


    properties(Access=private,Transient)

        AlphamapInternal(256,1)single{mustBeGreaterThanOrEqual(AlphamapInternal,0),mustBeLessThanOrEqual(AlphamapInternal,1)}
        ColormapInternal(256,3)single{mustBeGreaterThanOrEqual(ColormapInternal,0),mustBeLessThanOrEqual(ColormapInternal,1)}

    end


    methods




        function self=BlockedImage()





            self.Colormap=single(gray(256));



            self.Alphamap=[zeros([78,1],'single');ones([178,1],'single')*0.25];

        end




        function vol=readFirstBlock(self)



            if~self.Empty
                resetCurrentIndex(self);
                vol=readBlock(self,self.CurrentBlockIndex);
            else
                vol=[];
            end

        end




        function vol=readNextBlock(self)



            if~self.Empty
                sz=self.SizeInBlocks;

                if self.SkipCompletedBlocks
                    if all(self.CompletedBlocks)
                        notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(getString(message('images:segmenter:allMarkedComplete'))));
                        vol=[];
                        return;
                    end

                    currentIdx=sub2ind(sz,self.CurrentBlockIndex(1),self.CurrentBlockIndex(2),self.CurrentBlockIndex(3));
                    idx=find(~self.CompletedBlocks);

                    if any(idx>currentIdx)
                        idx=idx(idx>currentIdx);
                        newIdx=min(idx);
                    elseif any(idx<currentIdx)
                        idx=idx(idx<currentIdx);
                        newIdx=min(idx);
                    else
                        newIdx=currentIdx;
                    end

                    [i,j,k]=ind2sub(sz,newIdx);
                    self.CurrentBlockIndex=[i,j,k];

                else
                    if self.CurrentBlockIndex(1)<sz(1)
                        self.CurrentBlockIndex(1)=self.CurrentBlockIndex(1)+1;
                    elseif self.CurrentBlockIndex(2)<sz(2)
                        self.CurrentBlockIndex(2)=self.CurrentBlockIndex(2)+1;
                        self.CurrentBlockIndex(1)=1;
                    elseif self.CurrentBlockIndex(3)<sz(3)
                        self.CurrentBlockIndex(3)=self.CurrentBlockIndex(3)+1;
                        self.CurrentBlockIndex(1)=1;
                        self.CurrentBlockIndex(2)=1;
                    else
                        resetCurrentIndex(self);
                    end
                end

                vol=readBlock(self,self.CurrentBlockIndex);
            else
                vol=[];
            end

        end




        function vol=readPreviousBlock(self)




            if~self.Empty
                sz=self.SizeInBlocks;

                if self.SkipCompletedBlocks
                    if all(self.CompletedBlocks)
                        notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(getString(message('images:segmenter:allMarkedComplete'))));
                        vol=[];
                        return;
                    end

                    currentIdx=sub2ind(sz,self.CurrentBlockIndex(1),self.CurrentBlockIndex(2),self.CurrentBlockIndex(3));
                    idx=find(~self.CompletedBlocks);

                    if any(idx<currentIdx)
                        idx=idx(idx<currentIdx);
                        newIdx=max(idx);
                    elseif any(idx>currentIdx)
                        idx=idx(idx>currentIdx);
                        newIdx=max(idx);
                    else
                        newIdx=currentIdx;
                    end

                    [i,j,k]=ind2sub(sz,newIdx);
                    self.CurrentBlockIndex=[i,j,k];

                else
                    if self.CurrentBlockIndex(1)>1
                        self.CurrentBlockIndex(1)=self.CurrentBlockIndex(1)-1;
                    elseif self.CurrentBlockIndex(2)>1
                        self.CurrentBlockIndex(2)=self.CurrentBlockIndex(2)-1;
                        self.CurrentBlockIndex(1)=sz(1);
                    elseif self.CurrentBlockIndex(3)>1
                        self.CurrentBlockIndex(3)=self.CurrentBlockIndex(3)-1;
                        self.CurrentBlockIndex(1)=sz(1);
                        self.CurrentBlockIndex(2)=sz(2);
                    else
                        self.CurrentBlockIndex=sz;
                    end
                end

                vol=readBlock(self,self.CurrentBlockIndex);

            else
                vol=[];
            end

        end




        function vol=readBlock(self,idx)




            vol=[];

            if~self.Empty
                idx=round(idx);

                try
                    if isvalidBlock(self,idx)
                        self.CurrentBlockIndex=idx;
                        self.HistoryOfSeenBlocks(self.CurrentBlockIndex(1),self.CurrentBlockIndex(2),self.CurrentBlockIndex(3))=true;
                        redrawBlockOverview(self);
                        notify(self,'BlockReadStarted');
                        try
                            vol=squeeze(getBlock(self.BlockedImageFile,self.CurrentIndex));
                        catch ME
                            error(message('images:segmenter:readBlockedImageError',ME.message));
                        end
                        notify(self,'BlockIndexChanged',images.internal.app.segmenter.volume.events.BlockIndexChangedEventData(...
                        self.CurrentBlockIndex,self.SizeInBlocks,self.CompletedBlocks(self.CurrentBlockIndex(1),self.CurrentBlockIndex(2),self.CurrentBlockIndex(3))));
                        notify(self,'BlockReadFinished');
                    end
                catch ME
                    notify(self,'BlockReadFinished');
                    notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(ME.message));
                end
            end

        end




        function setBlockedImage(self,bim)





            try
                blockSize=bim.BlockSize(bim.BlockSize>1);
                sz=bim.Size(bim.Size>1);
                sizeInBlocks=bim.SizeInBlocks(bim.BlockSize>1);

                if numel(sz)<3
                    error(message('images:segmenter:invalidVolume'));
                end

                if numel(sz)~=3
                    if numel(sz)==4
                        if~(sz(4)==1||sz(4)==3)
                            error(message('images:segmenter:invalid4DVolume'));
                        end
                    else
                        error(message('images:segmenter:tooManyDimensions'));
                    end
                end

                if any(sz(1:3)<2)
                    error(message('images:segmenter:invalidVolume'));
                end

                if isempty(blockSize)||any(blockSize<2)
                    error(message('images:segmenter:invalidBlockSize'));
                end

                if numel(sz)==4&&sizeInBlocks(4)~=1
                    error(message('images:segmenter:invalidRGBBlockSize'));
                end

                if any(rem(sz(1:3),blockSize(1:3))==1)
                    error(message('images:segmenter:invalidTrailingBlockSize'));
                end

                self.SizeInBlocks=sizeInBlocks(1:3);
                self.BlockMap=bim.BlockSize;
                self.BlockMap(bim.BlockSize>1)=nan;
                self.IsRGB=numel(sz)==4;

                self.BlockedImageFile=bim.copy;

                setOverviewBlockSize(self,sz(1:3),blockSize(1:3));

                self.Overview=zeros(self.OverviewBlockSize.*self.SizeInBlocks,'uint8');

                self.LabelPath='';
                self.VariableName='';
                self.ReadableBlockedLabelFile=[];
                self.WritableBlockedLabelFile=[];
                self.HistoryOfSeenBlocks=false(self.SizeInBlocks);
                self.CompletedBlocks=false(self.SizeInBlocks);

                self.Empty=false;

                updateCompletePercentage(self);
                updateMetadata(self);

            catch ME
                self.Empty=true;
                notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(ME.message));
                updateMetadata(self);
            end

        end




        function setBlockedLabel(self,bim)

            try

                oldpath=self.LabelPath;
                oldLabels=self.ReadableBlockedLabelFile;
                oldWriteableLabels=self.WritableBlockedLabelFile;

                sz=bim.Size;

                if numel(sz)~=3
                    error(message('images:segmenter:invalidBlockedLabel'));
                end

                if~isequal(sz(1:3),self.BlockedImageFile.Size(1:3))||...
                    ~isequal(bim.BlockSize(1:3),self.BlockedImageFile.BlockSize(1:3))
                    error(message('images:segmenter:invalidBlockedLabel'));
                end

                if~isa(bim.Adapter,'images.blocked.H5Blocks')||bim.Adapter.GZIPLevel~=1
                    notify(self,'CompatibleAdapterRequired',images.internal.app.segmenter.volume.events.LabelEventData(bim));
                    return;
                end

                self.ReadableBlockedLabelFile=bim;
                self.LabelPath=self.ReadableBlockedLabelFile.Source;
                createWritableBlockedLabels(self);

                if isfield(bim.UserData,'Categories')
                    notify(self,'CategoriesDetected',images.internal.app.segmenter.volume.events.CategoriesDetectedEventData(...
                    bim.UserData.Categories));
                else




                    sz=bim.SizeInBlocks;

                    uniqueVals=[];

                    for i=1:sz(1)
                        for j=1:sz(2)
                            for k=1:sz(3)




                                bl=getBlock(bim,[i,j,k]);

                                if any(bl>0,'all')
                                    labelVals=unique(bl(:));
                                    labelVals=labelVals(labelVals~=0);
                                    uniqueVals=union(uniqueVals,labelVals);
                                end
                            end
                        end
                    end

                    uniqueVals=union(uniqueVals,(1:max(uniqueVals)));

                    if~isempty(uniqueVals)
                        if round(max(uniqueVals))~=max(uniqueVals)&&~isequal(uniqueVals,(1:max(uniqueVals)))
                            error(message('images:segmenter:unorderedLabelData'));
                        end

                        if max(uniqueVals)>255
                            error(message('images:segmenter:maxNumberExceeded'));
                        end

                        notify(self,'CategoriesDetected',images.internal.app.segmenter.volume.events.CategoriesDetectedEventData(...
                        max(uniqueVals)));
                    end
                end

                self.VariableName='';

                if isfield(bim.UserData,'HistoryOfSeenBlocks')&&islogical(bim.UserData.HistoryOfSeenBlocks)&&isequal(size(bim.UserData.HistoryOfSeenBlocks),self.SizeInBlocks)
                    self.HistoryOfSeenBlocks=bim.UserData.HistoryOfSeenBlocks;
                else
                    self.HistoryOfSeenBlocks=false(self.SizeInBlocks);
                end

                if isfield(bim.UserData,'CompletedBlocks')&&islogical(bim.UserData.CompletedBlocks)&&isequal(size(bim.UserData.CompletedBlocks),self.SizeInBlocks)
                    self.CompletedBlocks=bim.UserData.CompletedBlocks;
                else
                    self.CompletedBlocks=false(self.SizeInBlocks);
                end

                updateCompletePercentage(self);
                redrawBlockOverview(self);

            catch ME

                self.LabelPath=oldpath;
                self.ReadableBlockedLabelFile=oldLabels;
                self.WritableBlockedLabelFile=oldWriteableLabels;
                notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(ME.message));

            end

        end




        function saveToFile(self,var,labels,~)






            [path,folder,~]=fileparts(var);
            var=fullfile(path,folder);

            if isempty(self.WritableBlockedLabelFile)||isempty(self.LabelPath)

                if~isFolderNonEmpty(var)
                    error(message('images:segmenter:folderMustBeEmpty'));
                end

                self.LabelPath=var;

                createWritableBlockedLabels(self);
                createReadableBlockedLabels(self);

            elseif~strcmp(var,self.LabelPath)

                if~isFolderNonEmpty(var)
                    error(message('images:segmenter:folderMustBeEmpty'));
                end

                mkdir(fullfile(var,'L1'));
                copyfile(fullfile(self.LabelPath,'L1','*.*'),fullfile(var,'L1'),'f');
                copyfile(fullfile(self.LabelPath,'description.mat'),fullfile(var),'f');

                self.LabelPath=var;

                createWritableBlockedLabels(self);
                createReadableBlockedLabels(self);

            end

            setBlock(self.WritableBlockedLabelFile,self.CurrentBlockIndex,uint8(labels));

            self.WritableBlockedLabelFile.UserData.Categories=string(categories(labels));
            self.WritableBlockedLabelFile.UserData.HistoryOfSeenBlocks=self.HistoryOfSeenBlocks;
            self.WritableBlockedLabelFile.UserData.CompletedBlocks=self.CompletedBlocks;
            serializeUserData(self.WritableBlockedLabelFile);

            self.HistoryOfSeenBlocks(self.CurrentBlockIndex(1),self.CurrentBlockIndex(2),self.CurrentBlockIndex(3))=true;

        end




        function saveToWorkspace(self,var,labels,~)








            if isempty(self.WritableBlockedLabelFile)||isempty(self.VariableName)

                self.LabelPath=tempname;
                self.VariableName=var;


                createWritableBlockedLabels(self);
                createReadableBlockedLabels(self);

            elseif~strcmp(var,self.VariableName)

                path=tempname;

                copyfile(self.LabelPath,path);

                self.LabelPath=path;
                self.VariableName=var;

                createWritableBlockedLabels(self);
                createReadableBlockedLabels(self);

            end

            setBlock(self.WritableBlockedLabelFile,self.CurrentBlockIndex,uint8(labels));

            self.WritableBlockedLabelFile.UserData.Categories=string(categories(labels));
            self.WritableBlockedLabelFile.UserData.HistoryOfSeenBlocks=self.HistoryOfSeenBlocks;
            self.WritableBlockedLabelFile.UserData.CompletedBlocks=self.CompletedBlocks;
            serializeUserData(self.WritableBlockedLabelFile);

            assignin('base',var,self.ReadableBlockedLabelFile);

            self.HistoryOfSeenBlocks(self.CurrentBlockIndex(1),self.CurrentBlockIndex(2),self.CurrentBlockIndex(3))=true;

        end




        function updateRendering(self,thresh,alpha)



            thresh=round(thresh*255);

            self.Alphamap=[zeros([thresh+1,1],'single');ones([255-thresh,1],'single')*alpha];

        end




        function label=readCurrentLabelBlock(self)




            try
                if isempty(self.ReadableBlockedLabelFile)
                    label=uint8.empty;
                else
                    label=getBlock(self.ReadableBlockedLabelFile,self.CurrentBlockIndex);
                end
            catch ME
                notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(ME.message));
                label=uint8.empty;
            end

        end




        function removeLabel(self,idx)
















            if isempty(self.WritableBlockedLabelFile)

                return;
            end

            sz=self.SizeInBlocks;

            for i=1:sz(1)
                for j=1:sz(2)
                    for k=1:sz(3)

                        bl=getBlock(self.ReadableBlockedLabelFile,[i,j,k]);

                        if any(bl>=idx,'all')
                            bl(bl==idx)=0;
                            bl(bl>idx)=bl(bl>idx)-1;
                            setBlock(self.WritableBlockedLabelFile,[i,j,k],bl);
                        end

                    end
                end
            end

        end




        function generateOverview(self,hfig,R,G,B)

            if self.IsRGB
                if isempty(hfig)
                    self.Overview=images.internal.app.segmenter.volume.data.rescaleVolume(gather(apply(self.BlockedImageFile,...
                    @(bim)resizeRGBBlock(bim.Data,self.OverviewBlockSize),...
                    'Cancellable',true)),R,G,B);
                else
                    self.Overview=images.internal.app.segmenter.volume.data.rescaleVolume(gather(apply(self.BlockedImageFile,...
                    @(bim)resizeRGBBlock(bim.Data,self.OverviewBlockSize),...
                    'Cancellable',true,'Parent',hfig)),R,G,B);
                end
            else
                if isempty(hfig)
                    self.Overview=images.internal.app.segmenter.volume.data.rescaleVolume(gather(apply(self.BlockedImageFile,...
                    @(bim)resizeBlock(bim.Data,self.OverviewBlockSize),...
                    'Cancellable',true)),R,G,B);
                else
                    self.Overview=images.internal.app.segmenter.volume.data.rescaleVolume(gather(apply(self.BlockedImageFile,...
                    @(bim)resizeBlock(bim.Data,self.OverviewBlockSize),...
                    'Cancellable',true,'Parent',hfig)),R,G,B);
                end
            end

        end




        function redrawBlockOverview(self)
            notify(self,'OverviewUpdated',images.internal.app.segmenter.volume.events.BlockOverviewUpdatedEventData(...
            self.Overview,self.CompletedBlocks,self.HistoryOfSeenBlocks,...
            self.CurrentBlockIndex,self.OverviewBlockSize,...
            self.Colormap,self.Alphamap,self.BlockedImageFile.Size));
        end




        function regenerateBlockOverview(self,includeVolume,~,hfig,R,G,B)

            if includeVolume
                generateOverview(self,hfig,R,G,B);
            else
                self.Overview=zeros(self.OverviewBlockSize.*self.SizeInBlocks,'uint8');
            end

            redrawBlockOverview(self);

        end




        function markBlockAsComplete(self,TF)

            if isscalar(TF)
                self.CompletedBlocks(self.CurrentBlockIndex(1),self.CurrentBlockIndex(2),self.CurrentBlockIndex(3))=TF;
            else
                if~isequal(size(TF),size(self.CompletedBlocks))
                    return;
                end
                self.CompletedBlocks=self.CompletedBlocks|TF;
                redrawBlockOverview(self);
            end
            updateCompletePercentage(self);
            notify(self,'BlockIndexChanged',images.internal.app.segmenter.volume.events.BlockIndexChangedEventData(...
            self.CurrentBlockIndex,self.SizeInBlocks,self.CompletedBlocks(self.CurrentBlockIndex(1),self.CurrentBlockIndex(2),self.CurrentBlockIndex(3))));

        end




        function markBlockAsSeen(self,idx)

            self.CurrentBlockIndex=idx;
            self.HistoryOfSeenBlocks(idx(1),idx(2),idx(3))=true;

            redrawBlockOverview(self);

        end




        function skipCompletedBlocks(self,TF)
            self.SkipCompletedBlocks=TF;
        end




        function idx=shiftBlockIndex(self,idx,dim)

            switch dim

            case 1
                idx=[idx(3),idx(2),idx(1)];
            case 2
                idx=[idx(1),idx(3),idx(2)];
            case 3

            end

            idx=self.CurrentBlockIndex+idx;

            if isvalidBlock(self,idx)
                self.CurrentBlockIndex=idx;
            else
                idx=[];
            end

        end




        function pos=getVoxelLocation(self,pos,idx,dim)

            blockSize=self.BlockedImageFile.BlockSize(isnan(self.BlockMap));
            adjustForBlocks=(self.CurrentBlockIndex-[1,1,1]).*blockSize(1:3);

            try
                switch dim
                case 1
                    pos=[idx,pos(1),pos(2)];
                case 2
                    pos=[idx,pos(2),pos(1)];
                case 3
                    pos=[pos(1),pos(2),idx];
                end

                pos=pos+[adjustForBlocks(2),adjustForBlocks(1),adjustForBlocks(3)];

            catch
                pos=[];
            end

        end




        function refreshLabelSource(self)
            createReadableBlockedLabels(self);
        end




        function convertAdapter(self,bim,loc)

            try
                if~isFolderNonEmpty(loc)
                    error(message('images:segmenter:folderMustBeEmpty'));
                end

                uniqueVals=apply(bim,@(bl)detectUniqueLabels(bl.Data),'Cancellable',false,...
                'Adapter',images.blocked.InMemory);

                sz=uniqueVals.SizeInBlocks;

                labelVals=[];

                for i=1:sz(1)
                    for j=1:sz(2)
                        for k=1:sz(3)
                            bl=getBlock(uniqueVals,[i,j,k]);
                            labelVals=union(labelVals,bl.Labels);
                        end
                    end
                end

                if numel(labelVals)>255
                    error(message('images:segmenter:maxNumberExceeded'));
                end

                adapter=images.blocked.H5Blocks;
                adapter.GZIPLevel=1;

                targetFolder=tempname(loc);

                params={'BlockSize',bim.BlockSize...
                ,'OutputLocation',targetFolder,...
                'Adapter',adapter,...
                'Cancellable',false};

                labels=apply(bim,@(bl)sanitizeLabels(bl.Data,labelVals),params{:});%#ok<NASGU>
                movefile(fullfile(targetFolder,'L1','*.*'),fullfile(loc,'L1'),'f');
                movefile(fullfile(targetFolder,'description.mat'),fullfile(loc),'f');

                try %#ok<TRYNC>
                    rmdir(targetFolder,'s');
                end

                desc=load(fullfile(loc,'description.mat'));
                desc.Info.UserData.Categories=uint8(numel(labelVals));
                save(fullfile(loc,'description.mat'),'-struct','desc');

                labels=blockedImage(loc);

                setBlockedLabel(self,labels);

            catch ME
                notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(ME.message));
            end

        end




        function clear(self)
            if self.Empty
                return;
            end

            self.LabelPath='';
            self.VariableName='';
            self.ReadableBlockedLabelFile=[];
            self.WritableBlockedLabelFile=[];
            self.BlockedImageFile=[];
            self.Empty=true;

            updateCompletePercentage(self);
            updateMetadata(self);

        end

    end

    methods(Access=private)


        function TF=isvalidBlock(self,idx)

            sz=self.SizeInBlocks;

            TF=all(idx>=1)&&...
            idx(1)<=sz(1)&&...
            idx(2)<=sz(2)&&...
            idx(3)<=sz(3);

        end


        function createWritableBlockedLabels(self)

            adapter=images.blocked.H5Blocks();
            adapter.GZIPLevel=1;

            sz=self.BlockedImageFile.Size(isnan(self.BlockMap));
            blockSize=self.BlockedImageFile.BlockSize(isnan(self.BlockMap));



            self.WritableBlockedLabelFile=blockedImage(self.LabelPath,...
            sz(1:3),...
            blockSize(1:3),...
            uint8(0),...
            'Adapter',adapter,'Mode','a');

        end


        function createReadableBlockedLabels(self)

            self.ReadableBlockedLabelFile=blockedImage(self.WritableBlockedLabelFile.Source);

        end


        function resetCurrentIndex(self)

            self.CurrentBlockIndex=[1,1,1];

        end


        function setOverviewBlockSize(self,imageSize,blockSize)



            scaleFactor=imageSize./500;

            if any(scaleFactor>10)

                scaleValue=max(scaleFactor);

                self.OverviewBlockSize=ceil(blockSize/scaleValue);

            else

                self.OverviewBlockSize=ceil(blockSize/10);

            end

        end


        function idx=getIndex(self,idx)

            if self.IsRGB
                nanidx=[idx,1];
            else
                nanidx=idx;
            end

            idx=self.BlockMap;
            idx(isnan(idx))=nanidx;

        end


        function updateCompletePercentage(self)
            if self.Empty
                pct=0;
            else
                pct=sum(self.CompletedBlocks(:))/numel(self.CompletedBlocks);
            end
            notify(self,'CompletionPercentageUpdated',images.internal.app.segmenter.volume.events.BlockOverviewSettingsEventData(...
            [],[],pct));
        end


        function updateMetadata(self)
            if self.Empty
                blockSize='';
                sz='';
                sizeInBlocks='';
                adapter='';
                src='';
                classUnderlying='';
            else
                blockSize=['[',num2str(self.BlockedImageFile.BlockSize),']'];
                sz=['[',num2str(self.BlockedImageFile.Size),']'];
                sizeInBlocks=['[',num2str(self.BlockedImageFile.SizeInBlocks),']'];
                adapter=class(self.BlockedImageFile.Adapter);
                if ischar(self.BlockedImageFile.Source)||isstring(self.BlockedImageFile.Source)
                    src=char(self.BlockedImageFile.Source);
                else
                    src=class(self.BlockedImageFile.Source);
                end
                classUnderlying=char(self.BlockedImageFile.ClassUnderlying);
            end
            notify(self,'BlockMetadataUpdated',images.internal.app.segmenter.volume.events.BlockMetadataUpdatedEventData(...
            blockSize,sz,sizeInBlocks,adapter,src,classUnderlying));
        end

    end


    methods




        function set.Empty(self,TF)

            if xor(TF,self.Empty)

                notify(self,'ShowBlockedImageDisplay',images.internal.app.segmenter.volume.events.ShowBlockedImageEventData(~TF));

                if TF
                    self.BlockedImageFile=[];%#ok<MCSUP>
                    self.WritableBlockedLabelFile=[];%#ok<MCSUP>
                    self.ReadableBlockedLabelFile=[];%#ok<MCSUP>
                    self.Overview=uint8.empty;%#ok<MCSUP>
                    self.LabelPath='';%#ok<MCSUP>
                end

            end

            self.Empty=TF;

        end




        function set.Colormap(self,cmap)



            self.ColormapInternal=cmap;

            if~self.Empty
                redrawBlockOverview(self);
            end

        end

        function cmap=get.Colormap(self)

            cmap=self.ColormapInternal;

        end




        function set.Alphamap(self,amap)



            self.AlphamapInternal=amap;

            if~self.Empty
                redrawBlockOverview(self);
            end

        end

        function amap=get.Alphamap(self)

            amap=self.AlphamapInternal;

        end




        function set.CurrentIndex(self,idx)
            self.CurrentBlockIndex=idx(1:3);
        end

        function idx=get.CurrentIndex(self)





            idx=getIndex(self,self.CurrentBlockIndex);

        end

    end

end

function TF=isFolderNonEmpty(var)

    TF=false;

    contents=dir(var);

    if isempty(contents)||(length(contents)==2&&strcmp(contents(1).name,'.')&&strcmp(contents(2).name,'..'))
        TF=true;
    end

end

function out=resizeRGBBlock(bl,sz)

    out(:,:,:,3)=imresize3(bl(:,:,:,3),sz);
    out(:,:,:,2)=imresize3(bl(:,:,:,2),sz);
    out(:,:,:,1)=imresize3(bl(:,:,:,1),sz);

end

function out=resizeBlock(bl,sz)

    out=imresize3(bl,sz);

end

function labelStruct=detectUniqueLabels(bl)

    if~isnumeric(bl)
        bl=uint8(bl);
    end

    if any(bl>0,'all')
        labelVals=unique(bl(:));
        labelVals=labelVals(labelVals~=0);
    else
        labelVals=[];
    end

    labelStruct.Labels=labelVals;

end

function out=sanitizeLabels(bl,labelVals)

    if~isnumeric(bl)
        bl=uint8(bl);
    end

    out=bl;

    for idx=1:numel(labelVals)
        out(bl==labelVals(idx))=idx;
    end

end
