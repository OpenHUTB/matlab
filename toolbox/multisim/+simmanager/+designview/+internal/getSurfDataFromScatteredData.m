function[X,Y,Z]=getSurfDataFromScatteredData(scatterX,scatterY,scatterZ)


    finiteDataIndices=isfinite(scatterX)&isfinite(scatterY)&isfinite(scatterZ);
    numFinitePoints=sum(finiteDataIndices);

    if numFinitePoints<3

        X=[];
        Y=[];
        Z=[];
    else

        numPointsAlongEachAxis=2*ceil(sqrt(numFinitePoints));

        scatterX=scatterX(finiteDataIndices);
        scatterY=scatterY(finiteDataIndices);
        scatterZ=scatterZ(finiteDataIndices);

        xlin=linspace(min(scatterX),max(scatterX),numPointsAlongEachAxis);
        ylin=linspace(min(scatterY),max(scatterY),numPointsAlongEachAxis);
        [X,Y]=meshgrid(xlin,ylin);


        origState=warning('off','all');
        oc=onCleanup(@()warning(origState));

        Z=griddata(scatterX,scatterY,scatterZ,X,Y,'cubic');


        if isempty(Z)
            Z=nan(numel(xlin),numel(ylin));
        end
    end
end