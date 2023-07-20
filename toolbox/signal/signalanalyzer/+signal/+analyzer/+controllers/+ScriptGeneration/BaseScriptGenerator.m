

classdef BaseScriptGenerator<handle





%#ok<*AGROW>

    methods(Static)
        function ret=getController()
            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                ctrlObj=signal.analyzer.controllers.ScriptGeneration.BaseScriptGenerator(dispatcherObj);
            end


            ret=ctrlObj;
        end
    end


    methods(Hidden)
        function this=BaseScriptGenerator(dispatcherObj)

            this.Engine=Simulink.sdi.Instance.engine;
            this.Dispatcher=dispatcherObj;
            import signal.analyzer.controllers.ScriptGeneration.BaseScriptGenerator;


            this.Dispatcher.subscribe(...
            [BaseScriptGenerator.ControllerID,'/','generatescript'],...
            @(arg)cb_GenerateScript(this,arg));
        end


        function codeBuffer=testGenerateScript(this,args,testFileName,testPreferencesStruct)

            codeBuffer=cb_GenerateScript(this,args,testFileName,testPreferencesStruct);
        end
    end


    methods(Access=protected)

        function codeBuffer=cb_GenerateScript(this,args,testFileName,testPreferencesStruct)



            scriptType=args.data.scriptType;
            scriptParams=args.data;

            if nargin>2


                scriptParams.exportAsTimetablePreference=...
                testPreferencesStruct.exportAsTimetablePreference;
            else

                scriptParams.exportAsTimetablePreference=...
                Simulink.sdi.getExportAsTimetablePref();
            end

            codeBuffer=StringWriter;
            addHeader(this,codeBuffer,scriptType);
            isValid=generateMainScript(this,codeBuffer,scriptParams);

            if~isValid
                return;
            end

            codeBuffer.indentCode('matlab');

            if nargin>2

                codeBuffer.write(testFileName);
            else
                matlab.desktop.editor.newDocument(string(codeBuffer));
            end

        end


        function addHeader(this,codeBuffer,scriptType)
            h1Line=this.getH1LineForScriptType(scriptType);
            codeBuffer.addcr('%s',h1Line);
            codeBuffer.craddcr('%s',sptfileheader('','signal'));
        end


        function isValid=generateMainScript(this,codeBuffer,scriptParams)

            [scriptParams,sigInfoVect,isValid]=parseSignals(this,scriptParams);

            if~isValid
                return;
            end

            switch scriptParams.scriptType
            case{'roiBetweenLimits','roiBetweenCursors'}
                generateROIExtractionScript(this,codeBuffer,sigInfoVect,scriptParams);
            case{'spectrum','persistence','spectrogram','scalogram'}
                generateSpectrumFunctionScript(this,codeBuffer,sigInfoVect,scriptParams);
            end
        end


        function generateROIExtractionScript(this,codeBuffer,sigInfoVect,scriptParams)

            if strcmp(scriptParams.params.timeMode,'time')



                codeBuffer.craddcr('%s',['% ',getString(message('SDI:sigAnalyzer:ScriptParameter'))]);
                timeLimitsCodeStr=getTimeLimitsCodeString(this,scriptParams);
                codeBuffer.addcr('%s',timeLimitsCodeStr);
            end

            for idx=1:numel(sigInfoVect)

                codeBuffer.craddcr('%s','%%');
                str=getExtractROICodeString(this,scriptParams,sigInfoVect(idx));
                codeBuffer.addcr('%s',str);
            end
        end


        function generateSpectrumFunctionScript(this,codeBuffer,sigInfoVect,scriptParams)

            import signal.analyzer.controllers.ScriptGeneration.*;

            codeBuffer.craddcr('%s',['% ',getString(message('SDI:sigAnalyzer:ScriptParameter'))]);
            if strcmp(scriptParams.params.timeMode,'time')



                timeLimitsCodeStr=getTimeLimitsCodeString(this,scriptParams);
                codeBuffer.addcr('%s',timeLimitsCodeStr);
            end



            scriptType=scriptParams.scriptType;
            if any(strcmp(scriptType,{'spectrum','persistence','spectrogram'}))
                scriptGeneratorObj=SpectrumScriptGenerator();
            elseif(strcmp(scriptType,'scalogram'))
                scriptGeneratorObj=ScalogramScriptGenerator();
            end

            paramsCodeString=getParametersCodeString(scriptGeneratorObj,scriptParams);
            codeBuffer.addcr('%s',paramsCodeString);

            for idx=1:numel(sigInfoVect)

                codeBuffer.craddcr('%s','%%');
                codeBuffer.addcr('%s',['% ',getString(message('SDI:sigAnalyzer:ExtractROIComment'))]);
                str=getExtractROICodeString(this,scriptParams,sigInfoVect(idx));
                codeBuffer.addcr('%s',str);
                str=getFunctionCodeString(scriptGeneratorObj,scriptParams,sigInfoVect(idx));
                codeBuffer.craddcr('%s',str);
            end
        end


        function str=getExtractROICodeString(this,scriptParams,sigInfo)
            str1=sigInfo.dataRetreiveCode;
            str2=sigInfo.timeValuesCode;
            exportAsTimetablePreference=scriptParams.exportAsTimetablePreference;
            isAllTimeCasesInTableFormat=scriptParams.isAllTimeCasesInTableFormat;

            currMode=sigInfo.tmMode;
            if strcmp(currMode,'inherentLabeledSignalSet')
                currMode=sigInfo.tmModeLSS;
            end
            if strcmp(scriptParams.params.timeMode,'samples')
                str3=getTimeLimitsCodeString(this,scriptParams,sigInfo.signalTimeRange);
                str4=[sigInfo.roiVarName,' = ',sigInfo.roiVarName,'(timeLimits(1):timeLimits(2));'];
                str=sprintf('%s\n%s\n%s',str3,str1,str4);
            else
                if exportAsTimetablePreference||isAllTimeCasesInTableFormat



                    strRange=[sigInfo.roiVarName,' = ',sigInfo.roiVarName,'(timerange(timeLimits(1),timeLimits(2),''closed''),1);'];
                else
                    strRange=[sigInfo.roiVarName,' = ',sigInfo.roiVarName,'(timerange(seconds(timeLimits(1)),seconds(timeLimits(2)),''closed''),1);'];
                end
                if strcmp(sigInfo.origin,'timetableWithVector')
                    if isempty(str2)
                        str=sprintf('%s\n%s',str1,strRange);
                    else
                        str=sprintf('%s\n%s\n%s',str1,str2,strRange);
                    end

                elseif strcmp(sigInfo.origin,'timetableWithMatrix')
                    strTable=[sigInfo.roiVarName,' = timetable(timeValues,',sigInfo.roiVarName,',''VariableNames'',{''Data''});'];
                    str=sprintf('%s\n%s\n%s\n%s',str1,str2,strTable,strRange);

                else
                    if exportAsTimetablePreference||...
                        any(strcmp(sigInfo.origin,{'timeseriesWithVector','timeseriesWithMatrix','timeseriesWithMultidim'}))


                        if isTvDurationVector(this,sigInfo.TvString)
                            strTable=[sigInfo.roiVarName,' = timetable(timeValues(:),',sigInfo.roiVarName,',''VariableNames'',{''Data''});'];
                        else
                            strTable=[sigInfo.roiVarName,' = timetable(seconds(timeValues(:)),',sigInfo.roiVarName,',''VariableNames'',{''Data''});'];
                        end
                        str=sprintf('%s\n%s\n%s\n%s',str1,str2,strTable,strRange);
                    else
                        if strcmp(currMode,'tv')||any(strcmp(scriptParams.scriptType,{'spectrogram','scalogram'}))


                            strExtract=[sigInfo.roiVarName,' = ',sigInfo.roiVarName,'(minIdx&maxIdx);'];
                            if any(strcmp(scriptParams.scriptType,{'roiBetweenLimits','roiBetweenCursors'}))
                                str=sprintf('%s\n%s\n%s',str1,str2,strExtract);
                            else


                                strExtract2='timeValues = timeValues(minIdx&maxIdx);';
                                str=sprintf('%s\n%s\n%s\n%s',str1,str2,strExtract,strExtract2);
                            end
                        else
                            strExtract=[sigInfo.roiVarName,' = ',sigInfo.roiVarName,'(minIdx:maxIdx);'];
                            str=sprintf('%s\n%s\n%s',str1,str2,strExtract);
                        end
                    end
                end
            end
        end





        function[scriptParams,sigInfoVect,isValid]=parseSignals(this,scriptParams)


            isValid=true;
            sigIDs=scriptParams.signalList;
            sigInfoVect=repmat(struct(...
            'ID',[],...
            'tmMode',[],...
            'tmModeLSS',[],...
            'tmOrigin',[],...
            'Fs',[],...
            'Ts',[],...
            'Tstart',[],...
            'TvString',[],...
            'effectiveFs',[],...
            'signalTimeRange',[],...
            'origin','',...
            'originName','',...
            'roiVarName','',...
            'dataRetreiveCode','',...
            'timeValuesCode','',...
            'isComplex',false),...
            numel(sigIDs),1);


            [sigInfoVect,validFlag]=parseSignalTmModes(this,sigInfoVect,scriptParams);
            if strcmp(validFlag,'none')

                if any(strcmp(scriptParams.scriptType,{'roiBetweenLimits','roiBetweenCursors'}))
                    msgString=getString(message('SDI:sigAnalyzer:NoSignalsValidForTime'));
                else
                    msgString=getString(message('SDI:sigAnalyzer:NoSignalsValidForTimeAndFreq'));
                end
                showWarningDialog(this,msgString);
                isValid=false;
                return;
            end


            scriptParams.isAllTimeCasesInTableFormat=false;
            [scriptParams,sigInfoVect]=parseSignalNames(this,scriptParams,sigInfoVect);
            sigInfoVect=getSignalTimeValuesCodeString(this,scriptParams,sigInfoVect);
        end


        function[sigInfoVect,validFlag]=parseSignalTmModes(this,sigInfoVect,scriptParams)

            import signal.sigappsshared.Utilities;
            invalidIdx=[];
            sigIDs=scriptParams.signalList;
            for idx=1:numel(sigIDs)
                sigID=sigIDs(idx);
                tmMode=this.Engine.getSignalTmMode(sigID);
                tmOrigin=this.Engine.getSignalTmOrigin(sigID);
                sigInfoVect(idx).ID=sigID;
                sigInfoVect(idx).tmMode=tmMode;
                sigInfoVect(idx).tmOrigin=tmOrigin;
                sigInfoVect(idx).isComplex=this.Engine.sigRepository.getSignalComplexityAndLeafPath(sigID).IsComplex;
                currMode=tmMode;
                if strcmp(tmMode,'inherentLabeledSignalSet')
                    currMode=signal.sigappsshared.SignalUtilities.getTmModeLabeledSignalSet(this.Engine,sigID);
                    sigInfoVect(idx).tmModeLSS=currMode;
                end
                timeRange=this.Engine.sigRepository.getSignalRange(sigID);
                sigInfoVect(idx).signalTimeRange=timeRange;
                timeLimits=scriptParams.params.timeLimits;

                switch currMode
                case 'samples'
                    sigInfoVect(idx).effectiveFs=2;
                    timeLimits(1)=ceil(timeLimits(1));
                    timeLimits(2)=floor(timeLimits(2));
                case 'fs'
                    Fs=this.Engine.getSignalTmSampleRate(sigID);
                    FsUnits=this.Engine.getSignalTmSampleRateUnits(sigID);
                    Tstart=this.Engine.getSignalTmStartTime(sigID);
                    TstartUnits=this.Engine.getSignalTmStartTimeUnits(sigID);

                    Fs=Fs*Utilities.getFrequencyMultiplier(FsUnits);
                    Tstart=Tstart*Utilities.getTimeMultiplier(TstartUnits);

                    sigInfoVect(idx).Fs=Fs;
                    sigInfoVect(idx).Tstart=Tstart;

                    sigInfoVect(idx).effectiveFs=Fs;

                case 'ts'
                    Ts=this.Engine.getSignalTmSampleTime(sigID);
                    TsUnits=this.Engine.getSignalTmSampleTimeUnits(sigID);
                    Tstart=this.Engine.getSignalTmStartTime(sigID);
                    TstartUnits=this.Engine.getSignalTmStartTimeUnits(sigID);

                    Ts=Ts*Utilities.getTimeMultiplier(TsUnits);
                    Tstart=Tstart*Utilities.getTimeMultiplier(TstartUnits);

                    sigInfoVect(idx).Ts=Ts;
                    sigInfoVect(idx).Tstart=Tstart;

                    sigInfoVect(idx).effectiveFs=1/Ts;

                case 'tv'
                    TvString=this.Engine.getSignalTmTimeVectorStr(sigID);
                    if strcmp(tmMode,'inherentLabeledSignalSet')
                        lssID=signal.sigappsshared.SignalUtilities.getSignalSuperparent(this.Engine,sigID);
                        lssName=this.Engine.getSignalName(lssID);





                        hasEqualTimeFlag=signal.sigappsshared.SignalUtilities.verifyEqualTimeValues(this.Engine,lssID);
                        if hasEqualTimeFlag
                            TvString=[lssName,'.TimeValues{1}'];
                        else
                            memberIndex=signal.sigappsshared.SignalUtilities.getMemberIndexLabeledSignalSet(this.Engine,sigID);
                            TvString=[lssName,'.TimeValues{',num2str(memberIndex),'}'];
                        end
                    elseif isempty(TvString)||strcmp(TvString,' ')
                        TvString='t';
                    elseif(strcmp(TvString(end),';'))
                        TvString=TvString(1:end-1);
                    end

                    sigInfoVect(idx).TvString=TvString;

                    Fs=this.Engine.getSignalTmAvgSampleRate(sigID);
                    sigInfoVect(idx).effectiveFs=Fs;

                case{'inherentTimetable','inherentTimeseries'}
                    Fs=this.Engine.getSignalTmAvgSampleRate(sigID);
                    sigInfoVect(idx).effectiveFs=Fs;
                end



                isValid=true;
                if(timeLimits(2)<timeRange(1))||(timeLimits(1)>timeRange(2))
                    isValid=false;
                    invalidIdx=[invalidIdx,idx];
                end

                if(isValid&&isfield(scriptParams.params,'frequencyLimits'))
                    freqLimits=scriptParams.params.frequencyLimits;
                    freqRange=[0,sigInfoVect(idx).effectiveFs/2];
                    if(freqLimits(2)<freqRange(1))||(freqLimits(1)>freqRange(2))
                        invalidIdx=[invalidIdx,idx];
                    end
                end
            end


            sigInfoVect(invalidIdx)=[];
            if isempty(invalidIdx)
                validFlag='all';
            elseif isempty(sigInfoVect)
                validFlag='none';
            else
                validFlag='some';
            end

        end

        function[scriptParams,sigInfoVect]=parseSignalNames(this,scriptParams,sigInfoVect)

            isAllTimeCasesInTableFormat=true;
            for idx=1:numel(sigInfoVect)
                sigID=sigInfoVect(idx).ID;
                sigTmMode=sigInfoVect(idx).tmMode;
                sigTmOrigin=sigInfoVect(idx).tmOrigin;
                sigName=this.Engine.getSignalLabel(sigID);

                sigVarRetrieveCode=[];
                currMode=sigTmMode;
                if strcmp(sigTmMode,'inherentLabeledSignalSet')
                    memberIndex=signal.sigappsshared.SignalUtilities.getMemberIndexLabeledSignalSet(this.Engine,sigID);
                    [memberName,sigName,lssName]=Simulink.sdi.internal.signalanalyzer.Utilities.convertToValidMemberName(sigName);
                    sigVarRetrieveCode=[memberName,' = getSignal(',lssName,',',num2str(memberIndex),');'];
                    currMode=sigInfoVect(idx).tmModeLSS;
                end

                sigROIVarName=sigName;
                if contains(sigName,'(')&&~strcmp(currMode,'inherentTimeseries')

                    strIdx1=strfind(sigName,'(');
                    sigOriginName=sigName(1:strIdx1-1);
                    sigROIVarName=sigName(1:strIdx1-1);
                    strIdx1=strfind(sigName,',');
                    strIdx2=strfind(sigName,')');
                    colIdx=sigName(strIdx1+1:strIdx2-1);
                    sigROIVarName=[sigROIVarName,'_',colIdx,'_ROI'];

                    if strcmp(currMode,'inherentTimetable')
                        sigOrigin='timetableWithMatrix';
                        dotIdx=strfind(sigOriginName,'.');
                        sigOriginName=sigOriginName(1:dotIdx-1);
                        sigROIVarName=strrep(sigROIVarName,'.','_');
                    else
                        sigOrigin='matrix';
                        isAllTimeCasesInTableFormat=false;
                    end
                    sigDataRetreiveCode=sigName;

                elseif contains(sigName,'(')


                    strIdx1=strfind(sigName,'(');
                    sigOriginName=sigName(1:strIdx1(1)-1);
                    sigROIVarName=this.Engine.getSignalLabel(sigID,true);
                    sigROIVarName=[sigROIVarName,'_ROI'];
                    sigROIVarName=strrep(sigROIVarName,'.','_');

                    dotIdx=strfind(sigOriginName,'.');
                    sigOriginName=sigOriginName(1:dotIdx-1);
                    sigDataRetreiveCode=sigName;

                    dims=this.Engine.getSignalSampleDims(sigID);
                    if length(dims)==1
                        sigOrigin='timeseriesWithMatrix';
                        sigDataRetreiveCode=['(:,',sigDataRetreiveCode(strIdx1(1)+1:end-1),')'];
                    else
                        sigOrigin='timeseriesWithMultidim';
                        sigDataRetreiveCode=['(',sigDataRetreiveCode(strIdx1(1)+1:end-1),',:)'];
                    end
                    sigDataRetreiveCode=['squeeze(',sigOriginName,'.Data',sigDataRetreiveCode,')'];

                else
                    if~strcmp(currMode,'samples')&&any(strcmp(sigTmOrigin,{'timetable','timeseries'}))




                        sigOrigin='timetableWithVector';
                        sigOriginName=sigName;
                        sigROIVarName=[sigName,'_ROI'];
                        tblDataColName='Var1';
                        sigDataRetreiveCode=[sigName,'(:,''',tblDataColName,''')'];

                    elseif strcmp(currMode,'inherentTimetable')

                        sigOrigin='timetableWithVector';
                        sigROIVarName=strrep(sigName,'.','_');
                        sigROIVarName=[sigROIVarName,'_ROI'];

                        sigOriginName=sigName;
                        dotIdx=strfind(sigOriginName,'.');
                        sigOriginName=sigOriginName(1:dotIdx-1);
                        tblDataColName=sigName(dotIdx+1:end);

                        sigDataRetreiveCode=[sigOriginName,'(:,''',tblDataColName,''')'];

                    elseif strcmp(currMode,'inherentTimeseries')

                        sigOrigin='timeseriesWithVector';
                        sigOriginName=sigName;
                        dotIdx=strfind(sigOriginName,'.');
                        sigOriginName=sigOriginName(1:dotIdx-1);

                        sigDataRetreiveCode=['squeeze(',sigOriginName,'.Data)'];

                        sigROIVarName=strrep(sigROIVarName,'.','_');
                        sigROIVarName=[sigROIVarName,'_ROI'];
                    else
                        sigOrigin='vector';
                        sigOriginName=sigName;
                        sigROIVarName=[sigName,'_ROI'];
                        sigDataRetreiveCode=[sigName,'(:)'];
                        isAllTimeCasesInTableFormat=false;
                    end
                end


                cellOpenIdx=strfind(sigROIVarName,'{');
                if~isempty(cellOpenIdx)
                    sigROIVarName(cellOpenIdx)='_';
                    cellCloseIdx=strfind(sigROIVarName,'}');
                    sigROIVarName(cellCloseIdx)=[];
                end

                sigInfoVect(idx).origin=sigOrigin;
                sigInfoVect(idx).originName=sigOriginName;
                sigInfoVect(idx).roiVarName=sigROIVarName;
                if~isempty(sigVarRetrieveCode)
                    sigInfoVect(idx).dataRetreiveCode=sprintf('%s\n%s',sigVarRetrieveCode,[sigROIVarName,' = ',sigDataRetreiveCode,';']);
                else
                    sigInfoVect(idx).dataRetreiveCode=[sigROIVarName,' = ',sigDataRetreiveCode,';'];
                end

            end
            scriptParams.isAllTimeCasesInTableFormat=...
            scriptParams.exportAsTimetablePreference||isAllTimeCasesInTableFormat;
        end


        function sigInfoVect=getSignalTimeValuesCodeString(this,scriptParams,sigInfoVect)

            for idx=1:numel(sigInfoVect)
                currMode=sigInfoVect(idx).tmMode;
                if strcmp(currMode,'inherentLabeledSignalSet')
                    currMode=sigInfoVect(idx).tmModeLSS;
                end
                if strcmp(currMode,'samples')
                    sigInfoVect(idx).timeValuesCode='';
                    continue;
                end

                switch sigInfoVect(idx).origin
                case 'inherentLabeledSignalSet'
                    if strcmp(currMode,'inherentTimetable')
                        str=['timeValues = ',sigInfoVect(idx).originName,'.Properties.RowTimes;'];
                        if strcmp(scriptParams.scriptType,'scalogram')
                            str2='sampleRate = ';
                            str3='; % Hz';
                            str=sprintf('%s%0.7g%s\n%s',str2,sigInfoVect(idx).effectiveFs,str3,str);
                        end
                    else
                        str=getTimeValuesCodeByTimeMetadata(this,scriptParams,sigInfoVect(idx));
                    end

                case 'vector'
                    str=getTimeValuesCodeByTimeMetadata(this,scriptParams,sigInfoVect(idx));
                case 'matrix'
                    str=getTimeValuesCodeByTimeMetadata(this,scriptParams,sigInfoVect(idx));
                case 'timetableWithVector'
                    str='';
                    if strcmp(scriptParams.scriptType,'scalogram')
                        str1='sampleRate = ';
                        str2='; % Hz';
                        str=sprintf('%s%0.7g%s',str1,sigInfoVect(idx).effectiveFs,str2);
                    end

                case 'timetableWithMatrix'
                    str=['timeValues = ',sigInfoVect(idx).originName,'.Properties.RowTimes;'];
                    if strcmp(scriptParams.scriptType,'scalogram')
                        str2='sampleRate = ';
                        str3='; % Hz';
                        str=sprintf('%s%0.7g%s\n%s',str2,sigInfoVect(idx).effectiveFs,str3,str);
                    end

                case{'timeseriesWithVector','timeseriesWithMatrix','timeseriesWithMultidim'}
                    str=['timeValues = ',sigInfoVect(idx).originName,'.Time;'];
                end
                sigInfoVect(idx).timeValuesCode=str;
            end

        end

        function str=getTimeValuesCodeByTimeMetadata(this,scriptParams,sigInfo)
            exportAsTimetablePreference=scriptParams.exportAsTimetablePreference;
            currMode=sigInfo.tmMode;
            if strcmp(currMode,'inherentLabeledSignalSet')
                currMode=sigInfo.tmModeLSS;
            end

            switch currMode
            case 'fs'
                str1='sampleRate = ';
                str2='; % Hz';
                str3='startTime = ';
                str4=['; % ',getString(message('SDI:sigAnalyzer:ScriptSeconds'))];

                if exportAsTimetablePreference||...
                    any(strcmp(scriptParams.scriptType,{'spectrogram','scalogram'}))




                    str5=['timeValues = startTime + (0:length(',sigInfo.roiVarName,')-1).''/sampleRate;'];
                    if exportAsTimetablePreference
                        str=sprintf('%s%0.7g%s\n%s%0.7g%s\n%s',str1,sigInfo.Fs,str2,str3,sigInfo.Tstart,str4,str5);
                    else
                        str6='minIdx = timeValues >= timeLimits(1);';
                        str7='maxIdx = timeValues <= timeLimits(2);';
                        str=sprintf('%s%0.7g%s\n%s%0.7g%s\n%s\n%s\n%s',str1,sigInfo.Fs,str2,str3,sigInfo.Tstart,str4,str5,str6,str7);
                    end
                else
                    str5='minIdx = ceil(max((timeLimits(1)-startTime)*sampleRate,0))+1;';
                    str6=['maxIdx = floor(min((timeLimits(2)-startTime)*sampleRate,length(',sigInfo.roiVarName,')-1))+1;'];
                    str=sprintf('%s%0.7g%s\n%s%0.7g%s\n%s\n%s',str1,sigInfo.Fs,str2,str3,sigInfo.Tstart,str4,str5,str6);
                end
            case 'ts'
                str1='sampleTime = ';
                str2=['; % ',getString(message('SDI:sigAnalyzer:ScriptSeconds'))];
                str3='startTime = ';
                str4=['; % ',getString(message('SDI:sigAnalyzer:ScriptSeconds'))];

                if exportAsTimetablePreference||any(strcmp(scriptParams.scriptType,{'spectrogram','scalogram'}))




                    str5=['timeValues = startTime + (0:length(',sigInfo.roiVarName,')-1).''*sampleTime;'];
                    if exportAsTimetablePreference
                        str=sprintf('%s%0.7g%s\n%s%0.7g%s\n%s',str1,sigInfo.Ts,str2,str3,sigInfo.Tstart,str4,str5);
                    else
                        str6='minIdx = timeValues >= timeLimits(1);';
                        str7='maxIdx = timeValues <= timeLimits(2);';
                        str=sprintf('%s%0.7g%s\n%s%0.7g%s\n%s\n%s\n%s',str1,sigInfo.Ts,str2,str3,sigInfo.Tstart,str4,str5,str6,str7);
                    end
                else
                    str5='minIdx = ceil(max((timeLimits(1)-startTime)/sampleTime,0))+1;';
                    str6=['maxIdx = floor(min((timeLimits(2)-startTime)/sampleTime,length(',sigInfo.roiVarName,')-1))+1;'];
                    str=sprintf('%s%0.7g%s\n%s%0.7g%s\n%s\n%s',str1,sigInfo.Ts,str2,str3,sigInfo.Tstart,str4,str5,str6);
                end

            case 'tv'
                str1='timeValues = ';
                str2=';';
                if exportAsTimetablePreference
                    if(strcmp(scriptParams.scriptType,'scalogram'))
                        str5='sampleRate = ';
                        str6='; % Hz';
                        str=sprintf('%s%0.7g%s\n%s%s%s',str5,sigInfo.effectiveFs,str6,str1,sigInfo.TvString,str2);
                    else
                        str=sprintf('%s%s%s',str1,sigInfo.TvString,str2);
                    end
                else
                    if isTvDurationVector(this,sigInfo.TvString)
                        if strcmp(scriptParams.scriptType,'scalogram')
                            str3='minIdx = seconds(timeValues) >= timeLimits(1);';
                            str4='maxIdx = seconds(timeValues) <= timeLimits(2);';
                            str5='sampleRate = ';
                            str6='; % Hz';
                            str=sprintf('%s%0.7g%s\n%s%s%s\n%s\n%s',str5,sigInfo.effectiveFs,str6,str1,sigInfo.TvString,str2,str3,str4);
                        else
                            str3='minIdx = seconds(timeValues) >= timeLimits(1);';
                            str4='maxIdx = seconds(timeValues) <= timeLimits(2);';
                            str=sprintf('%s%s%s\n%s\n%s',str1,sigInfo.TvString,str2,str3,str4);
                        end
                    else
                        if strcmp(scriptParams.scriptType,'scalogram')
                            str3='minIdx = timeValues >= timeLimits(1);';
                            str4='maxIdx = timeValues <= timeLimits(2);';
                            str5='sampleRate = ';
                            str6='; % Hz';
                            str=sprintf('%s%0.7g%s\n%s%s%s\n%s\n%s',str5,sigInfo.effectiveFs,str6,str1,sigInfo.TvString,str2,str3,str4);
                        else
                            str3='minIdx = timeValues >= timeLimits(1);';
                            str4='maxIdx = timeValues <= timeLimits(2);';
                            str=sprintf('%s%s%s\n%s\n%s',str1,sigInfo.TvString,str2,str3,str4);
                        end
                    end
                end
            end
        end


        function str=getTimeUnitsForComment(~,timeMode)
            if strcmp(timeMode,'samples')
                str=getString(message('SDI:sigAnalyzer:ScriptSamples'));
            else
                str=getString(message('SDI:sigAnalyzer:ScriptSeconds'));
            end
        end


        function str=getTimeLimitsCodeString(this,scriptParams,signalRange)
            timeLimits=scriptParams.params.timeLimits;
            timeMode=scriptParams.params.timeMode;
            exportAsTimetablePreference=scriptParams.exportAsTimetablePreference;
            isAllTimeCasesInTableFormat=scriptParams.isAllTimeCasesInTableFormat;

            if nargin>2


                timeLimits(1)=max(timeLimits(1),signalRange(1));
                timeLimits(2)=min(timeLimits(2),signalRange(2));
            end

            timeUnitsStr=getTimeUnitsForComment(this,timeMode);

            if strcmp(timeMode,'samples')


                num1=sprintf('%0.7g',ceil(timeLimits(1)+1));
                num2=sprintf('%0.7g',floor(timeLimits(2)+1));

                str1='timeLimits = ';
                vectStr=['[',num1,' ',num2,']; % '];
            else
                num1=sprintf('%0.7g',timeLimits(1));
                num2=sprintf('%0.7g',timeLimits(2));

                if exportAsTimetablePreference||isAllTimeCasesInTableFormat
                    str1='timeLimits = seconds(';
                    vectStr=['[',num1,' ',num2,']); % '];
                else
                    str1='timeLimits = ';
                    vectStr=['[',num1,' ',num2,']; % '];
                end

            end
            str=sprintf('%s%s%s',str1,vectStr,timeUnitsStr);

        end


        function h1Line=getH1LineForScriptType(~,scriptType)
            switch scriptType
            case{'roiBetweenLimits','roiBetweenCursors'}
                h1Line=getString(message('SDI:sigAnalyzer:ScriptH1LineROI'));
            case 'spectrum'
                h1Line=getString(message('SDI:sigAnalyzer:ScriptH1LineSpectrum'));
            case 'persistence'
                h1Line=getString(message('SDI:sigAnalyzer:ScriptH1LinePersistence'));
            case 'spectrogram'
                h1Line=getString(message('SDI:sigAnalyzer:ScriptH1LineSpectrogram'));
            case 'scalogram'
                h1Line=getString(message('SDI:sigAnalyzer:ScriptH1LineScalogram'));
            end
            h1Line=['% ',h1Line];
        end


        function showWarningDialog(~,msgString)
            import signal.sigappsshared.Utilities;
            titleString=getString(message('SDI:sigAnalyzer:GenerateScriptWarnDlgTitle'));
            okStr=getString(message('SDI:sigAnalyzer:Ok'));
            Utilities.displayMsgBox(...
            titleString,...
            msgString,...
            {okStr},...
            0,...
            -1,...
            []);
        end
        function isDurationVector=isTvDurationVector(~,TvDurationVectoStr)
            isDurationVector=false;
            try
                v=evalin('base',TvDurationVectoStr);
                if isduration(v)
                    isDurationVector=true;
                end
            catch

            end
        end
    end



    properties
        Engine;
    end

    properties(Access=private)
        Dispatcher;
    end

    properties(Constant)
        ControllerID='scriptGenerator';
    end
end