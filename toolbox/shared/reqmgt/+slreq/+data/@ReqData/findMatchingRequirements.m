function dataReqs=findMatchingRequirements(this,reqSet,filters)






    if~isa(reqSet,'slreq.data.RequirementSet')
        error('Invalid input: expected slreq.data.RequirementSet');
    end

    slreq.utils.assertValid(reqSet);

    if nargin<3||isempty(filters)||...
        ~isa(filters,'struct')||~isfield(filters,'property')||~isfield(filters,'value')
        error('findMatchingRequirements() requires filter structure with "property" and "value" fields');
    end

    dataReqs=slreq.data.Requirement.empty;


    modelReqSet=this.getModelObj(reqSet);
    items=modelReqSet.items.toArray();
    for i=1:numel(items)
        if isMatched(items(i),filters)
            dataReqs(end+1)=this.wrap(items(i));%#ok<AGROW>
        end
    end
end

function match=isMatched(mfReq,filters)
    match=true;
    for i=1:numel(filters)
        propName=filters(i).property;
        if isprop(mfReq,propName)
            if strcmp(propName,'artifactUri')
                storedUri=mfReq.group.artifactUri;
                shortUri=slreq.uri.getShortNameExt(storedUri);
                matchIn={storedUri,shortUri};
            else
                matchIn=mfReq.(propName);
            end
            propValue=filters(i).value;
            if~isempty(propValue)&&propValue(1)=='~'

                match=~isempty(regexp(matchIn,propValue(2:end),'once'));
            else

                match=any(strcmp(matchIn,propValue));
            end
        else
            match=false;
        end
        if~match
            return;
        end
    end
end
