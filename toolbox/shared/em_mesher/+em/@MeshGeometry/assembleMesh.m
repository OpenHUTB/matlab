function[p,t]=assembleMesh(parray,tarray)










    [mp,np]=size(parray);

    p=cell2mat(parray);

    t=tarray{1}(1:3,:);
    tdomain=tarray{1}(4,:);
    for i=2:max(mp,np)
        temp=tarray{i}(1:3,:)+max(t,[],"all");
        tempdomain=tarray{i}(4,:);
        t=[t,temp];%#ok<AGROW>
        tdomain=[tdomain,tempdomain];%#ok<AGROW>
    end
    t=[t;tdomain];
