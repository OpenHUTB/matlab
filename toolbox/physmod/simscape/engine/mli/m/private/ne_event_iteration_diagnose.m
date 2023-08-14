function msg=ne_event_iteration_diagnose(ss,input,d,q)

    msg='';

    hp=[];
    hp=[hp,local_hyperlinks(ss,ss.DiscreteData(input.D~=d))];
    hp=[hp,local_hyperlinks(ss,ss.MajorModeData(input.Q~=q))];

    if~isempty(hp)
        msg=[hp{:}];
    end
end

function hyperlink=local_hyperlinks(sys,var_data)

    obsNames={sys.ObservableData.path}';
    obsMap=containers.Map(obsNames,1:length(obsNames));
    hyperlink=[];
    for i=1:length(var_data)
        vd=var_data(i);
        quotedBlockString=sprintf('''%s''',vd.object);
        varpath=simscape.internal.valuePathToUserString(vd.path);
        quotedVarString=sprintf('''%s''',varpath);
        hyperlink{end+1}=...
        ['<a href="matlab:simscape.internal.highlightSLStudio('...
        ,ne_stringify_cell({vd.object}),', ',ne_stringify_cell({''})...
        ,')">',quotedVarString,sprintf('</a>')];%#ok
        description='';
        if isfield(vd,'description')
            description=vd.description;
        end
        if isempty(description)
            if obsMap.isKey(vd.path)
                description=sys.ObservableData(obsMap(vd.path)).description;
            end
        end
        if~isempty(description)
            hyperlink{end}=[hyperlink{end},' (',description,')'];
        end
        hyperlink{end}=[hyperlink{end},sprintf('\n')];
    end
end
