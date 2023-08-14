







function instIDs=getComponentsWithProperties(this,props,externalProps)
    comps=this.getComponents();
    ismatch=true(size(comps));


    if~isempty(props)
        for n=1:length(comps)
            instObj=comps(n);
            propertyNames=fieldnames(props);
            tempIsMatch=true;

            propertiesApplicable=false;

            for ni=1:length(propertyNames)
                prop=propertyNames{ni};

                if isprop(instObj,prop)&&strcmp(class(instObj.(prop)),class(props.(prop)))

                    propertiesApplicable=true;

                    if ischar(props.(prop))&&~strcmp(props.(prop),instObj.(prop))
                        tempIsMatch=false;
                        break;
                    elseif props.(prop)~=instObj.(prop)
                        tempIsMatch=false;
                        break;
                    end
                end

            end



            if~propertiesApplicable
                tempIsMatch=false;
            end

            ismatch(n)=tempIsMatch;
        end

        comps=comps(ismatch);
    end

    instIDs={comps.ID};


    if~isempty(externalProps)
        subTable=this.ExternalProperties(instIDs,:);
        propertyNames=fieldnames(externalProps);

        rows=true(size(subTable,1),1);
        propertiesApplicable=false;

        for ni=1:length(propertyNames)
            prop=propertyNames{ni};

            if isfield(this.ExternalPropertiesDefaultValues,prop)
                propertiesApplicable=true;

                if ischar(this.ExternalPropertiesDefaultValues.(prop))

                    tempRows=strcmp(subTable.(prop),externalProps.(prop));
                else
                    tempRows=subTable.(prop)==externalProps.(prop);
                end

                rows=rows&tempRows;
            end
        end


        if propertiesApplicable
            instIDs=subTable.Properties.RowNames(rows);
        end
    end
end