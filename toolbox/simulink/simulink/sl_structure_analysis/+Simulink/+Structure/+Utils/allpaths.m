


function[paths]=allpaths(wt,startnode,endnode)

    lastpath=(startnode);

    costs=(0);

    paths=[zeros(0,1),zeros(0,1)];

    N=size(wt,1);

    assert(N==size(wt,2));
    for i=2:N



        nextmove=wt(lastpath(:,i-1),:)~=0;


        d=diag(1:size(lastpath,1));
        nrows=d*ones(size(lastpath));
        inds=sub2ind(size(nextmove),reshape(nrows,[],1),...
        reshape(lastpath,[],1));
        nextmove(inds)=false;


        if nextmove==0
            break;
        end



        nextmoverow=d*nextmove;
        nextmovecol=nextmove*diag(1:N);
        rowlist=reshape(nonzeros(nextmoverow),[],1);
        collist=reshape(nonzeros(nextmovecol),[],1);
        nextpath=[lastpath(rowlist,:),collist];



        inds=sub2ind([N,N],nextpath(:,i-1),nextpath(:,i));
        costs=costs(rowlist)+wt(inds);



        reachedend=nextpath(:,i)==endnode;
        paths=[paths;{nextpath(reachedend,:)},{costs(reachedend)}];


        lastpath=nextpath(~reachedend,:);
        costs=costs(~reachedend);


        if isempty(lastpath)
            break;
        end
    end

    emptyPath=[];
    [m,n]=size(paths);
    for i=1:m
        if isempty(paths{i})
            emptyPath=[emptyPath,i];
        end
    end
    paths(emptyPath,:)=[];

end