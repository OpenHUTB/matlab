
function[propertiesSectionError,messages]=checkDefiningClassPropertiesSection(this,classdefNode,messages,double2single)




    propertiesSectionError=false;
    properties=coder.internal.FcnInfoRegistryBuilder.parsePropertiesSections(classdefNode,this.className);
    propNames=properties.keys();
    for ii=1:length(propNames)
        propName=propNames{ii};
        propDecl=properties(propName);






        if isfield(propDecl,'propType')||isfield(propDecl,'propDimensions')||isfield(propDecl,'propValidators')
            messages=this.addClassConstraintFailureMessage(messages,...
            propDecl.node,'Coder:FXPCONV:UnsupportedMCOSPropertyValidators');
        elseif isfield(propDecl,'initialValue')

            initialValue=propDecl.initialValue;
            if isempty(initialValue)

                if propDecl.isConstant
                    messages=this.addClassConstraintFailureMessage(messages,...
                    propDecl.node,'Coder:FXPCONV:ConstantProperty',upper(propName));
                else
                    messages=this.addClassConstraintFailureMessage(messages,...
                    propDecl.node,'Coder:FXPCONV:PropertyInitialization');
                end
                propertiesSectionError=true;
            elseif isstruct(initialValue)
                if double2single
                    msgID='Coder:FXPCONV:StructProperty_DTS';
                else
                    msgID='Coder:FXPCONV:StructProperty';
                end
                messages=this.addClassConstraintFailureMessage(messages,...
                propDecl.node,msgID,propName);
            elseif~propDecl.isConstant
                isSupportedType=islogical(initialValue)||ischar(initialValue)...
                ||isfi(initialValue)||isnumerictype(initialValue)||isfimath(initialValue)...
                ||isnumeric(initialValue);
                if~isSupportedType
                    messages=this.addClassConstraintFailureMessage(messages,...
                    propDecl.node,'Coder:FXPCONV:UnSupportedPropertyInitialization',propName,class(initialValue));
                end
            end
        end
    end
end


