function style=constraintConvert2DTo3D(cons)

    switch cons
    case 'horizontal'
        style='x';
    case 'vertical'
        style='y';
    otherwise
        style='unconstrained';
    end
