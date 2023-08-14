function clearClasses(this)




    r=RptgenML.Root;

    clsName=[this.PkgName,'.',this.ClassName];

    if~isempty(r.Library)

        libComp=find(r.Library,...
        '-isa','RptgenML.LibraryComponent',...
        'ClassName',clsName);
        if~isempty(libComp)
            clearComponent(libComp(1));
        end
    end

    openClass=find(r,'-isa',clsName);

    if isempty(openClass)


        warnClassInstanceExists='MATLAB:ClassInstanceExists';
        warnObjectStillExists='MATLAB:objectStillExists';

        oldWarnClassInstanceExists=warning('query',warnClassInstanceExists);
        oldWarnObjectStillExists=warning('query',warnObjectStillExists);

        warning('off',warnClassInstanceExists);
        warning('off',warnObjectStillExists);

locClearClasses

        warning(oldWarnClassInstanceExists);
        warning(oldWarnObjectStillExists);
    else
        rptgen.displayMessage(sprintf(...
        getString(message('rptgen:RptgenML_ComponentMaker:cannotClearMsg')),...
        this.DisplayName,clsName),2);
        rptgen.displayMessage(getString(message('rptgen:RptgenML_ComponentMaker:howToClearMsg')),5);
    end


    function locClearClasses


        clear classes;
