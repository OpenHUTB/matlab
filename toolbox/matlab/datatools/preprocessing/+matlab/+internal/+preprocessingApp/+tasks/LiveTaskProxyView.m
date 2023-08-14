classdef LiveTaskProxyView...
    <internal.matlab.inspector.InspectorProxyMixin&dynamicprops&internal.matlab.inspector.ProxyAddPropMixin


    events
DataChange
    end

    properties(Access={?matlab.unittest.TestCase})
        ChangeListener event.listener
Editable
    end

    methods
        function this=LiveTaskProxyView(obj)
            this=this@internal.matlab.inspector.InspectorProxyMixin(obj);

            this.ChangeListener(1)=addlistener(obj,'StateChanged',@(e,d)this.updateDynamicProperties);
            if ismember('StateChangedFromRichEditor',events(obj))
                this.ChangeListener(2)=addlistener(obj,'StateChangedFromRichEditor',@(e,d)this.updatePropsWithoutNotifyDataChange);
            end




            props=this.OriginalObjects.getPropertyInformation;

            groupNames=unique(props.Group,'stable');
            for i=1:length(groupNames)
                groupName=groupNames(i);
                propertyNames=cellstr(props.Name(props.Group==groupName&props.InSubgroup==false));
                subGroupProps=cellstr(props.Name(props.Group==groupName&props.InSubgroup==true));
                group=this.createGroup(groupName,'','');

                for idx=1:length(propertyNames)
                    propName=propertyNames{idx};
                    propTable=props(props.Name==propName,:);
                    if propTable.InitializeFlag>1||isequal(propTable.Type,{'MultiselectDropDown'})


                        group.addEditorGroup(propName);
                    elseif contains(propTable.Type{:},'richeditors')

                        group.addEditorGroup(propName);

                        this.assignUserRichEditorUI(propName,string(propTable.Type),this.OriginalObjects.State.(propTable.StateName));
                    else
                        group.addProperties(propName);
                    end
                end

                group.addSubGroup(subGroupProps{:});
                isExpanded=props.GroupExpanded(props.Group==groupName);
                group.Expanded=isExpanded(1);
            end

            this.updateDynamicProperties;
        end

        function delete(this)
            for k=1:numel(this.ChangeListener)
                delete(this.ChangeListener(k));
            end
        end

        function val=getPropValue(this,propName)
            props=this.OriginalObjects.getPropertyInformation;
            stateField=props.StateName(props.Name==propName);
            s=this.OriginalObjects.State;
            val=s.(stateField);

            items=props.Items{props.Name==propName};
            spinnerprops=props.SpinnerProperties{props.Name==propName};
            type=props.Type{props.Name==propName};
            if~isempty(items)

                itemsData=props.ItemsData{props.Name==propName};
                if~isempty(val)

                    [isvalidvalue,valueLocations]=ismember(val,itemsData);
                    val=items(valueLocations(isvalidvalue));
                end
                if isequal(type,'MultiselectDropDown')
                    val=internal.matlab.editorconverters.datatype.CheckboxList(...
                    val,items(2:end),items(1));
                else
                    val=internal.matlab.editorconverters.datatype.ProtectedStringEnumeration(val,items);
                end
            elseif~isempty(spinnerprops)
                val=internal.matlab.editorconverters.datatype.SpinnerValue(val,...
                "MinValue",spinnerprops.Limits(1),...
                "MaxValue",spinnerprops.Limits(2),...
                "IncludeMin",logical(spinnerprops.LowerLimitInclusive),...
                "IncludeMax",logical(spinnerprops.UpperLimitInclusive),...
                "Step",spinnerprops.Step);
            elseif contains(type,'richeditors')
                val=internal.matlab.editorconverters.datatype.UserRichEditorUIType(val,this.getRichEditorUI(propName));
            end
        end

        function setPropValue(this,propName,val)
            props=this.OriginalObjects.getPropertyInformation;
            stateField=props.StateName(props.Name==propName);
            s=this.OriginalObjects.State;
            if isa(val,'internal.matlab.editorconverters.datatype.ProtectedStringEnumeration')||...
                isa(val,'internal.matlab.editorconverters.datatype.SpinnerValue')
                val=val.Value;
            elseif isa(val,"internal.matlab.editorconverters.datatype.CheckboxList")

                val=val.Value;
                if iscell(val)&&isequal(size(val),[1,1])
                    val=val{1};
                end
                if isempty(val)
                    val="";
                end
            elseif isa(val,'internal.matlab.editorconverters.datatype.UserRichEditorUIType')
                val=val.Value;
            end

            items=props.Items(props.Name==propName);
            if~isempty(items{:})
                items=string(items{:});
                itemsData=props.ItemsData(props.Name==propName);
                itemsData=string(itemsData{:});
                [isvalidvalue,valueLocations]=ismember(val,items);
                val=itemsData(valueLocations(isvalidvalue));
            end

            s.(stateField)=val;
            try
                this.OriginalObjects.setTaskState(s,propName);
            catch
                this.OriginalObjects.setTaskState(s);
            end
        end

        function val=getInitializers(this,propName)
            props=this.OriginalObjects.getPropertyInformation;
            initType=props.InitializeFlag(props.Name==propName);


            if initType==1


                val=this.getPropValue(propName);
            else
                propTbl=props(props.Name==propName,:);
                stateField=propTbl.StateName;
                s=this.OriginalObjects.State;
                currVal=string(s.(stateField));

                currVal=strip(currVal,'left','.');
                items=propTbl.Items{1};





                val=internal.matlab.editorconverters.datatype.CheckboxList(...
                currVal,items(2:end),items{1});
            end
        end

        function setInitializers(this,propName,val)
            props=this.OriginalObjects.getPropertyInformation;
            varProp=props.Name(props.InitializeFlag==1);
            tableProp=props.Name(props.InitializeFlag==2);
            if isa(val,"internal.matlab.editorconverters.datatype.CheckboxList")

                val=val.Value;
                if iscell(val)&&isequal(size(val),[1,1])
                    val=val{1};
                end
                if isempty(val)||isequal(val,'[]')
                    val='';
                end
            end

            if strcmp(propName,varProp)
                varValue=val;
                tableVarValue=this.getPropValue(tableProp).Value;
            else
                varValue=this.getPropValue(varProp).Value;
                tableVarValue=val;
            end
            if length(tableVarValue)>1
                this.OriginalObjects.initialize("Inputs",varValue,"TableVariableNames",tableVarValue);
            else
                this.OriginalObjects.initialize("Inputs",varValue);
            end
        end

        function updateEditableState(this,editable)
            this.Editable=editable;

            if this.Editable


                this.updateDynamicProperties();
            else
                currentProps=string(properties(this));
                for i=1:length(currentProps)
                    p=findprop(this,currentProps(i));
                    propName=p.Name;
                    p.SetMethod=[];
                    p.SetAccess='private';
                    this.notifyMetadataChange(propName);
                end
            end
        end
    end

    methods(Access=public)

        function updateDynamicProperties(this)
            updatePropsWithoutNotifyDataChange(this);
            notifyPropsAndDataChange(this);
        end

        function notifyPropsAndDataChange(this)
            this.notifyPropertiesUpdated();
            this.notify('DataChange');
        end

        function updatePropsWithoutNotifyDataChange(this)
            props=this.OriginalObjects.getPropertyInformation;


            this.BulkPropertyChange=true;


            currentProps=string(properties(this));
            newProps=props.Name(props.Visible);
            toRemove=currentProps(~ismember(currentProps,newProps));
            if~isempty(toRemove)
                for i=1:length(toRemove)
                    p=findprop(this,toRemove{i});
                    delete(p);
                end
            end


            for k=1:numel(newProps)
                propName=newProps(k);
                ind=props.Name==propName;
                if~ismember(propName,currentProps)

                    this.addNewProperty(propName,props(ind,:));
                else


                    p=findprop(this,propName);
                    this.setPropertyDisplayName(propName,props.DisplayName(ind))
                    this.setPropertyTooltip(propName,props.Tooltip{ind});
                    if props.Enable(ind)

                        if~props.InitializeFlag(ind)
                            p.SetMethod=@(t,v)setPropValue(t,propName,v);
                        else
                            p.SetMethod=@(t,v)setInitializers(t,propName,v);
                        end
                        p.SetAccess='public';
                    else

                        p.SetMethod=[];
                        p.SetAccess='private';
                    end
                    this.notifyPropChange(propName,this.(propName))
                end
            end
            this.BulkPropertyChange=false;
        end

        function addNewProperty(this,propName,propTable)
            displayName=propTable.DisplayName;
            tooltip=string(propTable.Tooltip);
            isEnabled=propTable.Enable;
            items=propTable.Items;
            isInitializer=propTable.InitializeFlag;


            if~isempty(items{:})
                if isInitializer||isequal(propTable.Type,{'MultiselectDropDown'})

                    propType='internal.matlab.editorconverters.datatype.CheckboxList';
                else

                    propType='internal.matlab.editorconverters.datatype.ProtectedStringEnumeration';
                end
            elseif~isempty(propTable.SpinnerProperties{:})
                propType='internal.matlab.editorconverters.datatype.SpinnerValue';
            elseif contains(propTable.Type{:},'richeditors')
                propType='internal.matlab.editorconverters.datatype.UserRichEditorUIType';
            else
                propType='any';
            end

            getMethod=@(t)getPropValue(t,propName);

            if isEnabled&&~isInitializer
                setMethod=@(t,v)setPropValue(t,propName,v);
                setAccess='public';
            elseif isEnabled&&isInitializer
                getMethod=@(t)getInitializers(t,propName);
                setMethod=@(t,v)setInitializers(t,propName,v);
                setAccess='public';
            else
                setMethod=function_handle.empty;
                setAccess='private';
            end

            currValue=getMethod(this);

            this.addDynamicProp(propName,...
            "Description",displayName,...
            "DetailedDescription",tooltip,...
            "Value",currValue,...
            "Type",propType,...
            "Access",setAccess,...
            "GetMethod",getMethod,...
            "SetMethod",setMethod);
        end
    end
end
