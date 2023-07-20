





function objs=collectDASObjects(this,obj,includeAggs)






    objs={};

    if isempty(obj)
        return;
    end

    slreq.utils.assertValid(obj);



    if nargin<3
        includeAggs=true;
    end


    if isa(obj,'slreq.das.Requirement')||...
        isa(obj,'slreq.das.RequirementSet')||...
        isa(obj,'slreq.das.Link')||...
        isa(obj,'slreq.das.LinkSet')
        obj=obj.dataModelObj;
    end


    if~isa(obj,'slreq.data.Requirement')&&...
        ~isa(obj,'slreq.data.RequirementSet')&&...
        ~isa(obj,'slreq.data.Link')&&...
        ~isa(obj,'slreq.data.LinkSet')


        objs{1}=obj;
        return;
    end

    mfObj=obj.getModelObj();



    dataObjs=slreq.cpputils.collectTags(mfObj,true,includeAggs);
    for i=1:length(dataObjs)
        dataObj=dataObjs{i};
        if isempty(dataObj)

            continue;
        end

        objs{end+1}=dataObj.getDasObject();%#ok<AGROW>
    end

end
