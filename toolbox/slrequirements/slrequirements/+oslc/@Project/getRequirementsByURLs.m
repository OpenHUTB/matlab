function[requirements,numericIds]=getRequirementsByURLs(this,items,progressBarInfo,myConnection)

    if nargin<4
        myConnection=oslc.connection();
    end




    isMatlabClient=isa(myConnection,'oslc.matlab.DngClient');

    requirementsURIs=cell(size(items));
    requirementsIDs=cell(size(items));
    numericIds=zeros(size(items));
    isNew=false(size(items));

    if isMatlabClient
        totalItems=numel(items);
    else
        totalItems=items.length;
    end
    for i=1:totalItems
        if isMatlabClient
            requirementsURIs{i}=items{i}{1};
        else
            requirementsURIs{i}=char(items(i));
        end
        requirementsIDs{i}=oslc.Requirement.registry(requirementsURIs{i});
        if isempty(requirementsIDs{i})
            isNew(i)=true;
        else
            numericIds(i)=str2num(requirementsIDs{i});%#ok<ST2NM>
        end
    end
    addedItems=requirementsURIs(isNew);
    if~isempty(addedItems)
        updatedRange=progressBarInfo.range;
        shrinkRange=updatedRange(1)+(updatedRange(2)-updatedRange(1))/4;
        progressBarInfo.range=[shrinkRange,updatedRange(2)];
        addedReqs=oslc.Requirement.getRequirements(myConnection,addedItems,this.name,this.queryBase,progressBarInfo);
        this.itemIds=oslc.Project.cacheIDs(this.itemIds,addedReqs);
        requirements(isNew)=addedReqs;
    end
    for i=1:length(requirementsURIs)
        if isNew(i)

            requirementsIDs{i}=oslc.Requirement.registry(requirementsURIs{i});
            numericIds(i)=str2num(requirementsIDs{i});%#ok<ST2NM>
        else

            requirements(i)=oslc.Requirement.registry(requirementsIDs{i});
        end
    end
end
