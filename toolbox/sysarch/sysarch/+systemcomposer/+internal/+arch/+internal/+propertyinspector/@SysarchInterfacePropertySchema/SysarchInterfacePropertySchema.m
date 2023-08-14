classdef SysarchInterfacePropertySchema<handle





    properties(SetAccess=private)
portIntef
propProvider
        context systemcomposer.architecture.model.interface.Context
    end

    properties(Constant,Access=private)
        isPropertyNode=@(id)length(strsplit(id,':'))==3;
        isPropertyFromValWidget=@(id)contains(id,':Value');
        isPropertyFromUnitWidget=@(id)contains(id,':Unit');
        stripStereotypeTag=@(id)id(12:end);
        RemoveStr=DAStudio.message('SystemArchitecture:PropertyInspector:RemoveAll');
        OpenProfEditorStr=DAStudio.message('SystemArchitecture:PropertyInspector:NewOrEdit');
        InterfaceTitleStr=DAStudio.message('SystemArchitecture:PropertyInspector:Interface');
    end

    methods(Access=private)
        function src=getSourceFromContext(this)

            src=this.portIntef.getCatalog.getStorageSource;
            if this.context==systemcomposer.architecture.model.interface.Context.MODEL
                src=get_param(src,'handle');
            end
        end

        function handleRemoveAllStereotypes(this,response,src,elem,propObj,newValue)
            if strcmp(response,DAStudio.message('SystemArchitecture:PropertyInspector:ConfirmRemoveAllStereotypes_Yes'))
                this.propProvider.setPropertyValue(src,elem.UUID,propObj,newValue);


                this.refresh(elem);
            end
        end

        function tf=isStereotypeNode(~,id)
            tf=contains(id,'Stereotype')&&length(strsplit(id,':'))==2;
        end
    end

    methods(Static,Access=public)
        function refresh(portIntef)
            pic=portIntef.getCatalog;
            context=pic.getStorageContext;
            srcName=pic.getStorageSource;
            switch context
            case systemcomposer.architecture.model.interface.Context.MODEL
                contextStr='Model';
            case systemcomposer.architecture.model.interface.Context.DICTIONARY
                contextStr='Dictionary';
            otherwise
                error('Invalid context on refresh')
            end
            systemcomposer.InterfaceEditor.OpenPropertyInspector(srcName,contextStr,'',portIntef.UUID,-1,false,false);
        end
    end

    methods


        function schema=getPropertySchema(this)
            schema=this;
        end


        function this=SysarchInterfacePropertySchema(prtInterface,bdH)
            this.portIntef=prtInterface;
            this.context=prtInterface.getCatalog.getStorageContext;
            switch this.context
            case systemcomposer.architecture.model.interface.Context.MODEL
                src=bdH;
            case systemcomposer.architecture.model.interface.Context.DICTIONARY
                src=get_param(bdH,'DataDictionary');
            otherwise
                error('Invalid context for interfaces');
            end
            this.propProvider=systemcomposer.internal.arch.internal.propertyinspector.PropertyProvider(prtInterface,src,[]);
        end


        function name=getObjectType(this)
            name=this.InterfaceTitleStr;
        end


        function toolTip=propertyTooltip(this,propId)
            propObj=this.propProvider.PropertySpecMap(propId);
            toolTip=propObj.tooltip;
        end


        function hasSub=hasSubProperties(this,propId)
            propObj=this.propProvider.PropertySpecMap(propId);

            hasSub=~isempty(propObj.children);
        end


        function subprops=subProperties(this,propId)
            if isempty(propId)

                subprops=cellfun(@(prop)prop.id,this.propProvider.Properties,'UniformOutput',false);
            else

                propObj=this.propProvider.PropertySpecMap(propId);
                subprops=cellfun(@(prop)prop.id,propObj.children,'UniformOutput',false);
            end
        end


        function value=propertyValue(this,propId)
            propObj=this.propProvider.PropertySpecMap(propId);
            value=propObj.value;
            if isempty(value)


                if this.isStereotypeNode(propId)&&~strcmp(propObj.rendermode,'none')

                    value=DAStudio.message('SystemArchitecture:PropertyInspector:Select');
                end
            end
        end


        function result=propertyDisplayLabel(this,propId)
            propObj=this.propProvider.PropertySpecMap(propId);
            result=propObj.label;
        end

        function mode=propertyRenderMode(this,propId)
            propObj=this.propProvider.PropertySpecMap(propId);
            switch propObj.rendermode
            case{'editbox','none','dualeditcombo'}
                mode='RenderAsText';
            case{'combobox','actioncallback'}
                mode='RenderAsComboBox';
            case 'checkbox'
                mode='RenderAsCheckBox';
            otherwise
                mode='RenderAsText';
            end

        end


        function enabled=isPropertyEnabled(this,propId)
            propObj=this.propProvider.PropertySpecMap(propId);
            enabled=propObj.enabled;
        end


        function editable=isPropertyEditable(this,propId)
            propObj=this.propProvider.PropertySpecMap(propId);
            editable=propObj.editable;
            if this.isPropertyNode(propObj.id)&&strcmp(propObj.rendermode,'combobox')




                editable=true;
            end
        end


        function editor=propertyEditor(this,propId)
            propObj=this.propProvider.PropertySpecMap(propId);
            switch propObj.rendermode
            case 'editbox'
                editor=DAStudio.UI.Widgets.Edit;
                editor.Text=propObj.value;
            case 'combobox'
                editor=DAStudio.UI.Widgets.ComboBox;
                entries=propObj.options;
                if strcmp(propObj.id,'Stereotype')
                    if length(this.portIntef.getPrototype)>=1

                        entries{end+1}=this.RemoveStr;
                    end
                    entries{end+1}=this.OpenProfEditorStr;
                end
                if this.isPropertyNode(propObj.id)

                    [stereoName,propName]=this.propProvider.getStereotypeAndPropertyNames(propObj.id);
                    PU=this.propProvider.getPropertyUsage(this.portIntef,stereoName,propName);
                    assert(isa(PU.initialValue.type,'systemcomposer.property.Enumeration'));
                    editor.Index=find(strcmp(eval(PU.initialValue.expression),entries),true,'first')-1;
                end
                editor.Entries=entries;
                editor.Editable=propObj.comboEditable;
            case 'actioncallback'
                if this.isStereotypeNode(propObj.id)

                    editor=DAStudio.UI.Widgets.ComboBox;
                    editor.Entries={'',...
                    DAStudio.message('SystemArchitecture:PropertyInspector:Remove'),...
                    DAStudio.message('SystemArchitecture:PropertyInspector:MakeDefault')};
                    editor.Index=0;
                    actualProto=this.portIntef.getPrototype.findobj('p_Name',propObj.label);
                    if(~isempty(actualProto))
                        if(actualProto.hasMissingParent(true))
                            editor.Entries{end+1}=DAStudio.message('SystemArchitecture:PropertyInspector:UnlinkParent');
                        end
                    end
                    editor.Editable=false;
                end
            case 'dualeditcombo'
                editor=DAStudio.UI.Container.Panel;
                assert(this.isPropertyNode(propObj.id));
                [stereoName,propName]=this.propProvider.getStereotypeAndPropertyNames(propObj.id);
                PU=this.propProvider.getPropertyUsage(this.portIntef,stereoName,propName);
                propVal=this.portIntef.getPropVal([stereoName,'.',propName]);


                valueBox=DAStudio.UI.Widgets.Edit;
                valueBox.Tag=strcat(propObj.id,':Value');
                valueBox.Text=propVal.expression;


                unitsBox=DAStudio.UI.Widgets.ComboBox;
                currentUnit=propVal.units;
                compatibleUnits=propObj.options;
                if isempty(compatibleUnits)&&~isempty(PU.propertyDef.type.units)


                    compatibleUnits={PU.propertyDef.type.units};
                end
                unitsBox.Entries=compatibleUnits;
                unitsBox.CurrentText=currentUnit;
                unitsBox.Index=find(strcmp(compatibleUnits,currentUnit),true,'first')-1;
                unitsBox.Editable=true;
                unitsBox.Tag=strcat(propObj.id,':Unit');

                editor.Children={valueBox,unitsBox};
            case 'dualedit'
                editor=DAStudio.UI.Container.Panel;
                assert(this.isPropertyNode(propObj.id));
                [stereoName,propName]=this.propProvider.getStereotypeAndPropertyNames(propObj.id);
                propVal=this.portIntef.getPropVal([stereoName,'.',propName]);


                valueBox=DAStudio.UI.Widgets.Edit;
                valueBox.Tag=strcat(propObj.id,':Value');
                valueBox.Text=propVal.expression;


                assert(isempty(propVal.units));
                unitsBox=DAStudio.UI.Widgets.Edit;
                unitsBox.Text=propVal.units;
                unitsBox.Enabled=false;
                unitsBox.Tag=strcat(propObj.id,':Unit');

                editor.Children={valueBox,unitsBox};
            end

        end

        function errors=setPropertyValues(this,vals,~)
            errors={};




            tfArray=cellfun(@(val)strcmp(DAStudio.message('SystemArchitecture:PropertyInspector:Remove'),val),vals);
            if any(tfArray)
                idx=find(tfArray);
                idx=idx(1);
                vals={vals{idx-1},vals{idx}};
            end

            for idx=1:2:numel(vals)
                propId=vals{idx};
                newValue=vals{idx+1};



                if this.isPropertyFromUnitWidget(propId)
                    unitIndex=strfind(propId,':Unit');
                    realPropId=propId(1:unitIndex-1);
                    propObj=this.propProvider.PropertySpecMap(realPropId);
                    valToSet=['Unit:',newValue];
                elseif this.isPropertyFromValWidget(propId)
                    valueIndex=strfind(propId,':Value');
                    realPropId=propId(1:valueIndex-1);
                    propObj=this.propProvider.PropertySpecMap(realPropId);
                    valToSet=['Value:',newValue];
                else
                    realPropId=propId;
                    valToSet=newValue;
                    propObj=this.propProvider.PropertySpecMap(propId);
                end

                src=this.getSourceFromContext();

                err=this.setPropertyVal(src,this.portIntef,propObj,valToSet);

                if~isempty(err)
                    if~isempty(err.cause)
                        causeMsg=err.cause{1}.message;
                    else
                        causeMsg='';
                    end
                    subError=DAStudio.UI.Util.Error(realPropId,...
                    'Error',...
                    [err.message,' ',causeMsg],...
                    []);
                    subError.DisplayValue=this.propertyValue(realPropId);
                    childError=DAStudio.UI.Util.Error(propId,...
                    'Error',...
                    [err.message,' ',causeMsg],...
                    []);
                    childError.DisplayValue=newValue;
                    subError.Children={childError};
                else
                    subError='';
                end
                errors=[errors,subError];%#ok<AGROW>
            end

            if~isempty(errors)

                errors={errors};
            else
                errors={};

                systemcomposer.internal.arch.internal.propertyinspector.SysarchInterfacePropertySchema.refresh(this.portIntef);
            end

        end

        function err=setPropertyVal(this,src,elem,propObj,newValue)
            err={};
            try

                if strcmp(propObj.id,'Stereotype')&&strcmp(newValue,DAStudio.message('SystemArchitecture:PropertyInspector:RemoveAll'))

                    dp=DAStudio.DialogProvider;
                    qDlg=dp.questdlg(DAStudio.message('SystemArchitecture:PropertyInspector:ConfirmRemoveAllStereotypes',elem.getName),...
                    DAStudio.message('SystemArchitecture:PropertyInspector:ConfirmRemoveAllStereotypes_Title'),...
                    {DAStudio.message('SystemArchitecture:PropertyInspector:ConfirmRemoveAllStereotypes_Yes'),...
                    DAStudio.message('SystemArchitecture:PropertyInspector:Cancel')},...
                    DAStudio.message('SystemArchitecture:PropertyInspector:Cancel'),...
                    @(response)this.handleRemoveAllStereotypes(response,src,elem,propObj,newValue));%#ok<NASGU> % callback
                elseif this.isStereotypeNode(propObj.id)&&strcmp(newValue,DAStudio.message('SystemArchitecture:PropertyInspector:Remove'))

                    confirm=systemcomposer.internal.arch.internal.propertyinspector.createDeleteStereotypeDialog(propObj.label,elem.getName);
                    if strcmp(confirm,message('SystemArchitecture:PropertyInspector:ConfirmDeleteStereotype_Yes').string)
                        this.propProvider.setPropertyValue(src,elem.UUID,propObj,newValue);
                    end
                else
                    this.propProvider.setPropertyValue(src,elem.UUID,propObj,newValue);
                end
            catch ME
                err=ME;
            end

        end


    end

end


