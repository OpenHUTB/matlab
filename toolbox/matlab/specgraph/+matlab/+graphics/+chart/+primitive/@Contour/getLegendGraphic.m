function graphic=getLegendGraphic(hObj)




    graphic=matlab.graphics.primitive.world.Group;


    if isscalar(hObj.LevelList)&&isscalar(hObj.EdgePrims)
        makeLine(graphic,hObj.EdgePrims(1));
    elseif isscalar(hObj.LevelList)&&isscalar(hObj.EdgeLoopPrims)
        makeLine(graphic,hObj.EdgeLoopPrims(1));
    else
        cs=ancestor(hObj,'matlab.graphics.axis.colorspace.ColorSpace','node');
        cmap=cs.Colormap;
        r=length(cmap);
        if r>0
            fc{1}=uint8([255*cmap(1,:)';255]);
            fc{2}=uint8([255*cmap(floor(r/2),:)';255]);
            fc{3}=uint8([255*cmap(r,:)';255]);
        else
            fc=cell(1,3);
        end


        lc=hObj.EdgeColor;
        if isnumeric(lc)
            c=uint8([255*lc';255]);
            ec{1}=c;
            ec{2}=c;
            ec{3}=c;
        elseif strcmp(lc,'flat')||strcmp(lc,'auto')
            ec{1}=fc{1};
            ec{2}=fc{2};
            ec{3}=fc{3};
        end

        for i=1:3
            w=(4-i)/3;
            h=(4-i)/3;
            theta=linspace(0,2*pi,48);
            x=single(w/2*cos(theta)+.5);
            y=single(h/2*sin(theta)+.5);
            z=single(zeros(size(x)));


            if~strcmp(hObj.FaceColor,'none')
                makeEllipseFill(graphic,x,y,z,fc{i});
            end
            if~strcmp(lc,'none')
                makeEllipseEdge(graphic,hObj,x,y,z,ec{i});
            end
        end


    end

    function makeEllipseFill(par,x,y,z,c)

        face=matlab.graphics.primitive.world.TriangleStrip;
        face.Parent=par;
        face.VertexData=[x;y;z];
        face.StripData=uint32([1,48]);
        face.VertexIndices=uint32([1,47,2,46,3,45,4,44,5,43,6,42,7,41,8,40,9,39,10,38,11,37,12,36,13,35,14,34,15,33,16,32,17,31,18,30,19,29,20,28,21,27,22,26,23,25,24]);
        face.ColorData=c;
        if isempty(c)
            face.ColorBinding='none';
        else
            face.ColorBinding='object';
        end

        function makeEllipseEdge(par,hObj,x,y,z,c)

            edge=matlab.graphics.primitive.world.LineStrip;
            edge.Parent=par;
            edge.LineWidth=hObj.LineWidth;
            hgfilter('LineStyleToPrimLineStyle',edge,hObj.LineStyle);
            edge.VertexData=[x;y;z];
            edge.StripData=uint32([1,49]);
            edge.ColorData=c;
            if isempty(c)
                edge.ColorBinding='none';
            else
                edge.ColorBinding='object';
            end



            function makeLine(par,prim)
                edge=matlab.graphics.primitive.world.LineStrip;
                edge.Parent=par;
                edge.LineWidth=prim.LineWidth;
                edge.LineStyle=prim.LineStyle;
                edge.ColorData=prim.ColorData;
                edge.ColorBinding=prim.ColorBinding;

                if strcmp(prim.Visible,'on')
                    edge.VertexData=single([0,1;0.5,0.5;0,0]);
                    edge.StripData=uint32([1,3]);
                    edge.Description='Icon Edge';
                end
