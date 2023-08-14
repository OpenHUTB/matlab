





function[pathRegion]=allPathRegion(wt,startnode,endnode)

    import Simulink.Structure.Utils.*

    pathRegion=[];
    wt(endnode,startnode)=1;
    DEOut=findSCC(wt);
    n=length(DEOut);


    for i=1:n
        region=DEOut{i};
        if(region(endnode,startnode)==1)
            pathRegion=region;
            break;
        end
    end


