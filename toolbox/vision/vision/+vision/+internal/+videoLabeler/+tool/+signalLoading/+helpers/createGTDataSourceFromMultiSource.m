function gtSource=createGTDataSourceFromMultiSource(signalSource)

    sourceName=signalSource.SourceName;

    if isa(signalSource,'vision.labeler.loading.VideoSource')

        gtSource=groundTruthDataSource(sourceName);
    elseif isa(signalSource,'vision.labeler.loading.ImageSequenceSource')

        timestamps=signalSource.Timestamp{1};
        gtSource=groundTruthDataSource(sourceName,timestamps);

    elseif isa(signalSource,'vision.labeler.loading.CustomImageSource')

        timestamps=signalSource.Timestamp{1};
        readerFcn=signalSource.SourceParams.FunctionHandle;
        gtSource=groundTruthDataSource(sourceName,readerFcn,timestamps);

    else
        gtSource=[];
    end

end