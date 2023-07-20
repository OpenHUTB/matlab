function[coordinate]=findLineCoordinate(connection)



    delta=10;
    switch connection.portType
    case 'LConn'
        flipSign=1;
    case 'RConn'
        flipSign=-1;
    otherwise
    end

    switch connection.parentOrientation
    case 'left'
        offset=flipSign.*[delta,0];
    case 'right'
        offset=flipSign.*[-delta,0];
    case 'down'
        offset=flipSign.*[0,-delta];
    case 'up'
        offset=flipSign.*[0,delta];
    otherwise
    end
    coordinate=connection.portPosition+offset;

end

