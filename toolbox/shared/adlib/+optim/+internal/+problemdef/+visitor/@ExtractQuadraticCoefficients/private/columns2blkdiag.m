function Mat=columns2blkdiag(A)









    [N,M]=size(A);
    Mat=[A;sparse(N*M,M)];
    Mat=reshape(Mat,N*M,M+1);
    Mat(:,end)=[];

end

