function propValMap=getPropertyValueMap(objHandle,prototype)





    if nargin<2
        prototype=[];
    end
    propValMap=containers.Map('keytype','char','valuetype','any');
    if isa(objHandle,'systemcomposer.arch.BaseComponent')
        objHandle=objHandle.Architecture;
    end

    if(~isempty(prototype)&&~strcmp(prototype.Profile.Name,'systemcomposer'))
        if(isempty(prototype.Properties))
            propValMap=systemcomposer.internal.getPropertyValueMap(objHandle,prototype.Parent);
        else
            if(~strcmp(prototype.Profile.Name,'systemcomposer'))

                protoQualName=prototype.FullyQualifiedName;
                posIdentifier=strfind(protoQualName,'.');
                properties=prototype.Properties;

                for propItr=1:numel(properties)
                    try

                        property=properties(propItr);
                        propertyName=property.Name;
                        propQualName=strcat(protoQualName(posIdentifier+1:end),'.',propertyName);
                        [propertyValue,propertyUnit]=objHandle.getProperty(strcat(protoQualName,'.',propertyName));


                        if(~isempty(propertyUnit))
                            propertyField=strcat(string(propertyValue),'{',propertyUnit,'}');
                        else
                            propertyField=string(propertyValue);
                        end
                        if(isempty(propertyValue))
                            propertyField="";
                        end


                        propValMap(char(propQualName))=propertyField;
                    catch
                    end
                end
            end
        end
    end
end

