classdef SpectrumScriptGenerator



    methods(Hidden)

        function str=getParametersCodeString(this,scriptParams)
            p=scriptParams.params;
            scriptType=scriptParams.scriptType;


            freqLimitsStr=getFrequencyLimitsCodeString(this,scriptParams);
            str=sprintf('%s%s','frequencyLimits = ',freqLimitsStr);


            if p.beta~=20
                leakageStr=getLeakageString(this,p);
                str=sprintf('%s\n%s',str,leakageStr);
            end

            if any(strcmp(scriptType,{'persistence','spectrogram'}))


                if~strcmp(p.timeResolutionMode,'auto')
                    timeResStr=getTimeResolutionString(this,p);
                    str=sprintf('%s\n%s',str,timeResStr);
                end


                overlapPercentStr=getOverlapPercentString(this,p);
                str=sprintf('%s\n%s',str,overlapPercentStr);

                if strcmp(scriptType,'spectrogram')

                    if p.reassign
                        reassignStr=getReassignString(this,p);
                        str=sprintf('%s\n%s',str,reassignStr);
                    end
                else

                    if~strcmp(p.numPowerBinsMode,'auto')
                        numPowBinsStr=getNumPowerBinsString(this,p);
                        str=sprintf('%s\n%s',str,numPowBinsStr);
                    end
                end
            end
        end


        function str=getFunctionCodeString(this,scriptParams,sigInfo)
            p=scriptParams.params;
            exportAsTimetablePreference=scriptParams.exportAsTimetablePreference;
            scriptType=scriptParams.scriptType;

            str1=['pspectrum(',sigInfo.roiVarName];

            currMode=sigInfo.tmMode;
            if strcmp(currMode,'inherentLabeledSignalSet')
                currMode=sigInfo.tmModeLSS;
            end
            if~exportAsTimetablePreference&&any(strcmp(sigInfo.origin,{'vector','matrix'}))
                if strcmp(currMode,'tv')||...
                    (~strcmp(currMode,'samples')&&strcmp(scriptParams.scriptType,'spectrogram'))


                    str1=[str1,',timeValues'];
                elseif strcmp(currMode,'fs')
                    str1=[str1,',sampleRate'];
                elseif strcmp(currMode,'ts')
                    str1=[str1,',seconds(sampleTime)'];
                end
            end

            if any(strcmp(scriptType,{'persistence','spectrogram'}))
                typeStr=['''',scriptType,''''];
                str1=appendStringParamWithEllipsis(this,str1,typeStr);
            end

            if scriptParams.params.frequencyLimits(1)<0&&~sigInfo.isComplex
                str1=appendStringParamWithEllipsis(this,str1,'''TwoSided'',true');
            end

            str1=appendStringParamWithEllipsis(this,str1,'''FrequencyLimits'',frequencyLimits');

            if p.beta~=20
                str1=appendStringParamWithEllipsis(this,str1,'''Leakage'',leakage');
            end

            if any(strcmp(scriptType,{'persistence','spectrogram'}))
                if~strcmp(p.timeResolutionMode,'auto')
                    str1=appendStringParamWithEllipsis(this,str1,'''TimeResolution'',timeResolution');
                end
                str1=appendStringParamWithEllipsis(this,str1,'''OverlapPercent'',overlapPercent');

                if strcmp(scriptType,'spectrogram')
                    if p.reassign
                        str1=appendStringParamWithEllipsis(this,str1,'''Reassign'',reassignFlag');
                    end
                else
                    if~strcmp(p.numPowerBinsMode,'auto')
                        str1=appendStringParamWithEllipsis(this,str1,'''NumPowerBins'',numPowerBins');
                    end
                end
            end
            str1=[str1,');'];
            pStr=['P',sigInfo.roiVarName];
            fStr=['F',sigInfo.roiVarName];

            if strcmp(scriptType,'spectrum')
                outputStr=['[',pStr,', ',fStr,'] = '];
            elseif strcmp(scriptType,'persistence')
                if numel(scriptParams.signalList)>1
                    pwrStr=['PWR',sigInfo.roiVarName];
                    outputStr=['[',pStr,', ',fStr,', ',pwrStr,'] = '];
                else
                    outputStr='[P,F,PWR] = ';
                end
            else
                if numel(scriptParams.signalList)>1
                    tStr=['T',sigInfo.roiVarName];
                    outputStr=['[',pStr,', ',fStr,', ',tStr,'] = '];
                else
                    outputStr='[P,F,T] = ';
                end
            end

            str2=[outputStr,str1];
            strComputeSpectrumComment=['% ',getString(message('SDI:sigAnalyzer:GetSpectralEstimatesComment'))];
            strPlotComment=['% ',getString(message('SDI:sigAnalyzer:CallForPlot'))];
            str=sprintf('%s\n%s\n%s',strComputeSpectrumComment,strPlotComment,str2);
        end





        function str=getLeakageString(this,params)
            leakage=getLeakageFromBeta(this,params.beta);
            str=sprintf('%s%0.7g%s','leakage = ',leakage,';');
        end


        function str=getTimeResolutionString(this,params)
            tres=params.timeResolution;
            if strcmp(params.timeMode,'samples')
                tres=floor(tres);
            end
            unitsStr=getTimeUnitsForComment(this,params.timeMode);
            str=sprintf('%s%0.7g%s%s','timeResolution = ',tres,'; % ',unitsStr);
        end


        function str=getOverlapPercentString(~,params)
            str=sprintf('%s%0.7g%s','overlapPercent = ',params.overlapPercent,';');
        end


        function str=getReassignString(~,params)
            if params.reassign
                str=sprintf('%s','reassignFlag = true;');
            else
                str=sprintf('%s','reassignFlag = false;');
            end
        end


        function str=getNumPowerBinsString(~,params)
            str=sprintf('%s%0.7g%s','numPowerBins = ',params.numPowerBins,';');
        end


        function str=getMinThresholdString(~,params)
            str=sprintf('%s%0.7g%s','minThreshold = ',params.minThreshold,';');
        end



        function str=getFrequencyUnitsForComment(~,timeMode)
            if strcmp(timeMode,'samples')
                str='Normalized frequency (rad/sample)';
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

            timeUnitsStr=getFrequencyUnitsForComment(this,timeMode);

            num1=sprintf('%0.7g',frequencyLimits(1));
            num2=sprintf('%0.7g',frequencyLimits(2));
            if strcmp(timeMode,'samples')
                str=['[',num1,' ',num2,']*pi; % ',timeUnitsStr];
            else
                str=['[',num1,' ',num2,']; % ',timeUnitsStr];
            end
        end


        function leakage=getLeakageFromBeta(~,beta)
            leakage=1-(beta/40);
        end


        function str=appendStringParamWithEllipsis(~,strIn,paramStr)
            ellipStr=', ...';
            str=sprintf('%s%s\n%s',strIn,ellipStr,paramStr);
        end
    end

end

