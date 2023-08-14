function[reqs,groups]=getSubIds(this,srcName,id)






    if nargin<3

        [srcName,id]=strtok(srcName,':');
    end
    try
        childIds=this.repository.getChildIds(srcName,id);
        reqs=[];
        groups=[];
        for i=1:length(childIds)
            myId=childIds{i};
            dotHere=find(myId=='.');
            if length(dotHere)==1
                groupIdx=str2num(myId(dotHere+1:end));%#ok<ST2NM>
                groupReqs=this.repository.getData(srcName,myId);
                if~isempty(groupReqs)
                    reqs=[reqs;groupReqs];%#ok<AGROW>
                    groups=[groups;ones(size(groupReqs))*groupIdx];%#ok<AGROW>
                end
            end
        end
    catch %#ok<CTCH>
        reqs=[];groups=[];
    end
end
