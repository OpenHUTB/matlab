function[out,varargout]=read(obj,varargin)


























































































































    try

        [varargin{:}]=convertStringsToChars(varargin{:});




        if(nargin==1)||((nargin>1)&&(ischar(varargin{1})))
            out=readFile(obj,varargin{:});





        elseif istable(varargin{1})
            out=readTable(obj,varargin{:});








        else
            [out,varargout{1:nargout-1}]=readDefaultSyntax(obj,varargin{:});
        end

    catch ME
        throwAsCaller(ME);
    end
end

function[out,varargout]=readFile(obj,varargin)








    count=numel(obj.ChannelGroup);

    out=cell(count,1);

    for ii=1:count
        out{ii,1}=readDefaultSyntax(obj,ii,obj.ChannelNames{ii},varargin{:});
    end
end

function[out,varargout]=readTable(obj,varargin)








    validateattributes(varargin{1},{'table'},{},'read','CHANNELLIST');

    count=height(varargin{1});

    out=cell(count,1);

    for ii=1:count
        out{ii,1}=readDefaultSyntax(obj,varargin{1}.ChannelGroupNumber(ii),varargin{1}.ChannelName(ii),varargin{2:end});
    end
end

function[out,varargout]=readDefaultSyntax(obj,varargin)












    [varargin{:}]=convertStringsToChars(varargin{:});




    endIdxForSplitting=numel(varargin);







    for idx=numel(varargin):-1:2
        if islogical(varargin{idx})


            argBeforeLogical=varargin{idx-1};
            if ischar(argBeforeLogical)







                endIdxForSplitting=idx-2;
            else



                endIdxForSplitting=idx-1;
            end
            break;
        end
    end







    try








        numNVPairParams=splitVararginSimple(varargin{1:endIdxForSplitting});



        numNVPairParams=numNVPairParams+numel(varargin)-endIdxForSplitting;


        [pNonNVPairs,pNVPairs]=parseInput(numNVPairParams,varargin{:});
    catch












        numNVPairParams=splitVararginHeuristic(varargin{1:endIdxForSplitting});



        numNVPairParams=numNVPairParams+numel(varargin)-endIdxForSplitting;


        [pNonNVPairs,pNVPairs]=parseInput(numNVPairParams,varargin{:});
    end
    chGroupIndex=uint64(pNonNVPairs.Results.chGroupIndex);


    if chGroupIndex>numel(obj.ChannelGroup)
        error(message('asam_mdf:MDF:ChannelGroupIndexDoesNotExist'));
    end


    chNameProvided=~contains('chName',pNonNVPairs.UsingDefaults);

    if chNameProvided

        chName=pNonNVPairs.Results.chName;
    else


        chName=obj.ChannelNames{chGroupIndex};
    end


    if ischar(chName)

        chName={chName};
    elseif iscell(chName)

        chName=chName(~cellfun('isempty',chName));



        for ii=1:numel(chName)
            if~ischar(chName{ii})
                error(message('asam_mdf:MDF:ChannelNameInvalid'));
            end
        end
    end

    outputFormatValue=validatestring(lower(pNVPairs.Results.OutputFormat),lower(cellstr(enumeration('asam.mdf.OutputFormat'))));


    if any(strcmpi(outputFormatValue,{'vector','timeseries'}))&&(numel(chName)>1)
        error(message('asam_mdf:MDF:SingleChannelReadOnly'));
    end


    startPos=pNonNVPairs.Results.startPos;
    startPosProvided=~contains('startPos',pNonNVPairs.UsingDefaults);
    startPosClass=class(pNonNVPairs.Results.startPos);
    endPos=pNonNVPairs.Results.endPos;
    endPosProvided=~contains('endPos',pNonNVPairs.UsingDefaults);
    endPosClass=class(pNonNVPairs.Results.endPos);


    if startPosProvided
        if isa(startPos,'numeric')
            validateattributes(startPos,{'numeric'},{'scalar','integer','real','finite','nonnan','positive'});
        elseif isa(startPos,'duration')
            validateattributes(seconds(startPos),{'numeric'},{'scalar','real','finite','nonnan','nonnegative'});
        end
    end


    if endPosProvided
        if isa(endPos,'numeric')
            validateattributes(endPos,{'numeric'},...
            {'scalar','integer','real','nonnan','positive'});
        elseif isa(endPos,'duration')
            validateattributes(seconds(endPos),{'numeric'},...
            {'scalar','real','nonnan','nonnegative'});
        end
    end



    if startPosProvided&&endPosProvided


        if~strcmpi(startPosClass,endPosClass)
            error(message('asam_mdf:MDF:StartAndEndPositionTypeMismatch'));
        end


        if startPos>endPos
            error(message('asam_mdf:MDF:EndPositionBeforeStart'));
        end
    end


    if endPos==inf

        endPos=double(obj.ChannelGroup(chGroupIndex).NumSamples);
    end



    for ii=1:numel(chName)
        if~any(strcmp(obj.ChannelNames{chGroupIndex},chName{ii}))
            error(message('asam_mdf:MDF:ChannelNotFound',chName{ii},chGroupIndex));
        end
    end



    if strcmpi(startPosClass,'duration')


        startPos=cast(seconds(startPos)*10^9,'uint64');

        indexType=asam.mdf.ReadIndexType.Timestamp;
    else

        indexType=asam.mdf.ReadIndexType.Numeric;
    end



    if strcmpi(class(endPos),'duration')


        endPos=cast(seconds(endPos)*10^9,'uint64');
    end


    if(indexType==asam.mdf.ReadIndexType.Numeric)
        startPos=startPos-1;
        endPos=endPos-1;
    end



    if startPosProvided&&(~endPosProvided)


        endPos=startPos;
    end



    if(~startPosProvided)&&(~endPosProvided)
        indexType=asam.mdf.ReadIndexType.All;
    end


    switch outputFormatValue
    case 'vector'
        out=[];
        varargout{1}=[];
    case 'timeseries'
        out=timeseries.empty();
    case 'timetable'
        out=timetable.empty();


        chColumnNames=matlab.lang.makeValidName(chName);


        if isrow(chColumnNames)
            chColumnNames=chColumnNames';
        end




        chColumnNames=['Time';chColumnNames];



        chColumnNames=matlab.lang.makeUniqueStrings(chColumnNames,{},namelengthmax());


        chColumnNames(1)=[];
    end


    if contains('Conversion',pNVPairs.UsingDefaults)


        conversionValue=obj.Conversion;
    else



        conversionValue=pNVPairs.Results.Conversion;
        conversionValue=validatestring(conversionValue,cellstr(enumeration('asam.mdf.Conversion')));
    end


    switch(conversionValue)
    case 'Numeric'
        conversionValue=asam.mdf.Conversion.Numeric;
    case 'None'
        conversionValue=asam.mdf.Conversion.None;
    case 'All'
        conversionValue=asam.mdf.Conversion.All;
    end



    includeMetadataValue=pNVPairs.Results.IncludeMetadata;



    warnState=warning('off','backtrace');
    cleanup=onCleanup(@()warning(warnState));


    options.IndexType=asam.mdf.castReadIndexType(indexType);
    options.StartPos=asam.mdf.castReadPosition(startPos);
    options.EndPos=asam.mdf.castReadPosition(endPos);
    options.Conversion=asam.mdf.castConversion(conversionValue);


    dataStruct=mexMDF(asam.mdf.castOperationType(asam.mdf.OperationType.Read),...
    obj.Handle,...
    chGroupIndex-1,...
    string(chName),...
    options);


    columnIndex=1;
    for ii=1:numel(dataStruct)


        if dataStruct(ii).Error
            warning(message('asam_mdf:MDF:ReadFailed',chGroupIndex,chName{ii}));


            if iscell(dataStruct(ii).Data)
                dataStruct(ii).Data(dataStruct(ii).ErrorIndices+1)={missing};
            else
                dataStruct(ii).Data(dataStruct(ii).ErrorIndices+1)=missing;
            end
        end



        t=(double(dataStruct(ii).Time)*1e-9)';
        v=(dataStruct(ii).Data)';


        switch outputFormatValue
        case 'vector'
            if iscell(v)&&~ischar(v{1})
                v=cell2mat(v);
            end
            out=v;
            varargout{1}=t;

        case 'timeseries'
            if((dataStruct(ii).DataType~=asam.mdf.ChannelDataType.IntegerUnsignedLittleEndian)&&...
                (dataStruct(ii).DataType~=asam.mdf.ChannelDataType.IntegerUnsignedBigEndian)&&...
                (dataStruct(ii).DataType~=asam.mdf.ChannelDataType.IntegerSignedLittleEndian)&&...
                (dataStruct(ii).DataType~=asam.mdf.ChannelDataType.IntegerSignedBigEndian)&&...
                (dataStruct(ii).DataType~=asam.mdf.ChannelDataType.RealLittleEndian)&&...
                (dataStruct(ii).DataType~=asam.mdf.ChannelDataType.RealBigEndian)&&...
                (~isempty(v)))
                error(message('asam_mdf:MDF:TimeseriesOnlySupportsNumericChannelData'));
            end

            if~isempty(v)
                out=timeseries(v,t);
                out.Name=chName{ii};
            end

        case 'timetable'




            if(dataStruct(ii).NumSamples==0)
                out=timetable.empty();
                out.Properties.RowTimes=duration.empty(0,1);
                break;
            end

            if isrow(v)
                v=v';
            end

            if isempty(out)
                if dataStruct(ii).DataTypeSupported


                    out=timetable(seconds(t),v,'VariableNames',chColumnNames(ii));


                    out.Properties.Description=obj.ChannelGroup(chGroupIndex).AcquisitionName;
                else


                    columnIndex=columnIndex-1;
                end
            else

                out.(chColumnNames{ii})=v;
            end


            if~isempty(out)
                out.Properties.VariableDescriptions{columnIndex}=dataStruct(ii).ChannelName;
                out.Properties.VariableUnits{columnIndex}=dataStruct(ii).Unit;
            end
        end




        columnIndex=columnIndex+1;
    end



    if includeMetadataValue

        if~strcmp(outputFormatValue,'timetable')
            error(message('asam_mdf:MDF:CannotIncludeMetadataInNonTimetableOutput'));
        end


        if~isempty(out)

            channelGroupPropertyNames=asam.mdf.FileInterface.getChannelGroupPropertyNames;
            channelGroupPropertyTypes=repmat({'table'},1,numel(channelGroupPropertyNames));


            channelPropertyNames=asam.mdf.FileInterface.getChannelPropertyNames;
            channelPropertyTypes=repmat({'variable'},1,numel(channelPropertyNames));


            out=addprop(out,channelGroupPropertyNames,channelGroupPropertyTypes);
            out=addprop(out,channelPropertyNames,channelPropertyTypes);


            out.Properties.CustomProperties.ChannelGroupAcquisitionName=string(obj.ChannelGroup(chGroupIndex).AcquisitionName);
            out.Properties.CustomProperties.ChannelGroupComment=string(obj.ChannelGroup(chGroupIndex).Comment);



            srcInfo=rmfield(obj.ChannelGroup(chGroupIndex).SourceInfo,'Simulated');
            out.Properties.CustomProperties.ChannelGroupSourceInfo=srcInfo;


            out.Properties.CustomProperties.ChannelGroupSourceInfo.Name=string(out.Properties.CustomProperties.ChannelGroupSourceInfo.Name);
            out.Properties.CustomProperties.ChannelGroupSourceInfo.Path=string(out.Properties.CustomProperties.ChannelGroupSourceInfo.Path);
            out.Properties.CustomProperties.ChannelGroupSourceInfo.Comment=string(out.Properties.CustomProperties.ChannelGroupSourceInfo.Comment);


            readChannelIdx=find(ismember(obj.ChannelNames{chGroupIndex},{dataStruct.ChannelName}'));


            readChannelStruct=obj.ChannelGroup(chGroupIndex).Channel(readChannelIdx);


            out.Properties.CustomProperties.ChannelDisplayName=string({readChannelStruct.DisplayName});
            out.Properties.CustomProperties.ChannelComment=string({readChannelStruct.Comment});
            out.Properties.CustomProperties.ChannelUnit=string({readChannelStruct.Unit});
            out.Properties.CustomProperties.ChannelType=[readChannelStruct.Type];
            out.Properties.CustomProperties.ChannelDataType=[readChannelStruct.DataType];
            out.Properties.CustomProperties.ChannelNumBits=double([readChannelStruct.NumBits]);
            out.Properties.CustomProperties.ChannelComponentType=[readChannelStruct.ComponentType];
            out.Properties.CustomProperties.ChannelCompositionType=[readChannelStruct.CompositionType];



            srcInfo=rmfield([readChannelStruct.SourceInfo],'Simulated');
            out.Properties.CustomProperties.ChannelSourceInfo=srcInfo;


            for ii=1:numel(out.Properties.CustomProperties.ChannelSourceInfo)
                out.Properties.CustomProperties.ChannelSourceInfo(ii).Name=string(out.Properties.CustomProperties.ChannelSourceInfo(ii).Name);
                out.Properties.CustomProperties.ChannelSourceInfo(ii).Path=string(out.Properties.CustomProperties.ChannelSourceInfo(ii).Path);
                out.Properties.CustomProperties.ChannelSourceInfo(ii).Comment=string(out.Properties.CustomProperties.ChannelSourceInfo(ii).Comment);
            end




            out.Properties.CustomProperties.ChannelReadOption=repmat(conversionValue,1,width(out));
        end
    end

end

function numNVPairParams=splitVararginSimple(varargin)









































    numTrailingCharParams=0;
    for idx=numel(varargin):-1:1
        if ischar(varargin{idx})
            numTrailingCharParams=numTrailingCharParams+1;
        else
            break;
        end
    end

    if rem(numTrailingCharParams,2)==0



        numNVPairParams=numTrailingCharParams;
    else



        numNVPairParams=numTrailingCharParams-1;
    end
end

function numNVPairParams=splitVararginHeuristic(varargin)




















































    numTrailingCharParams=0;
    for idx=numel(varargin):-1:1
        if ischar(varargin{idx})
            numTrailingCharParams=numTrailingCharParams+1;
        else
            break;
        end
    end


    if numel(varargin)>=3







        startIdxNVPair=numel(varargin)+1;
        idxOutputFormat=startIdxNVPair;
        idxConversion=startIdxNVPair;
        idxIncludeMetadata=startIdxNVPair;







        for idx=(numel(varargin)-numTrailingCharParams+1):1:numel(varargin)

            searchKey=['^',regexptranslate('escape',lower(varargin{idx}))];

            if numel(regexp('outputformat',searchKey))==1
                idxOutputFormat=idx;

            elseif numel(regexp('conversion',searchKey))==1
                idxConversion=idx;

            elseif numel(regexp('includemetadata',searchKey))==1
                idxIncludeMetadata=idx;
            end


            startIdxNVPair=min([idxOutputFormat,idxConversion,idxIncludeMetadata]);
        end



        numNVPairParams=numel(varargin)-startIdxNVPair+1;
    else



        numNVPairParams=0;
    end
end

function[pNonNVPairs,pNVPairs]=parseInput(numNVPairParams,varargin)





    pNonNVPairs=inputParser;
    pNonNVPairs.addRequired('chGroupIndex',@(x)validateattributes(x,{'numeric'},{'scalar','integer','finite','nonnan','positive'}));

    pNonNVPairs.addOptional('chName',{},@(x)validateattributes(x,{'char','cell'},{}));
    pNonNVPairs.addOptional('startPos',1,@(x)validateattributes(x,{'duration','numeric'},{}));
    pNonNVPairs.addOptional('endPos',inf,@(x)validateattributes(x,{'duration','numeric'},{}));
    pNonNVPairs.parse(varargin{1:end-numNVPairParams})


    pNVPairs=inputParser;
    pNVPairs.addParameter('OutputFormat','timetable',@(x)any(validatestring(x,{'vector','timeseries','timetable'})));
    pNVPairs.addParameter('Conversion','numeric',@(x)any(validatestring(x,cellstr(enumeration('asam.mdf.Conversion')))));
    pNVPairs.addParameter('IncludeMetadata',false,@(x)validateattributes(x,{'logical'},{}));
    pNVPairs.parse(varargin{end-numNVPairParams+1:end});
end
