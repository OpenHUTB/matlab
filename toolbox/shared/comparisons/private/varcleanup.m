function varcleanup(refname)







    [basename,fieldref]=strtok(refname,'.');
    fieldname=strtok(fieldref,'.');

    if evalin('base',['exist(''',basename,''')'])
        if evalin('base',['isstruct(',basename,')'])


            isopen=comparisons.internal.variableInUse(refname);
            if~isopen




                local=evalin('base',basename);
                if numel(fieldnames(local))==1


                    evalin('base',['clear ',basename]);
                elseif isfield(local,fieldname)
                    local=rmfield(local,fieldname);
                    assignin('base',basename,local);
                end
            end
        end
    end
end
