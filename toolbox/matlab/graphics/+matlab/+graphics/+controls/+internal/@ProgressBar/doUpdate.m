function doUpdate(obj,updateState)










    [barcolors,barverts,edgecolors,edgeverts]=localGetBar(obj);

    localsetGeometry(updateState,obj.ProgressFace,barverts,barcolors,'interpolated');
    localsetGeometry(updateState,obj.ProgressEdge,edgeverts,edgecolors,'discrete');
end


function localsetGeometry(updateState,hGeom,verts,colors,colorbinding)

    iter=matlab.graphics.axis.dataspace.IndexPointsIterator('Vertices',verts);
    vertdata=updateState.DataSpace.TransformPoints(updateState.TransformUnderDataSpace,iter);
    hGeom.VertexData=vertdata;

    iter=matlab.graphics.axis.colorspace.IndexColorsIterator('Colors',colors);
    colordata=updateState.ColorSpace.TransformTrueColorToTrueColor(iter);
    hGeom.ColorData=colordata.Data;
    hGeom.ColorType=colordata.Type;
    hGeom.ColorBinding=colorbinding;
end


function[colors,verts,edgecolors,edgeverts]=localGetBar(obj)



    if isfinite(obj.Progress)&&~(ischar(obj.Color)&&strcmp(obj.Color,'none'))
        progress=min(1,max(0,obj.Progress));

        barstart=obj.Position(1);
        barwidth=obj.Position(3);
        bary1=obj.Position(2);
        bary2=obj.Position(2)+obj.Position(4);

        bar1quart=barstart+0.25*progress*barwidth;
        barmid=barstart+0.5*progress*barwidth;
        bar3quart=barstart+0.75*progress*barwidth;
        barend=barstart+progress*barwidth;

        basecolor=uint8(obj.Color*255);



        midcolor=basecolor+0.4*(255-basecolor);


        edgecolor=0.7*basecolor;


        remaincolor=uint8([255,255,255]);
        remainedgecolor=uint8([153,153,153]);

        colors=[...
        makeInterpFaceColors(basecolor,basecolor);...
        makeInterpFaceColors(basecolor,midcolor);...
        makeInterpFaceColors(midcolor,basecolor);...
        makeInterpFaceColors(basecolor,basecolor);...
        makeInterpFaceColors(remaincolor,remaincolor)];

        verts=[...
        makeFaceVerts(barstart,bar1quart,bary1,bary2);...
        makeFaceVerts(bar1quart,barmid,bary1,bary2);...
        makeFaceVerts(barmid,bar3quart,bary1,bary2);...
        makeFaceVerts(bar3quart,barend,bary1,bary2);...
        makeFaceVerts(barend,barstart+barwidth,bary1,bary2)];

        edgecolors=[edgecolor;edgecolor;remainedgecolor;edgecolor;remainedgecolor;remainedgecolor];

        edgeinset=1e-3;
        edgestart=barstart+edgeinset;
        edgeend=barstart+barwidth-edgeinset;
        edgey1=bary1+edgeinset;
        edgey2=bary2-edgeinset;
        edgeverts=single([
        edgestart,edgey1;...
        edgestart,edgey2;...
        edgestart,edgey1;...
        barend,edgey1;...
        barend,edgey1;...
        edgeend,edgey1;...
        edgestart,edgey2;...
        barend,edgey2;...
        barend,edgey2;...
        edgeend,edgey2;
        edgeend,edgey1;...
        edgeend,edgey2]);
    else
        colors=zeros(0,3,'uint8');
        verts=zeros(0,2,'single');
        edgecolors=zeros(0,3,'uint8');
        edgeverts=zeros(0,2,'single');
    end
end


function colors=makeInterpFaceColors(c1,c2)
    colors=[c1;c1;c2;c2];
end


function verts=makeFaceVerts(x1,x2,y1,y2)
    verts=single([...
    x1,y1;...
    x1,y2;...
    x2,y2;...
    x2,y1]);
end
