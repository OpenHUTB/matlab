



classdef LUTWidgetController
    methods(Static)



        function[lutwidget,widgetStruct]=createWidget(widgetAttribs,...
            breakpoints,tableData,dlgSrc,dataSpec,lutObject,isEditTime)
            lutwidget=LUTWidget.Connector;
            lutwidget.addFeature(LUTWidget.DisableMATLABExpressionBox);

            lutWidgetStruct.Type='webbrowser';
            lutWidgetStruct.Name=widgetAttribs.Name;
            lutWidgetStruct.Tag=widgetAttribs.Tag;
            lutWidgetStruct.Url=lutwidget.getWidgetUrl();

            if(Simulink.Mask.LUTWidgetController.isValidAssociation(...
                dataSpec,tableData,breakpoints,lutObject))
                errHandlingPolicy=Simulink.Mask.LUTWidgetWarningPolicy;

                try
                    dataSize=Simulink.Mask.LUTWidgetController.setData(...
                    dlgSrc,lutwidget,dataSpec,tableData,breakpoints,lutObject,isEditTime,errHandlingPolicy);
                    lutWidgetStruct.MinimumSize=...
                    Simulink.Mask.LUTWidgetController.calculateWidgetSize(dataSize);
                catch me
                    warning(me.message);
                end
                if errHandlingPolicy.gotErrors
                    widgetAttribs.Enabled=false;
                end
                lutWidgetStruct.DisableContextMenu=true;
                addlistener(lutwidget,'Action',...
                @(src,eventData)Simulink.Mask.LUTWidgetController.handleAction(src,eventData,dlgSrc,lutWidgetStruct.Tag));
            else
                lutWidgetStruct.Type='text';
                lutWidgetStruct.Name=DAStudio.message('dastudio:studio:NoDataToDisplay');
            end

            if~isempty(widgetAttribs.Name)
                widgetStruct.Type='group';
                widgetStruct.Name=widgetAttribs.Name;
                widgetStruct.Tag=append(widgetAttribs.Tag,'group');
                widgetStruct.Items={lutWidgetStruct};
            else
                widgetStruct=lutWidgetStruct;
            end

            widgetStruct.RowSpan=widgetAttribs.RowSpan;
            widgetStruct.ColSpan=widgetAttribs.ColSpan;
            widgetStruct.Visible=widgetAttribs.Visible;
            widgetStruct.Enabled=widgetAttribs.Enabled;
            widgetStruct.ToolTip=widgetAttribs.ToolTip;
        end




        function handleAction(~,eventData,varargin)
            valueChanged=true;

            if(strcmp(eventData.ActionType,'CellEdit')&&numel(eventData.ActionData.Cells)==1)
                cellData=eventData.ActionData.Cells(1);
                valueChanged=(cellData{1}.OldValue~=cellData{1}.NewValue);
            end
            if(valueChanged)
                dlgSrc=varargin{1};
                widgetTag=varargin{2};
                handleLookupTableEvent(dlgSrc,widgetTag);
            end
        end




        function[dataSize]=updateWidget(dlgSrc,lutwidget,dataSpec,...
            tableData,breakpointData,lutObject)
            errHandlingPolicy=Simulink.Mask.LUTWidgetThrowErrorPolicy;
            dataSize=Simulink.Mask.LUTWidgetController.setData(dlgSrc,lutwidget,dataSpec,...
            tableData,breakpointData,lutObject,true,errHandlingPolicy);
        end




        function[dataSize]=setData(dlgSrc,lutwidget,dataSpec,tableData,...
            breakpointData,lutObject,isEditTime,errHandlingPolicy)
            block=dlgSrc.getBlock;

            if Simulink.Mask.LUTWidgetController.isReferenceMode(...
                block,dataSpec,lutObject)
                dataSize=Simulink.Mask.LUTWidgetController.updateFromLUTObject(...
                block,lutwidget,lutObject,isEditTime,errHandlingPolicy);
            else
                dataSize=Simulink.Mask.LUTWidgetController.updateFromExplicitData(...
                block,lutwidget,tableData,breakpointData,isEditTime,errHandlingPolicy);
            end

            lutwidget.clearHistory();
        end




        function paramValues=getData(~,lutwidget)
            paramValues.tableData=lutwidget.Table.Value;

            for i=1:length(lutwidget.Axes)
                paramValues.breakpointData(i).value=lutwidget.Axes(i).Value;
            end

            lutwidget.clearHistory();
        end





        function validateData(dlgSrc,lutwidget)
            for i=1:length(lutwidget.Axes)
                if(any(diff(lutwidget.Axes(i).Value)<=0))
                    errHandlingPolicy=Simulink.Mask.LUTWidgetThrowErrorPolicy;
                    errHandlingPolicy.handleError('Simulink:Masking:BreakpointNotMonotonicallyIncreasing',...
                    lutwidget.Axes(i).FieldName,dlgSrc.getBlock.getFullName);
                end
            end
        end




        function updateLUTObject(dlgSrc,lutwidget,lutObject)
            block=dlgSrc.getBlock;

            try
                lutObjectVar=slResolve(lutObject,block.Handle);
            catch
                lutObjectVar='';
            end

            if class(lutObjectVar)~="Simulink.LookupTable"
                return;
            end

            if(strcmp(lutObjectVar.BreakpointsSpecification,'Explicit values'))
                lutObjectVar.Breakpoints=Simulink.lookuptable.Breakpoint;
                for i=1:length(lutwidget.Axes)
                    lutObjectVar.Breakpoints(i).Value=lutwidget.Axes(i).Value;
                end
            elseif(strcmp(lutObjectVar.BreakpointsSpecification,'Reference'))
                for i=1:length(lutwidget.Axes)
                    Simulink.Mask.LUTWidgetController.updateBPObject(...
                    block,char(lutObjectVar.Breakpoints(i)),lutwidget.Axes(i));
                end
            else

            end

            lutObjectVar.Table.Value=lutwidget.Table.Value;

            lutwidget.clearHistory();
        end

    end

    methods(Static,Access=private)



        function result=isReferenceMode(block,dataspec,lutobj)
            dataspecVal='';

            if~isempty(dataspec)
                dataspecVal=get_param(block.Handle,dataspec);
            else
                if~isempty(lutobj.value)
                    dataspecVal='Lookup table object';
                end
            end
            result=strcmp(dataspecVal,'Lookup table object');
        end




        function result=isValidAssociation(dataSpec,tableData,breakpoints,lutObject)
            result=true;

            if(isempty(dataSpec))
                if(isempty(lutObject.value)&&isempty(tableData.name)&&isempty(breakpoints))

                    result=false;
                elseif(isempty(lutObject.value))
                    if(isempty(tableData.name))

                        result=false;
                    elseif(isempty(breakpoints))

                        result=false;
                    end
                end
            else
                if(isempty(lutObject.value)||isempty(tableData.name)||isempty(breakpoints))

                    result=false;
                end
            end
        end




        function[dataSize]=updateFromLUTObject(block,lutwidget,lutObject,isEditTime,errHandlingPolicy)
            try
                lutObjectVar=Simulink.Mask.LUTWidgetController.getEvaluatedValue(block,lutObject,isEditTime);
            catch
                lutObjectVar='';
            end

            if class(lutObjectVar)~="Simulink.LookupTable"
                if~isvarname(lutObject.value)
                    errHandlingPolicy.handleError('Simulink:Masking:InvalidSimulinkLookupTableObject',...
                    lutObject.value,block.getFullName);
                else
                    errHandlingPolicy.handleError('Simulink:Masking:UnableToResolveLUTObject',...
                    lutObject.value,block.getFullName);
                end
                dataSize=[];
                return;
            end

            Simulink.Mask.LUTWidgetController.removeWidgetFeature(lutwidget,'LUTWidget.DisableAxesEdit');
            disableAxesEditing=false;

            numBPs=length(lutObjectVar.Breakpoints);
            lutAxes(1,numBPs)=LUTWidget.Axis;

            if(strcmp(lutObjectVar.BreakpointsSpecification,'Explicit values'))

                for i=1:numBPs
                    lutAxes(i).Value=lutObjectVar.Breakpoints(i).Value;
                    lutAxes(i).FieldName=lutObjectVar.Breakpoints(i).FieldName;
                    lutAxes(i).Unit=lutObjectVar.Breakpoints(i).Unit;
                end
            elseif(strcmp(lutObjectVar.BreakpointsSpecification,'Reference'))

                for i=1:numBPs
                    Simulink.Mask.LUTWidgetController.updateBPFromObject(...
                    block,lutAxes(i),char(lutObjectVar.Breakpoints(i)));
                end
            else

                for i=1:numBPs
                    bpLength=lutObjectVar.Table.Dimensions(i);
                    firstPoint=lutObjectVar.Breakpoints(i).FirstPoint;
                    spacing=lutObjectVar.Breakpoints(i).Spacing;

                    lutAxes(i).Value=linspace(firstPoint,firstPoint+spacing*(bpLength-1),bpLength);
                    lutAxes(i).Unit=lutObjectVar.Breakpoints(i).Unit;
                end
                disableAxesEditing=true;
            end

            lutTable=LUTWidget.Table;
            lutTable.Value=lutObjectVar.Table.Value;
            lutTable.FieldName=lutObjectVar.Table.FieldName;
            lutTable.Unit=lutObjectVar.Table.Unit;

            lutwidget.setBaselineData(lutTable,lutAxes);
            if(disableAxesEditing)
                Simulink.Mask.LUTWidgetController.addWidgetFeature(lutwidget,LUTWidget.DisableAxesEdit);
            end
            dataSize=size(lutTable.Value);
        end




        function[dataSize]=updateFromExplicitData(block,lutwidget,table,breakpoints,isEditTime,errHandlingPolicy)
            blockPath=block.getFullName;
            mask=Simulink.Mask.get(block.Handle);


            try
                tableValue=Simulink.Mask.LUTWidgetController.getEvaluatedValue(block,table,isEditTime);
                if(class(tableValue)=="Simulink.Parameter")
                    tableData=tableValue.Value;
                else
                    tableData=tableValue;
                end
            catch
                errHandlingPolicy.handleError('Simulink:Masking:UnableToResolveTableData',table.name,blockPath);
                tableData=[];
            end


            dataSize=size(tableData);
            numBps=length(breakpoints);

            if isvector(tableData)
                if numBps~=1
                    errHandlingPolicy.handleError('Simulink:Masking:TableBPDataDimensionMismatch',...
                    blockPath,table.name,1,numBps);
                end
            elseif(length(dataSize)~=numBps)
                errHandlingPolicy.handleError('Simulink:Masking:TableBPDataDimensionMismatch',...
                blockPath,table.name,length(dataSize),numBps);
            end

            bpData=cell(1,numBps);
            for i=1:numBps
                try
                    bpValue=Simulink.Mask.LUTWidgetController.getEvaluatedValue(block,breakpoints(i),isEditTime);
                catch
                    errHandlingPolicy.handleError('Simulink:Masking:UnableToResolveBreakpointData',...
                    breakpoints(i).name,i,blockPath);
                    bpValue=[];
                end

                bplength=0;
                isInvalid=false;

                if(class(bpValue)=="Simulink.Breakpoint")
                    bplength=numel(bpValue.Breakpoints.Value);
                    isInvalid=any(diff(bpValue.Breakpoints.Value)<=0);
                elseif(class(bpValue)=="Simulink.Parameter"&&isvector(bpValue.Value))
                    bplength=numel(bpValue.Value);
                    isInvalid=any(diff(bpValue.Value)<=0);
                elseif(isvector(bpValue))
                    bplength=numel(bpValue);
                    isInvalid=any(diff(bpValue)<=0);
                else
                    errHandlingPolicy.handleError('Simulink:Masking:BreakpointNotAVector',...
                    breakpoints(i).name,blockPath,dataSize(i));
                end

                if isvector(tableData)
                    tableDataLength=length(tableData);
                else
                    tableDataLength=dataSize(i);
                end

                if(bplength~=tableDataLength)
                    errHandlingPolicy.handleError('Simulink:Masking:TableBPlementSizeMismatch',...
                    blockPath,breakpoints(i).name,i);
                end
                if(isInvalid)
                    errHandlingPolicy.handleError('Simulink:Masking:BreakpointNotMonotonicallyIncreasing',...
                    breakpoints(i).name,blockPath);
                end
                bpData{i}=bpValue;
            end


            lutAxes(1,numBps)=LUTWidget.Axis;
            for i=1:numBps
                if(class(bpData{i})=="Simulink.Breakpoint")
                    lutAxes(i).Value=bpData{i}.Breakpoints.Value;
                    lutAxes(i).FieldName=bpData{i}.Breakpoints.FieldName;
                    lutAxes(i).Unit=bpData{i}.Breakpoints.Unit;
                elseif(class(bpData{i})=="Simulink.Parameter")
                    lutAxes(i).Value=bpData{i}.Value;
                    lutAxes(i).Unit=bpData{i}.Unit;
                else
                    lutAxes(i).Value=bpData{i};

                    bpParamName=breakpoints(i).name;



                    [min,max]=Simulink.dialog.LookupTableControl.getMinMax(mask,bpParamName);
                    if~isempty(min)
                        lutAxes(i).Min=min;
                    end
                    if~isempty(max)
                        lutAxes(i).Max=max;
                    end
                end

                if~isempty(breakpoints(i).unit)
                    lutAxes(i).Unit=breakpoints(i).unit;
                end
                if~isempty(breakpoints(i).fieldName)
                    lutAxes(i).FieldName=breakpoints(i).fieldName;
                elseif isempty(lutAxes(i).FieldName)
                    if~isempty(breakpoints(i).prompt)
                        lutAxes(i).FieldName=breakpoints(i).prompt;
                    else
                        lutAxes(i).FieldName=breakpoints(i).name;
                    end
                end
            end


            lutTable=LUTWidget.Table;
            if~isempty(tableData)
                lutTable.Value=tableData;
            end

            if~isempty(table.unit)
                lutTable.Unit=table.unit;
            elseif(class(tableValue)=="Simulink.Parameter")
                lutTable.Unit=tableValue.Unit;
            end

            if~isempty(table.fieldName)
                lutTable.FieldName=table.fieldName;
            elseif~isempty(table.prompt)
                lutTable.FieldName=table.prompt;
            else
                lutTable.FieldName=table.name;
            end



            [min,max]=Simulink.dialog.LookupTableControl.getMinMax(mask,table.name);
            if~isempty(min)
                lutTable.Min=min;
            end
            if~isempty(max)
                lutTable.Max=max;
            end

            lutwidget.setBaselineData(lutTable,lutAxes);
        end




        function updateBPFromObject(block,widgetAxis,objName)
            try
                breakpoint=slResolve(objName,block.Handle);
            catch
                breakpoint='';
            end
            if(class(breakpoint)~="Simulink.Breakpoint")
                return;
            end
            widgetAxis.Value=breakpoint.Breakpoints.Value;
            widgetAxis.FieldName=breakpoint.Breakpoints.FieldName;
            widgetAxis.Unit=breakpoint.Breakpoints.Unit;
        end




        function updateBPObject(block,objName,widgetAxis)
            try
                breakpoint=slResolve(objName,block.Handle);
            catch
                breakpoint='';
            end
            if(class(breakpoint)~="Simulink.Breakpoint")
                return;
            end
            breakpoint.Breakpoints.Value=widgetAxis.Value;
        end




        function[value]=getEvaluatedValue(block,prm,isEditTime)
            if(isEditTime)
                value=[];
                if(isvarname(prm.value))
                    value=slResolve(prm.value,block.Handle,'variable');
                end
                if(isempty(value))
                    value=slResolve(prm.value,block.Handle);
                end
            else
                value=get_param(block.Handle,"value@"+prm.name);
            end
        end




        function[widgetSize]=calculateWidgetSize(dataSize)
            maxDim=max(dataSize);

            maxHeight=1000;
            minHeight=240;
            rowHeight=23;
            sliceSelectorHeight=95;

            height=maxDim*rowHeight+sliceSelectorHeight;
            height=max(minHeight,height);
            height=min(height,maxHeight);
            width=0;

            widgetSize=[width,height];
        end




        function addWidgetFeature(lutWidget,feature)
            widgetFeatures=lutWidget.getFeatures();
            if~any(cellfun(@(f)isa(f,class(feature)),widgetFeatures))
                lutWidget.addFeature(feature);
            end
        end




        function removeWidgetFeature(lutWidget,featureType)
            widgetFeatures=lutWidget.getFeatures();
            indx=find(cellfun(@(f)isa(f,featureType),widgetFeatures));
            if~isempty(indx)
                lutWidget.removeFeature(widgetFeatures{indx});
            end
        end

    end
end


