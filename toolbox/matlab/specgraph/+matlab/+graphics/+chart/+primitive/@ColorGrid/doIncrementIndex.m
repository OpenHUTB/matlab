function[index,interp]=doIncrementIndex(hObj,index,direction,~)








    [ny,nx]=size(hObj.ColorData);
    nx=max(1,nx);
    ny=max(1,ny);


    index=max(1,min(nx*ny,index));


    [y,x]=ind2sub([ny,nx],index);


    switch direction
    case 'down'
        y=max(y-1,1);
    case 'up'
        y=min(y+1,ny);
    case 'left'
        x=max(x-1,1);
    case 'right'
        x=min(x+1,nx);
    end


    index=sub2ind([ny,nx],y,x);
    interp=0;

end
