function w=getCodeGenerationSubSchema(obj)




    w=[];

    try
        items=l_getItems(obj);
    catch E
        warning(E.identifier,E.message);
        return;
    end

    if~isempty(items)
        w.Name=DAStudio.message('Simulink:taskEditor:CodegenPropertiesGroupText');
        w.Type='group';
        w.Items=items;
    end

    function l_templateSelector(arch,obj,entries,value)

        entry=entries{value+1};
        tmplNames={arch.Templates.Name};
        tmpl=arch.Templates(strcmp(tmplNames,entry));
        obj.setTemplate(tmpl);


        function items=l_getItems(obj)










            items=l_getItems_deprecate(obj);


            if~isprop(obj,'Template')||isempty(obj.Template);return;end

            arch=obj.Template.ParentArchitecture;
            tmplTypes={arch.Templates.Type};
            tmplNames={arch.Templates.Name};
            tmplNames=tmplNames(strcmp(tmplTypes,getTypeName(obj)));

            if length(tmplNames)>1&&~obj.Template.Implicit
                w.Name=DAStudio.message('Simulink:taskEditor:TargetText');
                w.Type='combobox';
                w.Tag='ConcurrentExecution_TemplateSelection_tag';
                w.WidgetId=w.Tag;
                w.Entries=tmplNames;
                w.Enabled=true;
                w.DialogRefresh=true;


                w.Value=obj.Template.Name;
                w.MatlabMethod='feval';
                w.MatlabArgs={@l_templateSelector,arch,obj,w.Entries,'%value'};
                items{end+1}=w;
            end


            panelItems=[];
            for i=1:length(obj.Template.TargetSpecificProperties)
                p=obj.Template.TargetSpecificProperties(i);
                tag=p.getUniqueTag;
                type=p.getWidgetType;
                adapter=Simulink.SoftwareTarget.DialogAdapter(obj,p,type);
                w=createWidget(type,'Value',adapter.Prompt,tag);
                w=rmfield(w,'Tag');
                if~isempty(p.AllowedValues)
                    w.Entries=p.AllowedValues';
                end
                w.Source=adapter;
                w.Enabled=p.Editable;
                panelItems{end+1}=w;%#ok
            end

            if~isempty(panelItems)
                panel=createWidget('panel','targetPanel2',...
                DAStudio.message('Simulink:taskEditor:PropertiesGroupText'));
                panel.Source=obj;
                panel.Items=panelItems;
                items{end+1}=panel;
            end

            function name=getTypeName(obj)

                nonUniformTypeNames={'SoftwareNode','Software',...
                'HardwareNode','Hardware'};
                cls=metaclass(obj);
                pkg=cls.ContainingPackage;
                name=cls.Name(length(pkg.Name)+2:end);

                for i=1:2:length(nonUniformTypeNames)
                    if strcmp(name,nonUniformTypeNames{i})
                        name=nonUniformTypeNames{i+1};
                        break;
                    end
                end

                function items=l_getItems_deprecate(obj)

                    items=[];

                    aperiodic=isa(obj,'Simulink.SoftwareTarget.AperiodicTrigger');

                    if~aperiodic,return;end

                    targetCustomizationObj=obj.ParentTaskConfiguration.TargetCustomizationObject;
                    isDeferredMCOSClass=isa(targetCustomizationObj,'Simulink.DeferredMCOSClass');

                    if isDeferredMCOSClass
                        lm=createWidget('text','noCustomizationClassError',...
                        DAStudio.message('Simulink:mds:NoTargetCustomizationClassName',...
                        targetCustomizationObj.MCOSClassName));

                        lm.ForegroundColor=[255,0,0];
                        lm.WordWrap=true;
                        lm.Visible=true;

                        items{end+1}=lm;
                    else
                        items=l_getItems_deprecate1(items,obj);
                    end

                    function items=l_getItems_deprecate1(items,obj)

                        readOnly=false;

                        if isempty(obj.TargetObject)
                            obj.createTargetObject();
                        end

                        isTargetValid=obj.validateTargetObject();



                        triggerTypes=obj.ParentTaskConfiguration.TargetCustomizationObject.getAperiodicTriggerTypes();


                        if~isTargetValid
                            tm=createWidget('text',[],...
                            DAStudio.message('Simulink:taskEditor:TaskGroupErrorText'));
                            tm.ForegroundColor=[255,0,0];
                            tm.WordWrap=true;
                            tm.Visible=true;
                            items{end+1}=tm;
                        end

                        widget=createWidget('combobox','EventHandlerType',...
                        [DAStudio.message('Simulink:taskEditor:EventHandlerType'),' ']);
                        if(isTargetValid)
                            widget.Entries=triggerTypes;
                        else
                            widget.Entries=[['<',DAStudio.message('Simulink:taskEditor:Incompatible'),'> ',obj.EventHandlerType],triggerTypes];
                        end

                        widget.Enabled=true;
                        widget.DialogRefresh=true;
                        widget.Mode=true;
                        widget.Source=obj;
                        items{end+1}=widget;









                        if~readOnly
                            obj.createTargetObject();
                        end

                        if~isempty(obj.TargetObject)

                            panel=createWidget('panel','targetPanel',...
                            [obj.EventHandlerType,' '...
                            ,DAStudio.message('Simulink:taskEditor:PropertiesGroupText')]);
                            panel.Source=obj.TargetObject;
                            try
                                panel=obj.TargetObject.getSubDialogSchema(panel);
                            catch e
                                warning(e.identifier,e.message);
                            end

                            if~isempty(panel.Items)
                                items{end+1}=panel;
                            end
                        end


                        function w=createWidget(widgetType,propertyName,propertyLabel,tag)


                            if(strcmp(widgetType,'edit')||...
                                strcmp(widgetType,'editarea')||...
                                strcmp(widgetType,'checkbox')||...
                                strcmp(widgetType,'listbox')||...
                                strcmp(widgetType,'combobox'))
                                w.ObjectProperty=propertyName;
                            end

                            if nargin==3
                                tag=[propertyName,'_tag'];
                            end

                            w.Name=propertyLabel;
                            w.Type=widgetType;
                            w.Tag=tag;
                            w.WidgetId=tag;


