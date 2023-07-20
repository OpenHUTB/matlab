classdef SysarchParameterHandler<handle




    properties(Constant,Access=public)
        stripParameterPropTag=@(tag)tag(20:end)

        extractTopTag=@(tag)tag(1:strfind(tag,':')-1)

        extractBottomTag=@(tag)tag(strfind(tag,':')+1:end)
    end

    methods(Static)

        function toolTip=propertyTooltip(elem,prop)
            import systemcomposer.internal.arch.internal.propertyinspector.SysarchParameterHandler
            paramTag=SysarchParameterHandler.stripParameterPropTag(prop);
            toolTip=paramTag;
            wrapper=systemcomposer.internal.getWrapperForImpl(elem);
            [~,~,isDefault]=wrapper.getParameterValue(paramName);
            if isDefault
                toolTip=[toolTip,' ',DAStudio.message('SystemArchitecture:PropertyInspector:DefaultLabel')];
            end

        end

        function hasSub=hasSubProperties(elem,prop)
            import systemcomposer.internal.arch.internal.propertyinspector.SysarchParameterHandler
            if strcmp(prop,'Sysarch:Parameters')
                hasSub=true;
            else
                hasSub=false;
            end
        end

        function subprops=subProperties(elem,prop)
            subprops={};
            paramNames={};
            import systemcomposer.internal.arch.internal.propertyinspector.SysarchParameterHandler
            if strcmp(prop,'Sysarch:Parameters')
                paramNames=elem.getParameterNames;
            end
            for i=1:numel(paramNames)
                subprops{i}=['Sysarch:Parameters:',paramNames{i}];
            end
            if isempty(paramNames)
                subprops{end+1}='Sysarch:Parameters:NoParametersDefined';
            end
        end

        function result=propertyDisplayLabel(prop)
            import systemcomposer.internal.arch.internal.propertyinspector.SysarchParameterHandler
            result=SysarchParameterHandler.stripParameterPropTag(prop);
            if strcmp(result,'NoParametersDefined')
                result=DAStudio.message('SystemArchitecture:PropertyInspector:NoParametersDefined');

            end
        end

        function editor=propertyEditor(elem,prop)
            import systemcomposer.internal.arch.internal.propertyinspector.SysarchParameterHandler
            if~isa(elem,'systemcomposer.architecture.model.design.Architecture')&&...
                SysarchParameterHandler.isInArchitectureContext(elem)
                elem=elem.getArchitecture;
            end
            paramName=SysarchParameterHandler.stripParameterPropTag(prop);
            propValue=elem.getParamVal(paramName);

            wrapper=systemcomposer.internal.getWrapperForImpl(elem);
            paramUsage=wrapper.getParameter(paramName);
            paramDef=elem.getParameterDefinition(paramName);

            if~isempty(paramDef)
                if SysarchParameterHandler.isParamNumeric(paramDef)

                    editor=DAStudio.UI.Widgets.Edit;
                    editor.Tag=strcat(prop,':Value');
                    editor.Text=propValue.expression;

                elseif SysarchParameterHandler.isParamEnum(paramDef)
                    editor=DAStudio.UI.Widgets.ComboBox;
                    editor.Entries=paramDef.type.getLiteralsAsStrings;
                    editor.Index=find(strcmp(eval(propValue.expression),editor.Entries),true,'first')-1;
                else
                    editor=DAStudio.UI.Widgets.Edit;
                    editor.Text=propValue.expression;
                end
            else
                editor=DAStudio.UI.Widgets.Edit;
                editor.Text=propValue.expression;
            end
        end

        function mode=propertyRenderMode(elem,prop)
            import systemcomposer.internal.arch.internal.propertyinspector.SysarchParameterHandler
            if~isa(elem,'systemcomposer.architecture.model.design.Architecture')&&...
                SysarchParameterHandler.isInArchitectureContext(elem)
                elem=elem.getArchitecture;
            end
            paramName=SysarchParameterHandler.stripParameterPropTag(prop);

            if strcmp(paramName,'NoParametersDefined')
                mode='RenderAsText';
                return
            end

            wrapper=systemcomposer.internal.getWrapperForImpl(elem);
            paramDef=elem.getParameterDefinition(paramName);
            pd_class='systemcomposer.property.FloatType';
            if~isempty(paramDef)
                pd_class=class(paramDef.type);
            end

            switch pd_class
            case 'systemcomposer.property.BooleanType'
                mode='RenderAsCheckBox';
            case{'systemcomposer.property.StringType',...
                'systemcomposer.property.StringArrayType'}
                mode='RenderAsText';
            case{'systemcomposer.property.FloatType',...
                'systemcomposer.property.IntegerType'}
                mode='RenderAsText';
            case 'systemcomposer.property.Enumeration'
                mode='RenderAsComboBox';
            otherwise
                mode='RenderAsText';
            end
        end

        function val=propertyValue(elem,prop)
            if contains(prop,'Sysarch:Parameters:')
                import systemcomposer.internal.arch.internal.propertyinspector.SysarchParameterHandler




                if~isa(elem,'systemcomposer.architecture.model.design.Architecture')&&...
                    SysarchParameterHandler.isInArchitectureContext(elem)
                    elem=elem.getArchitecture;
                end
                wrapper=systemcomposer.internal.getWrapperForImpl(elem);
                paramName=SysarchParameterHandler.stripParameterPropTag(prop);
                [val,unit,isDefault]=wrapper.getParameterValue(paramName);

                paramUsage=wrapper.getParameter(paramName);
                paramDef=elem.getParameterDefinition(paramName);

                if~isempty(paramDef)&&SysarchParameterHandler.isParamNumeric(paramDef)
                    if isempty(unit)
                        unit=paramDef.ownedType.units;
                    end
                    if~isempty(unit)
                        val=[val,' ',unit];
                    end
                end
                if~isempty(paramDef)&&SysarchParameterHandler.isParamBoolean(paramDef)
                    if logical(eval(val))
                        val='1';
                    else
                        val='0';
                    end
                    return;
                end

                if isDefault&&~wrapper.getImpl.ownsDefaultParamVal(paramName)&&~strcmpi(val,'<default>')
                    val=[val,' ',DAStudio.message('SystemArchitecture:PropertyInspector:DefaultLabel')];
                end
            else
                val='';
            end
        end

        function err=setParameterVal(elem,prop,val)
            err={};
            import systemcomposer.internal.arch.internal.propertyinspector.SysarchParameterHandler
            if~isa(elem,'systemcomposer.architecture.model.design.Architecture')&&...
                SysarchParameterHandler.isInArchitectureContext(elem)
                elem=elem.getArchitecture;
            end
            wrapper=systemcomposer.internal.getWrapperForImpl(elem);
            paramName=SysarchParameterHandler.stripParameterPropTag(prop);

            try
                wrapper.setParameterValue(paramName,val);
            catch e
                err=e;
            end
        end

        function enabled=isPropertyEnabled(elem,prop)
            blockH=[];
            if isa(elem,'systemcomposer.architecture.model.design.Architecture')
                if elem.hasParentComponent
                    elem=elem.getParentComponent;
                    blockH=systemcomposer.utils.getSimulinkPeer(elem);
                else
                    blockH=get_param(elem.getName,'Handle');
                end
            elseif isa(elem,'systemcomposer.architecture.model.design.BaseComponent')
                blockH=systemcomposer.utils.getSimulinkPeer(elem);
            end
            if(blockH&&systemcomposer.internal.isSubsystemReferenceComponent(blockH)...
                &&slInternal('isSRGraphLockedForEditing',blockH))
                enabled=false;
                return;
            end
            switch prop
            case 'Sysarch:Parameters'
                enabled=true;
            case 'Sysarch:Parameters:NoParametersDefined'
                enabled=false;
            otherwise
                enabled=true;
            end
        end

        function enabled=isPropertyEditable(~,prop)
            switch prop
            case 'Sysarch:Parameters'
                enabled=false;
            case 'Sysarch:Parameters:NoParametersDefined'
                enabled=false;
            otherwise
                enabled=true;
            end
        end

        function b=isParamNumeric(paramUsageOrDef)
            if~isa(paramUsageOrDef,'systemcomposer.internal.parameter.ParameterDefinition')
                paramUsageOrDef=paramUsageOrDef.definition;
            end
            type=paramUsageOrDef.type.baseType;
            b=isa(type,'systemcomposer.property.FloatType')||isa(type,'systemcomposer.property.IntegerType');
        end

        function b=isParamEnum(paramUsageOrDef)
            if~isa(paramUsageOrDef,'systemcomposer.internal.parameter.ParameterDefinition')
                paramUsageOrDef=paramUsageOrDef.definition;
            end
            type=paramUsageOrDef.type.baseType;
            b=isa(type,'systemcomposer.property.Enumeration');
        end

        function b=isParamBoolean(paramUsageOrDef)
            if~isa(paramUsageOrDef,'systemcomposer.internal.parameter.ParameterDefinition')
                paramUsageOrDef=paramUsageOrDef.definition;
            end
            type=paramUsageOrDef.type.baseType;
            b=isa(type,'systemcomposer.property.BooleanType');
        end

        function b=isInArchitectureContext(elem)




            studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            if~isempty(studios)
                editor=studios(1).App.getActiveEditor;
                context=editor.getDiagram.getFullName;
                try
                    slHdl=systemcomposer.utils.getSimulinkPeer(elem);
                    slObj=get_param(slHdl,'Object');
                catch

                    slObj=get_param(elem.getName,'Object');
                end
                b=isequal(context,slObj.getFullName);
            end
        end



    end


end
