classdef(Abstract)SoftwareElementPropertySchema<handle
    properties(GetAccess=protected,SetAccess=private)
ElementImpl
PrototypableZCModel
RefreshPIListener
    end


    properties(Constant)
        NameId='Sysarch:Name';
        MainId='Sysarch:Main';
        StereotypeId='Sysarch:Prototype';
        OpenProfEditorStr=DAStudio.message('SystemArchitecture:PropertyInspector:NewOrEdit');
        AddStr=DAStudio.message('SystemArchitecture:PropertyInspector:Add');
        RemoveStr=DAStudio.message('SystemArchitecture:PropertyInspector:RemoveAll');
    end


    methods(Abstract)
        getObjectType(this)
        setPrototypableName(this,value)
        getPrototypableName(this)
    end


    methods(Static,Access=private)
        function updatePropertyInspectorOnChange(studio,elemImpl,protoElem,report)
            if~isvalid(elemImpl)||~isvalid(protoElem)
                ZCStudio.StudioIntegManager.resetPropertyInspectorToModel(studio);
                return;
            end

            modified=report.Modified;
            if isempty(modified)
                return;
            end
            elemChanges=modified(arrayfun(@(mod)mod.Element==elemImpl,modified));
            nameChange=~isempty(elemChanges)&&...
            any(strcmpi('p_Name',{elemChanges.ModifiedProperties.name}));

            if nameChange||any(cellfun(@(mod)mod==protoElem,{modified.Element}))
                swarch.internal.propertyinspector.refresh(studio,elemImpl);
            end
        end
    end


    methods
        function this=SoftwareElementPropertySchema(studio,elemImpl)
            this.ElementImpl=elemImpl;
            protoElem=this.getPrototypable();
            this.RefreshPIListener=@(report)...
            swarch.internal.propertyinspector.SoftwareElementPropertySchema...
            .updatePropertyInspectorOnChange(studio,elemImpl,protoElem,report);

            mdl=mf.zero.getModel(protoElem);
            topEls=mdl.topLevelElements;
            this.PrototypableZCModel=topEls(...
            arrayfun(@(cls)...
            isa(cls,'systemcomposer.architecture.model.SystemComposerModel'),topEls));

            mdl.addObservingListener(this.RefreshPIListener);
        end


        function delete(this)
            if isvalid(this.PrototypableZCModel)
                mdl=mf.zero.getModel(this.PrototypableZCModel);
                mdl.removeListener(this.RefreshPIListener);
            end
        end


        function cls=getProtoClass(this)
            className=class(this.getPrototypable());
            periodIdxs=strfind(className,'.');
            cls=className((periodIdxs(end-1)+1):end);
        end


        function schema=getPropertySchema(this)
            schema=this;
        end


        function name=getObjectName(~)
            name='';
        end


        function result=supportTabView(~)
            result=false;
        end


        function mode=rootNodeViewMode(~,~)
            mode='TreeView';
        end


        function tf=hasSubProperties(this,prop)
            if this.isPrototypeProp(prop)
                tf=...
                systemcomposer.internal.arch.internal.propertyinspector...
                .SysarchPrototypeHandler.hasSubProperties(this.getPrototypable(),prop);
            else
                tf=isempty(prop)||strcmp(prop,this.MainId);
            end
        end


        function subProps=subProperties(this,prop)
            subProps={};
            if isempty(prop)
                subProps=[this.MainId,this.collectPrototypes()];
            elseif strcmp(prop,this.MainId)
                subProps{1}=this.NameId;
                if isa(this.ElementImpl,'systemcomposer.architecture.model.traits.EventChain')

                    if slfeature('ZCEventChainAdvanced')>0
                        subProps{end+1}=this.StereotypeId;
                    end
                else

                    subProps{end+1}=this.StereotypeId;
                end
            elseif this.isPrototypeProp(prop)
                subProps=...
                systemcomposer.internal.arch.internal.propertyinspector...
                .SysarchPrototypeHandler.subProperties(this.getPrototypable(),prop);
            end
        end


        function value=propertyValue(this,prop)
            if strcmp(prop,this.StereotypeId)
                value=this.AddStr;
            elseif strcmp(prop,this.NameId)
                value=this.getPrototypableName();
            elseif this.isPrototypeProp(prop)
                value=...
                systemcomposer.internal.arch.internal.propertyinspector...
                .SysarchPrototypeHandler.propertyValue(this.getPrototypable(),prop);
            else
                value='';
            end
        end


        function label=propertyDisplayLabel(this,prop)
            if strcmp(prop,this.MainId)
                label='Main';
            elseif strcmp(prop,this.NameId)
                label='Name';
            elseif strcmp(prop,this.StereotypeId)
                label='Stereotype';
            elseif strcmp(prop,'')
                label='';
            elseif this.isPrototypeProp(prop)
                label=systemcomposer.internal.arch.internal.propertyinspector...
                .SysarchPrototypeHandler.propertyDisplayLabel(prop);
            else
                label=prop;
            end
        end


        function tooltip=propertyTooltip(this,prop)
            if this.isPrototypeProp(prop)
                tooltip=systemcomposer.internal.arch.internal.propertyinspector...
                .SysarchPrototypeHandler.propertyTooltip(this.getPrototypable(),prop);
            else
                tooltip=this.propertyDisplayLabel(prop);
            end
        end


        function mode=propertyRenderMode(this,prop)
            if strcmp(prop,this.StereotypeId)
                mode='RenderAsComboBox';
            elseif any(cellfun(@(id)strcmp(id,prop),{this.MainId,'',this.NameId}))
                mode='RenderAsText';
            elseif this.isPrototypeProp(prop)
                mode=systemcomposer.internal.arch.internal.propertyinspector...
                .SysarchPrototypeHandler.propertyRenderMode(this.getPrototypable(),prop);
            else
                mode='RenderAsText';
            end
        end


        function tf=isPropertyEditable(this,prop)
            tf=contains(prop,this.StereotypeId)||strcmp(prop,this.NameId);
        end


        function tf=isPropertyEnabled(this,prop)

            if contains(prop,':NoPropertiesDefined')
                tf=false;
            elseif this.isPrototypeProp(prop)
                tf=systemcomposer.internal.arch.internal.propertyinspector...
                .SysarchPrototypeHandler.isPropertyEnabled(this.getPrototypable(),prop,[],[]);
            else
                tf=true;
            end
        end


        function setPropertyValue(this,prop,value)
            if this.isPrototypeProp(prop)
                systemcomposer.internal.arch.internal.propertyinspector...
                .SysarchPrototypeHandler.setPropertyVal(this.getPrototypable(),prop,value);
            elseif strcmp(prop,this.NameId)
                this.setPrototypableName(value);
            elseif strcmp(prop,this.StereotypeId)
                if strcmp(value,this.OpenProfEditorStr)
                    systemcomposer.internal.profile.Designer.launch;
                elseif strcmp(value,this.RemoveStr)
                    dp=DAStudio.DialogProvider;
                    qDlg=...
                    dp.questdlg(DAStudio.message(...
                    'SystemArchitecture:PropertyInspector:ConfirmRemoveAllStereotypes',...
                    this.getPrototypableName()),...
                    DAStudio.message('SystemArchitecture:PropertyInspector:ConfirmRemoveAllStereotypes_Title'),...
                    {...
                    DAStudio.message('SystemArchitecture:PropertyInspector:ConfirmRemoveAllStereotypes_Yes'),...
                    DAStudio.message('SystemArchitecture:PropertyInspector:Cancel')...
                    },...
                    DAStudio.message('SystemArchitecture:PropertyInspector:Cancel'),...
                    @(response)this.removeAll(response));%#ok<NASGU>
                else
                    this.getPrototypable().applyPrototype(value);
                end
            end
        end


        function editor=propertyEditor(this,prop)
            if strcmp(prop,this.StereotypeId)
                editor=DAStudio.UI.Widgets.ComboBox;
                editor.CurrentText=this.AddStr;
                editor.Editable=true;
                prototypes=systemcomposer.internal.arch.internal...
                .getAllPrototypesFromArchProfile(this.PrototypableZCModel.getName,true,this.getProtoClass());
                elemPrototypes={};
                mixinPrototypes={};
                for i=1:numel(prototypes)
                    if systemcomposer.internal.isPrototypeMixin(prototypes(i))
                        mixinPrototypes{end+1}=prototypes(i).fullyQualifiedName;%#ok<AGROW>
                    else
                        elemPrototypes{end+1}=prototypes(i).fullyQualifiedName;%#ok<AGROW>
                    end
                end
                editor.Entries=horzcat(elemPrototypes,mixinPrototypes);
                if~isempty(this.getPrototypable().getPrototype)

                    editor.Entries{end+1}=this.RemoveStr;
                end
                editor.Entries{end+1}=this.OpenProfEditorStr;
            elseif this.isPrototypeProp(prop)
                editor=systemcomposer.internal.arch.internal.propertyinspector...
                .SysarchPrototypeHandler.propertyEditor(this.getPrototypable(),prop);
            else
                editor=DAStudio.UI.Widgets.Edit;
            end
        end


        function removeAll(this,~)
            systemcomposer.internal.arch.removePrototype(this.getPrototypable(),'all');
        end
    end


    methods(Access=protected)
        function protoElem=getPrototypable(this)
            protoElem=this.ElementImpl;
        end
    end


    methods(Access=private)
        function tf=isPrototypeProp(this,prop)

            tf=contains(prop,[this.StereotypeId,':']);
        end


        function prototypeProps=collectPrototypes(this)
            if~isempty(this.getPrototypable().getPrototype)
                prototypeProps=systemcomposer.internal.arch.internal.propertyinspector...
                .SysarchPrototypeHandler.subProperties(this.getPrototypable(),'Sysarch:Prototype');
            else
                prototypeProps={};
            end
        end
    end
end


