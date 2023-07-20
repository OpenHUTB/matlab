function checkXmlSyntax(~,pNode,allowDeprecated)




    allowedAttributes={'visibility','handcode','CSH','feature','prototypeFeature'};
    allowedChildTags={'name','constraint','default','type',...
    'checksum','dependency','dependencyOverride','callback',...
    'tagException','keyException','modelref','modelrefCompliance',...
    'widgetValues','widget',...
    'noCopy','readOnly','externalReadOnly','writeToRTW',...
    'editableWhenLocked','editableWhenLockBypassed','okToShadow','mutable',...
    'forceSetCallback','evalParam','excludeFromCommon','noDirtyModel',...
    'updateParamEvent','redrawModel','freezeTimestamp','noChecksum',...
    'migration'};
    deprecatedChildTags={'value','tag','tag_exception','key_exception','widget_values','widget_type'};

    if allowDeprecated
        allowedChildTags=[allowedChildTags,deprecatedChildTags];
        allowedAttributes{end+1}='hidden';
    end


    attrs=pNode.getAttributes;
    for i=0:attrs.getLength-1
        attribute=attrs.item(i).getName;
        if~ismember(attribute,allowedAttributes)
            error(['Unsupported attribute: ',attribute]);
        end
    end


    children=configset.internal.helper.getAllChildTagNodes(pNode);
    for i=1:length(children)
        tag=children{i}.getTagName;
        if~ismember(tag,allowedChildTags)
            error(['Unsupported tag: ',tag]);
        end
    end



