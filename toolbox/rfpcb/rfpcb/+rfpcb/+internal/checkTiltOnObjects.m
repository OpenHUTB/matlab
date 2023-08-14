function checkTiltOnObjects(obj1,obj2)

    createGeometry(obj1);
    createGeometry(obj2);
    if isa(obj1,'pcbComponent')||isa(obj1,'pcbStack')
        G1=getGeometry(obj1);
    else
        pcb1=getPrintedStack(obj1);
        G1=getGeometry(pcb1);
    end

    if isa(obj2,'pcbComponent')||isa(obj2,'pcbStack')
        G2=getGeometry(obj2);
    else
        pcb2=getPrintedStack(obj2);
        G2=getGeometry(pcb2);
    end

    TR1=triangulation(G1{1}.polygons{1},G1{1}.BorderVertices);
    TR2=triangulation(G2{1}.polygons{1},G2{1}.BorderVertices);

    fn1=faceNormal(TR1);
    fn2=faceNormal(TR2);
    if any(cellfun(@(x)~isequal(x,[0,0,1]),num2cell(fn1,2)))
        error(message('rfpcb:rfpcberrors:Unsupported','Non Z-axis tilt on component 1','pcbcascade'));
    end

    if any(cellfun(@(x)~isequal(x,[0,0,1]),num2cell(fn2,2)))
        error(message('rfpcb:rfpcberrors:Unsupported','Non Z-axis tilt on component 2','pcbcascade'));
    end

end