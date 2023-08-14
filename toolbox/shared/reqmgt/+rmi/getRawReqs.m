function reqstr=getRawReqs(objH,isSf)



    if nargin==1
        [isSf,objH,~]=rmi.resolveobj(objH);
    end

    if isempty(objH)
        reqstr=[];
        return;
    end

    if isSf
        reqstr=sf('get',objH,'.requirementInfo');
    else
        reqstr=get_param(objH,'requirementInfo');
    end


