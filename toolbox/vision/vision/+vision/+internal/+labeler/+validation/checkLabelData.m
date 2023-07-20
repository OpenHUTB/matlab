function[labelData,isROILabelData]=checkLabelData(labelData,dataSource,labelDefs)







    import vision.internal.labeler.validation.*

    types=labelDefs{:,2};

    isPixelLabel=types==labelType.PixelLabel;
    isROILabelData=any(strcmp('ROILabelData',labelData.Properties.VariableNames));

    if any(isPixelLabel)
        numLabelDefs=height(labelDefs)-sum(isPixelLabel)+1;
    else
        numLabelDefs=height(labelDefs);
    end



    validDataSource=isa(dataSource,'groundTruthDataSource');
    if validDataSource
        if hasTimeStamps(dataSource)
            numTimes=numel(dataSource.TimeStamps);
            allowedLabelDataClass={'table','timetable'};
        else
            if isa(dataSource.Source,'matlab.io.datastore.ImageDatastore')
                numTimes=dataSource.Source.numobservations;
            else
                numTimes=numel(dataSource.Source);
            end
            allowedLabelDataClass={'table'};
        end

        validateattributes(labelData,allowedLabelDataClass,{'nonempty','nrows',numTimes},'groundTruth','LabelData');

    else
        validateattributes(labelData,{'table','timetable'},{'nonempty','ncols',numLabelDefs},'groundTruth','LabelData');
    end

    dataNames=labelData.Properties.VariableNames;
    defNames=labelDefs.Name;

    if any(isPixelLabel)

        pxData=strcmp(dataNames,'PixelLabelData');
        if~any(pxData)||sum(pxData)>1
            error(message('vision:groundTruth:labelDataMissingPixelLabelData'))
        end


        dataNames(pxData)=[];
        defNames(isPixelLabel)=[];
    end


    if~isempty(setdiff(dataNames,[defNames;{'ROILabelData'}]));
        error(message('vision:groundTruth:inconsistentLabelDefNames'))
    end

    labelData=validateLabelDataTableEntries(labelData,labelDefs);




    if validDataSource
        if hasTimeStamps(dataSource)
            if isa(labelData,'timetable')
                vision.internal.labeler.validation.checkTimes(labelData,dataSource);




                labelData.Time=dataSource.TimeStamps;
            else
                labelData=table2timetable(labelData,'RowTimes',dataSource.TimeStamps);
            end
        end
    end
end