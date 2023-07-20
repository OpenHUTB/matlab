classdef taskNode<handle
    properties
        STLObj;
        mModelName;
        mTopModelName;
        children;
        mRateSet;
        taskIdx;
        type='task';
        rateCount=1;
        source;
        isActive=false;
    end
    methods
        function this=taskNode(taskData,taskIdx,mModelName,mTopModelName,rateCount,source)
            this.source=source;
            this.mRateSet=taskData;
            this.mModelName=mModelName;
            this.mTopModelName=mTopModelName;

            this.taskIdx=taskIdx;
            for index=1:length(taskData)
                taskData(index).parent=this;
            end
            this.rateCount=rateCount;
        end


        function b=isHierarchical(~)
            b=false;
        end

        function children=getChildren(this)
            children=this.mRateSet;
        end


        function children=getHierarchicalChildren(this)
            children=this.mRateSet;
        end

        function readOnly=isReadonlyProperty(this,propName)
            readOnly=true;
        end


        function objInfo=getObjectInfo(obj)
            objInfo='';
            if(~obj.isActive)
                objInfo='{"selectable": false}';
            end
        end






        function valid=isValidProperty(this,propname)
            valid=true;
        end



        function propValue=getPropValue(obj,propName)
            switch propName
            case DAStudio.message('Simulink:utility:TaskID')
                propValue=" ";
                if(isequal(get_param(obj.mModelName,'EffectivelyUsingTaskBasedSorting'),'off'))
                    propValue=DAStudio.message('Simulink:utility:GlobeExecutionOrderDisplay');
                elseif(~isequal(obj.rateCount,1))
                    propValue=" ";
                else
                    propValue=DAStudio.message('Simulink:utility:SingleTaskText')+" "+num2str(obj.taskIdx);
                end
            otherwise
                propValue=obj.mRateSet(obj.rateCount).Description;
                val=obj.mRateSet(obj.rateCount);
                if(isequal(DAStudio.message('Simulink:SampleTime:ExportPeriodicSampleTimeDescription'),propValue)||...
                    isequal(DAStudio.message('Simulink:SampleTime:ExportInheritSampleTimeDescription'),propValue))
                    propValue=strcat(propValue,' (',val.Annotation,')');
                end
            end
        end


        function getPropertyStyle(this,aPropName,propertyStyle)


            if(~this.isActive)
                propertyStyle.BackgroundColor=[0.95,0.95,0.95,1];
                propertyStyle.ForegroundColor=[0.6,0.6,0.6,1];
            elseif(isequal('task',this.source.currentSelection.type)...
                &&isequal(this.mModelName,this.source.currentSelection.mModelName)...
                &&isequal(this.taskIdx,this.source.currentSelection.taskIdx))
                propertyStyle.BackgroundColor=[0,0.6,1,0.2];
            else
                propertyStyle.BackgroundColor=[1,1,1,1];
            end

            if(ismember(this.taskIdx,this.source.currentBlockTaskVec)&&isequal(aPropName,DAStudio.message('Simulink:utility:TaskID'))...
                &&isequal(this.rateCount,1)&&this.isActive)
                propertyStyle.BackgroundColor=[0.851,0.644,0.125,0.2];

            end
        end

    end

end
