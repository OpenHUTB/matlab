function refreshCustomizations












    if dig.isProductInstalled('Simulink')&&license('test','simulink')
        sl_refresh_customizations;
        return;
    end

    cm=struct('SimulinkRequirementsCustomizer',slreq.custom.BaseCustomizer.getInstance());
    cm.SimulinkRequirementsCustomizer.clear();
    funcs=getFuncs('sl_customization');
    evalFuncs(funcs,cm);
end

function funcs=getFuncs(fileName)
    funcs={};
    customizations=which('-all',fileName);

    if length(customizations)==0 %#ok
        return
    end

    for i=1:length(customizations)
        paths{i}=fileparts(customizations{i});%#ok
    end

    [paths,indexFromCustomizations,~]=unique(paths);

    for i=1:length(paths)
        funcs{i}=builtin('_GetFunctionHandleForFullpath',customizations{indexFromCustomizations(i)});%#ok
    end
end

function evalFuncs(funcs,cm)
    for i=1:length(funcs)
        try
            feval(funcs{i},cm);
        catch me
            if~strcmp(me.identifier,'MATLAB:nonExistentField')


                warning(me.identifier,'%s',getMessageWithTrimmedStack(me,'callAll'));
            end
        end
    end
end

function str=getMessageWithTrimmedStack(ME,func)
    str=ME.getReport;
    ind=strfind(str,func);
    if~isempty(ind)

        str=str(1:ind(1));
        ind=find(str==newline);
        if~isempty(ind)
            str=str(1:ind(end)-1);
        end
    end
end