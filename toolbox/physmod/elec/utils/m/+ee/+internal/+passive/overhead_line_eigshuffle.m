function[Vseq,Dseq]=overhead_line_eigshuffle(mat)







    N=size(mat,1);
    Nf=size(mat,3);
    Vseq=zeros(N,N,Nf);
    Dseq=zeros(N,Nf);

    for i=1:Nf
        [V,D]=eig(mat(:,:,i));
        Vseq(:,:,i)=V;
        Dseq(:,i)=diag(D);
    end

    test=Dseq';
    close all
figure
    hold on
    plot(test(:,1))
    plot(test(:,2))
    plot(test(:,3))
    plot(test(:,4))

end