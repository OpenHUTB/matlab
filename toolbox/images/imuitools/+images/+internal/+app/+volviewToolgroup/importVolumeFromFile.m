function[V,scaleTform]=importVolumeFromFile(filename)



    scaleTform=[];
    if contains(filename,'.tif')

        V=readTiffStack(filename);
    elseif contains(filename,'.nrrd')
        [V,scaleTform]=readNRRD(filename);
    elseif contains(filename,'.dcm')
        [V,scaleTform]=readDicom(filename);
    elseif contains(filename,{'.nii','.nii.gz'})
        [V,scaleTform]=readNIFTI(filename);
    elseif contains(filename,'.hdr')
        [V,scaleTform]=readAnalyze(filename);
    else
        [V,scaleTform]=readFileWithUnknownFormat(filename);
    end

    if~images.internal.app.volviewToolgroup.isVolume(V)
        ME=MException('images:volumeViewerRequiresVolumeData',...
        getString(message('images:volumeViewerToolgroup:requireVolumeData')));
        throw(ME);
    end

end


function[V,tform]=readFileWithUnknownFormat(filename)

    try
        s=warning('off');
        c=onCleanup(@()warning(s));
        [V,tform]=readDicom(filename);
    catch
        throwInvalidFileException('')
    end

end

function[V,tform]=readNRRD(filename)

    try
        [V,meta]=images.internal.app.volviewToolgroup.fileformats.nrrdread(filename);
    catch
        throwInvalidFileException('NRRD');
    end

    if isfield(meta,'spacedirections')
        directionsStr=meta.spacedirections;
        directionsStr=strsplit(directionsStr,{'(',')',',',' '});
        emptyInd=cellfun(@(c)isempty(c),directionsStr);
        directionsStr(emptyInd)=[];
        directions=abs(cellfun(@(c)str2double(c),directionsStr));
        directions=reshape(directions,[3,3]);
        if~isdiag(directions)||any(~isfinite(directions(:)))


            tform=[];
        else
            directionsDiag=diag(directions);
            minVoxelSize=min(directionsDiag);
            scale=directionsDiag./minVoxelSize;
            tform=makehgtform('scale',scale);
        end
    else
        tform=[];
    end

end

function[V,tform]=readNIFTI(filename)
    try
        info=niftiinfo(filename);
        V=niftiread(filename);
    catch
        throwInvalidFileException('NIFTI');
    end

    if isfield(info,'PixelDimensions')
        pixelDims=info.PixelDimensions(1:3);
        scaleFactors=pixelDims./min(pixelDims);
        tform=makehgtform('scale',scaleFactors);
    end

end

function V=readTiffStack(filename)

    try
        info=imfinfo(filename);
        numSlices=length(info);
        numColumns=info.Width;
        numRows=info.Height;

        V=zeros([numRows,numColumns,numSlices],'uint8');

        for zSlice=1:length(info)
            V(:,:,zSlice)=imread(filename,'Index',zSlice);
        end
    catch
        throwInvalidFileException('TIFF');
    end

end

function[V,tform]=readDicom(filename)

    V=[];
    try
        [V,spatialDetails,sliceDim]=dicomreadVolume(filename);
        V=squeeze(V);

        sliceLoc=spatialDetails.PatientPositions;
        allPixelSpacings=spatialDetails.PixelSpacings;

        xSpacing=allPixelSpacings(1,1);
        ySpacing=allPixelSpacings(1,2);
        zSpacing=mean(diff(sliceLoc(:,sliceDim)));
        spacings=[xSpacing,ySpacing,zSpacing];
        spacings=spacings./min(spacings);
        tform=makehgtform('scale',spacings);
        return
    catch
    end

    try
        if isempty(V)
            V=squeeze(dicomread(filename));
        end
        info=dicominfo(filename);
    catch
        throwInvalidFileException('DICOM');
    end

    tform=[];
    if isfield(info,'PixelSpacing')&&isfield(info,'SliceThickness')
        spacings=[info.PixelSpacing;info.SliceThickness];
        scale=spacings./min(spacings);
        tform=makehgtform('scale',scale);
    end

end

function[V,tform]=readAnalyze(filename)

    try
        metadata=analyze75info(filename);
        V=analyze75read(metadata);
    catch
        throwInvalidFileException('Analyze 7.5');
    end

    if isfield(metadata,'PixelDimensions')
        pixelDims=metadata.PixelDimensions;
        scaleFactors=pixelDims./min(pixelDims);
        tform=makehgtform('scale',scaleFactors);
    end

end

function throwInvalidFileException(fileTypeStr)
    ME=MException('images:invalidFile',getString(message('images:volumeViewerToolgroup:invalidFileWithFormat',fileTypeStr)));
    throw(ME);
end

