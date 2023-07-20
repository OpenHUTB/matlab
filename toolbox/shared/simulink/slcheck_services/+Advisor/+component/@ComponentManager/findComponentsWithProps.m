
function instIDs=findComponentsWithProps(this,nodeID,props,externalProps,exit)
    instIDs={};
    instObj=this.getComponent(nodeID);

    isMatch=true;


    if~isempty(props)
        propertyNames=fieldnames(props);
        propertApplicable=false;

        for ni=1:length(propertyNames)
            prop=propertyNames{ni};

            if isprop(instObj,prop)&&strcmp(class(instObj.(prop)),class(props.(prop)))

                propertiesApplicable=true;

                if ischar(props.(prop))&&~strcmp(props.(prop),instObj.(prop))
                    isMatch=false;
                    break;
                elseif props.(prop)~=instObj.(prop)
                    isMatch=false;
                    break;
                end
            end
        end



        if~propertiesApplicable
            isMatch=false;
        end
    end


    if isMatch&&~isempty(externalProps)
        propertyNames=fieldnames(externalProps);
        propStruct=table2struct(this.ExternalProperties(nodeID,propertyNames));
        propertiesApplicable=false;

        for ni=1:length(propertyNames)
            prop=propertyNames{ni};
            if strcmp(class(propStruct.(prop)),class(externalProps.(prop)))
                propertiesApplicable=true;
                if ischar(externalProps.(prop))&&~strcmp(externalProps.(prop),propStruct.(prop))
                    isMatch=false;
                    break;
                elseif externalProps.(prop)~=propStruct.(prop)
                    isMatch=false;
                    break;
                end
            end
        end



        if~propertiesApplicable
            isMatch=false;
        end
    end

    if isMatch

        instIDs={instObj.ID};
    end

    if(exit&&~isMatch)||~exit

        children=this.getChildNodes(nodeID);

        for n=1:length(children)
            instIDs=[instIDs,...
            this.findComponentsWithProps(children(n).ID,props,externalProps,exit)];%#ok<AGROW>
        end
    end
end