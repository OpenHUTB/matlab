classdef SimulationResults<handle

    properties
ParamNames
ParamValues

WaveNames

XaxisLabels

XaxisUnits

XaxisScales

XaxisValues

YaxisLabels

YaxisUnits

YaxisScales

YaxisValues

        isSameLabelsX=false;
        isSameLabelsY=false;
        isSameUnitsX=false;
        isSameUnitsY=false;
        isSameScalesX=false;
        isSameScalesY=false;
        isSameValuesX=false;
        isSameValuesY=false;
    end


    methods
        function obj=SimulationResults(varargin)

            narginchk(0,11)
            if nargin>=2
                obj.ParamNames=varargin{1};
                obj.ParamValues=varargin{2};
            end
            if nargin>=3
                obj.WaveNames=varargin{3};
            end
            if nargin>=7
                obj.XaxisLabels=varargin{4};
                obj.XaxisUnits=varargin{5};
                obj.XaxisScales=varargin{6};
                obj.XaxisValues=varargin{7};
            end
            if nargin>=11
                obj.YaxisLabels=varargin{8};
                obj.YaxisUnits=varargin{9};
                obj.YaxisScales=varargin{10};
                obj.YaxisValues=varargin{11};
            end
        end


        function setParam(obj,name,value)
            [~,index]=obj.getParamValue(name);
            if index==0

                index=length(obj.ParamNames)+1;
                obj.ParamNames{index}=name;
            end

            obj.ParamValues{index}=value;
        end

        function[value,index]=getParamValue(obj,name)
            if~isempty(name)
                for index=1:length(obj.ParamNames)
                    if strcmp(obj.ParamNames{index},name)
                        value=obj.ParamValues{index};
                        return;
                    end
                end
            end
            index=0;
            value=[];
        end


        function preAllocateWaveforms(obj,size)
            if size<1

                obj.WaveNames=[];
                obj.XaxisLabels=[];
                obj.XaxisUnits=[];
                obj.XaxisScales=[];
                obj.XaxisValues=[];
                obj.YaxisLabels=[];
                obj.YaxisUnits=[];
                obj.YaxisScales=[];
                obj.YaxisValues=[];
            else
                obj.WaveNames{size}=[];

                obj.XaxisLabels{size}=[];
                obj.XaxisUnits{size}=[];
                obj.XaxisScales{size}=[];
                obj.XaxisValues{size}=[];


                obj.YaxisLabels{size}=[];
                obj.YaxisUnits{size}=[];
                obj.YaxisScales{size}=[];
                obj.YaxisValues{size}=[];
            end
        end


        function setXaxis(obj,waveformName,label,unit,scale,values,index)
            if index>0

                obj.WaveNames{index}=waveformName;
            else
                [~,~,~,~,index]=obj.getXaxis(waveformName);
            end
            if index==0

                index=length(obj.WaveNames)+1;
                obj.WaveNames{index}=waveformName;
            end

            obj.XaxisLabels{index}=label;
            obj.XaxisUnits{index}=unit;
            obj.XaxisScales{index}=scale;
            obj.XaxisValues{index}=values;
        end

        function[label,unit,scale,values,index]=getXaxis(obj,waveformName)
            if~isempty(waveformName)
                for index=1:length(obj.WaveNames)
                    if strcmp(obj.WaveNames{index},waveformName)
                        label=obj.getValue(obj.isSameLabelsX,obj.XaxisLabels,index);
                        unit=obj.getValue(obj.isSameUnitsX,obj.XaxisUnits,index);
                        scale=obj.getValue(obj.isSameScalesX,obj.XaxisScales,index);
                        values=obj.getValue(obj.isSameValuesX,obj.XaxisValues,index);
                        return;
                    end
                end
            end
            index=0;
            label=[];
            unit=[];
            scale=[];
            values=[];
        end


        function value=getValue(obj,isSameValue,values,index)
            if isSameValue
                value=values;
            elseif index>size(values,2)
                value=[];
            else
                value=values{index};
            end
        end


        function setYaxis(obj,waveformName,label,unit,scale,values,index)
            if index>0

                obj.WaveNames{index}=waveformName;
            else

                [~,~,~,~,index]=obj.getYaxis(waveformName);
            end
            if index==0

                index=length(obj.WaveNames)+1;
                obj.WaveNames{index}=waveformName;
            end

            obj.YaxisLabels{index}=label;
            obj.YaxisUnits{index}=unit;
            obj.YaxisScales{index}=scale;
            obj.YaxisValues{index}=values;
        end

        function[label,unit,scale,values,index]=getYaxis(obj,waveformName)
            if~isempty(waveformName)
                for index=1:length(obj.WaveNames)
                    if strcmp(obj.WaveNames{index},waveformName)
                        label=obj.getValue(obj.isSameLabelsY,obj.YaxisLabels,index);
                        unit=obj.getValue(obj.isSameUnitsY,obj.YaxisUnits,index);
                        scale=obj.getValue(obj.isSameScalesY,obj.YaxisScales,index);
                        values=obj.getValue(obj.isSameValuesY,obj.YaxisValues,index);
                        return;
                    end
                end
            end
            index=0;
            label=[];
            unit=[];
            scale=[];
            values=[];
        end


        function compressWaveformProperties(obj)
            obj.isSameLabelsX=isSameCellValue(obj.XaxisLabels);
            obj.isSameLabelsY=isSameCellValue(obj.YaxisLabels);
            obj.isSameUnitsX=isSameCellValue(obj.XaxisUnits);
            obj.isSameUnitsY=isSameCellValue(obj.YaxisUnits);
            obj.isSameScalesX=isSameCellValue(obj.XaxisScales);
            obj.isSameScalesY=isSameCellValue(obj.YaxisScales);
            obj.isSameValuesX=isSameCellValue(obj.XaxisValues);
            obj.isSameValuesY=isSameCellValue(obj.YaxisValues);
            if obj.isSameLabelsX&&~isempty(obj.XaxisLabels)&&iscell(obj.XaxisLabels)
                obj.XaxisLabels=obj.XaxisLabels{1};
            end
            if obj.isSameLabelsY&&~isempty(obj.YaxisLabels)&&iscell(obj.YaxisLabels)
                obj.YaxisLabels=obj.YaxisLabels{1};
            end
            if obj.isSameUnitsX&&~isempty(obj.XaxisUnits)&&iscell(obj.XaxisUnits)
                obj.XaxisUnits=obj.XaxisUnits{1};
            end
            if obj.isSameUnitsY&&~isempty(obj.YaxisUnits)&&iscell(obj.YaxisUnits)
                obj.YaxisUnits=obj.YaxisUnits{1};
            end
            if obj.isSameScalesX&&~isempty(obj.XaxisScales)&&iscell(obj.XaxisScales)
                obj.XaxisScales=obj.XaxisScales{1};
            end
            if obj.isSameScalesY&&~isempty(obj.YaxisScales)&&iscell(obj.YaxisScales)
                obj.YaxisScales=obj.YaxisScales{1};
            end
            if obj.isSameValuesX&&~isempty(obj.XaxisValues)&&iscell(obj.XaxisValues)
                obj.XaxisValues=obj.XaxisValues{1};
            end
            if obj.isSameValuesY&&~isempty(obj.YaxisValues)&&iscell(obj.YaxisValues)
                obj.YaxisValues=obj.YaxisValues{1};
            end
        end


        function waveform=getWaveform(obj,waveformName)
            if~isempty(waveformName)
                for index=1:length(obj.WaveNames)
                    if strcmp(obj.WaveNames{index},waveformName)
                        waveform.name=waveformName;
                        waveform.xlabel=obj.getValue(obj.isSameLabelsX,obj.XaxisLabels,index);
                        waveform.xunit=obj.getValue(obj.isSameUnitsX,obj.XaxisUnits,index);
                        waveform.xscale=obj.getValue(obj.isSameScalesX,obj.XaxisScales,index);
                        waveform.x=obj.getValue(obj.isSameValuesX,obj.XaxisValues,index);
                        waveform.ylabel=obj.getValue(obj.isSameLabelsY,obj.YaxisLabels,index);
                        waveform.yunit=obj.getValue(obj.isSameUnitsY,obj.YaxisUnits,index);
                        waveform.yscale=obj.getValue(obj.isSameScalesY,obj.YaxisScales,index);
                        waveform.y=obj.getValue(obj.isSameValuesY,obj.YaxisValues,index);
                        return;
                    end
                end
            end
            waveform=[];
        end

        function[cornerParams,metricParams]=getShortParamNames(obj)
            designParamsCount=obj.getParamValue('designParamsCount');
            params=obj.getParamValue('paramNames_ShortMetrics');
            if~isempty(designParamsCount)&&~isempty(params)
                cornerParams=params(1:designParamsCount);
                metricParams=params(designParamsCount+1:end);
            else
                cornerParams=[];
                metricParams=[];
            end
        end


        function structCopy=get(obj)
            structCopy.ParamNames=obj.ParamNames;
            structCopy.ParamValues=obj.ParamValues;
            structCopy.WaveNames=obj.WaveNames;
            structCopy.XaxisLabels=obj.XaxisLabels;
            structCopy.XaxisUnits=obj.XaxisUnits;
            structCopy.XaxisScales=obj.XaxisScales;
            structCopy.XaxisValues=obj.XaxisValues;
            structCopy.YaxisLabels=obj.YaxisLabels;
            structCopy.YaxisUnits=obj.YaxisUnits;
            structCopy.YaxisScales=obj.YaxisScales;
            structCopy.YaxisValues=obj.YaxisValues;
            structCopy.isSameLabelsX=obj.isSameLabelsX;
            structCopy.isSameLabelsY=obj.isSameLabelsY;
            structCopy.isSameUnitsX=obj.isSameUnitsX;
            structCopy.isSameUnitsY=obj.isSameUnitsY;
            structCopy.isSameScalesX=obj.isSameScalesX;
            structCopy.isSameScalesY=obj.isSameScalesY;
            structCopy.isSameValuesX=obj.isSameValuesX;
            structCopy.isSameValuesY=obj.isSameValuesY;
        end


        function put(obj,structCopy)
            obj.ParamNames=structCopy.ParamNames;
            obj.ParamValues=structCopy.ParamValues;
            obj.WaveNames=structCopy.WaveNames;
            obj.XaxisLabels=structCopy.XaxisLabels;
            obj.XaxisUnits=structCopy.XaxisUnits;
            obj.XaxisScales=structCopy.XaxisScales;
            obj.XaxisValues=structCopy.XaxisValues;
            obj.YaxisLabels=structCopy.YaxisLabels;
            obj.YaxisUnits=structCopy.YaxisUnits;
            obj.YaxisScales=structCopy.YaxisScales;
            obj.YaxisValues=structCopy.YaxisValues;
            obj.isSameLabelsX=structCopy.isSameLabelsX;
            obj.isSameLabelsY=structCopy.isSameLabelsY;
            obj.isSameUnitsX=structCopy.isSameUnitsX;
            obj.isSameUnitsY=structCopy.isSameUnitsY;
            obj.isSameScalesX=structCopy.isSameScalesX;
            obj.isSameScalesY=structCopy.isSameScalesY;
            obj.isSameValuesX=structCopy.isSameValuesX;
            obj.isSameValuesY=structCopy.isSameValuesY;
        end


        function out=clone(obj)
            out=msblks.internal.mixedsignalanalysis.SimulationResults;
            out.ParamNames=obj.ParamNames;
            out.ParamValues=obj.ParamValues;
            out.WaveNames=obj.WaveNames;
            out.XaxisLabels=obj.XaxisLabels;
            out.XaxisUnits=obj.XaxisUnits;
            out.XaxisScales=obj.XaxisScales;
            out.XaxisValues=obj.XaxisValues;
            out.YaxisLabels=obj.YaxisLabels;
            out.YaxisUnits=obj.YaxisUnits;
            out.YaxisScales=obj.YaxisScales;
            out.YaxisValues=obj.YaxisValues;
            out.isSameLabelsX=obj.isSameLabelsX;
            out.isSameLabelsY=obj.isSameLabelsY;
            out.isSameUnitsX=obj.isSameUnitsX;
            out.isSameUnitsY=obj.isSameUnitsY;
            out.isSameScalesX=obj.isSameScalesX;
            out.isSameScalesY=obj.isSameScalesY;
            out.isSameValuesX=obj.isSameValuesX;
            out.isSameValuesY=obj.isSameValuesY;
        end
    end


    methods(Static)

        function values=stringCellArray2NumericCellArray(values)
            temp=str2double(values);
            if~any(isnan(temp))

                for i=1:length(values)
                    values{i}=temp(i);
                end
            end
        end


        function waveformName=packWaveformName(simName,simType,nodeName,simCorner)
            waveformName=[simName,', ',simType,', ',nodeName,', ',simCorner];
        end

        function[simName,simType,nodeName,simCorner]=unpackWaveformName(waveformName)
            simName=[];
            simType=[];
            nodeName=[];
            simCorner=[];
            commaPtrs=strfind(waveformName,', ');
            if length(commaPtrs)>=3
                simName=extractBetween(waveformName,1,commaPtrs(end-2)-1);
                if~isempty(simName)&&iscell(simName)
                    simName=simName{1};
                end
                simType=extractBetween(waveformName,commaPtrs(end-2)+2,commaPtrs(end-1)-1);
                if~isempty(simType)&&iscell(simType)
                    simType=simType{1};
                end
                nodeName=extractBetween(waveformName,commaPtrs(end-1)+2,commaPtrs(end)-1);
                if~isempty(nodeName)&&iscell(nodeName)
                    nodeName=nodeName{1};
                end
                simCorner=extractBetween(waveformName,commaPtrs(end)+2,length(waveformName));
                if~isempty(simCorner)&&iscell(simCorner)
                    simCorner=simCorner{1};
                end
            end
        end

        function[shortVsLongValues,paramValuesPerCorner]=getShortColumnValues_corModelSpec(paramNames,paramValuesPerCorner)
            shortVsLongValues={};
            columnIndex=find(strcmpi(paramNames,'corModelSpec'));
            if columnIndex>0
                for rowIndex=1:length(paramValuesPerCorner)
                    value=paramValuesPerCorner{rowIndex}{columnIndex};
                    slashIndices=strfind(value,'/');
                    if~isempty(slashIndices)

                        value=extractAfter(value,slashIndices(end));
                    end
                    trailingIndices=strfind(value,'.sp Section=;');
                    if~isempty(trailingIndices)

                        value=extractBefore(value,trailingIndices(1));
                    end
                    if~isempty(slashIndices)||~isempty(trailingIndices)
                        found=false;
                        for uniqueValuesIndex=1:length(shortVsLongValues)

                            if any(strcmp(shortVsLongValues{uniqueValuesIndex},paramValuesPerCorner{rowIndex}{columnIndex}))
                                found=true;
                                break;
                            end
                        end
                        if~found
                            shortVsLongValues{end+1}={value,paramValuesPerCorner{rowIndex}{columnIndex}};%#ok<AGROW>
                        end

                        paramValuesPerCorner{rowIndex}{columnIndex}=value;
                    end
                end
            end
        end

        function[shortVsLongNames,paramNames_ShortMetrics]=getShortColumnNames(designParamsCount,paramNames)

            count=0;
            if~iscell(paramNames)
                temp{1}=paramNames;
                paramNames=temp;
            end
            for metric=designParamsCount+1:length(paramNames)
                if~isempty(strfind(paramNames{metric},'('))
                    count=count+1;
                end
            end
            paramNames_ShortMetrics=paramNames;
            if count>0

                shortVsLongNames{count}=[];
            else

                shortVsLongNames=[];
            end
            count=0;
            for metric=designParamsCount+1:length(paramNames)
                if~isempty(strfind(paramNames{metric},'('))
                    count=count+1;
                    paramNames_ShortMetrics{metric}=extractBefore(paramNames{metric},'(');
                    shortVsLongNames{count}={paramNames_ShortMetrics{metric},paramNames{metric}};
                end
            end
        end

        function[shortVsLongNames,paramNames_ShortMetrics]=getUniqueColumnNames(designParamsCount,paramNames,paramNames_ShortMetrics,shortVsLongNames)

            replacementCount=0;
            if~iscell(paramNames)
                temp{1}=paramNames;
                paramNames=temp;
            end
            for metric=designParamsCount+1:length(paramNames)
                metricIndices=strcmpi(paramNames_ShortMetrics,paramNames_ShortMetrics{metric});
                if sum(metricIndices(:))>1
                    metricIndices=find(metricIndices==true);
                    minLength=Inf;
                    uniqueEnd=[];
                    for index=1:length(metricIndices)
                        uniqueEnd(index)=length(paramNames{metricIndices(index)});%#ok<AGROW>
                        minLength=min(uniqueEnd(index),minLength);
                    end
                    uniqueStart=-1;
                    for charPtr=2:minLength
                        sameString=extractBefore(paramNames{metricIndices(1)},charPtr);
                        for index=2:length(metricIndices)
                            if~startsWith(paramNames{metricIndices(index)},sameString)
                                uniqueStart=charPtr-1;
                                break;
                            end
                        end
                        if uniqueStart>0
                            break;
                        end
                    end
                    if uniqueStart>0
                        uniqueStop=-1;
                        for charPtr=length(paramNames{metricIndices(1)}):-1:uniqueStart
                            sameString=extractAfter(paramNames{metricIndices(1)},charPtr-1);
                            for index=2:length(metricIndices)
                                if~endsWith(paramNames{metricIndices(index)},sameString)
                                    uniqueStop=charPtr;
                                    break;
                                end
                            end
                            if uniqueStop>0
                                break;
                            end
                        end
                        if uniqueStop<uniqueStart
                            uniqueStop=uniqueStart;
                        end
                        endCount=length(paramNames{metricIndices(1)})-uniqueStop;
                        for index=1:length(metricIndices)

                            value=paramNames_ShortMetrics{metricIndices(index)};
                            valueUnique=[value,'.',paramNames{metricIndices(index)}(uniqueStart:end-endCount)];
                            if length(valueUnique)>namelengthmax

                                replacementCount=replacementCount+1;
                                valueUnique=[value,'.a',num2str(replacementCount)];
                                if length(valueUnique)>namelengthmax

                                    valueUnique=['a',num2str(replacementCount)];
                                end
                            end
                            paramNames_ShortMetrics{metricIndices(index)}=valueUnique;
                            for uniqueValuesIndex=1:length(shortVsLongNames)

                                if any(strcmp(shortVsLongNames{uniqueValuesIndex},paramNames{metricIndices(index)}))
                                    shortVsLongNames{uniqueValuesIndex}{1}=valueUnique;
                                    break;
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end


function isSame=isSameCellValue(values)
    isSame=true;
    if iscell(values)
        for i=1:size(values,2)-1
            if~isequal(values{i},values{i+1})
                isSame=false;
                return;
            end
        end
    end
end
