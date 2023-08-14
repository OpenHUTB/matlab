function pout=antuniquetol(pin,tol)


    flip_pout=false;
    [m,n]=size(pin);
    if(m==1)||(m<n)
        pin=pin.';
        flip_pout=true;
    end

    [~,ib]=uniquetol(pin,tol,'ByRows',true,'DataScale',1,'OutputAllIndices',true);
    repeatgroups=ib(cellfun(@numel,ib)>1);
    repeatgroups=cell2mat(repeatgroups);
    repeatgroups=[repeatgroups(1:2:end),repeatgroups(2:2:end)];
    pout=pin;
    if~isempty(repeatgroups)

        [~,i]=sort(repeatgroups(:,2));
        rr=repeatgroups(i,:);
        pout(rr(:,2),:)=[];
    end

    if flip_pout
        pout=pout.';
    end