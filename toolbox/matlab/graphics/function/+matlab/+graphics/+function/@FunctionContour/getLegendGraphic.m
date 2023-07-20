function graphic=getLegendGraphic(hObj)



    graphic=matlab.graphics.primitive.world.Group;


    if isscalar(hObj.LevelList)
        e=makeLine(hObj.Edge(1));
        e.Parent=graphic;
    else
        cmap=ancestor(hObj,'matlab.graphics.axis.colorspace.ColorSpace','node');
        cmap=cmap.Colormap;
        r=length(cmap);
        if r>0
            c1=uint8([255*cmap(1,:)';255]);
            c2=uint8([255*cmap(floor(r/2),:)';255]);
            c3=uint8([255*cmap(r,:)';255]);
        else
            c1=[];
            c2=[];
            c3=[];
        end

        if strcmp(hObj.Fill,'on')
            [e1,f1]=makeEllipse(1,1,c1,true);
            e1.Parent=graphic;
            f1.Parent=graphic;

            [e2,f2]=makeEllipse(2/3,2/3,c2,true);
            e2.Parent=graphic;
            f2.Parent=graphic;

            [e3,f3]=makeEllipse(1/3,1/3,c3,true);
            e3.Parent=graphic;
            f3.Parent=graphic;
        else
            e1=makeEllipse(1,1,c1,false);
            e1.Parent=graphic;

            e2=makeEllipse(2/3,2/3,c2,false);
            e2.Parent=graphic;

            e3=makeEllipse(1/3,1/3,c3,false);
            e3.Parent=graphic;
        end
    end

    function[edge,face]=makeEllipse(w,h,c,isFill)

        theta=linspace(0,2*pi,48);
        x=single(w/2*cos(theta)+.5);
        y=single(h/2*sin(theta)+.5);
        z=single(zeros(size(x)));

        if isFill
            face=matlab.graphics.primitive.world.TriangleStrip;
            face.VertexData=[x;y;z];
            face.StripData=uint32([1,48]);
            face.VertexIndices=uint32([1,47,2,46,3,45,4,44,5,43,6,42,7,41,8,40,9,39,10,38,11,37,12,36,13,35,14,34,15,33,16,32,17,31,18,30,19,29,20,28,21,27,22,26,23,25,24]);
            face.ColorData=c;
            if isempty(c)
                face.ColorBinding='none';
            else
                face.ColorBinding='object';
            end

            edge=matlab.graphics.primitive.world.LineStrip;
            edge.VertexData=[x;y;z];
            edge.StripData=uint32([1,49]);
            edge.ColorData=uint8([0;0;0;255]);
            edge.ColorBinding='object';
        else
            edge=matlab.graphics.primitive.world.LineStrip;
            edge.VertexData=[x;y;z];
            edge.StripData=uint32([1,49]);
            edge.ColorData=c;
            if isempty(c)
                edge.ColorBinding='none';
            else
                edge.ColorBinding='object';
            end
        end



        function edge=makeLine(prim)
            edge=matlab.graphics.primitive.world.LineStrip;

            edge.LineWidth=prim.LineWidth;
            edge.LineStyle=prim.LineStyle;
            edge.ColorData=prim.ColorData;
            edge.ColorBinding=prim.ColorBinding;

            if strcmp(prim.Visible,'on')
                edge.VertexData=single([0,1;0.5,0.5;0,0]);
                edge.StripData=uint32([1,3]);
                edge.Description='Icon Edge';
            end
