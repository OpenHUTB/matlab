function fullMatrix=hDAESparseToFull(s,nRow,nCol)







    fullMatrix=zeros(nRow,nCol);
    for i=1:length(s.Ir)-1
        for jidx=s.Ir(i):1:s.Ir(i+1)-1
            j=jidx+1;
            fullMatrix(i,s.Jc(j)+1)=s.Pr(j);
        end
    end
end