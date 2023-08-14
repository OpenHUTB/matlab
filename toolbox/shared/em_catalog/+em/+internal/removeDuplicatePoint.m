function[p,t]=removeDuplicatePoint(p_in,t_in)
    [r1,c1]=size(p_in);
    [r2,c2]=size(t_in);
    if c2~=4
        error('The t matrix must be of size Nx4');
    end
    if c1~=3
        error('The p matrix must be of size Nx3');
    end

    p_new=p_in;
    p_temp=uniquetol(p_new,'ByRows',true);
    t_new=reshape(t_in,[],1);
    for i=1:max(size(t_new))
        old_index=t_new(i);
        new_index=find(abs(p_temp(:,1)-p_new(old_index,1))<1e-6&...
        abs(p_temp(:,2)-p_new(old_index,2))<1e-6&...
        abs(p_temp(:,3)-p_new(old_index,3))<1e-6);
        t_new(i)=new_index;
    end
    p=p_temp;

    t=unique(sort(reshape(t_new,[],c2),2),'row');
