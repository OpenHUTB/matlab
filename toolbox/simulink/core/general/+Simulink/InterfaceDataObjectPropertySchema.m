classdef InterfaceDataObjectPropertySchema<Simulink.InterfaceParameterPropertySchema&Simulink.InterfaceSignalPropertySchema





    properties(Access=protected)
        UsageList='';
        ProxyObj;
        PropertyInspectorLevel;
        ObjectTypeName;
    end

    methods(Static)
        function name=getTabName()
            name=DAStudio.message('Simulink:studio:DataViewDataObjects');
        end
    end

    methods
        function this=InterfaceDataObjectPropertySchema(h,proxy)
            this@Simulink.InterfaceSignalPropertySchema(h);
            this@Simulink.InterfaceParameterPropertySchema(h);
            this.Source=h;
            this.ProxyObj=proxy;
            this.PropertyInspectorLevel=1;

            if~isempty(this.ProxyObj)&&~isa(this.ProxyObj,'Simulink.DataViewProxy')
                objectLevel=0;
                var=getVariable(this.ProxyObj);
                objectLevel=Simulink.data.getScalarObjectLevel(var);
                if(objectLevel==0)
                    className=DAStudio.message('Simulink:studio:DataViewDataObjects');
                else
                    className=class(var);
                end
            else
                className=DAStudio.message('Simulink:studio:DataViewDataObjects');
            end
            this.ObjectTypeName=className;

        end

        function mode=rootNodeViewMode(~,~)

            mode='TreeView';
        end

        function props=getPerspectives(obj,viewType)
            if isa(obj.ProxyObj,'Simulink.DataViewProxy')
                props={};
            elseif isa(obj.ProxyObj.getVariable,'Simulink.Signal')
                props=getPerspectives@Simulink.InterfaceSignalPropertySchema(obj,viewType);
            else
                props=getPerspectives@Simulink.InterfaceParameterPropertySchema(obj,viewType);
            end
            props{end+1}='Simulink:studio:DataViewPerspective_Other';
        end

        function subprops=subProperties(obj,prop)
            newsubprops={};
            if isequal(1,obj.PropertyInspectorLevel)
                subprops=subProperties@Simulink.InterfaceDataPropertySchema(obj,prop);
                if(isempty(prop))
                    for i=1:length(subprops)
                        if(hasSubProperties(obj,subprops{i}))
                            subpropsTemp=subProperties@Simulink.InterfaceDataPropertySchema(obj,subprops{i});
                            if(~isempty(subpropsTemp))
                                newsubprops=[newsubprops,subprops{i}];
                            end
                        else
                            newsubprops{end+1}=subprops{i};
                        end
                    end
                end

                if(~isempty(newsubprops))
                    subprops=newsubprops;
                end

            elseif~isempty(obj.ProxyObj)
                subprops=getPossibleProperties(obj.ProxyObj);
            else
                subprops={};
            end
        end

        function name=getObjectName(obj)
            name=obj.Source.getDisplayLabel;
        end

        function label=getObjectType(obj)
            label=obj.ObjectTypeName;
        end

        function value=getPropValue(obj,prop)
            value=getPropValue(obj.Source,prop);
        end

        function setPropValue(obj,prop,value)
            setPropValue(obj.Source,prop,value);
        end

        function allowed=isCSBAllowed(~)
            allowed=true;
        end
        function defaultSort=getDefaultSort(~)

            defaultSort={' ',true};
        end
        function props=getPerInstanceProperties(obj,perspective)
            if isa(obj.ProxyObj,'Simulink.DataViewProxy')
                props={};
            elseif isa(obj.ProxyObj.getVariable,'Simulink.Signal')
                props=getPerInstanceProperties@Simulink.InterfaceSignalPropertySchema(obj,perspective);
            else
                props=getPerInstanceProperties@Simulink.InterfaceParameterPropertySchema(obj,perspective);
            end
        end
        function handleHelp(obj,perspective)
            if isa(obj.ProxyObj,'Simulink.DataViewProxy')
                return;
            elseif isa(obj.ProxyObj.getVariable,'Simulink.Signal')
                handleHelp@Simulink.InterfaceSignalPropertySchema(obj,perspective);
            else
                handleHelp@Simulink.InterfaceParameterPropertySchema(obj,perspective);
            end
        end
        function retVal=getContextMenu(obj,ssComponent,item)
            retVal=[];
            imss=ssComponent.imSpreadSheetComponent;
            if isequal(1,length(imss.getSelection))
                actionStructs=struct('label',{},'enabled',{},'visible',{},'command',{});

                tag='dataObj_open';
                command=item.getContextCallback(tag);
                menuItem=struct('label',DAStudio.message('Simulink:dialog:VariableContextMenu_Open')...
                ,'enabled',~isempty(command),'visible',true,'command',command);
                if~isempty(command)
                    actionStructs(end+1)=menuItem;
                end

                tag='dataObj_explore';
                command=item.getContextCallback(tag);
                menuItem=struct('label',DAStudio.message('Simulink:dialog:VariableContextMenu_Explore')...
                ,'enabled',true,'visible',true,'command',command);
                if~isempty(command)
                    actionStructs(end+1)=menuItem;
                end

                actionStructs(end+1)=struct('label','separator'...
                ,'enabled',true,'visible',true,'command','');

                tag='dataObj_findUsed';
                command=item.getContextCallback(tag);
                menuItem=struct('label',DAStudio.message('modelexplorer:DAS:ME_FIND_WHERE_USED')...
                ,'enabled',true,'visible',true,'command',command);
                if~isempty(command)
                    actionStructs(end+1)=menuItem;
                end

                tag='dataObj_renameAll';
                command=item.getContextCallback(tag);
                menuItem=struct('label',DAStudio.message('Simulink:studio:RenameAll')...
                ,'enabled',true,'visible',~isequal(ssComponent.getName(),'CodeProperties'),'command',command);
                if~isempty(command)
                    actionStructs(end+1)=menuItem;
                end

                tag='dataObj_convertToParam';
                command=item.getContextCallback(tag);
                menuItem=struct('label',DAStudio.message('modelexplorer:DAS:ME_CONVERT_TO_PARAM')...
                ,'enabled',true,'visible',true,'command',command);
                if~isempty(command)
                    actionStructs(end+1)=struct('label','separator'...
                    ,'enabled',true,'visible',true,'command','');
                    actionStructs(end+1)=menuItem;
                end

                retVal=actionStructs;
            end
        end

        function isHierarchical=useHierarchicalSpreadsheet(~,~)
            if(slfeature('HierarchicalViewInMDE')>0)
                isHierarchical=true;
            else
                isHierarchical=false;
            end
        end

    end



    methods(Access=protected)

        function result=isRootNodeProperty(obj,prop)
            if isequal(prop,'Simulink:studio:DataViewPerspective_Other')
                result=true;
            else
                result=isRootNodeProperty@Simulink.InterfaceDataPropertySchema(obj,prop);
            end
        end

        function props=getCommonProperties(obj,perspective,includeHidden)
            if isa(obj.ProxyObj,'Simulink.DataViewProxy')
                props={};
            elseif isa(obj.ProxyObj.getVariable,'Simulink.Signal')
                props=getCommonProperties@Simulink.InterfaceSignalPropertySchema(obj,perspective,includeHidden);
            else
                props=getCommonProperties@Simulink.InterfaceParameterPropertySchema(obj,perspective,includeHidden);
            end
            if includeHidden
                if~isValidProperty(obj.Source,'Name')
                    idx=find(strcmp(props(:),'Name'));
                    if idx>0
                        props(idx)={'Path'};
                    end
                end
                props{end+1}='Description';
            end
        end
        function props=getPerspectiveProperties(obj,perspective,includeHidden)
            if isequal(perspective,'Simulink:studio:DataViewPerspective_Other')
                all_props=getPossibleProperties(obj.ProxyObj)';
                found_props={};

                perspectives=obj.getPerspectives('propertyInspector');
                known_properties=obj.getCommonProperties('',includeHidden);
                for item=perspectives
                    if~isequal(item{1},'Simulink:studio:DataViewPerspective_Other')
                        known_properties=[known_properties,getProperties(obj,item{1},includeHidden,false)];
                    end
                end
                real_props=getDisplayToRealProperty(obj.Source,known_properties);

                for possible_prop=all_props
                    if any(strcmp(possible_prop{1},real_props))
                        found_props{end+1}=possible_prop{1};
                    end
                end
                props={};
                numprops=numel(setxor(all_props,found_props));
                for prop=reshape(setxor(all_props,found_props),[1,numprops])
                    if~(startsWith(prop{1},'CoderInfo')...
                        ||startsWith(prop{1},'Table')...
                        ||startsWith(prop{1},'Breakpoints')...
                        ||startsWith(prop{1},'StructTypeInfo'))
                        bHideCode=isequal(slfeature('ShowCodePropertiesInMDE'),0);
                        if(bHideCode==false)||~startsWith(prop{1},'StorageClass')
                            props{end+1}=prop{1};
                        end
                    end
                end
            else
                if isa(obj.ProxyObj.getVariable,'Simulink.Signal')
                    props={};
                    perspectiveprops=getPerspectiveProperties@Simulink.InterfaceSignalPropertySchema(obj,perspective,includeHidden);
                    if includeHidden&&isequal(perspective,'Simulink:studio:DataViewPerspective_Design')
                        props{end+1}='Initial Value';
                        for propItem=perspectiveprops
                            props{end+1}=propItem{1};
                            if isequal(propItem{1},'Dimensions')
                                props{end+1}='Dimensions Mode';
                            end
                        end
                    else
                        props=[props,perspectiveprops];
                    end
                else
                    props=getPerspectiveProperties@Simulink.InterfaceParameterPropertySchema(obj,perspective,includeHidden);
                    if includeHidden
                        if isequal(perspective,'Simulink:studio:DataViewPerspective_Design')
                            props{end+1}='Complexity';
                        end
                        if isequal(perspective,'Simulink:studio:DataViewPerspective_Design')&&...
                            isValidProperty(obj.Source,'Default Value')


                            if strcmp(props{1},'Value')
                                props{1}='Active Value';
                                props=[props(1),...
                                {'Default Value'},...
                                props(2:end)];
                            end
                        end
                    end
                end
            end
        end
    end

end


