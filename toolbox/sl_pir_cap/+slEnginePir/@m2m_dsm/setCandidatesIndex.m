function this=setCandidatesIndex(this,wishList)


    mdls=[this.fMdl,this.fRefMdls];
    nMdls=length(this.fRefMdls)+1;

    this.fXlinkedBlks=struct('block',{},'lib',{});
    this.fDeactivatedLibBlks=struct('block',{},'lib',{});
    for i=1:length(this.fLibCandIdx)
        if~isempty(this.fLibCandIdx{i})
            for j=1:length(this.fLibCandIdx{i})
                idx=find(wishList==this.fLibCandIdx{i}(j));

                libBlk=getfullname(this.fByNameList{this.fLibCandIdx{i}(j)}(1));
                while~strcmp(get_param(libBlk,'LinkStatus'),'resolved')
                    libBlk=get_param(libBlk,'parent');
                end
                field1='block';
                field2='lib';
                value1=libBlk;
                value1(find(value1==char(10)))=' ';
                value2=this.fLibMdls{i};
                this.fXlinkedBlks(end+1)=struct(field1,value1,field2,value2);
                if j==1
                    this.fDeactivatedLibBlks(end+1)=this.fXlinkedBlks(end);
                end
            end
            for j=1:length(this.fLibCandIdx{i})
                idx=find(wishList==this.fLibCandIdx{i}(j));
                if~isempty(idx)
                    wishList=exclude(wishList,this.fLibCandIdx{i});
                    wishList(end+1)=this.fLibCandIdx{i}(1);










                    break;
                end
            end
        end
    end
    wishList=sort(wishList);

    this.fFinalCandidateIndex=cell([1,nMdls]);
    mdlXformed=zeros(1,nMdls);
    for i=1:length(wishList)
        for j=1:nMdls
            if find(this.fCandidateIndex{j}==wishList(i))
                this.fFinalCandidateIndex{j}(end+1)=wishList(i);
                mdlXformed(j)=1;
            end
        end
    end


    if nMdls>0
        this.fXformedMdls{end+1}=this.fMdl;
    end
    for i=1:nMdls
        if mdlXformed(i)==1
            if~strcmp(mdls{i},this.fMdl)
                this.fXformedMdls{end+1}=mdls{i};
            end
        end
    end


    for i=1:length(this.fLibMdls)
        if~isempty(this.fLibCandIdx{i})
            this.fXformedMdls{end+1}=this.fLibMdls{i};
        end
    end

end

function list=exclude(list,candList)
    idx=[];
    for i=1:length(candList)
        idx(end+1)=find(list==candList(i));
    end
    list(idx)=[];
end
