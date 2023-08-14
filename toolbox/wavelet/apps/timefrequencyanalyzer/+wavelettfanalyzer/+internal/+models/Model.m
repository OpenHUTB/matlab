classdef Model<handle




    properties(Access=private)
SignalInfo
CWTInfo
PlotInfo
CurrentSignalName
    end

    properties(Access=private,Hidden,Constant)
        UseBackgroundPool=false
    end

    methods(Hidden)

        function this=Model()
            this.reset();
        end


        function reset(this)
            this.SignalInfo=containers.Map;
            this.CWTInfo=containers.Map;
            this.PlotInfo.separatePlots=getpref("wavelettfanalyzer","separatePlots",true);
            this.PlotInfo.boundaryLine=getpref("wavelettfanalyzer","boundaryLine",true);
            this.PlotInfo.shadeRegion=getpref("wavelettfanalyzer","shadeRegion",true);

        end

        function empty=isEmpty(this)
            empty=this.SignalInfo.Count==0;
        end

        function exists=signalExists(this,name)
            exists=this.SignalInfo.isKey(name);
        end

        function[data,info]=importSignal(this,name,data,computeScalogram)
            isTimetable=istimetable(data);
            if isTimetable
                time=data.Properties.RowTimes;
                if isdatetime(time)
                    sampleRate=1/(mean(diff(seconds(time-time(1)))));
                else
                    sampleRate=1/(mean(diff(seconds(time))));
                end
                [data,variablenames]=wavelet.internal.CheckAndExtractTT(data);
                name=name+"_"+variablenames{1};
            else
                sampleRate=1;
                time=0:1/sampleRate:(length(data)*1/sampleRate)-1/sampleRate;
            end

            if computeScalogram
                info=this.getDefaultParameters(length(data),sampleRate);
                [waveletTransform,info.normalizedFrequency,info.adjustedFrequency]=this.computeCWT(data,sampleRate,info);
                info.scalogram=wavelet.internal.cwt.complexToScalogram(waveletTransform,"mag");
                info.scalogramIsComputed=true;
            else
                info.scalogramIsComputed=false;
            end

            info.name=name;
            info.length=length(data);
            info.isTimetable=isTimetable;
            info.isNormFreq=~isTimetable;
            info.isComplex=~isreal(data);
            info.sampleRate=sampleRate;
            info.time=time;
        end

        function defaults=updateScalogramDefaultParams(this)








            info=this.CWTInfo(this.CurrentSignalName);


            defaults=this.getDefaultParameters(info.length,info.sampleRate);

        end

        function info=updateScalogramDefaultParamsWithCompute(this)





            info=this.CWTInfo(this.CurrentSignalName);
            data=this.SignalInfo(this.CurrentSignalName);


            defaults=this.getDefaultParameters(info.length,info.sampleRate);

            [waveletTransform,info.normalizedFrequency,info.adjustedFrequency]=this.computeCWT(data,info.sampleRate,defaults);
            info.scalogram=wavelet.internal.cwt.complexToScalogram(waveletTransform,"mag");

            info.waveletName=defaults.waveletName;
            info.morseParams=defaults.morseParams;
            info.voices=defaults.voices;
            info.extendSignal=defaults.extendSignal;
            info.freqLims=defaults.freqLims;
            info.scalogramIsComputed=true;
        end

        function info=updateScalogram(this,args)
            data=this.SignalInfo(this.CurrentSignalName);
            info=this.CWTInfo(this.CurrentSignalName);
            [waveletTransform,info.normalizedFrequency,info.adjustedFrequency]=this.computeCWT(data,info.sampleRate,args);
            info.scalogram=wavelet.internal.cwt.complexToScalogram(waveletTransform,"mag");

            info.waveletName=args.waveletName;
            info.morseParams=args.morseParams;
            info.voices=args.voices;
            info.extendSignal=args.extendSignal;
            info.freqLims=args.freqLims;
        end

        function info=updateTimeSettings(this,isNormFreq,sampleRate)
            info=this.CWTInfo(this.CurrentSignalName);
            info.time=0:1/sampleRate:(info.length*1/sampleRate)-1/sampleRate;
            info.isNormFreq=isNormFreq;

            data=this.SignalInfo(this.CurrentSignalName());
            info.freqLims=this.getFrequencyBounds(info.length,sampleRate,info.waveletName,info.morseParams);
            [waveletTransform,info.normalizedFrequency,info.adjustedFrequency]=this.computeCWT(data,sampleRate,info);
            info.scalogram=wavelet.internal.cwt.complexToScalogram(waveletTransform,"mag");
            info.sampleRate=sampleRate;
        end

        function[waveletTransform,normalizedFrequency,adjustedFrequency]=computeCWT(this,data,sampleRate,params)
            if params.extendSignal
                boundary="reflection";
            else
                boundary="periodic";
            end

            defaultFreqLims=this.getFrequencyBounds(length(data),sampleRate,params.waveletName,params.morseParams);
            usingDefaultFreqLims=all(abs(defaultFreqLims-params.freqLims)<1e-4);
            if usingDefaultFreqLims



                if strcmp(params.waveletName,"morse")
                    [normalizedMinFrequency,normalizedMaxFrequency]=cwtfreqbounds(length(data),...
                    "Wavelet",params.waveletName,"WaveletParameters",[params.morseParams(1),params.morseParams(2)]);
                else
                    [normalizedMinFrequency,normalizedMaxFrequency]=cwtfreqbounds(length(data),"Wavelet",params.waveletName);
                end
            else
                [validMinFreq,validMaxFreq]=wavelet.internal.cwt.validFreqRange(length(data),sampleRate,params.freqLims(1),params.freqLims(2),...
                params.waveletName,params.morseParams,params.voices);
                params.freqLims=[validMinFreq,validMaxFreq];
                normalizedMinFrequency=params.freqLims(1)/sampleRate;
                normalizedMaxFrequency=params.freqLims(2)/sampleRate;
            end

            if strcmp(params.waveletName,"morse")
                filterBank=cwtfilterbank("SignalLength",length(data),...
                "Wavelet",params.waveletName,"VoicesPerOctave",params.voices,"Boundary",boundary,...
                "FrequencyLimits",[normalizedMinFrequency,normalizedMaxFrequency],"WaveletParameters",params.morseParams);
            else
                filterBank=cwtfilterbank("SignalLength",length(data),...
                "Wavelet",params.waveletName,"VoicesPerOctave",params.voices,"Boundary",boundary,...
                "FrequencyLimits",[normalizedMinFrequency,normalizedMaxFrequency]);
            end
            [waveletTransform,normalizedFrequency]=filterBank.wt(data);
            adjustedFrequency=normalizedFrequency*sampleRate;
        end

        function renameSignal(this,oldName,newName)
            signal=this.SignalInfo(oldName);
            cwtInfo=this.CWTInfo(this.CurrentSignalName);
            cwtInfo.name=newName;

            this.SignalInfo.remove(oldName);
            this.CWTInfo.remove(oldName);

            this.SignalInfo(newName)=signal;
            this.CWTInfo(newName)=cwtInfo;
            this.setCurrentSignalName(newName);
        end

        function duplicateSignal(this,duplicateName)
            signal=this.SignalInfo(this.CurrentSignalName);
            info=this.CWTInfo(this.CurrentSignalName);
            info.name=duplicateName;

            this.SignalInfo(duplicateName)=signal;
            this.CWTInfo(duplicateName)=info;

            this.CurrentSignalName=duplicateName;
        end

        function deleteSignal(this)
            this.SignalInfo.remove(this.CurrentSignalName);
            this.CWTInfo.remove(this.CurrentSignalName);
            this.CurrentSignalName=[];
        end

        function[import,errorMessage]=checkTimetables(this,names,datas)
            for idx=1:length(names)
                name=names(idx);
                data=datas(names(idx));
                [import,errorMessage]=wavelettfanalyzer.internal.Utilities.checkTimetable(data,name);
                if~import
                    return
                end
            end
        end

        function exists=checkSignalsExist(this,names,datas)
            exists=false;
            for idx=1:length(names)
                data=datas(names(idx));
                name=names(idx);
                if istimetable(data)
                    variablenames=data.Properties.VariableNames;
                    name=name+"_"+variablenames{1};
                end
                if this.signalExists(name)
                    exists=true;
                end
            end
        end


        function storeSignal(this,name,data)
            this.SignalInfo(name)=data;
        end

        function storeCWTInfo(this,name,info)
            if isfield(info,"scalogram")
                info=rmfield(info,"scalogram");
            end
            this.CWTInfo(name)=info;
        end

        function setCurrentSignalName(this,name)
            this.CurrentSignalName=name;
        end

        function setSeparatePlots(this,value)
            this.PlotInfo.separatePlots=value;
            setpref("wavelettfanalyzer","separatePlots",value);
        end

        function setBoundaryLine(this,value)
            this.PlotInfo.boundaryLine=value;
            setpref("wavelettfanalyzer","boundaryLine",value);
        end

        function setShadeRegion(this,value)
            this.PlotInfo.shadeRegion=value;
            setpref("wavelettfanalyzer","shadeRegion",value);
        end



        function info=getCWTInfo(this)
            info=this.CWTInfo(this.CurrentSignalName);
        end

        function defaults=getDefaultParameters(this,length,sampleRate)
            defaults.waveletName="morse";
            defaults.morseParams=[3,60];
            defaults.voices=10;
            defaults.extendSignal=true;
            defaults.freqLims=this.getFrequencyBounds(length,sampleRate,"morse",[3,60]);
        end

        function tableData=getTableData(this,name)
            info=this.CWTInfo(name);
            if info.isComplex
                type="Complex";
            else
                type="Real";
            end
            tableData=[info.name,type];
        end

        function updatePlotData=getUpdatePlotData(this)
            info=this.CWTInfo(this.CurrentSignalName);
            updatePlotData.name=info.name;
            updatePlotData.isComplex=info.isComplex;
            updatePlotData.separatePlots=this.PlotInfo.separatePlots;
            updatePlotData.boundaryLine=this.PlotInfo.boundaryLine;
            updatePlotData.shadeRegion=this.PlotInfo.shadeRegion;

        end

        function toolstripData=getToolstripData(this)
            toolstripData=this.CWTInfo(this.CurrentSignalName);
            toolstripData.separatePlots=this.PlotInfo.separatePlots;
            toolstripData.boundaryLine=this.PlotInfo.boundaryLine;
            toolstripData.shadeRegion=this.PlotInfo.shadeRegion;

        end

        function exportData=getExportData(this)
            data=this.SignalInfo(this.CurrentSignalName);
            info=this.CWTInfo(this.CurrentSignalName);
            exportData.coefficients=this.computeCWT(data,info.sampleRate,info);
            exportData.frequencyVector=info.adjustedFrequency;
            time=info.time;
            exportData.timeVector=time.';
        end

        function currentSignalName=getCurrentSignalName(this)
            currentSignalName=this.CurrentSignalName;
        end

        function isTimetable=getIsTimetable(this,name)
            info=this.CWTInfo(name);
            isTimetable=info.isTimetable;
        end

        function isComplex=getIsComplex(this,name)
            info=this.CWTInfo(name);
            isComplex=info.isComplex;
        end

        function scalogramIsComputed=getScalogramIsComputed(this)
            info=this.CWTInfo(this.CurrentSignalName);
            scalogramIsComputed=info.scalogramIsComputed;
        end

        function freqBounds=getFrequencyBounds(this,length,sampleRate,waveletName,morseParams)
            if strcmp(waveletName,"morse")
                [min,max]=cwtfreqbounds(length,sampleRate,"Wavelet",waveletName,"WaveletParameters",[morseParams(1),morseParams(2)]);
            else
                [min,max]=cwtfreqbounds(length,sampleRate,"Wavelet",waveletName);
            end
            freqBounds=[min,max];
        end

        function default=frequencyLimitsAreDefault(this,freqLims)
            info=this.CWTInfo(this.CurrentSignalName);
            freqBounds=this.getFrequencyBounds(info.length,info.sampleRate,info.waveletName,info.morseParams);
            default=all(abs(freqBounds-freqLims)<1e-4);
        end


        function freqLims=getValidFreqLims(this,freqLims,voices,waveletName,morseParams)
            info=this.CWTInfo(this.CurrentSignalName);
            [minFreq,maxFreq]=wavelet.internal.cwt.validFreqRange(info.length,info.sampleRate,freqLims(1),freqLims(2),...
            waveletName,morseParams,voices);
            freqLims=[minFreq,maxFreq];
        end

        function freqLims=getUpdatedFreqLimsSampleRateChanged(this,waveletName,morseParams)
            info=this.CWTInfo(this.CurrentSignalName);
            freqLims=this.getFrequencyBounds(info.length,info.sampleRate,waveletName,morseParams);
        end

        function tf=getUseBackgroundPool(this)
            tf=this.UseBackgroundPool;
        end

        function valid=sampleRateIsValid(this,sampleRate)
            valid=~isnan(sampleRate)&&sampleRate>0;
        end

        function valid=voicesIsValid(this,voices)
            valid=~isnan(voices)&&voices>=1&&voices<=48;
        end

        function valid=freqLimsAreValid(this,freqLims)
            valid=~isnan(freqLims(1))&&~isnan(freqLims(2))&&freqLims(1)<freqLims(2);
        end

        function valid=morseParamsAreValid(this,morseParams)
            symmetry=morseParams(1);
            timeBandwidthProduct=morseParams(2);
            valid=~isnan(symmetry)&&~isnan(timeBandwidthProduct)&&...
            symmetry>=1&&symmetry<=timeBandwidthProduct&&(timeBandwidthProduct/symmetry)<=40;
        end


        function str=getScriptString(this)
            params=this.CWTInfo(this.CurrentSignalName);

            header=wavelet.internal.wtbxfileheader('','wavelet');
            str=sprintf("%s\n\n%s","%Compute scalogram",header);

            defaults.normFreq=params.isNormFreq;
            defaults.waveletIsDefault=strcmp(params.waveletName,"morse");
            defaults.waveletParamsAreDefault=abs(params.morseParams(1)-3)<1e-4&&abs(params.morseParams(2)-60)<1e-4;
            defaults.voicesIsDefault=(params.voices==10);
            defaults.extendSignalIsDefault=params.extendSignal;
            defaults.frequencyLimitsAreDefault=this.frequencyLimitsAreDefault(params.freqLims);

            paramStr=this.getParamString(params,defaults);

            if~strcmp(paramStr,"")
                str=sprintf("%s\n\n%s%s",str,"%Parameters",paramStr);
            end

            if~params.isTimetable
                timeStr=this.getTimeString(params.name);
                str=sprintf("%s\n\n%s\n%s\n",str,"%Compute time vector",timeStr);
            end

            if params.isTimetable
                splitStr=split(params.name,"_");
                sname=splitStr(1);
            else
                sname=params.name;
            end
            str=sprintf("%s\n%s\n%s%s%s\n%s",str,"%Compute CWT","%If necessary, substitute workspace variable name for ",sname," as first input to cwt() function in code below",...
            "%Run the function call below without output arguments to plot the results");
            cwtStr=this.getCWTString(params,defaults);
            str=sprintf("%s\n%s",str,cwtStr);
            str=sprintf("%s\n%s",str,"scalogram = abs(waveletTransform);");
        end

        function paramStr=getParamString(this,params,defaults)
            paramStr="";
            if~params.isTimetable
                sampleRateStr=sprintf("%s%g%s","sampleRate = ",params.sampleRate,";");
                paramStr=sprintf("%s\n%s",paramStr,sampleRateStr);
            end

            if~defaults.waveletIsDefault
                waveletStr=sprintf("%s%s%s","wavelet = '",params.waveletName,"';");
                paramStr=sprintf("%s\n%s",paramStr,waveletStr);
            end

            if defaults.waveletIsDefault&&~defaults.waveletParamsAreDefault
                waveletParamsStr=sprintf("%s%g%s%g%s","waveletParameters = [",params.morseParams(1),",",params.morseParams(2),"];");
                paramStr=sprintf("%s\n%s",paramStr,waveletParamsStr);
            end

            if~defaults.voicesIsDefault
                voicesStr=sprintf("%s%g%s","voicesPerOctave = ",params.voices,";");
                paramStr=sprintf("%s\n%s",paramStr,voicesStr);
            end

            if~defaults.extendSignalIsDefault
                extendSignalStr=sprintf("%s","extendSignal = false;");
                paramStr=sprintf("%s\n%s",paramStr,extendSignalStr);
            end

            if~defaults.frequencyLimitsAreDefault
                freqLimStr=sprintf("%s%g%s%g%s","frequencyLimits = [",params.freqLims(1),",",params.freqLims(2),"];");
                paramStr=sprintf("%s\n%s",paramStr,freqLimStr);
            end
        end

        function str=getTimeString(this,name)
            str=sprintf("%s%s%s","t = 0:1/sampleRate:(length(",name,")*1/sampleRate)-1/sampleRate;");
        end

        function str=getCWTString(this,params,defaults)
            name=params.name;
            if params.isTimetable
                splitStr=split(name,"_");
                name=splitStr(1);
            end
            str=sprintf("%s%s","[waveletTransform,frequency] = cwt(",name);

            if~defaults.normFreq&&~params.isTimetable
                str=sprintf("%s%s",str,", sampleRate");
            end

            if~defaults.waveletIsDefault
                str=sprintf("%s%s%s",str,", wavelet");
            end

            if defaults.waveletIsDefault&&~defaults.waveletParamsAreDefault
                str=sprintf("%s%s\n\t%s",str,",...","WaveletParameters = waveletParameters");
            end

            if~defaults.voicesIsDefault
                str=sprintf("%s%s\n\t%s",str,",...","VoicesPerOctave = voicesPerOctave");
            end

            if~defaults.extendSignalIsDefault
                str=sprintf("%s%s\n\t%s",str,",...","ExtendSignal = extendSignal");
            end

            if~defaults.frequencyLimitsAreDefault
                str=sprintf("%s%s\n\t%s",str,",...","FrequencyLimits = frequencyLimits");
            end

            str=sprintf("%s%s",str,");");
        end
    end

end
