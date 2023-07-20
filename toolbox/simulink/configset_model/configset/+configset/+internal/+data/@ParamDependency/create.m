function depList=create(obj,node)





    depList={};

    if node.hasAttribute('value')
        value=node.getAttribute('value');
    else
        value=NaN;
    end
    if node.hasAttribute('_value')
        inv_value=node.getAttribute('_value');
    else
        inv_value=NaN;
    end
    if node.hasAttribute('uivalue')
        uivalue=node.getAttribute('uivalue');
    else
        uivalue=NaN;
    end
    if node.hasAttribute('_uivalue')
        inv_uivalue=node.getAttribute('_uivalue');
    else
        inv_uivalue=NaN;
    end
    if node.hasAttribute('function')
        update_fcn=node.getAttribute('function');
    else
        update_fcn=NaN;
    end

    isValueChange=~all([isnan(value),isnan(inv_value),...
    isnan(uivalue),isnan(inv_uivalue)]);
    values={value,inv_value,uivalue,inv_uivalue};

    status=node.getAttribute('status');
    isStatusChange=~isempty(status);

    licenses=node.getElementsByTagName('license');
    licenseCount=licenses.getLength;
    parents=node.getElementsByTagName('parent');
    parentCount=parents.getLength;

    if licenseCount>0&&parentCount==0
        depList{end+1}=configset.internal.dependency.LicenseDependency(licenses);
    elseif~isnan(update_fcn)
        depList{end+1}=configset.internal.dependency.CustomDependency(update_fcn);
    else

        if~isStatusChange
            isValueChange=true;
        end
        if isValueChange
            depList{end+1}=configset.internal.dependency.ValueDependency(values);
        end
        if isStatusChange

            relation=true;
            negate=false;

            if node.hasAttribute('relation')
                relation=strcmp(node.getAttribute('relation'),'and');
            end

            st=configset.internal.data.ParamStatus.create(status);

            if st
                relation=~relation;
                negate=true;
            else


                if status(1)=='~'
                    st=configset.internal.data.ParamStatus.create(status(2:end));
                else
                    st=configset.internal.data.ParamStatus.create(['~',status]);
                end

            end
            if relation
                for i=1:parentCount
                    parentNode=parents.item(i-1);
                    depList{end+1}=configset.internal.dependency.StatusDependency(st,{parentNode},{},negate);%#ok<AGROW>
                end
                for i=1:licenseCount
                    depList{end+1}=configset.internal.dependency.LicenseDependency(licenses(i));%#ok<AGROW>
                end
            else
                parentNodes=cell(1,parentCount);
                for i=1:parentCount
                    parentNodes{i}=parents.item(i-1);
                end
                if licenseCount==0
                    licenses={};
                end
                depList{end+1}=configset.internal.dependency.StatusDependency(st,parentNodes,licenses,negate);
            end
        end
    end

    parent={};
    for i=1:parentCount
        parentNode=parents.item(i-1);
        parent{i}=strtrim(parentNode.getFirstChild.getNodeValue);%#ok
    end
    obj.Parent=unique([obj.Parent,parent]);
