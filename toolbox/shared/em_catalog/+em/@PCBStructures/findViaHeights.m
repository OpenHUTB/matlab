function viaHeight=findViaHeights(obj,vias,layer_heights)%#ok<INUSL>

    viaHeight=zeros(1,size(vias,1));
    for i=1:size(vias,1)
        viaStartLayer=vias(i,3);
        viaStopLayer=vias(i,4);
        viaHeight(i)=abs(layer_heights(viaStartLayer)-layer_heights(viaStopLayer));
    end
end