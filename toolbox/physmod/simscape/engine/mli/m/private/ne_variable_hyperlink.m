function hyperlink=ne_variable_hyperlink(sys,dep,diffVarsDiffed)









    if nargin<3
        diffVarsDiffed=false;
    end
    var_data=sys.VariableData(dep);
    obsNames={sys.ObservableData.path}';
    obsMap=containers.Map(obsNames,1:length(obsNames));
    hyperlink=[];
    for i=1:length(var_data)
        vd=var_data(i);
        quotedBlockString=sprintf('''%s''',vd.object);
        varpath=simscape.internal.valuePathToUserString(vd.path);
        if prod(vd.dimension)>1
            varpath=[varpath,'(',num2str(vd.index),')'];%#ok
        end
        quotedVarString=sprintf('''%s''',varpath);
        hyperlink{end+1}=...
        ['<a href="matlab:simscape.internal.highlightSLStudio('...
        ,ne_stringify_cell({vd.object}),', ',ne_stringify_cell({''})...
        ,')">',quotedVarString,sprintf('</a>')];%#ok
        description=vd.description;
        if diffVarsDiffed&&vd.is_diff
            derId='physmod:simscape:engine:mli:ne_pre_transient_diagnose:TimeDerivativeOf';
            hyperlink{end}=[pm_message(derId),' ',hyperlink{end}];
        end
        if isempty(description)
            if obsMap.isKey(vd.path)
                description=sys.ObservableData(obsMap(vd.path)).description;
            end
        end
        if~isempty(description)
            hyperlink{end}=[hyperlink{end},' (',description,')'];
        end
    end
end
