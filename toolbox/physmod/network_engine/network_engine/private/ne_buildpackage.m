function ne_buildpackage(pkg,verbose)




    if nargin<2
        verbose=false;
    end

    [~,fileBase]=fileparts(pkg);

    pm_assert(strcmp(fileBase(1),'+'),'%s doesn''t start with a ''+''',fileBase);

    parseLibraryPackage=ne_private('ne_parselibrarypackage');
    libHelpers=parseLibraryPackage(pkg);

    if isempty(libHelpers)
        pm_error('physmod:network_engine:ne_buildpackage:EmptyPackage',pkg);
    end

    for idx=1:numel(libHelpers)

        [~,srcFileName,srcExt]=fileparts(libHelpers{idx}.SourceFile);
        if any(strcmp(srcFileName,{'sl_postprocess','lib'}))||...
            strcmp(srcExt,'.sscx')||...
            (~isempty(meta.class.fromName(libHelpers{idx}.Command))&&...
            meta.class.fromName(libHelpers{idx}.Command).Enumeration)
            continue;
        end





        clear(libHelpers{idx}.SourceFile);

        if verbose
            fprintf('Updating: %s ...',libHelpers{idx}.SourceFile);
        end


        if~libHelpers{idx}.IsSSCFunction
            lValidate(libHelpers{idx}.Command);
        end

        if verbose
            fprintf(' done\n');
        end

        clear(libHelpers{idx}.SourceFile);
    end

end

function lValidate(cmd)
    obj=feval(cmd);
    if isa(obj,'simscape.ComponentModel')
        simscape.validateModel(obj);
    elseif ismethod(obj,'validate')
        validate(obj);
    end
end


