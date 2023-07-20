classdef IO<handle




    events


VolumeLoaded



LabelsLoaded



ErrorThrown




ShowBlockedImageDisplay



BlockedImageOverviewUpdated



BlockIndexChanged

BlockCategoriesDetected

BlockedImageLoadingStarted

BlockedImageLoadingFinished

CompletionPercentageUpdated

LabelsSaved

CompatibleAdapterRequired

BlockMetadataUpdated

    end


    properties(SetAccess=private,Hidden,Transient)



        TransformFromFileMetadata(4,4)double=eye(4);

        LabelFile char='';

        BlockedImage images.internal.app.segmenter.volume.data.BlockedImage

    end


    properties(Dependent,SetAccess=private)

OverviewBlockSize

CompletedBlocks

BlockMap

    end


    methods




        function self=IO()




            wireUpBlockedImage(self);

        end




        function loadVolumeFromWorkspace(self,vol)




            if isa(vol,'blockedImage')

                setBlockedImage(self.BlockedImage,vol);

                if self.BlockedImage.Empty
                    return;
                end




                self.TransformFromFileMetadata=eye(4);

                vol=readFirstBlock(self.BlockedImage);

                if~isempty(vol)
                    loadVolume(self,vol);
                end

            else

                self.TransformFromFileMetadata=eye(4);

                loadVolume(self,vol);

                self.BlockedImage.Empty=true;
            end

        end




        function loadVolumeFromFile(self,filename)




            try

                [vol,tform]=images.internal.app.utilities.importVolumeFromFile(filename,'VolumeSegmenter');

            catch ME

                notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(ME.message));
                return;

            end


            if isempty(tform)
                self.TransformFromFileMetadata=eye(4);
            else
                self.TransformFromFileMetadata=double(tform);
            end

            loadVolume(self,vol);

            self.BlockedImage.Empty=true;

        end




        function loadBlockedImageFromFile(self,filename)




            try

                bim=blockedImage(filename);



                setBlockedImage(self.BlockedImage,bim);

                if self.BlockedImage.Empty
                    return;
                end

            catch ME

                notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(ME.message));
                return;

            end

            self.TransformFromFileMetadata=eye(4);

            vol=readFirstBlock(self.BlockedImage);

            if~isempty(vol)
                loadVolume(self,vol);
            end


        end




        function loadVolumeFromDICOMDirectory(self,directoryName)




            try


                [vol,spatialDetails,sliceDim]=dicomreadVolume(directoryName);
                vol=squeeze(vol);
                sliceLoc=spatialDetails.PatientPositions;
                allPixelSpacings=spatialDetails.PixelSpacings;

            catch ME

                notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(ME.message));
                return;

            end


            spacings=[allPixelSpacings(1,1:2),mean(diff(sliceLoc(:,sliceDim)))];
            tform=makehgtform('scale',spacings);

            self.TransformFromFileMetadata=tform;

            loadVolume(self,vol);

            self.BlockedImage.Empty=true;

        end




        function loadLabelsFromWorkspace(self,labels)



            if isa(labels,'blockedImage')
                try



                    setBlockedLabel(self.BlockedImage,labels);

                    if isempty(getBlockedLabels(self))
                        return;
                    end

                    updateBlockedLabelName(self);

                catch ME

                    notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(ME.message));
                    return;

                end
            else
                loadLabels(self,labels);
            end

        end




        function loadLabelsFromFile(self,filename)



            try


                [labels]=images.internal.app.utilities.importVolumeFromFile(filename,'VolumeSegmenter');

            catch ME

                notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(ME.message));
                return;

            end

            loadLabels(self,labels);

        end




        function loadBlockedLabelFromFile(self,filename)





            try

                bim=blockedImage(filename);



                setBlockedLabel(self.BlockedImage,bim);

                if isempty(getBlockedLabels(self))
                    return;
                end

                updateBlockedLabelName(self);

            catch ME

                notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(ME.message));
                return;

            end

        end




        function saveLabelsToWorkspace(self,var,labels,saveAsLogical,saveAsMATFile)







            try
                if self.BlockedImage.Empty

                    if saveAsLogical
                        labels=~ismissing(labels);
                    end

                    assignin('base',var,labels);

                else

                    saveToWorkspace(self.BlockedImage,var,labels,saveAsLogical);

                end

                notify(self,'LabelsSaved',images.internal.app.segmenter.volume.events.SaveEventData(var,logical.empty,saveAsMATFile));

            catch ME
                notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(ME.message));
            end

        end




        function saveLabelsToFile(self,var,labels,saveAsLogical,saveAsMATFile)






            try
                if self.BlockedImage.Empty

                    if saveAsLogical
                        labels=~ismissing(labels);
                    end

                    save(var,'labels');

                else

                    saveToFile(self.BlockedImage,var,labels,saveAsLogical);

                end

                notify(self,'LabelsSaved',images.internal.app.segmenter.volume.events.SaveEventData(var,logical.empty,saveAsMATFile));

            catch ME
                notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(ME.message));
            end

        end




        function nextBlock(self)



            vol=readNextBlock(self.BlockedImage);

            if~isempty(vol)
                loadVolume(self,vol);
            end

        end




        function previousBlock(self)




            vol=readPreviousBlock(self.BlockedImage);

            if~isempty(vol)
                loadVolume(self,vol);
            end

        end




        function readBlock(self,idx)



            vol=readBlock(self.BlockedImage,idx);

            if~isempty(vol)
                loadVolume(self,vol);
            end

        end




        function readCurrentBlock(self)

            readBlock(self,self.BlockedImage.CurrentBlockIndex);

        end




        function updateRendering(self,thresh,alpha)


            updateRendering(self.BlockedImage,thresh,alpha);
        end




        function bim=getBlockedImage(self)




            bim=self.BlockedImage.BlockedImageFile;
        end




        function bim=getBlockedLabels(self)




            bim=self.BlockedImage.ReadableBlockedLabelFile;
        end




        function bim=getWritableBlockedLabels(self)




            bim=self.BlockedImage.WritableBlockedLabelFile;
        end




        function label=getCurrentLabelBlock(self)


            label=readCurrentLabelBlock(self.BlockedImage);
        end




        function TF=isVolumeBlocked(self)




            TF=~self.BlockedImage.Empty;
        end




        function removeLabel(self,idx)


            removeLabel(self.BlockedImage,idx);
            updateBlockedLabelName(self);
        end




        function redrawBlockOverview(self)
            redrawBlockOverview(self.BlockedImage);
        end




        function regenerateBlockOverview(self,includeVolume,includeLabels,hfig,R,G,B)
            regenerateBlockOverview(self.BlockedImage,includeVolume,includeLabels,hfig,R,G,B);
        end




        function markBlockAsComplete(self,TF)
            markBlockAsComplete(self.BlockedImage,TF);
        end




        function shiftBlockIndex(self,idx,dim)

            idx=shiftBlockIndex(self.BlockedImage,idx,dim);

            if~isempty(idx)
                vol=readBlock(self.BlockedImage,idx);

                if~isempty(vol)
                    loadVolume(self,vol);
                end
            end

        end




        function pos=getVoxelLocation(self,pos,idx,dim)
            pos=getVoxelLocation(self.BlockedImage,pos,idx,dim);
        end




        function refreshLabelSource(self)
            refreshLabelSource(self.BlockedImage);
        end




        function updateBlockedLabelName(self)
            notify(self,'LabelsSaved',images.internal.app.segmenter.volume.events.SaveEventData(self.BlockedImage.LabelPath,logical.empty,true));
        end




        function convertAdapter(self,bim,loc)
            convertAdapter(self.BlockedImage,bim,loc);
            updateBlockedLabelName(self);
        end




        function markBlockAsSeen(self,idx)
            markBlockAsSeen(self.BlockedImage,idx);
        end




        function idx=getCurrentIndex(self)
            if isVolumeBlocked(self)
                idx=self.BlockedImage.CurrentIndex;
            else
                idx=[];
            end
        end




        function clear(self)
            clear(self.BlockedImage);
        end

    end

    methods(Access=private)


        function loadVolume(self,vol)

            notify(self,'VolumeLoaded',images.internal.app.segmenter.volume.events.VolumeEventData(...
            vol));

        end


        function loadLabels(self,labels)

            notify(self,'LabelsLoaded',images.internal.app.segmenter.volume.events.VolumeEventData(...
            labels));

        end


        function wireUpBlockedImage(self)

            self.BlockedImage=images.internal.app.segmenter.volume.data.BlockedImage();
            addlistener(self.BlockedImage,'ShowBlockedImageDisplay',@(src,evt)notify(self,'ShowBlockedImageDisplay',evt));
            addlistener(self.BlockedImage,'OverviewUpdated',@(src,evt)notify(self,'BlockedImageOverviewUpdated',evt));
            addlistener(self.BlockedImage,'ErrorThrown',@(src,evt)notify(self,'ErrorThrown',evt));
            addlistener(self.BlockedImage,'BlockIndexChanged',@(src,evt)notify(self,'BlockIndexChanged',evt));
            addlistener(self.BlockedImage,'CategoriesDetected',@(src,evt)notify(self,'BlockCategoriesDetected',evt));
            addlistener(self.BlockedImage,'BlockReadStarted',@(~,~)notify(self,'BlockedImageLoadingStarted'));
            addlistener(self.BlockedImage,'BlockReadFinished',@(~,~)notify(self,'BlockedImageLoadingFinished'));
            addlistener(self.BlockedImage,'CompletionPercentageUpdated',@(src,evt)notify(self,'CompletionPercentageUpdated',evt));
            addlistener(self.BlockedImage,'CompatibleAdapterRequired',@(src,evt)notify(self,'CompatibleAdapterRequired',evt));
            addlistener(self.BlockedImage,'BlockMetadataUpdated',@(src,evt)notify(self,'BlockMetadataUpdated',evt));

        end

    end

    methods




        function sz=get.OverviewBlockSize(self)
            sz=self.BlockedImage.OverviewBlockSize;
        end




        function blocks=get.CompletedBlocks(self)
            blocks=self.BlockedImage.CompletedBlocks;
        end




        function bmap=get.BlockMap(self)
            bmap=self.BlockedImage.BlockMap;
        end

    end

end