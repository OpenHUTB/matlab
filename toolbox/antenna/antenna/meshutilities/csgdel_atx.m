function[dl1,bt1]=csgdel_atx(dl,bt,bl)

















    if nargin<2
        error(message('pdelib:csgdel:nargin'));
    end

    if nargin<3
        bl=find([dl(6,:)~=0&dl(7,:)~=0]);
    end

    dl1=dl;
    bt1=bt;

    if isempty(bl)
        return
    end

    ns=max(max(dl(6,:)),max(dl(7,:)));


    i=find(dl(6,bl)==0|dl(7,bl)==0);
    if~isempty(i)
        error(message('pdelib:csgdel:CannotRemoveOutBnd'));
    end



    nl=[];
    for i=1:length(bl)
        k=find((dl(6,:)==dl(6,bl(i))&dl(7,:)==dl(7,bl(i)))|...
        (dl(6,:)==dl(7,bl(i))&dl(7,:)==dl(6,bl(i))));
        nl=[nl,k];
    end

    bl=sort(nl);
    bl=bl(logical([1,sign(diff(bl))]));

    cm=sparse(dl(6,bl),dl(7,bl),1,ns,ns);
    cm=cm+cm';
    tm=sparse([],[],[],ns,ns);
    while any(any(cm~=tm))
        tm=cm;
        cm=sign(cm+cm*cm);
    end

    eq=[];used=~full(sign(max(cm)));j=1;i=find(~used);

    while~isempty(i)
        i=find(cm(i(1),:))';
        used(i)=ones(1,length(i));
        eq(1:length(i)+1,j)=[length(i);i];
        i=find(~used);
        j=j+1;
    end

    for i=1:size(eq,2)
        for j=3:eq(1,i)+1
            k=find(dl1(6,:)==eq(j,i));
            dl1(6,k)=eq(2,i)*ones(1,length(k));
            k=find(dl1(7,:)==eq(j,i));
            dl1(7,k)=eq(2,i)*ones(1,length(k));
        end
    end

    ind=[dl1(6,:),dl1(7,:)];
    ind=sort(ind);
    ind=ind(logical([1,sign(diff(ind))]));
    ind(~ind)=[];
    bt1=bt(ind,:);
    j=1;
    for i=ind
        k=find(dl1(6,:)==i);
        dl1(6,k)=j*ones(1,length(k));
        k=find(dl1(7,:)==i);
        dl1(7,k)=j*ones(1,length(k));
        j=j+1;
    end

    dl1(:,bl)=[];

