function[results,filteredItems,detailedResult]=filterResultWithExclusions(system,modelObjects,checkID)













    results=modelObjects;
    filteredItems=[];
    detailedResult=[];

    if isempty(modelObjects)||(slcheck.doesCheckSupportExclusion(system,checkID)==false)
        return;
    end

    try
        filterManager=slcheck.getAdvisorFilterManager(bdroot(system));

        if ischar(modelObjects)
            output={slcheck.getsid(modelObjects)};
        elseif iscell(modelObjects)
            output=cellfun(@(x)slcheck.getsid(x),modelObjects,'UniformOutput',false);
        else
            output=arrayfun(@(x)slcheck.getsid(x),modelObjects,'UniformOutput',false);
        end

        output=filterManager.getFilterResults(checkID,output)';
        status=arrayfun(@(x)x.status,output);
        results=modelObjects(~status);
        detailedResult=output(status);
        filteredItems=modelObjects(status);

    catch E
        disp(checkID);
        disp(E.message);
    end
end
