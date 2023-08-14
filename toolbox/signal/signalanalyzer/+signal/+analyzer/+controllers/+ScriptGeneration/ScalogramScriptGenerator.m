classdef ScalogramScriptGenerator



    methods(Hidden)

        function str=getParametersCodeString(this,scriptParams)
            p=scriptParams.params;


            freqLimitsStr=getFrequencyLimitsCodeString(this,scriptParams);
            str=sprintf('%s%s','frequencyLimits = ',freqLimitsStr);


            if p.voicesPerOctave~=10
                voicesPerOctaveStr=getVoicesPerOctaveString(this,p);
                str=sprintf('%s\n%s',str,voicesPerOctaveStr);
            end

            if p.timeBandWidth~=60
                timeBandWidthStr=getTimeBandWidthString(this,p);
                str=sprintf('%s\n%s',str,timeBandWidthStr);
            end
        end


        function str=getFunctionCodeString(this,scriptParams,sigInfo)
            freqUnitCodeStr='';
            currMode=sigInfo.tmMode;
            if strcmp(currMode,'inherentLabeledSignalSet')
                currMode=sigInfo.tmModeLSS;
            end
            if strcmp(currMode,'samples')
                freqUnitCodeStr=sprintf('%s \n %s\n %s\n',...
                '%%',...
                ['% ',getString(message('SDI:sigAnalyzer:ConvertFreqUnitComment'))],...
                getConvertFreqUnitCodeString(this,scriptParams));
            end
            limitCWTFrequencyStr=sprintf('\n %s \n %s \n %s\n %s\n',...
            freqUnitCodeStr,...
            '%%',...
            ['% ',getString(message('SDI:sigAnalyzer:LimitFreqLimitsComment'))],...
            getLimitCWTFrequencyString(this,scriptParams,sigInfo));

            p=scriptParams.params;
            str1=['cwt(',sigInfo.roiVarName];
            if strcmp(currMode,'ts')&&~scriptParams.exportAsTimetablePreference
                str1=[str1,',1/sampleTime'];
            elseif~any(strcmp(sigInfo.origin,{'timetableWithVector','timetableWithMatrix'}))&&...
                ~(strcmp(currMode,'samples')||...
                scriptParams.exportAsTimetablePreference)


                str1=[str1,',sampleRate'];
            end
            if p.voicesPerOctave~=10
                str1=appendStringParamWithEllipsis(this,str1,'''VoicesPerOctave'',voicesPerOctave');
            end
            if p.timeBandWidth~=60
                str1=appendStringParamWithEllipsis(this,str1,'''TimeBandWidth'',timeBandWidth');
            end
            str1=appendStringParamWithEllipsis(this,str1,'''FrequencyLimits'',frequencyLimits');
            str1=[str1,');'];
            wtStr=['WT',sigInfo.roiVarName];
            fStr=['F',sigInfo.roiVarName];
            if numel(scriptParams.signalList)>1
                outputStr=['[',wtStr,', ',fStr,'] = '];
            else
                outputStr='[WT,F] = ';
            end


            str2=[outputStr,str1];
            strComputeSpectrumComment=['% ',getString(message('SDI:sigAnalyzer:GetCWTComment'))];
            strPlotComment=['% ',getString(message('SDI:sigAnalyzer:CallForPlot'))];
            str=sprintf('%s\n%s\n%s\n%s',limitCWTFrequencyStr,strComputeSpectrumComment,strPlotComment,str2);
        end


        function str=getConvertFreqUnitCodeString(~,~)
            str='frequencyLimits =frequencyLimits/2;';
        end


        function str=getLimitCWTFrequencyString(~,scriptParams,sigInfo)
            p=scriptParams.params;
            currMode=sigInfo.tmMode;
            if strcmp(currMode,'inherentLabeledSignalSet')
                currMode=sigInfo.tmModeLSS;
            end
            if p.timeBandWidth~=60
                if strcmp(currMode,'ts')
                    str1='frequencyLimits(1) = max(frequencyLimits(1),...';
                    str2=['cwtfreqbounds(numel(',sigInfo.roiVarName,'),1/sampleTime,...'];
                    str3=['''TimeBandWidth''',',timeBandWidth));'];
                    str=sprintf('%s\n%s\n%s',str1,str2,str3);
                elseif~strcmp(currMode,'samples')
                    str1='frequencyLimits(1) = max(frequencyLimits(1),...';
                    str2=['cwtfreqbounds(numel(',sigInfo.roiVarName,'),sampleRate,...'];
                    str3=['''TimeBandWidth''',',timeBandWidth));'];
                    str=sprintf('%s\n%s\n%s',str1,str2,str3);

                else
                    str1='frequencyLimits(1) = max(frequencyLimits(1),...';
                    str2=['cwtfreqbounds(numel(',sigInfo.roiVarName,'),...'];
                    str3=['''TimeBandWidth''',',timeBandWidth));'];
                    str=sprintf('%s\n%s\n%s',str1,str2,str3);
                end
            else
                if strcmp(currMode,'ts')
                    str1='frequencyLimits(1) = max(frequencyLimits(1),...';
                    str2=['cwtfreqbounds(numel(',sigInfo.roiVarName,'),1/sampleTime));'];
                    str=sprintf('%s\n%s\n%s',str1,str2);
                elseif~strcmp(currMode,'samples')
                    str1='frequencyLimits(1) = max(frequencyLimits(1),...';
                    str2=['cwtfreqbounds(numel(',sigInfo.roiVarName,'),sampleRate));'];

                    str=sprintf('%s\n%s\n%s',str1,str2);
                else
                    str1='frequencyLimits(1) = max(frequencyLimits(1),...';
                    str2=['cwtfreqbounds(numel(',sigInfo.roiVarName,')));'];
                    str=sprintf('%s\n%s\n%s',str1,str2);
                end
            end
        end






        function str=getVoicesPerOctaveString(~,params)
            voicesPerOctave=params.voicesPerOctave;
            str=sprintf('%s%0.7g%s','voicesPerOctave = ',voicesPerOctave,';');
        end


        function str=getTimeBandWidthString(~,params)
            timeBandWidth=params.timeBandWidth;
            str=sprintf('%s%0.7g%s%s','timeBandWidth = ',timeBandWidth,';');
        end



        function str=getFrequencyUnitsForComment(~,timeMode)
            if strcmp(timeMode,'samples')
                str='Normalized frequency (*pi rad/sample)';
            else
                str='Hz';
            end
        end


        function str=getTimeUnitsForComment(~,timeMode)
            if strcmp(timeMode,'samples')
                str=getString(message('SDI:sigAnalyzer:ScriptSamples'));
            else
                str=getString(message('SDI:sigAnalyzer:ScriptSeconds'));
            end
        end


        function str=getFrequencyLimitsCodeString(this,scriptParams,freqRange)
            frequencyLimits=scriptParams.params.frequencyLimits;
            timeMode=scriptParams.params.timeMode;

            if nargin>2


                frequencyLimits(1)=max(frequencyLimits(1),freqRange(1));
                frequencyLimits(2)=min(frequencyLimits(2),freqRange(2));
            end

            num1=sprintf('%0.7g',frequencyLimits(1));
            num2=sprintf('%0.7g',frequencyLimits(2));

            timeUnitsStr=getFrequencyUnitsForComment(this,timeMode);
            str=['[',num1,' ',num2,']; % ',timeUnitsStr];
        end



        function str=appendStringParamWithEllipsis(~,strIn,paramStr)
            ellipStr=', ...';
            str=sprintf('%s%s\n%s',strIn,ellipStr,paramStr);
        end
    end

end

