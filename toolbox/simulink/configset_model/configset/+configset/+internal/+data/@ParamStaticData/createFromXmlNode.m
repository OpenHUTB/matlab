function createFromXmlNode(obj,pNode,cp)







    if strcmp(obj.Type,'base')||strcmp(obj.Name,'ert')
        allowDeprecated=false;
    else
        allowDeprecated=true;
    end

    obj.checkXmlSyntax(pNode,allowDeprecated);

    if isa(obj,'configset.internal.data.WidgetStaticData')
        isWidget=true;
    else
        isWidget=false;
        useParamExceptions=false;


    end

    if~isWidget
        pType=pNode.getAttribute('hidden');
        if strcmp(pType,'1')
            obj.Hidden=true;
        end

        visibilitySet=false;
        pType=pNode.getAttribute('visibility');
        if~isempty(pType)
            visibilitySet=true;
            switch pType
            case 'HideButSerialize'
                obj.Hidden=true;
                obj.UDDProps.nonSerialize=false;
            case 'NonSerialize'
                obj.UDDProps.nonSerialize=true;
            case 'Derived'
                obj.UDDProps.derived=true;
            case 'Prototype'
                obj.Hidden=true;
                obj.UDDProps.nonSerialize=true;
                obj.UDDProps.prototype=true;
            case 'Grandfathered'
                obj.Hidden=true;
                obj.UDDProps.grandfathered=true;
            case 'GrandfatheredParent'



                obj.Hidden=true;
                obj.UDDProps.grandfatheredSpecialCase=true;
            case 'InternalUse'
                obj.Hidden=true;
                obj.UDDProps.nonSerialize=true;
            case 'Private'
                obj.Hidden=true;
                obj.UDDProps.private=true;
                obj.UDDProps.nonSerialize=true;
            case 'ControlledByMigration'
                obj.UDDProps.migration=true;

                obj.Hidden=true;
                obj.UDDProps.nonSerialize=false;
            case 'Normal'
                visibilitySet=false;

            otherwise
                error(['Invalid value ''',pType,''' for visibility attribute']);
            end
        end

        pType=pNode.getAttribute('handcode');
        if strcmp(pType,'true')
            obj.HandWriteGet=true;
            obj.HandWriteSet=true;
        else
            if contains(pType,'Get')
                obj.HandWriteGet=true;
            end
            if contains(pType,'Set')
                obj.HandWriteSet=true;
            end
        end

        pType=pNode.getAttribute('CSH');
        if strcmp(pType,'none')
            obj.CSH='none';
        end
    end

    obj.Feature=configset.internal.util.parseFeatureString(pNode.getAttribute('feature'));
    obj.PrototypeFeature=pNode.getAttribute('prototypeFeature');
    if~isempty(obj.Feature)&&~isempty(obj.PrototypeFeature)
        error(['Cannot use both feature and prototypeFeature for ''',obj.Name,'''']);
    end
    if~isempty(obj.PrototypeFeature)&&visibilitySet
        error(['Do not set visibility for ''',obj.Name,''' when using prototypeFeature.']);
    end

    node=configset.internal.helper.getChildNodeByTagName(pNode,'name');
    if isWidget
        if isempty(node)
            useParamExceptions=true;
        else
            useParamExceptions=false;
        end
    else
        assert(length(node)==1);
    end
    if~isempty(node)
        node=node{1};
        obj.Name=node.getFirstChild.getNodeValue;
        alias=node.getAttribute('alias');
        if~isempty(alias)
            obj.Alias=cellfun(@strtrim,strsplit(alias,','),'UniformOutput',false);
        end
    end
    assert(~isempty(obj.Name));

    node=configset.internal.helper.getChildNodeByTagName(pNode,'constraint');
    assert(length(node)<=1,obj.Name);
    if~isempty(node)
        obj.Constraint=configset.internal.data.ParamType.create(node{1});
    end

    node=configset.internal.helper.getChildNodeByTagName(pNode,'default');
    if isempty(node)
        node=configset.internal.helper.getChildNodeByTagName(pNode,'value');
    end
    assert(length(node)<=1,obj.Name);
    if~isempty(node)
        node=node{1};
        obj.ValueType=node.getAttribute('type');
        v=node.getFirstChild;
        if isempty(v)
            obj.DefaultValue='';
        else
            obj.DefaultValue=v.getNodeValue;
        end
    end


    node=configset.internal.helper.getChildNodeByTagName(pNode,'type');
    assert(length(node)<=1,obj.Name);
    if~isempty(node)
        node=node{1};
        val=strtrim(node.getFirstChild.getNodeValue);
        str=node.getAttribute('function');
        obj.f_AvailableValues=configset.internal.util.createCustomFunction(class(obj),str);

        if ismember(val,{'string','int','boolean','numeric','number','struct','mxArray','cellString'})
            obj.ValueType=val;
            if strcmp(val,'boolean')
                if node.hasAttribute('invert')
                    if strcmp(node.getAttribute('invert'),'1')
                        obj.Inverted=true;
                    end
                end
            end
        elseif strcmp(val,'enum')
            obj.ValueType=[obj.Name,'Enum'];
            obj.Constraint=configset.internal.data.ParamType.create(node);
            if isempty(obj.f_AvailableValues)
                if cp.typeMap.isKey(obj.ValueType)
                    error(['Duplicate definitions of type ',obj.ValueType,...
                    '. Please use typedef tags to create unique type names or avoid duplicate definitions.']);
                end
                cp.typeMap(obj.ValueType)=obj.Constraint;
            end
        elseif cp.typeMap.isKey(val)
            obj.ValueType=val;
            obj.Constraint=cp.typeMap(val);
        else
            error(['type ''',val,''' not defined for ''',obj.Name,'''']);
        end

    end



    if~isWidget
        uddProps=fieldnames(obj.UDDProps);
        for i=1:length(uddProps)
            node=configset.internal.helper.getChildNodeByTagName(pNode,uddProps{i});
            if~isempty(node)
                obj.UDDProps=setfield(obj.UDDProps,uddProps{i},true);
            end
        end

        obj.UDDProps.dirtyModel=~obj.UDDProps.noDirtyModel;


        checksums=pNode.getElementsByTagName('checksum');
        for j=1:checksums.getLength
            cNode=checksums.item(j-1);
            type=strtrim(cNode.getFirstChild.getNodeValue);
            if ismember(type,{'SimNumerical','SimDiagnostic','CodeGenCode','CodeGenProcess'})
                obj.Checksums{end+1}=type;
            else
                error(['Invalid checksum type ',type,' for parameter ',obj.Name]);
            end
        end

        if~isempty(obj.Checksums)&&obj.UDDProps.noChecksum
            error(['Parameter ',obj.Name,': Do not specify checksum tags if noChecksum tag is also used.']);
        end


        if ismember(cp.Name,{'Solver',...
            'Data Import/Export',...
            'Optimization',...
            'Diagnostics',...
            'Hardware Implementation',...
            'Model Referencing',...
            'Simulation Target',...
            'Code Appearance',...
            'Code Generation',...
            'Target',...
            'grt'})
            if~obj.Hidden&&isempty(obj.Checksums)&&~obj.UDDProps.noChecksum
                error(['Parameter ',obj.Name,': Must specify noChecksum tag if parameter is not used in any checksums.']);
            end
        end
    end


    node=configset.internal.helper.getChildNodeByTagName(pNode,'dependency');
    if~isempty(node)
        obj.Dependency=configset.internal.data.ParamDependency(node);
    end

    node=configset.internal.helper.getChildNodeByTagName(pNode,'dependencyOverride');
    if~isempty(node)
        if isWidget
            error('The dependencyOverride tag can only be used for parameters.');
        end
        obj.DependencyOverride=true;
    end

    node=configset.internal.helper.getChildNodeByTagName(pNode,'callback');
    if~isempty(node)&&node{1}.hasAttribute('function')
        str=node{1}.getAttribute('function');
        obj.CallbackFunction=configset.internal.util.createCustomFunction(class(obj),str);
    end

    obj.Component=cp.Name;



    node=configset.internal.helper.getChildNodeByTagName(pNode,'tag');
    if isempty(node)
        node=configset.internal.helper.getChildNodeByTagName(pNode,'tagException');
    end
    if isempty(node)
        node=configset.internal.helper.getChildNodeByTagName(pNode,'tag_exception');
    end
    if~isempty(node)
        if~isempty(node{1}.getFirstChild)
            obj.v_Tag=strtrim(node{1}.getFirstChild.getNodeValue);
        end
    end
    if isempty(obj.v_Tag)&&~useParamExceptions
        obj.v_Tag=[cp.tag,'_',obj.Name];
    end

    if~isempty(node)
        if node{1}.hasAttribute('function')
            str=node{1}.getAttribute('function');
            obj.f_Tag=configset.internal.util.createCustomFunction(class(obj),str);
        end
    end


    node=configset.internal.helper.getChildNodeByTagName(pNode,'modelref');
    if~isempty(node)

        obj.ModelRef.function='';
        obj.ModelRef.match='off';

        node=node{1};
        if node.hasAttribute('function')
            obj.ModelRef.function=node.getAttribute('function');
        elseif node.hasAttribute('match')
            obj.ModelRef.match=node.getAttribute('match');
        else
            error(['modelref ''match'' or ''function'' attribute not defined for ',obj.Name,'.']);
        end
    end

    node=configset.internal.helper.getChildNodeByTagName(pNode,'modelrefCompliance');
    if~isempty(node)
        node=node{1};
        if node.hasAttribute('function')
            obj.ModelRefCompliance=node.getAttribute('function');
        end
    end



    node=configset.internal.helper.getChildNodeByTagName(pNode,'migration');
    if~isempty(node)
        node=node{1};
        if node.hasAttribute('function')
            obj.Migration.function=node.getAttribute('function');
        end
    end


    prefix=[];
    f_tooltip='';
    f_prompt='';
    colon='';
    node=configset.internal.helper.getChildNodeByTagName(pNode,'keyException');
    if isempty(node)
        node=configset.internal.helper.getChildNodeByTagName(pNode,'key_exception');
    end
    assert(length(node)<=1);
    if~isempty(node)
        node=node{1};
        if node.hasAttribute('prefix')
            prefix=node.getAttribute('prefix');
        end

        obj.UI=configset.internal.helper.createStruct(node);
        tooltip=configset.internal.helper.getChildNodeByTagName(node,'tooltip');
        if~isempty(tooltip)
            f_tooltip=tooltip{1}.getAttribute('function');
        end
        prompt=configset.internal.helper.getChildNodeByTagName(node,'prompt');
        if isempty(prompt)
            prompt=configset.internal.helper.getChildNodeByTagName(node,'normalview_prompt');
        end
        if~isempty(prompt)
            f_prompt=prompt{1}.getAttribute('function');
            if isempty(f_prompt)
                f_prompt=prompt{1}.getAttribute('image');
            end
            colon=prompt{1}.getAttribute('addColon');
        end
    end

    if isempty(obj.UI)
        if~useParamExceptions
            obj.UI=loc_createDefaultUI(obj,cp.key_suffix_name);
        end
    else
        obj.UI=loc_completeUI(obj,cp.key_suffix_name);
    end

    if~isempty(obj.UI)
        if isempty(prefix)
            obj.UI=configset.internal.helper.addKeyPrefix(cp.key_prefix,obj.UI);
        else
            obj.UI=configset.internal.helper.addKeyPrefix(prefix,obj.UI);
        end


        obj.UI.f_tooltip=configset.internal.util.createCustomFunction(class(obj),f_tooltip);
        obj.UI.f_prompt=configset.internal.util.createCustomFunction(class(obj),f_prompt);
        if~isempty(colon)

            obj.UI.addColon=str2num(colon);%#ok<ST2NM>
            if obj.UI.addColon~=true
                error(['non-true values are not supported for addColon attribute,  param: ',obj.Name]);
            end
        end
    end


    if~isWidget
        node=configset.internal.helper.getChildNodeByTagName(pNode,'widgetValues');
        if isempty(node)
            node=configset.internal.helper.getChildNodeByTagName(pNode,'widget_values');
        end
        if~isempty(node)&&node{1}.hasAttribute('function')
            str=node{1}.getAttribute('function');


            obj.WidgetValuesFcn=configset.internal.util.createCustomFunction('configset.internal.data.WidgetStaticData',str);
        end

        widgets=pNode.getElementsByTagName('widget');
        for j=1:widgets.getLength
            wNode=widgets.item(j-1);
            w=configset.internal.data.WidgetStaticData(wNode,obj,cp);
            obj.WidgetList{end+1}=w;
        end
    end


    obj.setup;
    for j=1:length(obj.WidgetList)
        obj.WidgetList{j}.setupWidget(obj);
    end


    function out=loc_createDefaultUI(obj,key_suffix_name)

        out.prompt=[obj.Name,key_suffix_name];
        out.searchPrompt=[obj.Name,key_suffix_name];
        out.tooltip=[obj.Name,'ToolTip'];


        function out=loc_completeUI(obj,key_suffix_name)

            if ischar(obj.UI)
                out.prompt=[obj.UI,key_suffix_name];
                out.searchPrompt=[obj.UI,key_suffix_name];
                out.tooltip=[obj.UI,'ToolTip'];
            else
                out=obj.UI;

                if isfield(out,'listview_prompt')
                    out.searchPrompt=out.listview_prompt;
                    out=rmfield(out,'listview_prompt');
                end
                if isfield(out,'normalview_prompt')
                    out.prompt=out.normalview_prompt;
                    out=rmfield(out,'normalview_prompt');
                end

                if~isfield(out,'searchPrompt')
                    out.searchPrompt=out.prompt;
                end
                if~isequal(fieldnames(orderfields(out)),...
                    {'prompt';'searchPrompt';'tooltip'})&&...
                    ~isequal(fieldnames(orderfields(out)),...
                    {'addColon';'prompt';'searchPrompt';'tooltip'})
                    error(['Invalid prompt and tooltip tags for ',obj.Name...
                    ,'. Correct tags should be ''prompt'', '...
                    ,'''searchPrompt'' (optional), and ''tooltip''.']);
                end
            end


