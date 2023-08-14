classdef QosPolicy<dds.internal.simulink.ui.internal.dds.datamodel.Element



    properties(Access=private)
        mPolicyName;
        mData;
    end

    properties(Constant,Hidden)
        HIDDENPROPS={'Annotations'};
    end

    methods
        function this=QosPolicy(mdl,tree,node,policyName)
            this@dds.internal.simulink.ui.internal.dds.datamodel.Element(mdl,tree,node);
            this.mPolicyName=policyName;
        end

        function name=getDisplayLabel(this)
            name=this.mPolicyName;
        end

        function icon=getDisplayIcon(this)
            path='toolbox/dds/adaptor/+dds/+internal/+simulink/+ui/+internal/resources/';
            objType='QosPolicy';
            icon=[path,objType,'.png'];
        end

        function tf=isHierarchical(this)
            tf=true;
        end

        function tf=isHierarchicalChildren(this)
            tf=true;
        end

        function children=getChildren(this)
            children=[];
            if isempty(this.mData)
                this.mData=this.generateChildren();
            end
            children=this.mData;
        end

        function children=getHierarchicalChildren(this)
            children=[];
            if isempty(this.mData)
                this.mData=this.generateChildren();
            end
            children=this.mData;
        end

        function isValid=isValidProperty(this,propName)
            if isequal(propName,'Name')
                isValid=true;
                return;
            elseif~isequal(propName,'Value')
                isValid=false;
                return;
            end
            isValid=false;
            if isempty(properties(this.mNode.(this.mPolicyName)))
                isValid=true;
            end
        end

        function isReadonly=isReadonlyProperty(this,propName)
            if~isequal(propName,'Value')
                isReadonly=true;
                return;
            end
            isReadonly=true;
            if isempty(properties(this.mNode.(this.mPolicyName)))
                isReadonly=false;
            end
        end

        function dataType=getPropDataType(this,propName)
            if islogical(this.mNode.(this.mPolicyName))
                dataType='bool';
            elseif isenum(this.mNode.(this.mPolicyName))
                dataType='enum';
            else
                dataType='string';
            end
        end

        function values=getPropAllowedValues(this,propName)
            if isenum(this.mNode.(this.mPolicyName))
                values=cellstr(enumeration(this.mNode.(this.mPolicyName)));
            else
                values='';
            end
        end

        function propVal=getPropValue(this,propName)
            propVal='';
            if isequal(propName,'Name')
                propVal=this.mPolicyName;
            elseif isequal(propName,'Value')
                propVal=this.mNode.(this.mPolicyName);
                switch this.getPropDataType(propName)
                case 'bool'
                    if propVal
                        propVal='1';
                    else
                        propVal='0';
                    end
                case 'enum'
                    values=cellstr(this.mNode.(this.mPolicyName));
                    propVal=values{1};
                otherwise
                    if isnumeric(propVal)
                        propVal=num2str(propVal);
                    end
                end
            end
        end

        function setPropValue(this,propName,propVal)
            switch this.getPropDataType(propName)
            case 'bool'
                if isequal(propVal,'1')
                    this.mNode.(this.mPolicyName)=true;
                else
                    this.mNode.(this.mPolicyName)=false;
                end
            case 'enum'
                this.mNode.(this.mPolicyName)=propVal;
            otherwise
                if isnumeric(this.mNode.(this.mPolicyName))
                    objclass=class(this.mNode.(this.mPolicyName));
                    this.mNode.(this.mPolicyName)=feval(objclass,str2num(propVal));
                else
                    this.mNode.(this.mPolicyName)=propVal;
                end
            end
        end

        function getPropertyStyle(this,propName,propertyStyle)

            if isequal(propName,'Name')
                policyName=this.getPropValue(propName);
                tooltipName=['QosPolicy_',policyName];
                try
                    toolTip=message(['dds:ui:',tooltipName]).getString;
                catch
                    toolTip='';
                end
                if~isempty(toolTip)
                    propertyStyle.Tooltip=toolTip;
                end
            end
        end

        function children=generateChildren(this)
            children=[];
            element=this.mNode.(this.mPolicyName);
            if~isempty(element)
                props=properties(element);
                idxs=ismember(props,dds.internal.simulink.ui.internal.dds.datamodel.qos.QosPolicy.HIDDENPROPS);
                props(idxs,:)=[];
                for idx=1:numel(props)
                    child=dds.internal.simulink.ui.internal.dds.datamodel.qos.QosPolicy(this.mMdl,this.mTree,element,props{idx});
                    children=[children,child];%#ok<AGROW> 
                end
            end
        end

    end


    methods(Static,Access=public)


    end



    methods(Access=private)


    end
end
