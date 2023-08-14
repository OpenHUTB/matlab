classdef InterfaceDataPropertySchema<handle





    properties(Access=protected)
        Source='';
        mPropMap;
    end

    methods
        function this=InterfaceDataPropertySchema()
            this.mPropMap=containers.Map;
        end

        function tabview=supportTabView(~)
            tabview=false;
        end

        function mode=rootNodeViewMode(~,~)
            mode='TreeView';
        end

        function hasSub=hasSubProperties(obj,prop)
            if(isempty(prop)||obj.isRootNodeProperty(prop))
                hasSub=true;
            else
                hasSub=false;
            end
        end

        function subprops=subProperties(obj,prop)
            if isempty(prop)
                if strcmp(obj.Source.getPropValue('isTreeNode'),'true')
                    subprops=[];
                else

                    subprops=[obj.getProperties(prop,true,false),...
                    obj.getPerspectives('propertyInspector')];
                end
            else
                subprops=obj.getProperties(prop,true,true);
            end
        end

        function label=propertyDisplayLabel(obj,prop)
            if contains(prop,':')
                label=DAStudio.message(prop);
            else
                label=obj.getPropName(prop);
            end
        end

        function name=getObjectName(obj)
            name=getPropValue(obj.Source,'Source');
        end

        function label=getObjectType(obj)
            label=obj.getTabName();
        end

        function handle=getOwnerGraphHandle(obj)
            proxy=obj.Source;
            canvasObj=proxy.getForwardedObject;
            if~isempty(canvasObj)
                if isa(canvasObj,'Simulink.Port')
                    portH=canvasObj.Handle;
                    handle=bdroot(portH);
                elseif isa(canvasObj,'Simulink.BlockDiagram')
                    handle=bdroot(canvasObj.Handle);
                elseif(isprop(canvasObj,'Type')&&strcmp(canvasObj.Type,'block'))
                    blockH=canvasObj.Handle;
                    handle=bdroot(blockH);
                else

                    model=proxy.getFullName;
                    handle=get_param(model,'Handle');
                end
            else
                handle=proxy;
            end
        end


        function value=propertyValue(obj,prop)
            value='';
            if~obj.hasSubProperties(prop)&&obj.Source.isValidProperty(prop)
                value=obj.Source.getPropValue(prop);
            end
        end

        function setPropertyValue(obj,prop,value)
            setPropValue(obj.Source,prop,value);
        end

        function readonly=isHierarchyReadonly(obj)
            readonly=obj.Source.isHierarchyReadonly;
        end

        function valid=isValidProperty(obj,prop)
            valid=obj.Source.isValidProperty(prop);
        end

        function label=getDisplayLabel(obj)
            label=obj.Source.getDisplayLabel;
        end

        function enabled=isPropertyEnabled(obj,prop)

            if obj.hasSubProperties(prop)
                enabled=true;
            else
                enabled=~(obj.Source.isHierarchyReadonly)&&...
                ~(obj.Source.isHierarchySimulating&&~isTunableProperty(obj.Source,prop))&&...
                isValidProperty(obj.Source,prop)&&~isReadonlyProperty(obj.Source,prop);
            end
        end

        function editor=propertyEditor(obj,prop)
            editor={};
            editType=false;
            if isequal('enum',getPropDataType(obj.Source,prop))
                editor=DAStudio.UI.Widgets.ComboBox;
                editor.Entries=getPropAllowedValues(obj.Source,prop);
                editor.CurrentText=obj.Source.getPropValue(prop);
                editor.Editable=false;
                if isempty(editor.Entries)

                    editor=DAStudio.UI.Widgets.Edit;
                    editor.Text=obj.Source.getPropValue(prop);
                end
            elseif isequal('bool',getPropDataType(obj.Source,prop))
                editor=DAStudio.UI.Widgets.CheckBox;
                editor.Checked=obj.Source.getPropValue(prop);
                if strcmp(editor.Checked,'1')||strcmp(editor.Checked,'on')
                    editor.Checked=true;
                elseif strcmp(editor.Checked,'0')||strcmp(editor.Checked,'off')
                    editor.Checked=false;
                end
            else
                entries=getPropAllowedValues(obj.Source,prop);
                if isempty(entries)
                    editor=DAStudio.UI.Widgets.Edit;
                    editType=true;
                    editor.Text=obj.Source.getPropValue(prop);
                else
                    editor=DAStudio.UI.Widgets.ComboBox;
                    editor.Entries=entries;
                    editor.CurrentText=obj.Source.getPropValue(prop);
                    editor.Editable=true;
                end
            end
            if~isempty(editor)
                editor.Enabled=isEditableProperty(obj.Source,prop);
                try
                    if editType&&obj.Source.propertyHyperlink(prop,false)


                        editor.Enabled=false;
                    end
                catch
                end

                editor.Tag=prop;
            end

        end

        function editable=isPropertyEditable(obj,prop)

            if obj.hasSubProperties(prop)
                editable=false;
            else
                editable=~isReadonlyProperty(obj.Source,prop);
                try
                    if obj.Source.propertyHyperlink(prop,false)


                        editable=false;
                    end
                catch
                end
            end
        end

        function mode=propertyRenderMode(obj,prop)
            if isValidProperty(obj.Source,prop)&&isequal('bool',getPropDataType(obj.Source,prop))
                mode='RenderAsCheckBox';
            else
                mode='RenderAsText';
            end
        end

        function props=getColumnHeaders(obj,perspective,addPath)
            props={};
            perspectives=obj.getPerspectives('spreadsheet');
            for name=perspectives
                if isequal(perspective,DAStudio.message(name{1}))
                    props=[obj.getCommonProperties(perspective,false),...
                    obj.getProperties(name{1},false,false)];
                    break;
                end
            end
            if addPath
                props=[props,'Path'];
            end
        end

        function isVisible=isTabVisible(~,currentSystem)
            isVisible=true;
        end

        function isEnabled=isTabEnabled(~,currentSystem)
            isEnabled=true;
        end

        function needsRefresh=needsRefreshForMappingChange(~,~)
            needsRefresh=false;
        end
        function props=getPerInstanceProperties(~,~)
            props={};
        end
        function handleHelp(~,~)

        end
        function menu=getContextMenu(~,~,~)
            menu=[];
        end
        function isHierarchical=useHierarchicalSpreadsheet(~,~)
            isHierarchical=false;
        end
        function out=needsRefresh(~,~)
            out=false;
        end
    end


    methods(Access=protected)


        function result=isRootNodeProperty(obj,prop)
            result=any(strcmp(prop,obj.getPerspectives('propertyInspector')));
        end
        function props=getProperties(obj,perspective,justValid,checkForDuplicates)
            includeHidden=justValid;
            if isempty(perspective)
                props=getCommonProperties(obj,[],includeHidden);

                if includeHidden
                    perspectives=obj.getPerspectives('propertyInspector');
                    allprops={};
                    duplicateList={};
                    for name=perspectives
                        perspProps=obj.getPerspectiveProperties(name{1},includeHidden);
                        duplicateList=union(duplicateList,intersect(allprops,perspProps))';
                        allprops=union(perspProps,allprops,'stable')';
                    end
                    props=union(props,duplicateList,'stable');
                end

            else
                props=getPerspectiveProperties(obj,perspective,includeHidden);
                if includeHidden&&isequal(perspective,'Simulink:studio:DataViewPerspective_CodeGen')
                    props=[props,getHiddenProps(obj,perspective,props)];
                end
            end
            if justValid
                validProps={};
                len=length(props);
                for i=1:len
                    if isValidProperty(obj.Source,props{i})
                        validProps{end+1}=props{i};
                    end
                end
                props=validProps;
            end
            props=[props,obj.getPerInstanceProperties(perspective)];
            if~isempty(perspective)&&includeHidden&&checkForDuplicates
                commonprops=getProperties(obj,'',includeHidden,true);

                props=setdiff(props,commonprops,'stable');
            end

            if~isempty(perspective)
                prefix=[perspective,'.'];
                len=length(props);
                for i=1:len
                    if startsWith(props{i},prefix)
                        propname=propertyName(length(prefix)+1:end);
                        obj.mPropMap(props{i})=propname;
                    elseif strcmp(perspective,'Calibration')||...
                        strcmp(perspective,'Measurement')
                        propname=coder.internal.ProfileStereotypeUtils.getDisplayName(props{i},prefix);
                        obj.mPropMap(props{i})=propname;
                    end

                end
            end
        end

        function hiddenProps=getHiddenProps(obj,perspective,props)
            hiddenProps={};
            hiddenPropsRealNames={};
            pattern='';
            if isequal(perspective,'Simulink:studio:DataViewPerspective_CodeGen')
                pattern='CoderInfo';
            end
            all_props=getPossibleProperties(obj.Source)';
            real_props=getDisplayToRealProperty(obj.Source,props);
            for possible_prop=all_props
                realName=getDisplayToRealProperty(obj.Source,possible_prop);
                if startsWith(realName,pattern)&&~any(strcmp(realName,real_props))&&~any(strcmp(possible_prop{1},hiddenPropsRealNames))
                    hiddenProps{end+1}=possible_prop{1};
                    hiddenPropsRealNames{end+1}=realName{1};
                end
            end
        end

        function outprops=addResolveProperty(obj,props)
            outprops=props;
            if isa(obj.Source,'DataView')
                model=bdroot(obj.Source.m_Source.Handle);
            else
                slObj=obj.Source.getForwardedObject;
                model=bdroot(slObj.getParent.Handle);
            end
            if isequal(model,0)



                warnState=warning('off','Simulink:Commands:GetParamDefaultBlockDiagram');
                if~strcmp(get_param(model,'SignalResolutionControl'),'None')
                    outprops{end+1}='Resolve';
                end
                warning(warnState);
            else
                if~strcmp(get_param(model,'SignalResolutionControl'),'None')
                    outprops{end+1}='Resolve';
                end
            end
        end

        function realProp=getPropName(obj,propName)
            if obj.mPropMap.isKey(propName)
                realProp=obj.mPropMap(propName);
            else
                realProp=propName;
            end
        end
    end

    methods(Abstract,Static)
        getTabName();
    end

    methods(Abstract)

        getPerspectives(obj,viewType);
        isCSBAllowed(obj);
        getDefaultSort(obj);
    end

    methods(Access=protected,Abstract)


        getCommonProperties(obj,perspective,includeHidden);
        getPerspectiveProperties(obj,perspective,includeHidden);
    end

end


