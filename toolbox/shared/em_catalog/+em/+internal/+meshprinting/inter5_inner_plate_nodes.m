function[P]=inter5_inner_plate_nodes(L,W,Tri)




    N=ceil(sqrt(Tri*L/(2.2*W)));sizex=L/(N-1);sizey=sizex*sqrt(3)/2;
    x=-L/2+sizex/2:sizex:L/2-sizex/2;
    y=-W/2+sizey/2:sizey:W/2-sizey/2;
    [X,Y]=meshgrid(x,y);
    X(1:2:end,:)=X(1:2:end,:)+sizex/4;
    X(2:2:end,:)=X(2:2:end,:)-sizex/4;
    P=[X(:),Y(:)];
end