function[systemModel,harnessOwnerHandle]=parseForSystemModel(harnessOwner)

    try
        systemModel=bdroot(harnessOwner);
    catch ME
        throwAsCaller(ME);
    end
    if~isnumeric(harnessOwner)

        harnessOwnerHandle=get_param(harnessOwner,'handle');
    else

        harnessOwnerHandle=harnessOwner;
        systemModel=get(systemModel,'name');
    end

end
