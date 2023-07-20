classdef StepperBreakpointSingle<handle


    properties
        mId;
        mSrc;
        mIndex;
        mType;
        mCondition;
        mValue;
        mHits;
        mEnable;
        mHighlight;
    end






    methods
        function this=StepperBreakpointSingle(id,sourceHandle,bp_data)
            this.mId=id;
            this.mSrc=sourceHandle;

            if strcmp(get_param(sourceHandle,'Type'),'block')
                this.mType='b';
            else
                this.mType='s';
            end
            this.mIndex=bp_data{1};
            this.mCondition=bp_data{2};
            this.mValue=bp_data{3};
            this.mEnable=bp_data{4}==1;
            this.mHighlight=bp_data{5};
            this.mHits=bp_data{6};
        end
        function label=getDisplayLabel(this)

            label=num2str(this.mId);
        end
        function aResolve=resolveComponentSelection(this)


            obj=get_param(this.mSrc,'Object');
            aResolve{1}=obj;
            if(isa(obj,'Simulink.Port'))

                aResolve{2}=get_param(get_param(this.mSrc,'Parent'),'Object');
            end
        end
        function tf=isReadonlyProperty(~,propName)

            switch propName
            case 'Hits'
                tf=true;
            case 'Id'
                tf=true;
            case 'Source'
                tf=true;
            case 'Type'
                tf=true;
            case 'Condition'
                tf=true;
            otherwise
                tf=false;
            end
        end
        function dtype=getPropDataType(~,propName)


            switch propName
            case 'Enabled'
                dtype='bool';
            otherwise
                dtype='string';
            end
        end
        function getPropertyStyle(this,propName,aStyle)


            aStyle.Tooltip=propName;

            aStyle.ForegroundColor=[];
            if this.mHighlight
                aStyle.BackgroundColor=[1,0.1,0.1,0.5];
            else
                aStyle.BackgroundColor=[1,1,1,0];
            end
            aStyle.Bold=false;
            aStyle.Italic=false;
        end
        function setPropValue(this,propName,newValue)
            switch propName
            case 'Enabled'
                condStatus.index=this.mIndex;
                condStatus.status=~this.mEnable;
                set_param(this.mSrc,'ConditionalPauseStatus',condStatus);
                this.mEnable=~this.mEnable;
            otherwise
                return;
            end
        end
        function propValue=getPropValue(this,propName)
            switch propName
            case 'Id'
                propValue=num2str(this.mId);
            case 'Source'
                if this.mType=='s'
                    propValue=[get_param(this.mSrc,'Parent'),':',...
                    num2str(get_param(this.mSrc,'PortNumber'))];
                else
                    propValue=get_param(this.mSrc,'Parent');
                end
            case 'Condition'
                if this.mType=='s'
                    propValue=[SLStudio.StepperBreakpointSingle.relationalOperatorString(...
                    this.mCondition),' ',num2str(this.mValue)];
                else
                    propValue=this.mValue;
                end
            case 'Hits'
                propValue=num2str(this.mHits);
            case 'Enabled'
                propValue=num2str(this.mEnable);
            case 'Type'
                if this.mType=='s'
                    propValue='signal';
                else
                    propValue='block';
                end
            otherwise
                propValue='';
            end
        end

        function isHyperlink=propertyHyperlink(this,propName,clicked)
            switch propName
            case 'Source'
                isHyperlink=true;
                if clicked
                    hilite_system(this.mSrc);
                end
            case 'Condition'
                isHyperlink=false;




            case 'Enabled'
                isHyperlink=false;
            otherwise
                isHyperlink=false;
            end
        end

        function isValid=isValidProperty(~,propName)
            switch propName
            case 'Id'
                isValid=true;
            case 'Source'
                isValid=true;
            case 'Condition'
                isValid=true;
            case 'Hits'
                isValid=true;
            case 'Enabled'
                isValid=true;
            case 'Type'
                isValid=true;
            otherwise
                isValid=false;


            end
        end
    end
    methods(Static)
        function str=relationalOperatorString(idx)
            switch(idx)
            case 0
                str=DAStudio.message('Simulink:studio:Greater');
            case 1
                str=DAStudio.message('Simulink:studio:GreaterEqual');
            case 2
                str=DAStudio.message('Simulink:studio:Equal');
            case 3
                str=DAStudio.message('Simulink:studio:NotEqual');
            case 4
                str=DAStudio.message('Simulink:studio:LessEqual');
            case 5
                str=DAStudio.message('Simulink:studio:Less');
            case 6
                str='Diagnostic';

            otherwise
                str=DAStudio.message('Simulink:studio:Greater');
            end
        end
    end
end
