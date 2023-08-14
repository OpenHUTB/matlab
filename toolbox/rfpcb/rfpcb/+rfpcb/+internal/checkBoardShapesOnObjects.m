function checkBoardShapesOnObjects(L1,L2)

    if~isequal(class(L1),class(L2))
        if(isa(L1,'traceRectangular')&&isa(L2,'antenna.Rectangle'))||...
            (isa(L2,'traceRectangular')&&isa(L1,'antenna.Rectangle'))
            return;
        else
            error(message('rfpcb:rfpcberrors:DifferingBoardShapes'));
        end
    end