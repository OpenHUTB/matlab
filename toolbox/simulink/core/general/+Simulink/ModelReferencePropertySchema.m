classdef ModelReferencePropertySchema<handle





    properties(SetAccess=private)
Source
SourceHandle
PropertyMap
IsProtected
Params
DefaultParams
    end


    methods

        function this=ModelReferencePropertySchema(h)

            this.Source=h;
            this.SourceHandle=h.Handle;
            this.PropertyMap=containers.Map();
            this.IsProtected=strcmp('on',get_param(this.SourceHandle,'ProtectedModel'));
            this.Params={'ModelNameDialog','ParameterArgumentNames',...
            'ParameterArgumentValues','SimulationMode','CodeInterface'};
            this.DefaultParams=setxor('CodeInterface',this.Params);



            iParams=get_param(this.SourceHandle,'IntrinsicDialogParameters');
            for index=1:numel(this.Params)
                this.PropertyMap(this.Params{index})=iParams.(this.Params{index});
            end
        end


        function hasSub=hasSubProperties(obj,prop)
            if isempty(prop)||obj.isRootNodeProperty(prop)
                hasSub=true;
            else
                hasSub=false;
            end
        end


        function subprops=subProperties(obj,prop)
            subprops={};


            if isempty(prop)


                subprops{1}='Simulink:ModelReference:Parameters';
                subprops{2}='Simulink:Dialog:Properties';
                subprops{3}='Simulink:Dialog:Info';
            elseif strcmp(prop,'Simulink:ModelReference:Parameters')
                subprops=obj.getParams();
            end
        end


        function value=propertyValue(obj,prop)
            value='';
            if~obj.hasSubProperties(prop)&&obj.Source.isValidProperty(prop)
                value=obj.Source.getPropValue(prop);
            end
        end


        function enabled=isPropertyEnabled(obj,prop)

            if obj.hasSubProperties(prop)
                enabled=true;
                return;
            end

            enabled=false;
            if obj.Source.isValidProperty(prop)&&~obj.Source.isReadonlyProperty(prop)
                enabled=true;
            end
        end


        function result=getObjectType(obj)

            if obj.IsProtected
                result=DAStudio.message('Simulink:modelReference:PropertyInspectorProtectedModelRefObjectType');
            else
                result=DAStudio.message('Simulink:modelReference:PropertyInspectorModelRefObjectType');
            end
        end


        function setPropertyValue(obj,prop,newValue)

            [isModelVariant,activeVariant]=obj.isModelVariant();


            if obj.isRootNodeProperty(prop)||~isModelVariant
                set_param(obj.SourceHandle,prop,newValue);
            else

                v=get_param(obj.SourceHandle,'Variants');
                vActiveIndex=strcmp(activeVariant,{v.Name});


                if strcmp(prop,'ModelNameDialog')
                    v(vActiveIndex).ModelName=newValue;
                else
                    v(vActiveIndex).(prop)=newValue;
                end
                set_param(obj.SourceHandle,'Variants',v);
            end



            if strcmp(prop,'ModelNameDialog')
                isProtectedNow=strcmp('on',get_param(obj.SourceHandle,'ProtectedModel'));
                if~isequal(isProtectedNow,obj.IsProtected)
                    obj.IsProtected=isProtectedNow;


                    ev=DAStudio.EventDispatcher;
                    ev.broadcastEvent('ObjectStateChangedEvent',...
                    get_param(obj.SourceHandle,'object'),'ModelChanged');
                end
            end
        end


        function result=propertyDisplayLabel(obj,prop)
            if obj.isRootNodeProperty(prop)
                switch(prop)
                case 'Simulink:ModelReference:Parameters'
                    result='Parameters';
                case 'Simulink:Dialog:Properties'
                    result='Properties';
                case 'Simulink:Dialog:Info'
                    result='Info';
                otherwise
                    result=prop;
                end
            else
                result=obj.PropertyMap(prop).Prompt;
            end
        end


        function editor=propertyEditor(obj,prop)
            editor={};


            if strcmp(prop,'SimulationMode')
                editor=DAStudio.UI.Widgets.ComboBox;
                editor.CurrentText=obj.propertyValue(prop);
                editor.Entries=obj.getSimAttributes();
            end
            if~isempty(editor)
                editor.Tag=prop;
            end
        end


        function result=supportTabView(~)
            result=true;
        end


        function result=rootNodeViewMode(~,rootnode)
            if strcmp(rootnode,'Simulink:ModelReference:Parameters')
                result='TreeView';
            else
                result='SlimDialogView';
            end
        end


        function result=getOwnerGraphHandle(obj)
            parent=get_param(obj.SourceHandle,'Parent');
            result=get_param(parent,'Handle');
        end

    end



    methods(Access=private)

        function result=getParams(obj)
            result=obj.DefaultParams;


            if~obj.isModelVariant()
                simMode=get_param(obj.SourceHandle,'SimulationMode');
                if shouldCodeInterfaceBeEnabled(simMode)
                    result=obj.Params;
                end
            end
        end


        function[isVariant,activeVariant]=isModelVariant(obj)
            activeVariant=get_param(obj.SourceHandle,'ActiveVariant');
            isVariant=~isempty(activeVariant);
        end


        function choices=getSimAttributes(obj)

            defaultChoices=obj.PropertyMap('SimulationMode').Enum;


            if isstudent
                choices=defaultChoices(1);
                return;
            end


            if obj.IsProtected
                indices=2;
                runConsistencyChecks='runNoConsistencyChecks';
                model=get_param(obj.SourceHandle,'ModelFile');
                opts=Simulink.ModelReference.ProtectedModel.getOptions(model,...
                runConsistencyChecks);
                if~isempty(opts)
                    if opts.hasSILSupport
                        indices=[indices,3];
                    end
                    if opts.hasPILSupport
                        indices=[indices,4];
                    end
                end

                choices=defaultChoices(indices);
            else
                choices=defaultChoices;
            end
        end


        function result=isRootNodeProperty(~,prop)
            result=any(strcmp(prop,...
            {'Simulink:ModelReference:Parameters',...
            'Simulink:Dialog:Properties',...
            'Simulink:Dialog:Info'}));
        end
    end
end