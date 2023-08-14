classdef rateNode<handle
    properties
        Color;
        Annotation;
        Description;
        Value;
        ValueOrig;
        mSTLObj;
        RowIdx;
        mModelName;
        TaskId;
        TID;
        parent;
        sourceObj;
        AllBlocks;
        SourceBlocks;
        RateOwner;
        STOObj;
        type='rate';
        executionTypeIdx=1000;
        executionType;
        baseRate;
    end
    methods
        function this=rateNode(sourceObj,rowData,sampletimelegnedObj,rowIdx,mModelName,baseRate)
            this.Color=rowData.ColorRGBValue;
            this.Annotation=rowData.Annotation;
            this.Description=rowData.Description;
            this.Value=rowData.ValueDetails;
            this.ValueOrig=rowData.Value;
            this.TID=rowData.TID;
            this.RateOwner=rowData.Owner;
            this.SourceBlocks=rowData.SourceBlocks;
            this.AllBlocks=rowData.AllBlocks;
            this.mSTLObj=sampletimelegnedObj;
            this.RowIdx=rowIdx;
            this.mModelName=mModelName;
            this.STOObj=rowData.STOObj;
            this.sourceObj=sourceObj;
            this.baseRate=baseRate;
            if(~isempty(rowData.taskId))
                this.TaskId=rowData.taskId;
            else
                this.TaskId=100000;
            end

            val=rowData.Value;

            if(isequal(val,[inf,1]))
                this.executionTypeIdx=3;
                this.executionType=DAStudio.message('Simulink:utility:ModelWideEventTitle');
            elseif(isequal(size(val),[1,2])&&(isequal(val,[0,0])||isequal(val,[0,1])||isequal(val(1),-2)))
                this.executionTypeIdx=0;
                this.executionType=DAStudio.message('Simulink:utility:ContinuousTitle');
                if((isequal(val,[0,0]))||(isequal(val,[0,1])))
                    this.Value.Value{1}=this.Description;
                    this.Value.Value{2}=this.Value.Value{1};
                end
            elseif(isequal(size(val),[1,2])&&isnumeric(val)&&val(1)>0&&~isinf(val(1)))
                this.executionTypeIdx=1;
                this.executionType=DAStudio.message('Simulink:utility:DiscreteTitle');
            elseif(isequal(size(val),[1,2])&&isequal(val(1),-1)&&~isinf(val(2))&&val(2)<=-2)
                this.executionTypeIdx=2;
                this.executionType=DAStudio.message('Simulink:utility:EventTitle');
                this.Value.Value{1}=this.Description;
                this.Value.Value{2}=this.Description;
            elseif(isequal(size(val),[1,2])&&isnumeric(val)&&val(1)>0&&~isinf(val(1))&&val(2)<=-30...
                &&isequal(floor((-val(2))/power(10,floor(log10(-val(2))))),3))
                this.executionTypeIdx=1;
                this.executionType=DAStudio.message('Simulink:utility:DiscreteTitle');
            elseif(isequal(size(val),[1,2])&&isequal(val(1),inf)&&val(2)>2&&~isinf(val(2)))
                this.executionTypeIdx=3;
                this.executionType=DAStudio.message('Simulink:utility:ModelWideEventTitle');
                this.Value.Value{1}=this.Description;
                this.Value.Value{2}=this.Description;
            elseif(isequal(val,[inf,2]))
                this.executionTypeIdx=3;
                this.executionType=DAStudio.message('Simulink:utility:ModelWideEventTitle');
                this.Value.Value{1}=this.Description;
                this.Value.Value{2}=this.Description;
            elseif(ischar(val)&&isfield(this.STOObj,'clockEventType')&&...
                (strcmp(this.STOObj.clockEventType,"EXTERNAL_RUNTIME_EVENT")||...
                strcmp(this.STOObj.clockEventType,"SL_MESSAGES")))
                this.executionTypeIdx=2;
                this.executionType=DAStudio.message('Simulink:utility:EventTitle');
                this.Value.Value{1}=this.Description;
                this.Value.Value{2}=this.Description;
            else
                this.executionTypeIdx=1000;
                this.executionType=DAStudio.message('Simulink:utility:OtherTitle');
            end
        end

        function getPropertyStyle(this,aPropName,propertyStyle)
            barWidth=32;

            if(slfeature('SampleTimeStyling')==1)
                modelToFollow=this.sourceObj.mTopModelName;
            else
                modelToFollow=this.mModelName;
            end
            showColor=get_param(modelToFollow,'SampleTimeColors');
            showAnnotation=get_param(modelToFollow,'SampleTimeAnnotations');
            displaySetting=['Color_',showColor,':Annotation_',showAnnotation];

            if(isequal(aPropName,'Type'))
                switch displaySetting
                case 'Color_on:Annotation_on'
                    if~isempty(this.AllBlocks)
                        propertyStyle.WidgetInfo=struct('Type','progressbar',...
                        'Values',1,'Colors',[this.Color,1],'Width',barWidth,'Text',this.Annotation);
                    end
                case 'Color_on:Annotation_off'
                    if~isempty(this.AllBlocks)
                        propertyStyle.WidgetInfo=struct('Type','progressbar',...
                        'Values',1,'Colors',[this.Color,1],'Width',barWidth);
                    end
                case 'Color_off:Annotation_on'
                    if~isempty(this.AllBlocks)
                        propertyStyle.WidgetInfo=struct('Type','progressbar',...
                        'Values',1,'Colors',[1,1,1,1],'Width',barWidth,'Text',this.Annotation);
                    end
                otherwise
                    propertyStyle.WidgetInfo=struct('Type','progressbar',...
                    'Values',1,'Colors',[1,1,1,1],'Width',barWidth);
                end
            end
            if slfeature('DisplayBaseRate')
                if(isequal(aPropName,DAStudio.message('Simulink:utility:ValueWithoutColon')))
                    period=str2double(this.Value.Value{1});
                    if(~isnan(period)&&~isinf(period))
                        multiplier=num2str(round(period/str2double(this.baseRate)));
                        propertyStyle.WidgetInfo=struct('Type','label',...
                        'Text',strcat(multiplier,'*H'));
                    end
                end
            end
            if(isequal(this.sourceObj.highlightMode,'all'))
                propertyStyle.Tooltip=DAStudio.message('Simulink:utility:HighlightClickToolTipsAll',this.Description);
            elseif(isequal(this.sourceObj.highlightMode,'source'))
                propertyStyle.Tooltip=DAStudio.message('Simulink:utility:HighlightClickToolTipsOrig',this.Description);
            else
                propertyStyle.Tooltip=this.Description;
            end
        end

        function b=isHierarchical(~)
            b=false;
        end

        function readOnly=isReadonlyProperty(this,propName)
            readOnly=true;
        end

        function propValue=getPropValue(obj,propName)
            switch propName
            case 'Type'
                if(isempty(obj.AllBlocks)&&strcmp(get_param(obj.mModelName,'SampleTimeAnnotations'),'on'))
                    propValue=strcat(DAStudio.message('Simulink:utility:Empty'),": ",obj.Annotation);
                elseif(isempty(obj.AllBlocks)&&strcmp(get_param(obj.mModelName,'SampleTimeAnnotations'),'off'))
                    propValue=DAStudio.message('Simulink:utility:Empty');
                else
                    propValue='';
                end
            case DAStudio.message('Simulink:utility:ValueWithoutColon')
                isDiscrete=obj.Value.isDiscrete;
                showInvertPeriod=obj.sourceObj.mInvertPeriod;
                hasOffset=false;
                if(isDiscrete&&~isempty(obj.Value.Value{2}))
                    hasOffset=true;
                end

                if isDiscrete
                    if(showInvertPeriod)
                        if(hasOffset)
                            propValue=strcat(obj.Value.Value{3},", (",DAStudio.message('Simulink:utility:DiscToolTipOffsetPeriodRatio'),": ",obj.Value.Value{4},")");
                        else
                            propValue=obj.Value.Value{3};
                        end
                    else
                        if(hasOffset)
                            propValue=strcat(obj.Value.Value{1},", (",DAStudio.message('Simulink:utility:DiscToolTipOffset'),": ",obj.Value.Value{2},")");
                        else
                            propValue=obj.Value.Value{1};
                        end
                    end
                elseif strcmp(obj.executionType,DAStudio.message('Simulink:utility:OtherTitle'))
                    if(ischar(obj.ValueOrig)&&~isequal(obj.ValueOrig,'N/A'))
                        propValue=strcat(obj.Description,",  ",obj.ValueOrig);
                    elseif(isequal(isnan(obj.ValueOrig),[1,1]))
                        propValue=strcat(obj.Description,":  ",obj.Value.Value{1});
                    else
                        propValue=obj.Description;
                    end
                else
                    propValue=obj.Value.Value{1};
                end
            otherwise
                propValue=' ';
            end
        end

        function isHyperlink=propertyHyperlink(this,propName,clicked)
            isHyperlink=false;
        end


        function isValid=isValidProperty(this,propName)
            isValid=true;
        end

    end

    methods
        function HyperlinkOfSampeTime(~)
            web(fullfile(docroot,'simulink/ug/types-of-sample-time.html'));
        end
    end

end
