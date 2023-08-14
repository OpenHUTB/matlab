function refname=loadVariable(filename,varname,basevarsuffix)









    if nargin<3
        basevarsuffix='';
    end

    try
        fullname=comparisons.internal.resolvePath(filename);
    catch E
        if strcmp(E.identifier,'comparisons:comparisons:FileNotFound')


            try
                fullname=comparisons.internal.resolvePath([filename,'.mat']);
            catch F


                rethrow(E);
            end
        else
            rethrow(E);
        end
    end
    [~,shortname]=fileparts(fullname);

    s=load('-mat',fullname,varname);



    rootname=[shortname,'_file_contents',basevarsuffix];
    genvarnameMaxLength=62;
    if length(rootname)<genvarnameMaxLength
        basename=genvarname(rootname);
    else
        basename=genvarname(rootname(length(rootname)-genvarnameMaxLength+1:end));
    end
    refname=[basename,'.',varname];




    if evalin('base',['exist(''',basename,''')'])
        if evalin('base',['isstruct(',basename,')'])



            local=evalin('base',basename);
            fields=fieldnames(local);
            for i=1:numel(fields)


                isopen=comparisons.internal.variableInUse([shortname,'.',fields{i}])||...
                comparisons.internal.variableInUse([basename,'.',fields{i}]);
                if~isopen

                    local=rmfield(local,fields{i});
                end
            end

            local.(varname)=s.(varname);
            assignin('base',basename,local);
            return;
        end
    end

    assignin('base',basename,s);
end
