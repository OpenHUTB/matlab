function lines=getFeatureControlScript(mcc,target)






    lines={};
    lines{end+1}='  FC = struct(''feature'', [], ''license'', [], ''status'', []);';
    if strcmp(mcc.Type,'Target')&&...
        ~strcmp(mcc.Class,'Simulink.CPPComponent')&&...
        ~isempty(target)


        featureList=union(target.Feature,mcc.Feature);
        licenseList=union(target.License,mcc.License,'stable');
        productList=union(target.Product,mcc.Product,'stable');
    else
        featureList=mcc.Feature;
        licenseList=mcc.License;
        productList=mcc.Product;
    end
    for j=1:length(featureList)
        name=featureList{j};
        lines{end+1}=sprintf('  FC.feature.%s = slfeature(''%s'');',name,name);%#ok<*AGROW>
    end
    for j=1:length(licenseList)
        name=licenseList{j};
        product=productList{j};
        lines{end+1}=sprintf('  FC.license.%s = dig.isProductInstalled(''%s'');',name,product);
    end
    if isempty(mcc.Dependency)
        lines{end+1}=sprintf('  FC.status = 0;');
    else
        strs={};
        depinfo=mcc.Dependency.getInfo;
        for k=1:length(depinfo)
            dep=depinfo{k};
            str={};
            if isfield(dep,'parentList')
                for p=1:length(dep.parentList)
                    pa=dep.parentList{p};
                    if~isempty(pa.values)
                        for v=1:length(pa.values)
                            val{v}=['''',pa.values{v},''''];
                        end
                    end
                    str{p}=sprintf('ismember(cs.getProp(''%s''), {%s})',pa.name,strjoin(val,','));
                    if~pa.flag
                        str{p}=['~',str{p}];
                    end
                end
            elseif isfield(dep,'license')
                for l=1:length(dep.license)
                    str{l}=sprintf('dig.isProductInstalled(''%s'')',dep.product{l});
                end
            end
            strs{end+1}=sprintf('~(%s) * %d',strjoin(str,' || '),dep.statusLimit);
        end
        cdl=mcc.Dependency.CustomDepList;
        for k=1:length(cdl)
            fn=func2str(cdl{k}.getStatusFcn);
            strs{end+1}=sprintf('%s(cs)',fn);
        end
        if length(strs)>1
            lines{end+1}=sprintf('  FC.status = max([%s]);',strjoin(strs,', '));
        else
            lines{end+1}=sprintf('  FC.status = %s;',strs{1});
        end
    end
end

