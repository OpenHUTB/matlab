function[x,y,z]=create_tile_coordinates(xedges,yedges,...
    values,dropzero,brushvalues)





    countslenx=length(xedges)-1;
    countsleny=length(yedges)-1;

    x=reshape([xedges(1:end-1);xedges(2:end);xedges(2:end);...
    xedges(1:end-1)],1,[]);
    x=repmat(x,1,countsleny);
    y=repmat([yedges(2:end);yedges(2:end);yedges(1:end-1);...
    yedges(1:end-1)],countslenx,1);

    if nargin>4&&~isempty(brushvalues)

        bi=reshape(find(brushvalues),1,[]);
        bvi=bsxfun(@plus,4*(bi-1),(1:4)');
        values(bi)=[];
        x(bvi)=[];
        y(bvi)=[];
    end
    if dropzero

        zzero=~(values>0);
        x=reshape(x,4,[]);
        x(:,zzero)=[];
        y=reshape(y,4,[]);
        y(:,zzero)=[];
    end
    x=reshape(x,1,[]);
    y=reshape(y,1,[]);

    z=zeros(1,length(x));

end