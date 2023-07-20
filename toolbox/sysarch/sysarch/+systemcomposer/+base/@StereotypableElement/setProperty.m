function setProperty(this,qualifiedPropName,propExpr,propUnit)








    narginchk(3,4);

    if nargin<4
        propUnit='*';
    end

    qualifiedPropName=this.getPropertyFQN(qualifiedPropName);


    mdl=mf.zero.getModel(this.getPrototypable);
    t=mdl.beginTransaction;
    try
        str=split(qualifiedPropName,'.');
        propSetUsageName=[str{1},'.',str{2}];
        if numel(str)>2
            propName=str{3};
            propUsage=this.getPropertyUsage(propSetUsageName,propName);

            if~isempty(propUsage)&&(isa(propUsage.initialValue.type,'systemcomposer.property.StringType')||...
                isa(propUsage.initialValue.type,'systemcomposer.property.StringArrayType'))
                try
                    propUsage.validateExpression(propExpr);
                catch ME
                    if(strcmp(ME.identifier,'SystemArchitecture:Property:CannotEvalExpression')||...
                        strcmp(ME.identifier,'SystemArchitecture:Property:InvalidStringPropValue'))

                        propExpr="'"+string(propExpr)+"'";
                    else
                        throw(ME);
                    end
                end
            end
        end
        this.getPrototypable.setPropVal(qualifiedPropName,propExpr,propUnit);
    catch ex
        if strcmpi(ex.identifier,'SystemArchitecture:Property:PropertyNotFound')
            throw(ex);
        end
        if isa(propUsage.initialValue.type,'systemcomposer.property.StringType')||...
            isa(propUsage.initialValue.type,'systemcomposer.property.StringArrayType')
            ex=MException('SystemArchitecture:Property:ErrorSettingPropertyValue',message('SystemArchitecture:Property:ErrorSettingPropertyValue',qualifiedPropName).getString);
            ex=ex.addCause(MException('systemcomposer:API:SetStringPropertyValue',message('SystemArchitecture:API:SetStringPropertyValue',ex.message).getString));
        end
        throw(ex);
    end
    t.commit;


end

