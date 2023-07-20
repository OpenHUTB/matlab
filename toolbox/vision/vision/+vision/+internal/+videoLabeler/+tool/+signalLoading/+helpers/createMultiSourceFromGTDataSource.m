function signalSource=createMultiSourceFromGTDataSource(gtDataSource)

    sourceType=gtDataSource.SourceType;

    if sourceType==vision.internal.labeler.DataSourceType.VideoReader
        fullFileName=gtDataSource.Source;
        signalSource=vision.labeler.loading.VideoSource();
        signalSource.loadSource(fullFileName,[]);
    elseif sourceType==vision.internal.labeler.DataSourceType.ImageSequence
        [pathname,~]=fileparts(gtDataSource.Source{1});
        timeStamps=gtDataSource.TimeStamps;
        signalSource=vision.labeler.loading.ImageSequenceSource();
        signalSource.setTimestamps(timeStamps);
        signalSource.loadSource(pathname,[]);
    elseif sourceType==vision.internal.labeler.DataSourceType.CustomReader

        timestamps=gtDataSource.TimeStamps;
        sourceName=gtDataSource.Source;
        fcnHandle=gtDataSource.Reader.Reader;

        signalSource=vision.labeler.loading.CustomImageSource();
        signalSource.setTimestamps(timestamps);

        sourceParams=struct();
        sourceParams.FunctionHandle=fcnHandle;

        signalSource.loadSource(sourceName,sourceParams);
    elseif sourceType==vision.internal.labeler.DataSourceType.ImageDatastore
        exception=MException('GTL:UnableToLoadLabels',message('vision:labeler:ImportingImageLabelsUnsupported'));
        throw(exception);
    else
        assert(false,"Invalid source type");
    end

end