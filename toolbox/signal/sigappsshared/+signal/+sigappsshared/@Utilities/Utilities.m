classdef Utilities<handle



    methods(Static,Hidden)

        function m=getTimeMultiplier(units)

            switch units
            case 'ns'
                m=1e-9;
            case 'us'
                m=1e-6;
            case 'ms'
                m=1e-3;
            case 's'
                m=1;
            case 'minutes'
                m=60;
            case 'hours'
                m=60*60;
            case 'days'
                m=60*60*24;
            case 'years'
                m=60*60*24*365;
            end
        end


        function m=getFrequencyMultiplier(units)

            switch lower(units)
            case 'hz'
                m=1;
            case 'khz'
                m=1e3;
            case 'mhz'
                m=1e6;
            case 'ghz'
                m=1e9;
            end
        end


        function userData=displayMsgBox(title,msg,buttons,defaultButton,escOption,cb)%#ok<INUSD>

            arg.Title=title;
            arg.Msg=msg;
            arg.Buttons=buttons;
            arg.Default=defaultButton;
            arg.EscapeOption=escOption;
            arg.CbChannel='/sdi2/msgBoxResponse';
            arg.CbUserData=char(matlab.lang.internal.uuid());
            message.publish('/sdi2/displayMsgBox',arg);
            userData=arg.CbUserData;
        end


        function flag=validateNonUniformTimeValues(tv)






            dtv=diff(tv);
            medianTimeInterval=median(dtv);
            meanTimeInterval=mean(dtv);
            flag=medianTimeInterval/meanTimeInterval<100&&meanTimeInterval/medianTimeInterval<100;
        end


        function publishSignalCreationCompleted(action)

            if nargin==0
                action='';
            end
            message.publish('/sdi2/signalCreationCompleted',action);
        end


        function publishCustomPreprocessAddCompleted(functionName)

            message.publish('/sdi2/customPreprocessAddCompleted',functionName);
        end


        function effSampleRate=getEffectiveSampleRate(sigID)
            eng=Simulink.sdi.Instance.engine;
            tmMode=eng.getSignalTmMode(sigID);
            if strcmp(tmMode,'samples')
                effSampleRate=2;
            elseif strcmp(tmMode,'fs')
                effSampleRate=eng.getSignalTmSampleRate(sigID);
                units=eng.getSignalTmSampleRateUnits(sigID);
                effSampleRate=effSampleRate*signal.sigappsshared.Utilities.getFrequencyMultiplier(units);
            elseif strcmp(tmMode,'ts')
                effSampleTime=eng.getSignalTmSampleTime(sigID);
                units=eng.getSignalTmSampleTimeUnits(sigID);
                effSampleTime=effSampleTime*signal.sigappsshared.Utilities.getTimeMultiplier(units);
                effSampleRate=1/effSampleTime;
            else
                effSampleRate=eng.getSignalTmAvgSampleRate(sigID);
            end
        end


        function y=convertFromHzToFreqUnits(value,units)
            y=value/signal.sigappsshared.Utilities.getFrequencyMultiplier(units);
        end


        function y=convertFromSecondsToTimeUnits(value,units)
            y=value/signal.sigappsshared.Utilities.getTimeMultiplier(units);
        end


        function bIsValid=isValidDataType(value)
            bIsValid=isa(value,'double')&&~isscalar(value)...
            &&isvector(value)...
            &&~issparse(value);
        end


        function commaSeperateString=convertToCommaSeperateString(input)

            commaSeperateString="";
            for idx=1:length(input)
                if idx==1
                    commaSeperateString=input{idx};
                else
                    commaSeperateString=commaSeperateString+","+input{idx};
                end
            end
        end


        function params=parseCommaSeperateString(input)

            inputs=strsplit(input,',');
            params=cell(length(inputs),1);
            for idx=1:length(inputs)
                params{idx}=str2num(inputs{idx});
                if isempty(params{idx})

                    inputs{idx}=strrep(inputs{idx},'''','');
                    params{idx}=sscanf(inputs{idx},'%s');
                end
            end
        end


        function params=parseCommaSeperateStringAsCellOfStrings(input,isFileName)


            if nargin==1
                isFileName=false;
            end
            inputs=strsplit(input,',');
            params=cell(length(inputs),1);
            for idx=1:length(inputs)
                if isempty(params{idx})
                    if~isFileName

                        inputs{idx}=strrep(inputs{idx},'''','');
                    end

                    params{idx}=strtrim(inputs{idx});
                end
            end
            params=string(params);
        end



        function N=getRequiredPrecisionDigits(number)
            if number==0
                N=0;
                return;
            end
            number=abs(number);
            if fix(number)==number
                N=ceil(log10(number));
            else
                N=abs(ceil(log10(eps(number)))-ceil(log10(number)))+1;
            end
        end


        function[dispLabel,dispValue,dispUnits]=getDisplayValuesForAvgSampleRate(avgSampleRate)



            fsLabel="Fs: ";
            tsLabel="Ts: ";
            avgSampleTime=1/avgSampleRate;
            if avgSampleRate==-1
                dispUnits="";
                dispValue="";
                dispLabel="";
            elseif avgSampleRate>=1e9
                dispUnits="GHz";
                dispValue=signal.sigappsshared.Utilities.getFormattedNumberString(avgSampleRate/1e9);
                dispLabel=fsLabel;
            elseif avgSampleRate>=1e6
                dispUnits="MHz";
                dispValue=signal.sigappsshared.Utilities.getFormattedNumberString(avgSampleRate/1e6);
                dispLabel=fsLabel;
            elseif avgSampleRate>=1e3
                dispUnits="kHz";
                dispValue=signal.sigappsshared.Utilities.getFormattedNumberString(avgSampleRate/1e3);
                dispLabel=fsLabel;
            elseif avgSampleRate>=1
                dispUnits="Hz";
                dispValue=signal.sigappsshared.Utilities.getFormattedNumberString(avgSampleRate);
                dispLabel=fsLabel;
            elseif avgSampleTime>=60*60*24*365
                dispUnits=signal.sigappsshared.Utilities.getTranslatedTimeUnits("years");
                dispValue=signal.sigappsshared.Utilities.getFormattedNumberString(avgSampleTime/(60*60*24*365));
                dispLabel=tsLabel;
            elseif avgSampleTime>=60*60*24
                dispUnits=signal.sigappsshared.Utilities.getTranslatedTimeUnits("days");
                dispValue=signal.sigappsshared.Utilities.getFormattedNumberString(avgSampleTime/(60*60*24));
                dispLabel=tsLabel;
            elseif avgSampleTime>=60*60
                dispUnits=signal.sigappsshared.Utilities.getTranslatedTimeUnits("hours");
                dispValue=signal.sigappsshared.Utilities.getFormattedNumberString(avgSampleTime/(60*60));
                dispLabel=tsLabel;
            elseif avgSampleTime>=60
                dispUnits=signal.sigappsshared.Utilities.getTranslatedTimeUnits("minutes");
                dispValue=signal.sigappsshared.Utilities.getFormattedNumberString(avgSampleTime/60);
                dispLabel=tsLabel;
            else
                dispUnits="s";
                dispValue=signal.sigappsshared.Utilities.getFormattedNumberString(avgSampleTime);
                dispLabel=tsLabel;
            end
        end


        function[dispValue,dispUnits]=getDisplayValuesForStartTime(startTime)



            if abs(startTime)>=60*60*24*365
                dispUnits=signal.sigappsshared.Utilities.getTranslatedTimeUnits("years");
                dispValue=signal.sigappsshared.Utilities.getFormattedNumberString(startTime/(60*60*24*365));
            elseif abs(startTime)>=60*60*24
                dispUnits=signal.sigappsshared.Utilities.getTranslatedTimeUnits("days");
                dispValue=signal.sigappsshared.Utilities.getFormattedNumberString(startTime/(60*60*24));
            elseif abs(startTime)>=60*60
                dispUnits=signal.sigappsshared.Utilities.getTranslatedTimeUnits("hours");
                dispValue=signal.sigappsshared.Utilities.getFormattedNumberString(startTime/(60*60));
            elseif abs(startTime)>=60
                dispUnits=signal.sigappsshared.Utilities.getTranslatedTimeUnits("minutes");
                dispValue=signal.sigappsshared.Utilities.getFormattedNumberString(startTime/60);
            elseif abs(startTime)>=1||startTime==0
                dispUnits="s";
                dispValue=signal.sigappsshared.Utilities.getFormattedNumberString(startTime);
            elseif abs(startTime)>=1e-3
                dispValue=signal.sigappsshared.Utilities.getFormattedNumberString(startTime*1e3);
                dispUnits="ms";
            elseif abs(startTime)>=1e-6
                dispValue=signal.sigappsshared.Utilities.getFormattedNumberString(startTime*1e6);
                dispUnits="us";
            elseif abs(startTime)>=1e-9
                dispValue=signal.sigappsshared.Utilities.getFormattedNumberString(startTime*1e9);
                dispUnits="ns";
            else
                dispValue=signal.sigappsshared.Utilities.getFormattedNumberString(startTime*1e12);
                dispUnits="ps";
            end
        end

        function y=getTranslatedTimeUnits(timeUnits)
            if timeUnits=="minutes"
                y=getString(message('SDI:sdi:Minutes'));
            elseif timeUnits=="hours"
                y=getString(message('SDI:sdi:Hours'));
            elseif timeUnits=="days"
                y=getString(message('SDI:sdi:Days'));
            elseif timeUnits=="years"
                y=getString(message('SDI:sdi:Years'));
            elseif timeUnits=="ns"
                y="ns";
            elseif timeUnits=="us"
                y="us";
            elseif timeUnits=="ms"
                y="ms";
            elseif timeUnits=="s"
                y="s";
            end
        end

        function y=getFormattedNumberString(val)
            if val==0
                y=sprintf('%d',val);
            else
                if abs(val)<1e-6||abs(val)>1e6
                    y=sprintf('%.7g',val);
                elseif abs(val)<1e-3||abs(val)>1e3
                    y=sprintf('%.4g',val);
                else
                    if abs(val)==ceil(abs(val))
                        y=sprintf('%d',val);
                    else
                        y=sprintf('%.4f',val);
                    end
                end
            end
        end

        function[v,errStr]=evaluateValue(value,type,nonnegativeFlag)




















            if nargin<2
                type='scalar';
            end

            if nargin<3
                nonnegativeFlag=false;
            end



            if strcmp(type,'timevector')
                errStr='';
                try
                    v=evalin('base',value);
                    if~isnumeric(v)&&~isduration(v)
                        v=[];
                        errStr=getString(message('SDI:dialogs:NotNumericOrDuration'));
                    end

                    if isempty(errStr)&&isduration(v)
                        v=seconds(v);
                    end
                catch
                    [v,errStr]=evaluatevars(value);
                end
            else
                [v,errStr]=evaluatevars(value);
            end

            if isempty(errStr)

                if strcmp(type,'scalar')
                    try
                        if isempty(nonnegativeFlag)
                            validateattributes(v,{'numeric'},...
                            {'scalar','real','finite'});
                        elseif nonnegativeFlag
                            validateattributes(v,{'numeric'},...
                            {'nonnegative','scalar','real','finite'});
                        else
                            validateattributes(v,{'numeric'},...
                            {'positive','scalar','real','finite'});
                        end
                    catch e
                        errStr=e.message;
                    end
                end

                if strcmp(type,'vector')
                    try
                        validateattributes(v,{'numeric'},{'vector','real','finite'});
                    catch e
                        errStr=e.message;
                    end
                end

                if strcmp(type,'timevector')
                    try


                        validateattributes(v,{'numeric','duration'},{'vector','real','finite'});
                    catch e
                        errStr=e.message;
                    end
                end
            end
        end

        function flag=checkNumericValue(value)
            flag=isnumeric(value)&&ndims(value)<=2&&~isscalar(value)&&allfinite(value(:))&&~issparse(value);
        end

        function flag=checkCellOfMatrix(value)


            flag=iscell(value)&&all(cellfun(@signal.sigappsshared.Utilities.checkNumericValueForCell,value));
        end

        function flag=checkNumericValueForCell(value)
            flag=isnumeric(value)&&ndims(value)<=2&&~isscalar(value)&&allfinite(value(:))&&~issparse(value);
        end

        function flag=checkCellOfTimetables(value)


            flag=iscell(value)&&all(cellfun(@signal.sigappsshared.Utilities.checkTimetable,value));
        end

        function flag=checkTimetable(value)
            flag=istimetable(value)&&isduration(value.Properties.RowTimes)&&...
            all(varfun(@signal.sigappsshared.Utilities.checkNumericValue,value,'OutputFormat','uniform'));
        end

        function flag=checkAllInCellIsTimetable(value)
            flag=all(cellfun(@istimetable,value));
        end

        function flag=checkAnyInCellIsTimetable(value)
            flag=any(cellfun(@istimetable,value));
        end

        function fs=getEffectiveFsOfTimeTable(value)
            time=value.Properties.RowTimes;
            if(isa(time,'duration'))
                time=seconds(time);
            end
            isValid=signal.internal.validateNonUniformTimeValues(time);
            fs=nan;
            if isValid
                fs=signal.internal.utilities.getEffectiveFs(time);
            end
        end

        function fs=getAllFsOfTimetable(value)
            fs=cellfun(@signal.sigappsshared.Utilities.getEffectiveFsOfTimeTable,value);
        end

        function args=getMetaStruct(mode,Fs,Ts,St,Tv,clientID)




            startTime='';
            sampleTimeOrRate='';
            timeVector='';

            switch mode
            case 'fs'
                startTime=St;
                sampleTimeOrRate=Fs;
                timeVector='';
            case 'ts'
                startTime=St;
                sampleTimeOrRate=Ts;
                timeVector='';
            case 'samples'
                startTime='';
                sampleTimeOrRate='';
                timeVector='';
            case 'tv'
                startTime='';
                sampleTimeOrRate='';
                timeVector=Tv(:);
            case 'inherent'
                startTime='';
                sampleTimeOrRate='';
                timeVector='';
            case 'inherentLabeledSignalSet'
                startTime='';
                sampleTimeOrRate='';
                timeVector='';
            case 'file'
                startTime='';
                sampleTimeOrRate=Fs;
                timeVector='';
            end

            data.startTime=startTime;
            data.signalIDs=[];
            data.tmMode=mode;
            data.runIDs=[];
            data.clientID=str2double(clientID);
            data.sampleTimeOrRate=sampleTimeOrRate;
            data.timeVector=timeVector;

            opts.appName="SignalLabeler";
            opts.reImportExistingVarNames=false;
            opts.warnIfExceedsMaxNumColumns=false;

            args.clientID=clientID;
            args.data=data;
            args.opts=opts;
        end


        function baseColors=getBaseColors()
            baseColors={[0.000,0.447,0.741],...
            [0.850,0.325,0.098],...
            [0.929,0.694,0.125],...
            [0.494,0.184,0.556],...
            [0.466,0.674,0.188],...
            [0.301,0.745,0.933],...
            [0.635,0.078,0.184],...
            [0.074,0.624,1.000],...
            [1.000,0.412,0.161],...
            [0.718,0.275,1.000],...
            [0.392,0.831,0.075],...
            [1.000,0.075,0.651],...
            [0.996,0.200,0.039],...
            [0.133,0.710,0.451]};
        end
    end
end

