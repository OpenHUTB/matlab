function varList=getVariableList(varTypes)



    wkspaceVars=evalin('base','whos');
    varList={'None'};

    for idx=1:numel(wkspaceVars)
        if strcmp(wkspaceVars(idx).class,'struct')
            fnames=evalin('base',['fieldnames(',wkspaceVars(idx).name,');']);
            for ii=1:length(fnames)
                try
                    TF=cellfun(@(x)evalin('base',sprintf('isa(%s.%s,''%s'') && isscalar(%s.%s)',wkspaceVars(idx).name,fnames{ii},x,wkspaceVars(idx).name,fnames{ii})),varTypes);
                    if any(TF)
                        varList{end+1}=sprintf('%s.%s',wkspaceVars(idx).name,fnames{ii});%#ok<AGROW>
                    end
                catch

                end
            end
        elseif any(strcmp(wkspaceVars(idx).class,varTypes))&&isequal(wkspaceVars(idx).size,[1,1])
            varList{end+1}=wkspaceVars(idx).name;%#ok<AGROW>
        end
    end