function hyperlink=ne_discrete_hyperlink(sys,dep)






    dis_data=sys.DiscreteData(dep);
    obsNames={sys.ObservableData.path}';
    obsMap=containers.Map(obsNames,1:length(obsNames));
    hyperlink=[];
    for i=1:length(dis_data)
        dd=dis_data(i);
        varpath=simscape.internal.valuePathToUserString(dd.path);
        if prod(dd.dimension)>1
            varpath=[varpath,'(',num2str(dd.index),')'];%#ok
        end
        quotedVarString=sprintf('''%s''',varpath);
        hyperlink{end+1}=...
        ['<a href="matlab:simscape.internal.highlightSLStudio('...
        ,ne_stringify_cell({dd.object}),', ',ne_stringify_cell({''})...
        ,')">',quotedVarString,sprintf('</a>')];%#ok
        description=dd.description;

        if isempty(description)
            if obsMap.isKey(dd.path)
                description=sys.ObservableData(obsMap(dd.path)).description;
            end
        end
        if~isempty(description)
            hyperlink{end}=[hyperlink{end},' (',description,')'];
        end
    end
end
