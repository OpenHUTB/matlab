function dtaItems=setDefaultDtaItems(dtaItems)







    if~isfield(dtaItems,'allowsExpression')||isempty(dtaItems.allowsExpression)
        dtaItems.allowsExpression=true;
    end

    if~isfield(dtaItems,'inheritRules')||isempty(dtaItems.inheritRules)
        dtaItems.inheritRules={};
    end

    if~isfield(dtaItems,'builtinTypes')||isempty(dtaItems.builtinTypes)
        dtaItems.builtinTypes={};
    end

    if~isfield(dtaItems,'scalingModes')||isempty(dtaItems.scalingModes)
        dtaItems.scalingModes={};
    end


    if~isfield(dtaItems,'signModes')||isempty(dtaItems.signModes)
        dtaItems.signModes={};
    end

    if~isfield(dtaItems,'supportsEnumType')||isempty(dtaItems.supportsEnumType)
        dtaItems.supportsEnumType=false;
    end

    if~isfield(dtaItems,'supportsBusType')||isempty(dtaItems.supportsBusType)
        dtaItems.supportsBusType=false;
    end

    if~isfield(dtaItems,'supportsConnectionBusType')||isempty(dtaItems.supportsConnectionBusType)
        dtaItems.supportsConnectionBusType=false;
    end

    if~isfield(dtaItems,'supportsServiceBusType')||isempty(dtaItems.supportsServiceBusType)
        dtaItems.supportsServiceBusType=false;
    end

    if~isfield(dtaItems,'supportsConnectionType')||isempty(dtaItems.supportsConnectionType)
        dtaItems.supportsConnectionType=false;
    end

    if slfeature('SLValueType')==1&&(~isfield(dtaItems,'supportsValueTypeType')||isempty(dtaItems.supportsValueTypeType))
        dtaItems.supportsValueTypeType=false;
    end

    if~isfield(dtaItems,'supportsStringType')||isempty(dtaItems.supportsStringType)
        dtaItems.supportsStringType=false;
    end

    if slfeature('SupportImageInDTA')==1&&(~isfield(dtaItems,'supportsImageDataType')||isempty(dtaItems.supportsStringType))
        dtaItems.supportsImageDataType=false;
    end

    if~isfield(dtaItems,'tattoos')||isempty(dtaItems.tattoos)
        dtaItems.tattoos={};
    end
    if~isfield(dtaItems.tattoos,'wordLength')
        dtaItems.tattoos.wordLength={};
    end
    if~isfield(dtaItems.tattoos,'fractionLength')
        dtaItems.tattoos.fractionLength={};
    end
    if~isfield(dtaItems.tattoos,'slope')
        dtaItems.tattoos.slope={};
    end
    if~isfield(dtaItems.tattoos,'bias')
        dtaItems.tattoos.bias={};
    end

    if~isfield(dtaItems,'ruleTranslator')
        dtaItems.ruleTranslator={};
    end

    if~isfield(dtaItems,'extras')||isempty(dtaItems.extras)
        dtaItems.extras=[];
    end

    if~isfield(dtaItems,'scalingMinTag')
        dtaItems.scalingMinTag={};
    end
    if~isfield(dtaItems,'scalingMaxTag')
        dtaItems.scalingMaxTag={};
    end
    if~isfield(dtaItems,'scalingValueTags')
        dtaItems.scalingValueTags={};
    end

    if~isfield(dtaItems,'aliasObjectName')
        dtaItems.aliasObjectName='';
    end
    if~isfield(dtaItems,'isAliasObject')
        dtaItems.isAliasObject=false;
    end


