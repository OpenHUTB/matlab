function buildDispatchScripts(layout,dataModel,dirName)






    lines=loc_addHeader;
    if isa(dataModel,'configset.internal.data.MetaConfigSet')


        name='getComponentData';
        disp(['  building ',name,' web dialog script']);
        lines=[lines,loc_getDispatcher(name,dataModel)];
        lines=[lines,loc_getFeatureControlFunction(dataModel)];
    else

        name=['get_',strrep(dataModel.Class,'.','_'),'_ComponentData'];
        disp(['  building ',name,' web dialog script']);
        lines{end+1}=sprintf('function FC = %s(cs)',name);
        lines=[lines,dataModel.getFeatureControlScript([])];
        lines=[lines,layout.getFeatureControlScript];
        lines{end+1}=sprintf('  FC.layout = layoutFC;');
        lines{end+1}=sprintf('end');
    end
    loc_writeFile(lines,name,dirName);

    if isa(dataModel,'configset.internal.data.MetaConfigSet')


        name='getLayoutFeatures';
        disp(['  building ',name,' web dialog script']);
        lines=loc_addHeader;
        lines{end+1}=sprintf('function layoutFC = %s\n',name);
        lines=[lines,layout.getFeatureControlScript];
        lines{end+1}=sprintf('end');
        loc_writeFile(lines,name,dirName);
    end
end



function lines=loc_addHeader
    lines{1}='% DO NOT MODIFY THIS FILE.  IT IS AUTO-GENERATED USING THE COMMAND configset.rehash.';
end

function loc_writeFile(lines,name,dirName)
    script=strjoin(lines,'\n');


    file=fullfile(dirName,[name,'.m']);
    fid=fopen(file,'w');
    fprintf(fid,'%s',script);
    fclose(fid);
end

function lines=loc_getDispatcher(name,mcs)

    lines={};
    lines{end+1}=sprintf('function FC = %s(cc, cid)\n',name);
    lines{end+1}='if isempty(cc)';
    for i=1:length(mcs.ComponentList)
        mcc=mcs.ComponentList{i};
        strs{i}=['''',mcc.Class,''''];%#ok<*AGROW>
    end
    lines{end+1}=sprintf('  FC = ismember(cid, {%s});\n  return;',strjoin(strs,','));
    lines{end+1}=sprintf('end\n');
end

function lines=loc_getFeatureControlFunction(mcs)

    lines={};
    lines{end+1}=sprintf('if isempty(cid)\n  cid = class(cc);\nend');
    lines{end+1}='cs = cc.getConfigSet;';
    lines{end+1}='switch cid';

    target=mcs.getComponent('Simulink.TargetCC');
    for i=1:length(mcs.ComponentList)
        mcc=mcs.ComponentList{i};
        cid=mcc.Class;
        lines{end+1}=sprintf('case ''%s''',cid);
        lines=[lines,mcc.getFeatureControlScript(target)];
    end
    lines{end+1}='otherwise';
    lines{end+1}='  FC = [];';
    lines{end+1}='end';
end


