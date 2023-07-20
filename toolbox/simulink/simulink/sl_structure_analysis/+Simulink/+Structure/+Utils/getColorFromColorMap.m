



function color=getColorFromColorMap(cmap,value,min,max)
    [m,~]=size(cmap);
    row=round((value/(max-min))*(m-1))+1;
    color=cmap(row,:);
    color=[color,1];
end
