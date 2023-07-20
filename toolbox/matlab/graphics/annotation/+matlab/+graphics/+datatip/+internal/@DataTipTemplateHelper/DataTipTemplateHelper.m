classdef(Hidden)DataTipTemplateHelper




    methods(Static)












        function dataTipRows=createDefaultDataTipRows(hObj)
            dataTipRows=matlab.graphics.datatip.DataTipTextRow.empty(0,1);

            if isa(hObj,'matlab.graphics.chart.interaction.dataannotatable.AnnotationAdaptor')
                hObj=hObj.getAnnotationTarget();
            end

            if isa(hObj,'matlab.graphics.mixin.DataProperties')&&...
                isa(hObj,'matlab.graphics.primitive.Data')







                visualChannels=["X","Y","Z","Size","Color","Alpha"];





                defaultLabels=visualChannels;
                defaultLabels(1:3)=string(hObj.DimensionNames);



                dataPropertyNames=defaultLabels+"Data";


                dataPropertyNames(5)="CData";



                n=numel(hObj.YData_I);
                for c=1:numel(visualChannels)
                    channel=visualChannels(c);
                    source=dataPropertyNames{c};
                    label=defaultLabels{c};

                    if isprop(hObj,source)


                        if source=="CData"
                            value=hObj.CData_I;
                        else
                            value=hObj.(source);
                        end

                        if isvector(value)&&numel(value)==n







                            channelDisplayName=hObj.getChannelDisplayNames(channel);
                            if channelDisplayName~=""
                                label=channelDisplayName{1};
                            end

                            dataTipRows(end+1,1)=matlab.graphics.datatip.DataTipTextRow(label,source);%#ok<AGROW>
                        end
                    end
                end
            elseif isprop(hObj,'DimensionNames')





                dimensionNames=hObj.DimensionNames;
                for i=1:numel(dimensionNames)

                    if strcmpi(strcat(dimensionNames{i},'Data'),'ZData')&&...
                        (~isprop(hObj,'ZData')||(isprop(hObj,'ZData')&&...
                        isempty(hObj.ZData)))
                        continue;
                    end

                    dataTipRows(i,1)=matlab.graphics.datatip.DataTipTextRow(dimensionNames{i},strcat(dimensionNames{i},'Data'));
                end
            end
        end



        function valueSources=getAllValidValueSources(hObj)
            valueSources=string.empty(0,1);

            if isa(hObj,'matlab.graphics.mixin.DataProperties')&&...
                isa(hObj,'matlab.graphics.primitive.Data')







                visualChannels=["X";"Y";"Z";"Size";"Color";"Alpha"];





                dataPropertyNames=visualChannels;
                dataPropertyNames(1:3)=string(hObj.DimensionNames);
                dataPropertyNames=dataPropertyNames+"Data";


                dataPropertyNames(5)="CData";



                n=numel(hObj.YData_I);
                valid=false(numel(visualChannels),1);
                for c=1:numel(visualChannels)
                    propName=dataPropertyNames(c);
                    if isprop(hObj,propName)
                        value=hObj.(propName);
                        if isvector(value)&&numel(value)==n
                            valid(c)=true;
                        end
                    end
                end
                valueSources=dataPropertyNames(valid);
            elseif isprop(hObj,'DimensionNames')




                dimensionNames=hObj.DimensionNames;
                for i=1:numel(dimensionNames)
                    valueSource=strcat(dimensionNames{i},'Data');

                    if strcmpi(valueSource,'ZData')&&...
                        (~isprop(hObj,'ZData')||(isprop(hObj,'ZData')&&...
                        isempty(hObj.ZData)))
                        continue;
                    end
                    valueSources(i,1)=valueSource;
                end
            end
        end


        function isValidSource=isValueSourceValid(hObj,valueSource)
            isValidSource=false;
            if~isempty(valueSource)&&(isstring(valueSource)||ischar(valueSource))
                isValidSource=ismember(valueSource,hObj.getAllValidValueSources());
            end
        end






        function coordinateData=createCoordinateData(hObj,valueSource,dataIndex,interpolationFactor)
            import matlab.graphics.chart.interaction.dataannotatable.internal.CoordinateData;

            if nargin<3
                interpolationFactor=0;
            end
            coordinateData=CoordinateData.empty(0,1);
            vertexPosition=hObj.getReportedPosition(dataIndex,interpolationFactor);
            location=vertexPosition.getLocation(hObj);



            location3=[];
            if numel(location)==3
                location3=location(3);
            end


            [xLoc,yLoc,zLoc]=matlab.graphics.internal.makeNonNumeric(hObj,location(1),location(2),location3);
            calculatedPosition={xLoc,yLoc,zLoc};



            dimensionData=strcat(hObj.DimensionNames,'Data');
            dimInd=strcmpi(dimensionData,valueSource);
            if any(dimInd)
                coordinateData=CoordinateData(dimensionData{dimInd},calculatedPosition{dimInd});
            end
        end




        function ret=isCustomizable(hParent)
            ret=false;
            if~isempty(hParent)
                ret=isa(hParent,'matlab.graphics.chart.primitive.Line')||...
                isa(hParent,'matlab.graphics.chart.primitive.Stem')||...
                isa(hParent,'matlab.graphics.chart.primitive.internal.AbstractScatter')||...
                isa(hParent,'matlab.graphics.chart.primitive.Surface')||...
                isa(hParent,'matlab.graphics.chart.primitive.Stair')||...
                isa(hParent,'matlab.graphics.chart.primitive.Area')||...
                isa(hParent,'matlab.graphics.chart.primitive.ErrorBar')||...
                isa(hParent,'matlab.graphics.chart.primitive.Quiver')||...
                isa(hParent,'matlab.graphics.chart.primitive.Bar')||...
                isa(hParent,'matlab.graphics.chart.primitive.Contour')||...
                isa(hParent,'matlab.graphics.chart.primitive.Binscatter')||...
                isa(hParent,'textanalytics.chart.TextScatter')||...
                isa(hParent,'matlab.graphics.chart.primitive.Histogram')||...
                isa(hParent,'matlab.graphics.chart.primitive.Histogram2')||...
                isa(hParent,'matlab.graphics.function.ImplicitFunctionLine')||...
                isa(hParent,'matlab.graphics.function.ImplicitFunctionSurface')||...
                isa(hParent,'matlab.graphics.function.ParameterizedFunctionLine')||...
                isa(hParent,'matlab.graphics.function.ParameterizedFunctionSurface')||...
                isa(hParent,'matlab.graphics.function.FunctionLine')||...
                isa(hParent,'matlab.graphics.function.FunctionSurface')||...
                isa(hParent,'matlab.graphics.function.FunctionContour')||...
                isa(hParent,'matlab.graphics.chart.primitive.ColorGrid')||...
                isa(hParent,'matlab.graphics.chart.interaction.dataannotatable.LineAdaptor')||...
                isa(hParent,'matlab.graphics.chart.interaction.dataannotatable.SurfaceAdaptor')||...
                isa(hParent,'matlab.graphics.chart.interaction.dataannotatable.PatchAdaptor')||...
                isa(hParent,'matlab.graphics.chart.interaction.dataannotatable.PolygonAdaptor')||...
                isa(hParent,'matlab.graphics.chart.interaction.dataannotatable.ImageAdaptor')||...
                isa(hParent,'matlab.graphics.chart.primitive.GraphPlot')||...
                isa(hParent,'matlab.graphics.chart.primitive.categorical.Histogram')||...
                isa(hParent,'mlearnlib.graphics.chart.ROCCurve');
            end
        end









        function applyDataTipTemplate(hObj,hDT)
            hObj.DataTipTemplate.DataTipRows=hDT.DataTipRows;
            hObj.DataTipTemplate.Interpreter=hDT.Interpreter;
            hObj.DataTipTemplate.FontSize=hDT.FontSize;
            hObj.DataTipTemplate.FontName=hDT.FontName;
            hObj.DataTipTemplate.FontAngle=hDT.FontAngle;
            hObj.DataTipTemplate.DataTipRowsMode=hDT.DataTipRowsMode;
            hObj.DataTipTemplate.InterpreterMode=hDT.InterpreterMode;
        end








        function dataDescriptors=generateContent(hDataSource,dataIndex,interpolationFactor)

            dataDescriptors=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor.empty;




            if isempty(hggetbehavior(hDataSource,'datacursor','-peek'))&&...
                matlab.graphics.datatip.internal.DataTipTemplateHelper.isCustomizable(hDataSource)
                if nargin<3
                    interpolationFactor=0;
                end

                hTarget=hDataSource;
                if isa(hTarget,'matlab.graphics.chart.interaction.dataannotatable.AnnotationAdaptor')
                    hTarget=hDataSource.getAnnotationTarget();
                end

                for rowNumber=1:length(hDataSource.DataTipTemplate.DataTipRows)
                    rowLabel=hTarget.DataTipTemplate.DataTipRows(rowNumber).Label;
                    rowValue=matlab.graphics.datatip.internal.DataTipTemplateHelper.getDataTipRowValue...
                    (hTarget,rowNumber,dataIndex,interpolationFactor);

                    dataDescriptors(rowNumber)=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(rowLabel,rowValue);
                end
            else




                dataDescriptors=hDataSource.getDataDescriptors(dataIndex,interpolationFactor);
            end
        end



        function rowValue=getDataTipRowValue(hTarget,rowNumber,dataIndex,interpolationFactor)

            hDT=hTarget.DataTipTemplate;
            rowFormat=hDT.DataTipRows(rowNumber).Format;
            rowValue=hDT.DataTipRows(rowNumber).Value;


            hDataSource=hDT.Parent;





            coordinateValue=matlab.graphics.datatip.internal.DataTipTemplateHelper.getCoordinateValue...
            (hDataSource,dataIndex,interpolationFactor,rowValue);

            if~isempty(coordinateValue)
                rowValue=coordinateValue;
            elseif ischar(rowValue)&&any(strcmpi(properties(hTarget),rowValue))
                rowValue=hTarget.(rowValue);
                rowValue=localIndexData(rowValue,dataIndex);
            else


                if isa(rowValue,'function_handle')
                    try

                        defaultDescriptors=hDataSource.createDefaultDataTipRows();
                        dataArgs=cell(1,nargin(rowValue));
                        for rowIndex=1:nargin(rowValue)




                            dataArgs{rowIndex}=matlab.graphics.datatip.internal.DataTipTemplateHelper.getCoordinateValue...
                            (hDataSource,dataIndex,interpolationFactor,defaultDescriptors(rowIndex).Value);
                        end
                        rowValue=feval(rowValue,dataArgs{:});
                    catch ex


                        rowValue=char(ex.message);


                        if strcmpi(hDT.Interpreter,'tex')
                            rowValue=['\color[rgb]{1 0 0}\bf',rowValue];
                        end
                    end
                else
                    rowValue=localIndexData(rowValue,dataIndex);
                end
            end
            rowValue=matlab.graphics.datatip.internal.DataTipTemplateHelper.applyFormatToValue(rowValue,rowFormat);
        end



        function formattedValue=applyFormatToValue(rowValue,rowFormat)
            formattedValue=rowValue;
            if isnumeric(rowValue)&&~isempty(rowValue)
                for i=1:numel(rowValue)
                    if strcmpi(rowFormat,'auto')


                        numericVal(i)=str2double(sprintf('%g',rowValue(i)));%#ok<AGROW>
                    else
                        numericVal(i)=string(sprintf(rowFormat,rowValue(i)));%#ok<AGROW>
                    end
                end
                formattedValue=numericVal;
            elseif isstring(rowValue)||iscategorical(rowValue)
                formattedValue=rowValue;
            elseif isdatetime(rowValue)
                if~strcmpi(rowFormat,'auto')
                    for i=1:numel(rowValue)


                        datetimeVal(i)=datetime(rowValue(i),'Format',rowFormat);%#ok<AGROW>
                    end
                    formattedValue=datetimeVal;
                end
            elseif isduration(rowValue)
                if~strcmpi(rowFormat,'auto')
                    for i=1:numel(rowValue)


                        durationFormatVal(i)=duration(rowValue(i),'Format',rowFormat);%#ok<AGROW>
                    end
                    formattedValue=durationFormatVal;
                end
            elseif islogical(rowValue)
                formattedValue=double(rowValue);
            elseif iscell(rowValue)
                rowValue=rowValue{:};


                if~ischar(rowValue)&&~isstring(rowValue)&&numel(rowValue)>1
                    fdu=internal.matlab.datatoolsservices.FormatDataUtils;
                    formattedValue=fdu.formatSingleDataForMixedView(rowValue);
                else
                    formattedValue=rowValue;
                end
            elseif isobject(rowValue)

                className=split(class(rowValue),'.');
                objectDisplayName=className{end};
                if isprop(rowValue,'DisplayName')&&~isempty(rowValue.DisplayName)
                    objectDisplayName=rowValue.DisplayName;
                end
                formattedValue=objectDisplayName;
            end

            if numel(formattedValue)>1&&isstring(formattedValue)
                formattedValue=mat2str(formattedValue);
            end
        end






        function coordinateValue=getCoordinateValue(hObj,dataIndex,interpolationFactor,valueSource)
            coordinateValue=[];
            if~isempty(valueSource)&&(isstring(valueSource)||ischar(valueSource))
                coordinateDataSource=hObj.createCoordinateData(valueSource,dataIndex,interpolationFactor);

                coordinateValueIndex=find(strcmpi({coordinateDataSource.Source},valueSource),1);
                if~isempty(coordinateValueIndex)&&coordinateValueIndex>0
                    coordinateValue=coordinateDataSource(coordinateValueIndex).Value;
                end
            end
        end
    end
end

function val=localIndexData(data,index)

    val='';
    if isempty(data)||ischar(data)||(isstring(data)&&numel(data)<2)
        return;
    end

    if index>0&&index<=numel(data)
        val=data(index);
    end
end
