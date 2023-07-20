function req=findProxyItem(this,domain,artifactUri,artifactId,searchInDefaultReqSet)






    req=[];

    if nargin<5
        searchInDefaultReqSet=false;
    end


    group=this.findGroup(artifactUri,domain);

    if isempty(group)&&searchInDefaultReqSet







        defaultReqSet=this.getDefaultReqSet();
        group=this.findGroupInReqSet(defaultReqSet,artifactUri,domain);
    end

    if isempty(group)



        return;
    end


    reqs=group.items{artifactId};
    if~isempty(reqs)
        req=this.wrap(reqs(1));

    end
end

