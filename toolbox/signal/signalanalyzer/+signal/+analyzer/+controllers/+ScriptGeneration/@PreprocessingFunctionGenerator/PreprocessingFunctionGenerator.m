

classdef PreprocessingFunctionGenerator<handle






    properties(Hidden)
        Engine;
    end

    properties(Access=private)
        Dispatcher;
TimeMode
InputType
PreprocessData
    end

    properties(Hidden,Constant)
        ControllerID='preprocessingFunctionGenerator';
    end


    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                ctrlObj=signal.analyzer.controllers.ScriptGeneration.PreprocessingFunctionGenerator(dispatcherObj);
            end


            ret=ctrlObj;
        end
    end


    methods(Hidden)
        function this=PreprocessingFunctionGenerator(dispatcherObj)

            this.Engine=Simulink.sdi.Instance.engine;
            this.Dispatcher=dispatcherObj;
            import signal.analyzer.controllers.ScriptGeneration.PreprocessingFunctionGenerator;


            this.Dispatcher.subscribe(...
            [PreprocessingFunctionGenerator.ControllerID,'/','preprocessgeneratefunction'],...
            @(arg)cb_GenerateFunction(this,arg));
        end


        function codeBuffer=testGenerateFunction(this,args,testFileName,testPreferencesStruct)

            codeBuffer=cb_GenerateFunction(this,args,testFileName,testPreferencesStruct);
        end
    end


    methods(Access=protected)
        function codeBufferCell=cb_GenerateFunction(this,args,testFileName,~)

            codeBufferCell={};

            signalIDs=parseSignalIDs(this,args);
            for idx=1:numel(signalIDs)
                sigID=signalIDs(idx);

                preprocessData=retrievePreprocessMetadata(this,sigID);
                if isempty(preprocessData)
                    continue;
                end

                this.PreprocessData=preprocessData;
                codeBuffer=generateFunctionCode(this,sigID);
                codeBuffer.indentCode('matlab');

                if nargin>2

                    codeBufferCell{end+1}=codeBuffer;%#ok<AGROW>
                    fileIdx=numel(codeBufferCell);
                    codeBuffer.write([testFileName,num2str(fileIdx),'.m']);
                else
                    matlab.desktop.editor.newDocument(string(codeBuffer));
                end


                this.TimeMode='';
                this.PreprocessData={};
            end
        end



        function signalIDs=parseSignalIDs(this,args)

            if isfield(args.data,'selectedViewIndices')
                [~,signalIDs]=signal.sigappsshared.SignalUtilities.getUniqueSetOfSelectedSignalIDsByViewIndex(...
                this.Engine,args.data.selectedViewIndices,args.data.clientID);
            else


                signalIDs=signal.sigappsshared.SignalUtilities.getUniqueSetOfSelectedSignalIDsByID(...
                this.Engine,args.data.signalIDs);
            end

        end



        function preprocessMetaData=retrievePreprocessMetadata(this,sigID)




            preprocessMetaData=[];

            if~isempty(this.Engine.getMetaDataV2(sigID,'ActionNameThatCreatedSignal'))
                preprocessMetaData=[preprocessMetaData,jsondecode(this.Engine.getMetaDataV2(sigID,'SaPreprocessSettings'))];
            end

            backupSignalIDs=this.Engine.sigRepository.getSignalSaPreprocessBackupIDs(sigID);
            for idx=numel(backupSignalIDs):-1:1
                preprocessMetaData=...
                [preprocessMetaData,jsondecode(this.Engine.getMetaDataV2(backupSignalIDs(idx),'SaPreprocessSettings'))];%#ok<AGROW>
            end
        end


        function codeBuffer=generateFunctionCode(this,sigID)


            codeBuffer=StringWriter;
            addHeader(this,codeBuffer,sigID);
            addFunctionCalls(this,codeBuffer);
        end


        function addHeader(this,codeBuffer,sigID)

            tmMode=this.Engine.getSignalTmMode(sigID);
            tmOrigin=this.Engine.getSignalTmOrigin(sigID);

            timetablePreference=Simulink.sdi.getExportAsTimetablePref();
            this.InputType='vectorOrMatrix';
            this.TimeMode='tv';
            fcnHeader2=getString(this,'PreprocessFcnGenVectorTvHeader');
            fcnH1=getString(this,'PreprocessFcnGenH1');
            if strcmp(tmMode,'samples')
                this.TimeMode='samples';
                fcnHeader2=getString(this,'PreprocessFcnGenVectorSamplesHeader');
            elseif(timetablePreference&&~strcmp(tmMode,'samples'))||strcmp(tmMode,'inherentTimetable')
                this.InputType='timetable';
                fcnHeader2=getString(this,'PreprocessFcnGenFromTimetableHeader');
            elseif strcmp(tmMode,'inherentTimeseries')
                this.InputType='timeseries';
                fcnHeader2=getString(this,'PreprocessFcnGenFromTimeseriesHeader');
            elseif strcmp(tmMode,'tv')
                if strcmp(tmOrigin,'timetable')
                    this.InputType='timetable';
                    fcnHeader2=getString(this,'PreprocessFcnGenFromTimetableHeader');
                elseif strcmp(tmOrigin,'timeseries')
                    this.InputType='timeseries';
                    fcnHeader2=getString(this,'PreprocessFcnGenFromTimeseriesHeader');
                else
                    this.InputType='timevector';
                    fcnHeader2=getString(this,'PreprocessFcnGenVectorTvHeader');
                end
            end

            if strcmp(this.TimeMode,'samples')
                fcnHeader1='function y = preprocess(x)';
            else
                bTimeOutputAndInputRequired=isTimeOutputAndInputRequired(this);
                bOnlyTimeInputRequired=isOnlyTimeInputRequired(this);
                if bTimeOutputAndInputRequired
                    fcnHeader1='function [y,ty] = preprocess(x,tx)';
                elseif bOnlyTimeInputRequired
                    fcnHeader1='function y = preprocess(x,tx)';
                else
                    fcnHeader1='function y = preprocess(x)';
                    fcnHeader2=getString(this,'PreprocessFcnGenVectorSamplesHeader');
                end
            end
            codeBuffer.addcr('%s',fcnHeader1);
            codeBuffer.addcr('%s%s','%  ',fcnH1);
            codeBuffer.addcr('%s%s','%    ',fcnHeader2);
            codeBuffer.craddcr('%s',sptfileheader('','signal'));
        end


        function addFunctionCalls(this,codeBuffer)

            isFsLineAdded=false;
            isFsModified=false;
            isTyGenerated=false;
            for idx=1:numel(this.PreprocessData)
                codeBuffer.addcr('%s','');
                processData=this.PreprocessData(idx);
                inputVarName='x';
                outputVarName='y';
                outputTimeVarName='ty';
                inputTimeVarName='tx';
                if idx~=1


                    inputVarName='y';
                    if isTyGenerated
                        inputTimeVarName='ty';
                    end
                end
                switch lower(processData.ActionName)
                case 'split'
                    addSplitCall(this,codeBuffer,processData,inputVarName,outputVarName,inputTimeVarName,outputTimeVarName);
                    isTyGenerated=true;
                case{'trimleft','trimright'}
                    addTrimCall(this,codeBuffer,processData,inputVarName,outputVarName,inputTimeVarName,outputTimeVarName);
                    isTyGenerated=true;
                case{'clipabove','clipbelow'}
                    addClipCall(this,codeBuffer,processData,inputVarName,outputVarName);
                case{'crop','extract'}
                    addCropOrExtractCall(this,codeBuffer,processData,inputVarName,outputVarName,inputTimeVarName,outputTimeVarName);
                    isTyGenerated=true;
                case 'denoise'
                    addDenoiseCall(this,codeBuffer,processData,inputVarName,outputVarName);
                case 'envelope'
                    addEnvelopingCall(this,codeBuffer,processData,inputVarName,outputVarName);
                case 'detrend'
                    addDetrendingCall(this,codeBuffer,processData,inputVarName,outputVarName);
                case 'smooth'
                    addSmoothingCall(this,codeBuffer,processData,inputVarName,outputVarName,inputTimeVarName);
                case{'lowpassfilter','highpassfilter'}



                    if(~isFsLineAdded||isFsModified)&&~strcmp(this.TimeMode,'samples')


                        addFsCompuatationLine(this,codeBuffer,inputTimeVarName);
                        isFsModified=false;
                        isFsLineAdded=true;
                    end
                    addLpHpFilteringCall(this,codeBuffer,processData,inputVarName,outputVarName);
                case{'bandpassfilter','bandstopfilter'}



                    if(~isFsLineAdded||isFsModified)&&~strcmp(this.TimeMode,'samples')


                        addFsCompuatationLine(this,codeBuffer,inputTimeVarName);
                        isFsModified=false;
                        isFsLineAdded=true;
                    end
                    addBpBsFilteringCall(this,codeBuffer,processData,inputVarName,outputVarName);
                case{'resample'}
                    addResampleCall(this,codeBuffer,processData,inputVarName,outputVarName,inputTimeVarName,outputTimeVarName);
                    isFsModified=true;
                    isTyGenerated=true;
                otherwise
                    addCustomFunctionCall(this,codeBuffer,processData,inputVarName,outputVarName,inputTimeVarName,outputTimeVarName);
                    isFsModified=true;
                    isTyGenerated=true;
                end

            end
        end



        function flag=needFsComputationLine(~,preprocessList)


            numOfResampleAndCustomPreprocess=length(preprocessList)-...
            sum(contains(preprocessList,{'smooth','lowpassfilter',...
            'highpassfilter','bandpassfilter','bandstopfilter','detrend','envelope'}));
            flag=numOfResampleAndCustomPreprocess~=0;
        end


        function flag=isProcessingContainsCustomFunction(this)
            actionNames={this.PreprocessData.ActionName};
            numberOfNonCustomAction=0;
            actionNamesToCheck=["smooth","lowpassfilter","highpassfilter",...
            "bandpassfilter","bandstopfilter","resample","detrend",...
            "envelope","denoise","trimleft","trimright","crop",...
            "clipabove","clipbelow"];

            for idx=1:numel(actionNamesToCheck)
                numberOfNonCustomAction=numberOfNonCustomAction+sum(strcmp(actionNames,actionNamesToCheck(idx)));
            end

            flag=abs(numberOfNonCustomAction-numel(actionNames))>0;
        end


        function flag=isTimeOutputAndInputRequired(this)
            flag=isProcessingContainsCustomFunction(this);
            actionNames={this.PreprocessData.ActionName};
            actionNamesToCheck=["resample","trimleft","trimright","crop"];

            for idx=1:numel(actionNamesToCheck)
                flag=flag|any(strcmp(actionNames,actionNamesToCheck(idx)));
            end
        end


        function flag=isOnlyTimeInputRequired(this)
            actionNames={this.PreprocessData.ActionName};
            actionNamesToCheck=["lowpassfilter","highpassfilter",...
            "bandpassfilter","bandstopfilter","smooth"];

            flag=false;
            for idx=1:numel(actionNamesToCheck)
                flag=flag|any(strcmp(actionNames,actionNamesToCheck(idx)));
            end
        end


        function str=getString(~,key)

            str=getString(message(['SDI:sigAnalyzer:',key]));
        end


        function flag=isTimeSignal(this)
            flag=~strcmp(this.TimeMode,'samples');
        end



        function addSmoothingCall(~,codeBuffer,processData,inputVarName,outputVarName,inputTimeVarName)


            params=processData.Parameters;
            codeStr=sprintf('%s%s%s%s%s%s',outputVarName,' = smoothdata(',inputVarName,',''',params.method,'''');
            isTimeSignal=any(strcmp(params.timeMode,{'uniform','nonuniform','timemixed'}));

            if isTimeSignal
                winLength=params.windowLengthTime;
            else
                winLength=params.windowLengthSamples;
            end

            switch params.windowSpecType
            case 'smoothingfactor'
                codeStr=[codeStr,sprintf('%s%s',',''SmoothingFactor'',',num2str(params.windowSmoothFactor))];
            case 'duration'
                if~ischar(winLength)
                    codeStr=[codeStr,sprintf('%s%s',',',num2str(winLength))];
                end
            end

            if strcmp(params.method,'sgolay')&&~isempty(params.sgDegree)&&~ischar(params.sgDegree)
                codeStr=[codeStr,sprintf('%s%s',',''Degree'',',num2str(params.sgDegree))];
            end

            if isTimeSignal
                codeStr=[codeStr,sprintf('%s%s',',''SamplePoints'',',inputTimeVarName)];
            end

            codeBuffer.addcr('%s%s',codeStr,');');
        end


        function addLpHpFilteringCall(~,codeBuffer,processData,inputVarName,outputVarName)


            params=processData.Parameters;
            isTimeSignal=any(strcmp(params.timeMode,{'uniform','nonuniform','timemixed'}));
            if strcmp(processData.ActionName,'lowpassfilter')
                resp='lowpass';
            else
                resp='highpass';
            end

            codeStr=sprintf('%s%s%s%s%s',outputVarName,' = ',resp,'(',inputVarName);

            if isTimeSignal
                codeStr=[codeStr,sprintf('%s%s%s',',',num2str(params.passbandFrequency))];
                codeStr=[codeStr,sprintf('%s%s%s',',','Fs')];
            else
                codeStr=[codeStr,sprintf('%s%s%s',',',num2str(params.passbandFrequencyNormalized))];
            end

            codeStr=[codeStr,sprintf('%s%s%s',',''Steepness''',',',num2str(params.steepness))];
            codeStr=[codeStr,sprintf('%s%s%s',',''StopbandAttenuation''',',',num2str(params.stopbandAttenuation))];

            codeBuffer.addcr('%s%s',codeStr,');');
        end


        function addBpBsFilteringCall(~,codeBuffer,processData,inputVarName,outputVarName)


            params=processData.Parameters;
            isTimeSignal=any(strcmp(params.timeMode,{'uniform','nonuniform','timemixed'}));
            if strcmp(processData.ActionName,'bandpassfilter')
                resp='bandpass';
            else
                resp='bandstop';
            end

            codeStr=sprintf('%s%s%s%s%s',outputVarName,' = ',resp,'(',inputVarName);

            if isTimeSignal
                fpvect=[params.passbandFrequency1,params.passbandFrequency2];
                codeStr=[codeStr,sprintf('%s%s%s',',',mat2str(fpvect))];
                codeStr=[codeStr,sprintf('%s%s%s',',','Fs')];
            else
                fpvect=[params.passbandFrequencyNormalized1,params.passbandFrequencyNormalized2];
                codeStr=[codeStr,sprintf('%s%s%s',',',mat2str(fpvect))];
            end

            if strcmp(params.steepnessMode,'single')
                codeStr=[codeStr,sprintf('%s%s%s',',''Steepness''',',',num2str(params.steepness1))];
            else
                svect=[params.steepness1,params.steepness2];
                codeStr=[codeStr,sprintf('%s%s%s',',''Steepness''',',',mat2str(svect))];
            end

            codeStr=[codeStr,sprintf('%s%s%s',',''StopbandAttenuation''',',',num2str(params.stopbandAttenuation))];

            codeBuffer.addcr('%s%s',codeStr,');');

        end


        function addResampleCall(this,codeBuffer,processData,inputVarName,outputVarName,inputTimeVarName,outputTimeVarName)

            params=processData.Parameters;
            Nprecision=signal.sigappsshared.Utilities.getRequiredPrecisionDigits(params.targetSampleRate);
            targetSampleRate=num2str(params.targetSampleRate,Nprecision);
            if strcmp(params.sampleRate,'Auto')
                paramStr=['targetSampleRate = 1/median(diff(',inputTimeVarName,'));'];
            else
                paramStr=['targetSampleRate = ',targetSampleRate,';'];
            end
            codeStr=['[',outputVarName,',',outputTimeVarName,']',' = resample(',inputVarName,',',inputTimeVarName,',targetSampleRate'];

            if strcmp(params.timeMode,'nonuniform')
                if~strcmp(params.criticalFrequency,'Auto')
                    calculateRatioDescription=getString(this,'PreprocessFcnGenCalculateRatioDescription');
                    calculateRatioStr=['[P,Q] = rat(',targetSampleRate,'/',num2str(params.criticalFrequency),');'];
                    codeStr=sprintf('%s\n %s',calculateRatioStr,[codeStr,',P,Q']);
                    codeStr=sprintf('%s%s\n %s','% ',calculateRatioDescription,codeStr);
                end
                codeStr=[codeStr,',''',params.interpolationMethod,''''];
            end

            codeBuffer.addcr('%s\n%s%s',paramStr,codeStr,');');
        end


        function addCustomFunctionCall(~,codeBuffer,processData,inputVarName,outputVarName,inputTimeVarName,outputTimeVarName)


            params=processData.Parameters;
            isTimeSignal=any(strcmp(params.timeMode,{'uniform','nonuniform','timemixed'}));
            if isTimeSignal
                if isempty(params.arguments)
                    fStr=['[',outputVarName,',',outputTimeVarName,']',' = ',params.method,'(',inputVarName,',',inputTimeVarName,');'];
                else
                    fStr=['[',outputVarName,',',outputTimeVarName,']',' = ',params.method,'(',inputVarName,',',inputTimeVarName,',',params.arguments,');'];
                end
            else
                if isempty(params.arguments)
                    fStr=[outputVarName,' = ',params.method,'(',inputVarName,',[]);'];
                else
                    fStr=[outputVarName,' = ',params.method,'(',inputVarName,',[],',params.arguments,');'];
                end
            end
            codeBuffer.addcr('%s',fStr);
        end


        function addFsCompuatationLine(this,codeBuffer,inputTimeVarName)
            avgFsStr=getString(this,'PreprocessAvgFs');
            codeBuffer.addcr('%s%s%s',['Fs = 1/mean(diff(',inputTimeVarName,'));'],' % ',avgFsStr);
        end

        function addEnvelopingCall(~,codeBuffer,processData,inputVarName,outputVarName)

            params=processData.Parameters;

            switch params.outputType
            case 'upper'
                leftStr=sprintf('%s%s%s','[',outputVarName,',~]');
            case 'lower'
                leftStr=sprintf('%s%s%s','[~,',outputVarName,']');
            end

            if~strcmp(params.method,'hilbert')
                if strcmp(params.method,'fir')
                    methodName='analytic';
                    windowParam=params.filterOrder;
                    windowParamVarName='filterOrder';
                    windowParamEndStr=';';
                elseif strcmp(params.method,'rms')
                    methodName='rms';
                    windowParamVarName='windowLength';
                    if strcmp(params.windowLengthTimeUnits,'samples')
                        windowParam=params.windowLength;
                        windowParamEndStr=';';
                    else
                        windowParam=params.formattedWindowLength;
                        windowParamEndStr='; %Value converted to samples';
                    end
                elseif strcmp(params.method,'peak')
                    methodName='peak';
                    windowParamVarName='maximaSeparation';
                    if strcmp(params.maximaSeparationTimeUnits,'samples')
                        windowParam=params.maximaSeparation;
                        windowParamEndStr=';';
                    else
                        windowParam=params.formattedMaximaSeparation;
                        windowParamEndStr='; %Value converted to samples';
                    end
                end

                varStr=sprintf('%s%s%s',windowParamVarName,' = ',num2str(windowParam));
                codeStr=sprintf('%s%s%s%s%s%s%s%s',leftStr,' = envelope(',inputVarName,',',windowParamVarName,',''',methodName,'''');

                codeBuffer.addcr('%s%s',varStr,windowParamEndStr);
            else

                codeStr=sprintf('%s%s%s',leftStr,' = envelope(',inputVarName);
            end

            codeBuffer.addcr('%s%s',codeStr,');');
        end

        function addDenoiseCall(~,codeBuffer,processData,inputVarName,outputVarName)

            params=processData.Parameters;
            wname=string(params.waveletName)+string(params.waveletNumber);
            denoisingMethod=params.denoisingMethod;
            if denoisingMethod=="FDR"
                denoisingMethod="{'"+denoisingMethod+"' "+params.QValue+"}";
            else
                denoisingMethod="'"+denoisingMethod+"'";
            end

            codeStr=string(outputVarName)+" = wdenoise("+...
            string(inputVarName)+", "+...
            string(params.levels)+", ..."+newline+...
            "'Wavelet', '"+wname+"', ..."+newline+...
            "'DenoisingMethod', "+denoisingMethod+", ..."+newline+...
            "'ThresholdRule', '"+params.thresholdRule+"', ..."+newline+...
            "'NoiseEstimate', '"+params.noiseEstimate+"');";

            codeBuffer.addcr('%s',codeStr);
        end

        function addDetrendingCall(~,codeBuffer,processData,inputVarName,outputVarName)


            params=processData.Parameters;

            if strcmp(params.method,'piecewiselinear')
                methodName='linear';

                if~isempty(params.breakpoints)
                    if strcmp(params.timeMode,'samples')
                        endptVals=mat2str(params.breakpoints(:)');
                        endptValsEndStr=' + 1; %Add one to convert samples to valid MATLAB index values';
                    else
                        endptVals=mat2str(params.formattedBreakpoints(:)');
                        endptValsEndStr='; %Value converted to samples';
                    end

                    varName='breakPoints';
                    varStr=sprintf('%s%s%s%s%s%s',varName,' = ',endptVals);
                    codeStr=sprintf('%s%s%s%s%s%s%s',outputVarName,' = detrend(',inputVarName,',''',methodName,''',',varName);

                    codeBuffer.addcr('%s%s',varStr,endptValsEndStr);

                else
                    codeStr=sprintf('%s%s%s%s%s%s',outputVarName,' = detrend(',inputVarName,',''',methodName,'''');
                end
            else
                methodName=params.method;
                codeStr=sprintf('%s%s%s%s%s%s',outputVarName,' = detrend(',inputVarName,',''',methodName,'''');
            end

            codeBuffer.addcr('%s%s',codeStr,');');
        end

    end
end