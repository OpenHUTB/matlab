function style=constraintConvert3DTo2D(cons)

    switch cons
    case{'x','xz'}
        style='horizontal';
    case{'y','yz'}
        style='vertical';
    otherwise
        style='both';
    end
