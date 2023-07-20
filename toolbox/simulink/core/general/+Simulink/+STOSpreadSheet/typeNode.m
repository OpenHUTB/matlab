classdef typeNode<handle
    properties
        mSTLObj;
        mModelName;
        children;
        mRateSet;
        type='type';
        typeName;
        sourceObj;
        baseRate;
    end
    methods
        function this=typeNode(sourceObj,typeData,sampletimelegnedObj,mModelName,baseRate)
            this.mRateSet=typeData;
            this.mModelName=mModelName;
            this.mSTLObj=sampletimelegnedObj;
            this.typeName=typeData(1).executionType;
            this.sourceObj=sourceObj;
            this.baseRate=baseRate;
            for index=1:length(typeData)
                typeData(index).parent=this;
            end
        end


        function b=isHierarchical(~)
            b=true;
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

        function readOnly=isExpanded(this,propName)
            readOnly=true;
        end






        function valid=isValidProperty(this,propName)
            if(isequal(propName,'Type')||isequal(this.typeName,DAStudio.message('Simulink:utility:DiscreteTitle')))
                valid=true;
            else
                valid=false;
            end
        end


        function propValue=getPropValue(obj,propName)
            switch propName
            case 'Type'
                propValue=obj.typeName;
            case 'Value'
                if(isequal(obj.typeName,DAStudio.message('Simulink:utility:DiscreteTitle')))
                    if(obj.sourceObj.mInvertPeriod)
                        propValue=DAStudio.message('Simulink:utility:DiscInvPeriod');
                    else
                        propValue=DAStudio.message('Simulink:utility:DiscPeriod');
                        if slfeature('DisplayBaseRate')
                            propValue=DAStudio.message('Simulink:utility:DiscSampleTime');
                        end
                    end
                else
                    propValue='';
                end
            otherwise
                propValue='';
            end
        end


        function getPropertyStyle(this,aPropName,propertyStyle)
            propertyStyle.BackgroundColor=[0.95,0.95,0.95];
            propertyStyle.Bold=true;

            if(isequal(this.sourceObj.highlightMode,'all'))
                propertyStyle.Tooltip=DAStudio.message('Simulink:utility:HighlightClickTypeToolTipsAll',this.typeName);
            elseif(isequal(this.sourceObj.highlightMode,'source'))
                propertyStyle.Tooltip=DAStudio.message('Simulink:utility:HighlightClickTypeToolTipsOrig',this.typeName);
            else
                propertyStyle.Tooltip='';
            end

        end

    end
end
