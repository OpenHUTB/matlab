classdef(Sealed)Dataset<handle




    properties
Configuration
Data
Header
Information
    end

    properties(Dependent,Access=private)
ConfigurationName
DataName
HeaderName
InformationName
ConfigurationFullPath
DataFullPath
HeaderFullPath
InformationFullPath
    end

    properties(Access=private)
Name
HeaderFileType
    end

    methods
        function obj=Dataset(varargin)



            parseObject=inputParser;
            parseObject.addRequired('Name');
            parseObject.addParameter('HeaderFileType','Text');
            parseObject.parse(varargin{:});


            obj.Name=parseObject.Results.Name;
            obj.HeaderFileType=upper(parseObject.Results.HeaderFileType);


            obj.Configuration=obj.readConfigFile;


            obj.Data=obj.readDatafile;


            obj.Header=obj.readHeaderFile;


            obj.Information=obj.readInformationFile;

        end

        function exportMATFile(obj)
            fieldNames=fieldnames(obj.Data.Analog);
            numberOfSignals=length(fieldNames);
            signalCellarray=struct2cell(obj.Data.Analog);
            timeValue=obj.Data.Time;
            signalDataset=Simulink.SimulationData.Dataset;
            for signalIdx=1:numberOfSignals
                value=cell2mat(signalCellarray(signalIdx));
                signal=Simulink.SimulationData.Signal;
                signal.Name=fieldNames{signalIdx};
                signal.Values=timeseries(value,timeValue);
                signal.PortType='outport';
                signalDataset=signalDataset.addElement(signal);
            end
            save(obj.Name,'signalDataset');
        end

        function value=get.ConfigurationName(obj)
            value=strcat(obj.Name,'.cfg');
        end

        function value=get.DataName(obj)
            value=strcat(obj.Name,'.dat');
        end

        function value=get.HeaderName(obj)
            value=strcat(obj.Name,'.hdr');
        end

        function value=get.InformationName(obj)
            value=strcat(obj.Name,'.inf');
        end

        function value=get.ConfigurationFullPath(obj)
            value=which(obj.ConfigurationName);
        end

        function value=get.DataFullPath(obj)
            value=which(obj.DataName);
        end

        function value=get.HeaderFullPath(obj)
            value=which(obj.HeaderName);
        end

        function value=get.InformationFullPath(obj)
            value=which(obj.InformationName);
        end
    end

    methods(Access=private)

        function dataConfig=readConfigFile(obj)
            if~isempty(obj.ConfigurationFullPath)

                fileIdConfig=fopen(obj.ConfigurationName);
                if~isequal(fileIdConfig,-1)
                    individualEntries=readNextLineConfig(fileIdConfig);

                    if numel(individualEntries{:})>=2

                        dataConfig.StationName=individualEntries{:}{1};
                        dataConfig.RecordingDevice=individualEntries{:}{2};


                        if numel(individualEntries{:})==3
                            dataConfig.RevisionYear=individualEntries{:}{3};
                        else
                            dataConfig.RevisionYear='1991';
                        end
                    else
                        fclose(fileIdConfig);
                        pm_error('physmod:ee:comtrade:CheckConfigurationFileContents',1);
                    end

                    individualEntries=readNextLineConfig(fileIdConfig);

                    if numel(individualEntries{:})==3
                        dataConfig.TotalChannels=str2double(individualEntries{:}{1});
                        dataConfig.TotalAnalogChannels=str2double(individualEntries{:}{2}(1:end-1));
                        dataConfig.TotalDigitalChannels=str2double(individualEntries{:}{3}(1:end-1));
                    else
                        fclose(fileIdConfig);
                        pm_error('physmod:ee:comtrade:CheckConfigurationFileContents',2);
                    end

                    if isequal(dataConfig.TotalChannels,(dataConfig.TotalAnalogChannels+...
                        dataConfig.TotalDigitalChannels))

                        for analogLoopVariable=1:dataConfig.TotalAnalogChannels

                            individualEntries=readNextLineConfig(fileIdConfig);

                            if numel(individualEntries{:})==13
                                dataConfig.Analog.Index(analogLoopVariable,1)=individualEntries{:}(1);
                                dataConfig.Analog.Identifier(analogLoopVariable,1)=strtrim(individualEntries{:}(2));
                                dataConfig.Analog.PhaseIdentifier(analogLoopVariable,1)=strtrim(individualEntries{:}(3));
                                dataConfig.Analog.CircuitComponentMonitored(analogLoopVariable,1)=strtrim(individualEntries{:}(4));
                                dataConfig.Analog.Unit(analogLoopVariable,1)=strtrim(individualEntries{:}(5));
                                dataConfig.Analog.Multiplier(analogLoopVariable,1)=str2double(individualEntries{:}(6));
                                dataConfig.Analog.OffsetAdder(analogLoopVariable,1)=str2double(individualEntries{:}(7));
                                dataConfig.Analog.TimeSkew(analogLoopVariable,1)=str2double(individualEntries{:}(8));
                                dataConfig.Analog.MinimumDataValue(analogLoopVariable,1)=str2double(individualEntries{:}(9));
                                dataConfig.Analog.MaximumDataValue(analogLoopVariable,1)=str2double(individualEntries{:}(10));
                                dataConfig.Analog.CTratioPrimary(analogLoopVariable,1)=str2double(individualEntries{:}(11));
                                dataConfig.Analog.CTratioSecondary(analogLoopVariable,1)=str2double(individualEntries{:}(12));
                                dataConfig.Analog.DataScalingId(analogLoopVariable,1)=strtrim(individualEntries{:}(13));
                            else
                                fclose(fileIdConfig);
                                pm_error('physmod:ee:comtrade:CheckConfigurationFileContents',analogLoopVariable+2);
                            end

                        end
                        for digitalLoopVariable=1:dataConfig.TotalDigitalChannels

                            individualEntries=readNextLineConfig(fileIdConfig);

                            if numel(individualEntries{:})==5
                                dataConfig.Digital.Index(digitalLoopVariable,1)=individualEntries{:}(1);
                                dataConfig.Digital.Identifier(digitalLoopVariable,1)=strtrim(individualEntries{:}(2));
                                dataConfig.Digital.PhaseIdentifier(digitalLoopVariable,1)=strtrim(individualEntries{:}(3));
                                dataConfig.Digital.CircuitComponentMonitored(digitalLoopVariable,1)=strtrim(individualEntries{:}(4));
                                dataConfig.Digital.StatusChannelState(digitalLoopVariable,1)=str2double(individualEntries{:}(5));
                            else
                                fclose(fileIdConfig);
                                pm_error('physmod:ee:comtrade:CheckConfigurationFileContents',digitalLoopVariable+analogLoopVariable+2);
                            end
                        end

                        individualEntries=readNextLineConfig(fileIdConfig);
                        if numel(individualEntries{:})==1
                            dataConfig.LineFrequency=str2double(individualEntries{:});
                        else
                            fclose(fileIdConfig);
                            pm_error('physmod:ee:comtrade:CheckConfigurationFileContents',digitalLoopVariable+analogLoopVariable+3);
                        end




                        individualEntries=readNextLineConfig(fileIdConfig);
                        if numel(individualEntries{:})==1
                            dataConfig.NumberOfRates=str2double(individualEntries{:});
                        else
                            fclose(fileIdConfig);
                            pm_error('physmod:ee:comtrade:CheckConfigurationFileContents',digitalLoopVariable+analogLoopVariable+4);
                        end


                        individualEntries=readNextLineConfig(fileIdConfig);
                        if numel(individualEntries{:})==2
                            if dataConfig.NumberOfRates==0
                                dataConfig.SampleRate=0;
                                dataConfig.LastSampleNumber=str2double(individualEntries{:}{2});
                            else
                                for sampleRateIdx=1:dataConfig.NumberOfRates
                                    dataConfig.SampleRate(sampleRateIdx,1)=str2double(individualEntries{:}{1});
                                    dataConfig.LastSampleNumber(sampleRateIdx,1)=str2double(individualEntries{:}{2});
                                end
                            end
                        else
                            fclose(fileIdConfig);
                            pm_error('physmod:ee:comtrade:CheckConfigurationFileContents',digitalLoopVariable+analogLoopVariable+5);
                        end



                        individualEntries=readNextLineConfig(fileIdConfig);
                        if numel(individualEntries{:})==2
                            dataConfig.StartDate=individualEntries{:}{1};
                            dataConfig.StartTime=individualEntries{:}{2};
                        else
                            fclose(fileIdConfig);
                            pm_error('physmod:ee:comtrade:CheckConfigurationFileContents',digitalLoopVariable+analogLoopVariable+6);
                        end



                        individualEntries=readNextLineConfig(fileIdConfig);
                        if numel(individualEntries{:})==2
                            dataConfig.TriggerDate=individualEntries{:}{1};
                            dataConfig.TriggerTime=individualEntries{:}{2};
                        else
                            fclose(fileIdConfig);
                            pm_error('physmod:ee:comtrade:CheckConfigurationFileContents',digitalLoopVariable+analogLoopVariable+7);
                        end



                        individualEntries=readNextLineConfig(fileIdConfig);
                        if numel(individualEntries{:})==1
                            dataConfig.FileType=individualEntries{:}{1};
                        else
                            fclose(fileIdConfig);
                            pm_error('physmod:ee:comtrade:CheckConfigurationFileContents',digitalLoopVariable+analogLoopVariable+8);
                        end


                        individualEntries=readNextLineConfig(fileIdConfig);
                        if numel(individualEntries{:})==1
                            dataConfig.TimeStampMultiplicationFactor=str2double(individualEntries{:}{1});
                        else
                            fclose(fileIdConfig);
                            pm_error('physmod:ee:comtrade:CheckConfigurationFileContents',digitalLoopVariable+analogLoopVariable+9);
                        end

                        if strcmp(dataConfig.RevisionYear,'2013')
                            if feof(fileIdConfig)

                                disp(getString(message('physmod:ee:comtrade:MissingFields')));




                                if dataConfig.TotalAnalogChannels~=0
                                    dataConfig.Analog.MLidentifier=matlab.lang.makeValidName(matlab.lang.makeUniqueStrings(dataConfig.Analog.Identifier));
                                end
                                if dataConfig.TotalDigitalChannels~=0
                                    dataConfig.Digital.MLidentifier=matlab.lang.makeValidName(matlab.lang.makeUniqueStrings(dataConfig.Digital.Identifier));
                                end
                                fclose(fileIdConfig);
                                return
                            end


                            individualEntries=readNextLineConfig(fileIdConfig);
                            if numel(individualEntries{:})==2
                                dataConfig.TimeCode=individualEntries{:}{1};
                                dataConfig.LocalCode=individualEntries{:}{2};
                            else
                                fclose(fileIdConfig);
                                pm_error('physmod:ee:comtrade:CheckConfigurationFileContents',digitalLoopVariable+analogLoopVariable+10);
                            end




                            individualEntries=readNextLineConfig(fileIdConfig);
                            if numel(individualEntries{:})==2
                                dataConfig.TimeQualityIndicatorCode=individualEntries{:}{1};
                                dataConfig.LeapSecondIndicator=individualEntries{:}{2};
                            else
                                fclose(fileIdConfig);
                                pm_error('physmod:ee:comtrade:CheckConfigurationFileContents',digitalLoopVariable+analogLoopVariable+11);
                            end
                        end


                        if dataConfig.TotalAnalogChannels~=0
                            dataConfig.Analog.MLidentifier=matlab.lang.makeValidName(matlab.lang.makeUniqueStrings(dataConfig.Analog.Identifier));
                        end
                        if dataConfig.TotalDigitalChannels~=0
                            dataConfig.Digital.MLidentifier=matlab.lang.makeValidName(matlab.lang.makeUniqueStrings(dataConfig.Digital.Identifier));
                        end
                    else
                        fclose(fileIdConfig);
                        pm_error('physmod:ee:comtrade:CheckTotalChannels');
                    end
                else
                    fclose(fileIdConfig);
                    pm_error('physmod:ee:comtrade:UnableToOpenConfigFile');
                end

            else
                pm_error('physmod:ee:comtrade:CheckConfigurationFile');
            end
            fclose(fileIdConfig);
        end

        function data=readDatafile(obj)
            if~isempty(obj.DataFullPath)

                fileIdData=fopen(obj.DataName);

                if~isequal(fileIdData,-1)

                    if strcmp(obj.Configuration.FileType,'ASCII')
                        formatSpecifierString=repmat('%n',1,obj.Configuration.TotalChannels+2);
                        readData=textscan(fileIdData,formatSpecifierString,'delimiter',',');

                        readDataCheck=readData{:};
                        if~isempty(readDataCheck)
                            if(obj.Configuration.NumberOfRates~=0)&&...
                                (obj.Configuration.SampleRate~=0)

                                disp(getString(message('physmod:ee:comtrade:SampleRate')));
                                data.Time=(readData{1}-1)/obj.Configuration.SampleRate;

                            else
                                disp(getString(message('physmod:ee:comtrade:TimeStamps')));
                                data.Time=readData{2}*1e-6*obj.Configuration.TimeStampMultiplicationFactor;
                            end


                            for lengthOfAnalogChannels=1:obj.Configuration.TotalAnalogChannels
                                data.Analog.(obj.Configuration.Analog.MLidentifier{lengthOfAnalogChannels})=obj.Configuration.Analog.Multiplier(lengthOfAnalogChannels)...
                                *readData{lengthOfAnalogChannels+2}+obj.Configuration.Analog.OffsetAdder(lengthOfAnalogChannels);
                            end


                            for lengthOfDigitalChannels=1:obj.Configuration.TotalDigitalChannels
                                data.Digital.(obj.Configuration.Digital.MLidentifier{lengthOfDigitalChannels})=readData{lengthOfAnalogChannels+lengthOfDigitalChannels+2};
                            end
                        else
                            fclose(fileIdData);
                            pm_error('physmod:ee:comtrade:CheckDataFileContents');
                        end

                    elseif strcmp(obj.Configuration.FileType,'BINARY')
                        dataType=[{'uint32','uint32'},repmat({'uint16'},1,obj.Configuration.TotalAnalogChannels)...
                        ,repmat({'uint16'},1,ceil(obj.Configuration.TotalDigitalChannels/16))];
                        byteOffset=[0,4,4,2*ones(1,obj.Configuration.TotalAnalogChannels+ceil(obj.Configuration.TotalDigitalChannels/16))];
                        cumulativeByteOffset=cumsum(byteOffset);
                        numberOfBytes=sum(byteOffset);

                        analogCounter=0;
                        digitalCounter=0;
                        for dataEntry=1:numel(dataType)
                            fseek(fileIdData,cumulativeByteOffset(dataEntry),'bof');
                            columnData=fread(fileIdData,dataType{dataEntry},numberOfBytes-byteOffset(dataEntry+1));

                            if any(columnData)
                                if dataEntry==1
                                    data.Sequence=columnData;

                                elseif dataEntry==2

                                    if(obj.Configuration.NumberOfRates~=0)&&(obj.Configuration.SampleRate~=0)
                                        disp(getString(message('physmod:ee:comtrade:SampleRate')));
                                        data.Time=(data.Sequence-1)/obj.Configuration.SampleRate;

                                    else
                                        disp(getString(message('physmod:ee:comtrade:TimeStamps')));
                                        data.time=columnData*1e-6*obj.Configuration.TimeStampMultiplicationFactor;

                                    end

                                elseif dataEntry>2&&dataEntry<=obj.Configuration.TotalAnalogChannels+2
                                    analogCounter=analogCounter+1;
                                    indexNegativeNumbers=columnData>obj.Configuration.Analog.MaximumDataValue(analogCounter);
                                    columnData(indexNegativeNumbers)=-(2^16-columnData(indexNegativeNumbers));
                                    data.Analog.(obj.Configuration.Analog.MLidentifier{analogCounter})=obj.Configuration.Analog.Multiplier(analogCounter)*columnData...
                                    +obj.Configuration.Analog.TimeSkew(analogCounter);

                                else
                                    digitalCounter=digitalCounter+1;
                                    extractedBits=fliplr(dec2bin(columnData,16));

                                    for lengthOfBits=1:16
                                        if lengthOfBits+(digitalCounter-1)*16<size(obj.Configuration.Digital.MLidentifier,1)
                                            data.Digital.(obj.Configuration.Digital.MLidentifier{lengthOfBits+(digitalCounter-1)*16})=extractedBits(:,lengthOfBits);
                                        end
                                    end
                                end
                            else
                                fclose(fileIdData);
                                pm_error('physmod:ee:comtrade:CheckDataFileContents');
                            end
                        end
                    end
                else
                    fclose(fileIdData);
                    pm_error('physmod:ee:comtrade:UnableToOpenDataFile');
                end
            else
                pm_error('physmod:ee:comtrade:CheckDataFile');
            end
            fclose(fileIdData);
        end

        function header=readHeaderFile(obj)

            if~isempty(obj.HeaderFullPath)

                switch obj.HeaderFileType
                case 'XML'
                    header=readstruct(obj.HeaderName,'FileType','xml');
                case 'TEXT'
                    header.Text=fileread(obj.HeaderName);
                end
            else
                header.Text='';
            end
        end

        function information=readInformationFile(obj)
            if~isempty(obj.InformationFullPath)
                information.Text=fileread(obj.InformationName);
            else
                information.Text='';
            end
        end
    end
end



function individualEntries=readNextLineConfig(FileId)
    readLine=fgetl(FileId);
    if~isempty(readLine)&&~isequal(readLine,-1)
        individualEntries=textscan(readLine,'%s','delimiter',',');
    else
        fclose(FileId);
        pm_error('physmod:ee:comtrade:MissingFieldsConfigurationFile');
    end
end
