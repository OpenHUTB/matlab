classdef FileInterface





    properties(Constant)
        MDFVersions={'3.00','3.10','3.20','3.30','4.00','4.10','4.20'}
        ChannelGroupPropertyNames={'ChannelGroupAcquisitionName','ChannelGroupComment','ChannelGroupSourceInfo'}
        ChannelPropertyNames={'ChannelDisplayName','ChannelComment','ChannelUnit','ChannelType','ChannelDataType',...
        'ChannelNumBits','ChannelComponentType','ChannelCompositionType','ChannelSourceInfo','ChannelReadOption'}
        FileInfoStructFields={'Author','Department','Project','Subject','Comment','Version','InitialTimestamp','Creator'}
        FileInfoCreatorStructFields={'UserName','Comment'}
    end

    methods(Static,Access=public)
        function handle=Open(filePath,varargin)



            asam.mdf.FileInterface.platformCheck();


            p=inputParser;
            p.addRequired('filePath',@(x)validateattributes(x,{'char'},{'nonempty','row'}));
            p.addParameter('MathWorksMDFInternalControl','BlockControlledAccess');
            p.addParameter('Writable',false,@(x)validateattributes(x,{'logical'},{}));
            p.parse(filePath,varargin{:});


            if string(p.Results.MathWorksMDFInternalControl)~="AllowControlledAccess"
                asam.mdf.FileInterface.licenseCheck();
            end



            handle=mexMDF(asam.mdf.castOperationType(asam.mdf.OperationType.Open),char(filePath),p.Results.Writable);
        end

        function[creatorDetailsStruct,fileDetailsStruct,attachmentDetailsStruct,chanGrpDetailsStruct]=Parse(handle)



            asam.mdf.FileInterface.platformCheck();


            [creatorDetailsStruct,fileDetailsStruct,attachmentDetailsStruct,chanGrpDetailsStruct]=mexMDF(asam.mdf.castOperationType(asam.mdf.OperationType.Parse),handle);


            fileDetailsStruct=asam.mdf.FileInterface.prepareFileDetails(fileDetailsStruct);


            attachmentDetailsStruct=asam.mdf.FileInterface.prepareAttachmentDetails(attachmentDetailsStruct);


            chanGrpDetailsStruct=asam.mdf.FileInterface.prepareChannelGroupDetails(chanGrpDetailsStruct);

        end

        function dataStruct=Read(handle,channelGroupIndex,channelName,indexType,startPos,endPos)



            asam.mdf.FileInterface.platformCheck();

            dataStruct=mexMDF(asam.mdf.castOperationType(asam.mdf.OperationType.Read),handle,channelGroupIndex-1,string(channelName),asam.mdf.castReadIndexType(indexType),startPos,endPos);
        end

        function SaveAttachment(handle,attachmentIndex,destination)



            asam.mdf.FileInterface.platformCheck();


            asam.mdf.FileInterface.licenseCheck();



            mexMDF(asam.mdf.castOperationType(asam.mdf.OperationType.SaveAttachment),handle,attachmentIndex-1,destination);
        end

        function Close(handle)



            asam.mdf.FileInterface.platformCheck();



            if~isempty(handle)
                mexMDF(asam.mdf.castOperationType(asam.mdf.OperationType.Close),handle);
            end
        end

        function mdfDetails=Info(varargin)



            asam.mdf.FileInterface.platformCheck();


            asam.mdf.FileInterface.licenseCheck();


            p=inputParser;
            p.addOptional('file',{},@(x)validateattributes(x,{'char'},{'nonempty','row'},'MDFINFO','FILE'));
            p.parse(varargin{:});


            switch nargin
            case 0


                mdfDetails=struct(...
                'Author','',...
                'Department','',...
                'Project','',...
                'Subject','',...
                'Comment','',...
                'Version',asam.mdf.FileInterface.getLatestMDFVersion,...
                'InitialTimestamp',NaT,...
                'Creator',struct);
                mdfDetails.Creator.UserName='';
                mdfDetails.Creator.Comment='';

            case 1

                file=p.Results.file;


                [fileName,fileFullPath]=asam.mdf.FileInterface.validateMDFFilePath(file);


                mdfDetails.Name=fileName;
                mdfDetails.Path=fileFullPath;



                mdfHandle=asam.mdf.FileInterface.Open(char(fileFullPath));


                [creatorDetailsStruct,fileDetailsStruct,attachmentDetailsStruct]=mexMDF(asam.mdf.castOperationType(asam.mdf.OperationType.Info),mdfHandle);


                fileDetailsStruct=asam.mdf.FileInterface.prepareFileDetails(fileDetailsStruct);


                mdfDetails.Author=fileDetailsStruct.Author;
                mdfDetails.Department=fileDetailsStruct.Department;
                mdfDetails.Project=fileDetailsStruct.Project;
                mdfDetails.Subject=fileDetailsStruct.Subject;
                mdfDetails.Comment=fileDetailsStruct.Comment;
                mdfDetails.Version=fileDetailsStruct.Version;
                mdfDetails.ProgramIdentifier=fileDetailsStruct.ProgramIdentifier;
                mdfDetails.InitialTimestamp=fileDetailsStruct.InitialTimestamp;
                mdfDetails.ChannelGroupCount=fileDetailsStruct.ChannelGroupCount;


                mdfDetails.Creator=creatorDetailsStruct;


                mdfDetails.Attachment=asam.mdf.FileInterface.prepareAttachmentDetails(attachmentDetailsStruct);


                asam.mdf.FileInterface.Close(mdfHandle);
            end
        end

        function sortedFilePath=Sort(srcFile,varargin)




            asam.mdf.FileInterface.platformCheck();


            asam.mdf.FileInterface.licenseCheck();


            p=inputParser;
            p.addRequired('srcFile',@(x)validateattributes(x,{'char'},{'nonempty','row'}));
            p.addOptional('destFile',[],@(x)validateattributes(x,{'char'},{'nonempty','row'}));
            p.parse(srcFile,varargin{:});


            warnState=warning('off','backtrace');
            cleanup=onCleanup(@()warning(warnState));


            [srcFileFullPath,destFileFullPath]=asam.mdf.FileInterface.getSrcDestFileFullPath(srcFile,p.Results.destFile);

            try

                mexMDF(asam.mdf.castOperationType(asam.mdf.OperationType.Sort),srcFileFullPath,destFileFullPath);
            catch ME
                if strcmpi(ME.identifier,'asam_mdf:MDF:FileAlreadySorted')
                    if strcmp(srcFileFullPath,destFileFullPath)


                        warning(message('asam_mdf:MDF:FileAlreadySortedInPlace'));
                    else



                        try
                            copyfile(srcFileFullPath,destFileFullPath);
                        catch ME

                            if strcmpi(ME.identifier,'MATLAB:COPYFILE:ReadOnly')
                                error(message('asam_mdf:MDF:FileCreateError'));
                            else
                                rethrow(ME);
                            end
                        end
                        warning(message('asam_mdf:MDF:FileAlreadySortedOutOfPlace'));
                    end
                else
                    rethrow(ME);
                end
            end



            sortedFilePath=destFileFullPath;
        end

        function finalizedFilePath=Finalize(srcFile,varargin)




            asam.mdf.FileInterface.platformCheck();


            asam.mdf.FileInterface.licenseCheck();


            p=inputParser;
            p.addRequired('srcFile',@(x)validateattributes(x,{'char'},{'nonempty','row'}));
            p.addOptional('destFile',[],@(x)validateattributes(x,{'char'},{'nonempty','row'}));
            p.parse(srcFile,varargin{:});


            warnState=warning('off','backtrace');
            cleanup=onCleanup(@()warning(warnState));


            [srcFileFullPath,destFileFullPath]=asam.mdf.FileInterface.getSrcDestFileFullPath(srcFile,p.Results.destFile);

            try

                mexMDF(asam.mdf.castOperationType(asam.mdf.OperationType.Finalize),srcFileFullPath,destFileFullPath);
            catch ME
                if strcmpi(ME.identifier,'asam_mdf:MDF:FileAlreadyFinalized')
                    if strcmp(srcFileFullPath,destFileFullPath)


                        warning(message('asam_mdf:MDF:FileAlreadyFinalizedInPlace'));
                    else



                        try
                            copyfile(srcFileFullPath,destFileFullPath);
                        catch ME

                            if strcmpi(ME.identifier,'MATLAB:COPYFILE:ReadOnly')
                                error(message('asam_mdf:MDF:FileCreateError'));
                            else
                                rethrow(ME);
                            end
                        end
                        warning(message('asam_mdf:MDF:FileAlreadyFinalizedOutOfPlace'));
                    end
                else
                    rethrow(ME);
                end
            end



            finalizedFilePath=destFileFullPath;
        end

        function createdFilePath=Create(filePath,fileInfo)



            asam.mdf.FileInterface.platformCheck();


            asam.mdf.FileInterface.licenseCheck();


            warnState=warning('off','backtrace');
            cleanup=onCleanup(@()warning(warnState));


            filePathTest=[];%#ok<NASGU> 
            try
                filePathTest=asam.mdf.FileInterface.validateDestMDFFilePath(filePath);
            catch ME
                rethrow(ME);
            end



            if~isempty(filePathTest)
                error(message('asam_mdf:MDF:FileAlreadyExists'));
            end


            if asam.mdf.FileInterface.isAbsoluteFilePath(filePath)
                fileFullPath=filePath;
            else

                fileFullPath=fullfile(pwd,filePath);
            end

            [fileDir,~,fileExt]=fileparts(fileFullPath);



            if~isempty(fileInfo)

                for ii=1:numel(asam.mdf.FileInterface.FileInfoStructFields)
                    if~isfield(fileInfo,asam.mdf.FileInterface.FileInfoStructFields{ii})
                        error(message('asam_mdf:MDF:FileInfoStructMissingField',asam.mdf.FileInterface.FileInfoStructFields{ii}));
                    end
                end

                for ii=1:numel(asam.mdf.FileInterface.FileInfoCreatorStructFields)
                    if~isfield(fileInfo.Creator,asam.mdf.FileInterface.FileInfoCreatorStructFields{ii})
                        error(message('asam_mdf:MDF:FileInfoStructMissingField',['Creator.',asam.mdf.FileInterface.FileInfoCreatorStructFields{ii}]));
                    end
                end


                validateattributes(fileInfo.Author,{'char','string'},{},'mdfCreate','Author')
                validateattributes(fileInfo.Department,{'char','string'},{},'mdfCreate','Department')
                validateattributes(fileInfo.Project,{'char','string'},{},'mdfCreate','Project')
                validateattributes(fileInfo.Subject,{'char','string'},{},'mdfCreate','Subject')
                validateattributes(fileInfo.Comment,{'char','string'},{},'mdfCreate','Comment')
                validateattributes(fileInfo.Version,{'char','string'},{},'mdfCreate','Version')
                validateattributes(fileInfo.InitialTimestamp,{'datetime'},{},'mdfCreate','InitialTimestamp')
                validateattributes(fileInfo.Creator,{'struct'},{'nonempty'},'mdfCreate','Creator')
                validateattributes(fileInfo.Creator.UserName,{'char','string'},{},'mdfCreate','Creator.UserName')
                validateattributes(fileInfo.Creator.Comment,{'char','string'},{},'mdfCreate','Creator.Comment')

                try

                    mustBeMember(fileInfo.Version,asam.mdf.FileInterface.MDFVersions);

                catch ME
                    if strcmpi(ME.identifier,'MATLAB:validators:mustBeMember')
                        validVersionsText=['''',strjoin(asam.mdf.FileInterface.MDFVersions,''' '''),''''];
                        error(message('asam_mdf:MDF:InvalidVersion',validVersionsText));
                    end


                    rethrow(ME);
                end
            else
                if any(strcmpi(fileExt,{'.mf4'}))

                    fileInfo=mdfInfo;
                elseif any(strcmpi(fileExt,{'.dat','.mdf'}))

                    fileInfo=mdfInfo;
                    fileInfo.Version='3.30';
                end
            end


            fileDetailsStruct.Author=char(fileInfo.Author);
            fileDetailsStruct.Department=char(fileInfo.Department);
            fileDetailsStruct.Project=char(fileInfo.Project);
            fileDetailsStruct.Subject=char(fileInfo.Subject);
            fileDetailsStruct.Comment=char(fileInfo.Comment);


            fileDetailsStruct.VersionNumber=uint16(str2double(fileInfo.Version)*100);




            if isnat(fileInfo.InitialTimestamp)




                fileDetailsStruct.InitialTimestamp=intmax('uint64');



                fileDetailsStruct.TimeZoneUnset=true;
                fileDetailsStruct.TimeZoneOffsetMin=int32(0);
                fileDetailsStruct.DSTOffsetMin=int32(0);
            else

                fileDetailsStruct.InitialTimestamp=uint64(posixtime(fileInfo.InitialTimestamp)*(10^9));

                if isempty(fileInfo.InitialTimestamp.TimeZone)

                    fileDetailsStruct.TimeZoneUnset=true;


                    fileDetailsStruct.TimeZoneOffsetMin=int32(0);
                    fileDetailsStruct.DSTOffsetMin=int32(0);
                else

                    fileDetailsStruct.TimeZoneUnset=false;



                    [dt,dst]=tzoffset(fileInfo.InitialTimestamp);
                    fileDetailsStruct.TimeZoneOffsetMin=int32(minutes(dt-dst));
                    fileDetailsStruct.DSTOffsetMin=int32(minutes(dst));
                end
            end


            creatorDetailsStruct.UserName=char(fileInfo.Creator.UserName);
            creatorDetailsStruct.Comment=char(fileInfo.Creator.Comment);


            creatorDetailsStruct.ToolVersion=version;


            if(fileDetailsStruct.VersionNumber>=400)

                if~any(strcmpi(fileExt,{'.mf4'}))
                    error(message('asam_mdf:MDF:FileExtensionAndVersionMismatch'));
                end
            else

                if~any(strcmpi(fileExt,{'.dat','.mdf'}))
                    error(message('asam_mdf:MDF:FileExtensionAndVersionMismatch'));
                end
            end


            if~exist(fileDir,'dir')
                try
                    mkdir(fileDir)
                catch ME
                    rethrow(ME);
                end
            end

            try

                mexMDF(asam.mdf.castOperationType(asam.mdf.OperationType.Create),char(fileFullPath),fileDetailsStruct,creatorDetailsStruct);
            catch ME
                rethrow(ME);
            end

            createdFilePath=string(fileFullPath);



            if(fileDetailsStruct.VersionNumber<400)&&(~isempty(creatorDetailsStruct.UserName)||~isempty(creatorDetailsStruct.Comment))
                warning(message('asam_mdf:MDF:MDF3MetadataNotApplicable','creator','file'));
            end
        end

        function Write(handle,data,groupNumber,mdfDetails)



            asam.mdf.FileInterface.platformCheck();


            asam.mdf.FileInterface.licenseCheck();


            mdfVersion=str2double(mdfDetails.Version);


            isMDF3=(mdfVersion<4.00);



            if isempty(groupNumber)
                groupNumber=mdfDetails.ChannelGroupCount+1;
            end



            if(groupNumber>mdfDetails.ChannelGroupCount)
                overwrite=false;
            else
                overwrite=true;
            end




            if overwrite&&isempty(properties(data.Properties.CustomProperties))
                error(message('asam_mdf:MDF:CannotOverwriteChannelGroupWithoutMetadata'));
            end




            if~overwrite

                if~isprop(data.Properties.CustomProperties,'ChannelReadOption')
                    data=addprop(data,'ChannelReadOption','variable');
                end



                data.Properties.CustomProperties.ChannelReadOption=repmat(asam.mdf.Conversion.Missing,1,width(data));
            end


            tt=mdfAddChannelGroupMetadata(data);


            varNames=tt.Properties.VariableNames;
            chNames=varNames;
            for ii=1:numel(chNames)





                if~isempty(tt.Properties.VariableDescriptions)&&~isempty(tt.Properties.VariableDescriptions{ii})
                    chNames{ii}=tt.Properties.VariableDescriptions{ii};
                end
            end


            tt=addprop(tt,'ChannelWriteMethod','variable');
            tt.Properties.CustomProperties.ChannelWriteMethod=repmat(asam.mdf.WriteMethod.Missing,1,width(tt));

            if(overwrite)





                chanDetailsStruct=asam.mdf.FileInterface.Peek(handle,groupNumber-1);



                for ii=1:numel(chanDetailsStruct)

                    chName=chanDetailsStruct(ii).Name;



                    idx=find(strcmp(chNames,chName));






                    if isempty(idx)

                        if(chanDetailsStruct(ii).Type~=asam.mdf.ChannelType.Master)||(chanDetailsStruct(ii).SyncType~=asam.mdf.ChannelSyncType.Time)
                            warning(message('asam_mdf:MDF:ChannelRemovedWhenOverwriting',chName));
                        end
                        continue;
                    end


                    varName=varNames{idx};


                    if(chanDetailsStruct(ii).Type~=tt.Properties.CustomProperties.ChannelType(idx))
                        error(message('asam_mdf:MDF:CannotModifyMetadataWhenOverwriting','ChannelType',varName,'"'+string(chanDetailsStruct(ii).Type)+'"'));
                    end
                    if(chanDetailsStruct(ii).DataType~=tt.Properties.CustomProperties.ChannelDataType(idx))
                        error(message('asam_mdf:MDF:CannotModifyMetadataWhenOverwriting','ChannelDataType',varName,'"'+string(chanDetailsStruct(ii).DataType)+'"'));
                    end
                    if(chanDetailsStruct(ii).NumBits~=tt.Properties.CustomProperties.ChannelNumBits(idx))
                        error(message('asam_mdf:MDF:CannotModifyMetadataWhenOverwriting','ChannelNumBits',varName,chanDetailsStruct(ii).NumBits));
                    end
                    if(chanDetailsStruct(ii).ComponentType~=tt.Properties.CustomProperties.ChannelComponentType(idx))
                        error(message('asam_mdf:MDF:CannotModifyMetadataWhenOverwriting','ChannelComponentType',varName,'"'+string(chanDetailsStruct(ii).ComponentType)+'"'));
                    end
                    if(chanDetailsStruct(ii).CompositionType~=tt.Properties.CustomProperties.ChannelCompositionType(idx))
                        error(message('asam_mdf:MDF:CannotModifyMetadataWhenOverwriting','ChannelCompositionType',varName,'"'+string(chanDetailsStruct(ii).CompositionType)+'"'));
                    end


                    conversionType=chanDetailsStruct(ii).ConversionType;
                    readOption=tt.Properties.CustomProperties.ChannelReadOption(idx);

                    if((conversionType>=asam.mdf.ChannelConversionType.Linear)&&(conversionType<=asam.mdf.ChannelConversionType.ValueRangeToValue))||...
                        (conversionType>=asam.mdf.ChannelConversionType.Polynomial)&&(conversionType<=asam.mdf.ChannelConversionType.Logarithmic)

                        if(readOption==asam.mdf.Conversion.Numeric)||(readOption==asam.mdf.Conversion.All)
                            tt.Properties.CustomProperties.ChannelWriteMethod(idx)=asam.mdf.WriteMethod.FunctionWritePhysValueDouble;
                        end

                    elseif(conversionType==asam.mdf.ChannelConversionType.ValueToText)...
                        ||(conversionType==asam.mdf.ChannelConversionType.ValueRangeToText)...
                        ||(conversionType==asam.mdf.ChannelConversionType.TextToText)

                        if readOption==asam.mdf.Conversion.All
                            tt.Properties.CustomProperties.ChannelWriteMethod(idx)=asam.mdf.WriteMethod.FunctionWritePhysValueString;
                        end

                    elseif(conversionType==asam.mdf.ChannelConversionType.TextToValue)

                        if readOption==asam.mdf.Conversion.All
                            tt.Properties.CustomProperties.ChannelWriteMethod(idx)=asam.mdf.WriteMethod.FunctionWritePhysValueDouble;
                        end
                    end
                end
            end

            for ii=1:width(tt)


                if isnan(tt.Properties.CustomProperties.ChannelWriteMethod(ii))
                    dataType=tt.Properties.CustomProperties.ChannelDataType(ii);
                    switch dataType
                    case{asam.mdf.ChannelDataType.IntegerUnsignedLittleEndian,...
                        asam.mdf.ChannelDataType.IntegerUnsignedBigEndian,...
                        asam.mdf.ChannelDataType.IntegerSignedLittleEndian,...
                        asam.mdf.ChannelDataType.IntegerSignedBigEndian}

                        tt.Properties.CustomProperties.ChannelWriteMethod(ii)=asam.mdf.WriteMethod.FunctionWriteRawValueInt64;
                    case{asam.mdf.ChannelDataType.RealLittleEndian,...
                        asam.mdf.ChannelDataType.RealBigEndian}

                        tt.Properties.CustomProperties.ChannelWriteMethod(ii)=asam.mdf.WriteMethod.FunctionWriteRawValueDouble;
                    case{asam.mdf.ChannelDataType.StringASCII,...
                        asam.mdf.ChannelDataType.StringUTF8,...
                        asam.mdf.ChannelDataType.StringUTF16LittleEndian,...
                        asam.mdf.ChannelDataType.StringUTF16BigEndian}

                        tt.Properties.CustomProperties.ChannelWriteMethod(ii)=asam.mdf.WriteMethod.FunctionWriteRawValueString;
                    case asam.mdf.ChannelDataType.ByteArray

                        tt.Properties.CustomProperties.ChannelWriteMethod(ii)=asam.mdf.WriteMethod.FunctionWriteRawValueByteArray;
                    end
                end
            end



            if isdatetime(tt.Properties.RowTimes)


                if any(isnat(tt.Properties.RowTimes))
                    error(message('asam_mdf:MDF:TimetableMissingRowTimes'));
                end



                try
                    relativeTime=tt.Properties.RowTimes-mdfDetails.InitialTimestamp;
                catch ME


                    if strcmpi(ME.identifier,'MATLAB:datetime:IncompatibleTZ')
                        error(message('asam_mdf:MDF:CannotGetDurationFromRowTimes'));
                    end


                    rethrow(ME);
                end


                tt.Properties.RowTimes=relativeTime;
            end


            if any(isnan(tt.Properties.RowTimes))
                error(message('asam_mdf:MDF:TimetableMissingRowTimes'));
            end



            if~issorted(tt.Properties.RowTimes,'ascend')
                error(message('asam_mdf:MDF:RowTimesNotMonotonicallyIncreasing'));
            end


            chTypes=tt.Properties.CustomProperties.ChannelType;
            masterChIdx=find(chTypes==asam.mdf.ChannelType.Master);
            masterChNameRemoved='';
            if isempty(masterChIdx)


                chGrpStruct.TimeData=seconds(tt.Properties.RowTimes)';
            elseif(numel(masterChIdx)>1)

                error(message('asam_mdf:MDF:MultipleMasterChannelsNotSupported'));
            else



                chGrpStruct.TimeData=seconds(tt.Properties.RowTimes)';


                masterChNameRemoved=tt.Properties.VariableNames{masterChIdx};






                if~isempty(tt.Properties.VariableDescriptions)&&~isempty(tt.Properties.VariableDescriptions{masterChIdx})
                    masterChNameRemoved=tt.Properties.VariableDescriptions{masterChIdx};
                end


                tt=removevars(tt,masterChIdx);


                chNames(masterChIdx)=[];


                warning(message('asam_mdf:MDF:MasterChannelDisregarded',masterChNameRemoved));
            end


            chGrpStruct.TimeData=int64(chGrpStruct.TimeData*(10^9));
            if isempty(masterChNameRemoved)
                chGrpStruct.TimeChannelName='time';
            else
                chGrpStruct.TimeChannelName=char(masterChNameRemoved);
            end


            customProps=tt.Properties.CustomProperties;


            numVars=width(tt);


            if isMDF3


                if any(customProps.ChannelType==asam.mdf.ChannelType.VariableLength)
                    error(message('asam_mdf:MDF:InvalidCustomPropertyValueForMDFVersion','ChannelType','"VariableLength"','3'));
                end


                if any(customProps.ChannelDataType==asam.mdf.ChannelDataType.StringUTF8)...
                    ||any(customProps.ChannelDataType==asam.mdf.ChannelDataType.StringUTF16LittleEndian)...
                    ||any(customProps.ChannelDataType==asam.mdf.ChannelDataType.StringUTF16BigEndian)
                    error(message('asam_mdf:MDF:InvalidCustomPropertyValueForMDFVersion','ChannelDataType','"StringUTF8", "StringUTF16LittleEndian" or "StringUTF16BigEndian"','3'));
                end


                if any([customProps.ChannelSourceInfo.SourceType]==asam.mdf.SourceType.Other)...
                    ||any([customProps.ChannelSourceInfo.SourceType]>asam.mdf.SourceType.Bus)
                    error(message('asam_mdf:MDF:InvalidCustomPropertyValueForMDFVersion','ChannelSourceInfo.SourceType','"Other", "IODevice", "Tool" or "User"','3'));
                end

                for varIdx=1:numVars


                    varName=tt.Properties.VariableNames{varIdx};


                    if(customProps.ChannelSourceInfo(varIdx).SourceType==asam.mdf.SourceType.ECU)...
                        &&(customProps.ChannelSourceInfo(varIdx).BusType~=asam.mdf.SourceBusType.None)
                        error(message('asam_mdf:MDF:MDF3InvalidChannelSourceBusType','ChannelSourceInfo.SourceBusType',varName,'"None"','"ECU"'));
                    end


                    if(customProps.ChannelSourceInfo(varIdx).SourceType==asam.mdf.SourceType.Bus)...
                        &&(customProps.ChannelSourceInfo(varIdx).BusType~=asam.mdf.SourceBusType.Other)
                        error(message('asam_mdf:MDF:MDF3InvalidChannelSourceBusType','ChannelSourceInfo.SourceBusType',varName,'"Other"','"Bus"'));
                    end
                end
            end


            chGrpStruct.GroupNumber=uint64(groupNumber-1);
            chGrpStruct.AcquisitionName=char(customProps.ChannelGroupAcquisitionName);
            chGrpStruct.Comment=char(customProps.ChannelGroupComment);
            chGrpStruct.SourceInfo=customProps.ChannelGroupSourceInfo;
            chGrpStruct.SourceInfo.Name=char(chGrpStruct.SourceInfo.Name);
            chGrpStruct.SourceInfo.Path=char(chGrpStruct.SourceInfo.Path);
            chGrpStruct.SourceInfo.Comment=char(chGrpStruct.SourceInfo.Comment);
            chGrpStruct.SourceInfo.SourceType=int32(chGrpStruct.SourceInfo.SourceType);
            chGrpStruct.SourceInfo.BusType=int32(chGrpStruct.SourceInfo.BusType);
            chGrpStruct.SourceInfo.BusChannelNumber=uint32(chGrpStruct.SourceInfo.BusChannelNumber);


            for ii=1:numel(chNames)
                chStructs(ii).ChannelName=char(chNames{ii});
                chStructs(ii).DisplayName=char(customProps.ChannelDisplayName(ii));
                chStructs(ii).Comment=char(customProps.ChannelComment(ii));
                chStructs(ii).Unit=char(customProps.ChannelUnit(ii));
                chStructs(ii).Type=int32(customProps.ChannelType(ii));
                chStructs(ii).DataType=int32(customProps.ChannelDataType(ii));
                chStructs(ii).NumBits=uint32(customProps.ChannelNumBits(ii));
                chStructs(ii).SourceInfo=customProps.ChannelSourceInfo(ii);
                chStructs(ii).SourceInfo.Name=char(chStructs(ii).SourceInfo.Name);
                chStructs(ii).SourceInfo.Path=char(chStructs(ii).SourceInfo.Path);
                chStructs(ii).SourceInfo.Comment=char(chStructs(ii).SourceInfo.Comment);
                chStructs(ii).SourceInfo.SourceType=int32(chStructs(ii).SourceInfo.SourceType);
                chStructs(ii).SourceInfo.BusType=int32(chStructs(ii).SourceInfo.BusType);
                chStructs(ii).SourceInfo.BusChannelNumber=uint32(chStructs(ii).SourceInfo.BusChannelNumber);
                chStructs(ii).WriteMethod=uint8(customProps.ChannelWriteMethod(ii));

                if chStructs(ii).WriteMethod==uint8(asam.mdf.WriteMethod.FunctionWritePhysValueDouble)
                    chStructs(ii).DataType=int32(asam.mdf.ChannelDataType.RealLittleEndian);
                elseif chStructs(ii).WriteMethod==uint8(asam.mdf.WriteMethod.FunctionWritePhysValueString)
                    chStructs(ii).DataType=int32(asam.mdf.ChannelDataType.StringASCII);
                end

                if isstring(tt.(ii))
                    chStructs(ii).Data=cellstr(tt.(ii))';
                elseif iscell(tt.(ii))&&isstring(tt.(ii){1})
                    chStructs(ii).Data=cellfun(@cellstr,tt.(ii))';
                elseif isa(tt.(ii),'uint8')&&(chStructs(ii).DataType==int32(asam.mdf.ChannelDataType.ByteArray))

                    chStructs(ii).Data=mat2cell(tt.(ii),ones(1,height(tt.(ii))));
                else
                    chStructs(ii).Data=tt.(ii)';
                end
            end


            mexMDF(asam.mdf.castOperationType(asam.mdf.OperationType.Write),handle,chGrpStruct,chStructs);


            mexMDF(asam.mdf.castOperationType(asam.mdf.OperationType.SetFileHistory),handle,version);


            if isMDF3


                if~strcmp(customProps.ChannelGroupAcquisitionName,"")
                    warning(message('asam_mdf:MDF:MDF3MetadataNotApplicable','acquisition name','channel group'));
                end


                defaultSourceInfo=asam.mdf.FileInterface.getDefaultSourceInfoStruct();
                if~isequal(customProps.ChannelGroupSourceInfo,defaultSourceInfo)
                    warning(message('asam_mdf:MDF:MDF3MetadataNotApplicable','source info','channel group'));
                end


                if any(~strcmp([customProps.ChannelSourceInfo.Path],""))
                    warning(message('asam_mdf:MDF:MDF3MetadataNotApplicable','source info path','channel'));
                end
            end
        end

        function AddAttachment(handle,attachmentFile,embedded,comment,mimeType,mdfDetails)



            asam.mdf.FileInterface.platformCheck();


            asam.mdf.FileInterface.licenseCheck();


            attDetailsStruct.Embedded=embedded;
            attDetailsStruct.Comment=comment;
            attDetailsStruct.MIMEType=mimeType;


            [attAbsPath,idxMatchedAttNameOnly,~,idxMatchedAttAbsPath]=asam.mdf.FileInterface.findAttachmentInFile(attachmentFile,mdfDetails);


            if~isfile(attAbsPath)
                error(message('asam_mdf:MDF:AttachmentNotFoundForAdd'));
            end

            attNameOnlyExists=~isempty(idxMatchedAttNameOnly);
            attAbsPathExists=~isempty(idxMatchedAttAbsPath);



            matchedAnyExternal=any([mdfDetails.Attachment(idxMatchedAttAbsPath).Type]==asam.mdf.AttachmentType.External);


            if isempty(attDetailsStruct.MIMEType)
                [~,~,ext]=fileparts(attachmentFile);
                attDetailsStruct.MIMEType=strcat('application/',ext(2:end));
            end


            attDetailsStruct.MIMEType=lower(attDetailsStruct.MIMEType);


            mexMDF(asam.mdf.castOperationType(asam.mdf.OperationType.AddAttachment),handle,attachmentFile,attDetailsStruct);


            mexMDF(asam.mdf.castOperationType(asam.mdf.OperationType.SetFileHistory),handle,version);

            if embedded
                if attNameOnlyExists



                    warning(message('asam_mdf:MDF:EmbeddedAttachmentWithSameNameAdded'));
                end
            else
                if attAbsPathExists&&matchedAnyExternal



                    warning(message('asam_mdf:MDF:ExternalAttachmentWithSamePathAdded'));
                end
            end
        end

        function RemoveAttachment(handle,attachmentFile,mdfDetails)



            asam.mdf.FileInterface.platformCheck();


            asam.mdf.FileInterface.licenseCheck();


            [~,~,idxMatchedAttInput,~]=asam.mdf.FileInterface.findAttachmentInFile(attachmentFile,mdfDetails);



            needWarning=false;

            if numel(idxMatchedAttInput)==1


                indexToRemove=idxMatchedAttInput;

            elseif numel(idxMatchedAttInput)>=1


                indexToRemove=idxMatchedAttInput(1);
                needWarning=true;

            else

                error(message('asam_mdf:MDF:AttachmentNotFoundForRemove'));

            end


            mexMDF(asam.mdf.castOperationType(asam.mdf.OperationType.RemoveAttachment),handle,indexToRemove-1);


            mexMDF(asam.mdf.castOperationType(asam.mdf.OperationType.SetFileHistory),handle,version);

            if(needWarning)
                warning(message('asam_mdf:MDF:MultipleAttachmentsFoundForRemove',indexToRemove));
            end
        end

        function Rewrite(filePath)



            asam.mdf.FileInterface.platformCheck();


            p=inputParser;
            p.addRequired('filePath',@(x)validateattributes(x,{'char'},{'nonempty','row'}));
            p.parse(filePath);


            mexMDF(asam.mdf.castOperationType(asam.mdf.OperationType.Rewrite),char(filePath));
        end

        function chanDetailsStruct=Peek(handle,chanGrpIdx)



            asam.mdf.FileInterface.platformCheck();


            chanDetailsStruct=mexMDF(asam.mdf.castOperationType(asam.mdf.OperationType.Peek),handle,chanGrpIdx);


            chanDetailsStruct=asam.mdf.FileInterface.prepareChannelDetails(chanDetailsStruct);
        end

        function[fileName,filePath]=validateMDFFilePath(file)




            file=convertStringsToChars(file);




            [~,fileName,fileExt]=fileparts(file);


            if isempty(fileExt)
                error(message('asam_mdf:MDF:FileExtensionNotSpecified'));
            end


            if~any(strcmpi(fileExt,{'.dat','.mf4','.mdf'}))
                error(message('asam_mdf:MDF:FileNotAnMDFFile'));
            end


            fileFullPath=asam.MDF.findFullFilePath(file);
            if strcmp(fileFullPath,'')


                fileFullPath=asam.MDF.findFullFilePath([fileName,fileExt]);
            end


            if isempty(fileFullPath)
                error(message('asam_mdf:MDF:FileNotFound'));
            end



            fileName=[fileName,fileExt];
            filePath=fileFullPath;
        end

        function filePath=validateDestMDFFilePath(file)




            file=convertStringsToChars(file);




            [~,fileName,fileExt]=fileparts(file);


            if isempty(fileExt)
                error(message('asam_mdf:MDF:FileExtensionNotSpecified'));
            end


            if~any(strcmpi(fileExt,{'.dat','.mf4','.mdf'}))
                error(message('asam_mdf:MDF:FileNotAnMDFFile'));
            end


            if asam.mdf.FileInterface.isAbsoluteFilePath(file)
                fullPath=file;
            else

                fullPath=fullfile(pwd,file);
            end


            filePath=asam.MDF.findFullFilePath(fullPath);



            if isempty(filePath)

                [fid,~]=fopen([fileName,fileExt],'w+');



                if fid==-1
                    error(message('asam_mdf:MDF:FileCreateError'));
                end


                fclose(fid);
                delete([fileName,fileExt]);
            end
        end

        function version=getLatestMDFVersion
            version=asam.mdf.FileInterface.MDFVersions{end};
        end

        function channelGroupPropertyNames=getChannelGroupPropertyNames
            channelGroupPropertyNames=asam.mdf.FileInterface.ChannelGroupPropertyNames;
        end

        function channelPropertyNames=getChannelPropertyNames
            channelPropertyNames=asam.mdf.FileInterface.ChannelPropertyNames;
        end

        function defaultSourceInfo=getDefaultSourceInfoStruct()

            defaultSourceInfo=struct("Name","","Path","","Comment","","SourceType",asam.mdf.SourceType(-1),...
            "BusType",asam.mdf.SourceBusType(-1),"BusChannelNumber",uint32(0));
        end

    end

    methods(Static,Access=?asam.MDF)
        function licenseCheck()



            if isempty(builtin('license','inuse','Vehicle_Network_Toolbox'))&&...
                isempty(builtin('license','inuse','Powertrain_Blockset'))

                [vntStatus,~]=builtin('license','checkout','Vehicle_Network_Toolbox');
                if~vntStatus

                    [ptbsStatus,~]=builtin('license','checkout','Powertrain_Blockset');
                    if~ptbsStatus


                        error(message('asam_mdf:MDF:LicenseNotFound'));
                    end
                end
            end
        end
    end

    methods(Static,Access=private)
        function platformCheck()

            if ismac()
                error(message('asam_mdf:MDF:PlatformNotSupported'));
            end
        end

        function fileDetailsStruct=prepareFileDetails(fileDetailsStruct)


            fileDetailsStruct.Version=strtrim(fileDetailsStruct.Version);
            fileDetailsStruct.VersionNumber=str2double(fileDetailsStruct.Version);



            initTimestampBefore=fileDetailsStruct.InitialTimestamp;
            initTimestampAfter=erase(initTimestampBefore,' UTC');


            dateTimeFormat='yyyy-MM-dd HH:mm:ss.SSSSSSSSS';
            fileDetailsStruct.InitialTimestamp=datetime(initTimestampAfter,'InputFormat',dateTimeFormat);
            fileDetailsStruct.InitialTimestamp.Format=dateTimeFormat;




            if(~strcmp(initTimestampAfter,initTimestampBefore))
                fileDetailsStruct.InitialTimestamp.TimeZone='UTC';
            end
        end

        function attachmentDetailsStruct=prepareAttachmentDetails(attachmentDetailsStruct)








            for ii=1:numel(attachmentDetailsStruct)


                if isempty(attachmentDetailsStruct(ii).MD5CheckSum)
                    attachmentDetailsStruct(ii).MD5CheckSum='00000000000000000000000000000000';
                else
                    attachmentDetailsStruct(ii).MD5CheckSum=upper(attachmentDetailsStruct(ii).MD5CheckSum);
                end
                attachmentDetailsStruct(ii).Type=asam.mdf.AttachmentType(attachmentDetailsStruct(ii).Type);
                attachmentDetailsStruct(ii).Name=fullfile(attachmentDetailsStruct(ii).Name);
                attachmentDetailsStruct(ii).Path=fullfile(attachmentDetailsStruct(ii).Path);
                if strcmp(filesep,'\')

                    attachmentDetailsStruct(ii).Name=strrep(attachmentDetailsStruct(ii).Name,'/','\');
                    attachmentDetailsStruct(ii).Path=strrep(attachmentDetailsStruct(ii).Path,'/','\');
                elseif strcmp(filesep,'/')

                    attachmentDetailsStruct(ii).Name=strrep(attachmentDetailsStruct(ii).Name,'\','/');
                    attachmentDetailsStruct(ii).Path=strrep(attachmentDetailsStruct(ii).Path,'\','/');
                end
            end
        end

        function chanGrpDetailsStruct=prepareChannelGroupDetails(chanGrpDetailsStruct)



            for ii=1:numel(chanGrpDetailsStruct)
                chanGrpDetailsStruct(ii).SourceInfo.BusType=asam.mdf.SourceBusType(chanGrpDetailsStruct(ii).SourceInfo.BusType);
                chanGrpDetailsStruct(ii).SourceInfo.SourceType=asam.mdf.SourceType(chanGrpDetailsStruct(ii).SourceInfo.SourceType);
                for jj=1:numel(chanGrpDetailsStruct(ii).Channel)
                    chanGrpDetailsStruct(ii).Channel(jj).Type=asam.mdf.ChannelType(chanGrpDetailsStruct(ii).Channel(jj).Type);
                    chanGrpDetailsStruct(ii).Channel(jj).DataType=asam.mdf.ChannelDataType(chanGrpDetailsStruct(ii).Channel(jj).DataType);
                    chanGrpDetailsStruct(ii).Channel(jj).ComponentType=asam.mdf.ChannelComponentType(chanGrpDetailsStruct(ii).Channel(jj).ComponentType);
                    chanGrpDetailsStruct(ii).Channel(jj).CompositionType=asam.mdf.ChannelCompositionType(chanGrpDetailsStruct(ii).Channel(jj).CompositionType);
                    chanGrpDetailsStruct(ii).Channel(jj).ConversionType=asam.mdf.ChannelConversionType(chanGrpDetailsStruct(ii).Channel(jj).ConversionType);
                    chanGrpDetailsStruct(ii).Channel(jj).SourceInfo.BusType=asam.mdf.SourceBusType(chanGrpDetailsStruct(ii).Channel(jj).SourceInfo.BusType);
                    chanGrpDetailsStruct(ii).Channel(jj).SourceInfo.SourceType=asam.mdf.SourceType(chanGrpDetailsStruct(ii).Channel(jj).SourceInfo.SourceType);
                end
            end
        end

        function chanDetailsStruct=prepareChannelDetails(chanDetailsStruct)



            for ii=1:numel(chanDetailsStruct)
                chanDetailsStruct(ii).Type=asam.mdf.ChannelType(chanDetailsStruct(ii).Type);
                chanDetailsStruct(ii).DataType=asam.mdf.ChannelDataType(chanDetailsStruct(ii).DataType);
                chanDetailsStruct(ii).SyncType=asam.mdf.ChannelSyncType(chanDetailsStruct(ii).SyncType);
                chanDetailsStruct(ii).ComponentType=asam.mdf.ChannelComponentType(chanDetailsStruct(ii).ComponentType);
                chanDetailsStruct(ii).CompositionType=asam.mdf.ChannelCompositionType(chanDetailsStruct(ii).CompositionType);
            end

        end

        function isAbsolutePath=isAbsoluteFilePath(file)




            isLinuxorUNCPath=startsWith(file,["\\","/"]);


            isDrivePath=~isempty(regexpi(file,'^[a-zA-Z]:\\'));


            isAbsolutePath=isLinuxorUNCPath||isDrivePath;
        end

        function[srcFileFullPath,destFileFullPath]=getSrcDestFileFullPath(srcFile,destFile)




            try
                [~,srcFileFullPath]=asam.mdf.FileInterface.validateMDFFilePath(srcFile);
            catch ME

                if strcmpi(ME.identifier,'asam_mdf:MDF:FileExtensionNotSpecified')
                    error(message('asam_mdf:MDF:SourceFileExtensionNotSpecified'));
                end
                if strcmpi(ME.identifier,'asam_mdf:MDF:FileNotAnMDFFile')
                    error(message('asam_mdf:MDF:SourceFileNotAnMDFFile'));
                end


                rethrow(ME);
            end


            destFileFullPath=srcFileFullPath;


            if~isempty(destFile)

                destFilePathTest=[];%#ok<NASGU> 
                try
                    destFilePathTest=asam.mdf.FileInterface.validateDestMDFFilePath(destFile);
                catch ME

                    if strcmpi(ME.identifier,'asam_mdf:MDF:FileExtensionNotSpecified')
                        error(message('asam_mdf:MDF:TargetFileExtensionNotSpecified'));
                    end
                    if strcmpi(ME.identifier,'asam_mdf:MDF:FileNotAnMDFFile')
                        error(message('asam_mdf:MDF:TargetFileNotAnMDFFile'));
                    end


                    rethrow(ME);
                end



                if strcmp(srcFileFullPath,destFilePathTest)
                    error(message('asam_mdf:MDF:TargetFileSameAsSourceFile'));
                end



                if~isempty(destFilePathTest)
                    error(message('asam_mdf:MDF:FileAlreadyExists'));
                end


                if asam.mdf.FileInterface.isAbsoluteFilePath(destFile)
                    destFileFullPath=destFile;
                else

                    destFileFullPath=fullfile(pwd,destFile);
                end

                [~,~,srcExt]=fileparts(srcFileFullPath);
                [destFileDir,~,destExt]=fileparts(destFileFullPath);


                if~strcmpi(srcExt,destExt)
                    error(message('asam_mdf:MDF:FileExtensionMismatch'));
                end


                if~exist(destFileDir,'dir')
                    try
                        mkdir(destFileDir)
                    catch ME
                        if strcmpi(ME.identifier,'MATLAB:MKDIR:OSError')
                            error(message('asam_mdf:MDF:FileCreateError'));
                        end

                        rethrow(ME);
                    end
                end
            end
        end

        function[attAbsPath,idxMatchedAttNameOnly,idxMatchedAttInput,idxMatchedAttAbsPath]=findAttachmentInFile(attachmentFile,mdfDetails)













            existingAttNames={mdfDetails.Attachment.Name};




            existingAttPaths={mdfDetails.Attachment.Path};


            [mdfPath,~,~]=fileparts(mdfDetails.Path);


            [path,name,ext]=fileparts(attachmentFile);


            if isempty(ext)
                error(message('asam_mdf:MDF:AttachmentFileExtensionNotSpecified'));
            end


            attNameOnly=strcat(name,ext);



            attInput=fullfile(path,attNameOnly);


            if asam.mdf.FileInterface.isAbsoluteFilePath(attInput)
                attAbsPath=attInput;
            else

                attAbsPath=fullfile(mdfPath,attInput);
            end


            attAbsPath=fullfile(attAbsPath);
            existingAttAbsPaths=cellfun(@fullfile,existingAttPaths,'UniformOutput',false);





            idxMatchedAttNameOnly=find(strcmpi(attNameOnly,existingAttNames));




            idxMatchedAttInput=find(strcmpi(attInput,existingAttNames));



            idxMatchedAttAbsPath=find(strcmpi(attAbsPath,existingAttAbsPaths));
        end
    end
end
