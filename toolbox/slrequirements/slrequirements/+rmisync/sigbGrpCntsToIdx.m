function my_idx=sigbGrpCntsToIdx(cnts)





    cs=cumsum(cnts(:));
    pivot([1;cs+1])=1;
    my_idx=cumsum(pivot)';
    my_idx(end)=[];
end
