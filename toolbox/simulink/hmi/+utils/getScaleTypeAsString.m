

function scaleType=getScaleTypeAsString(val)


    switch(val)
    case 0
        scaleType='Linear';
    case 1
        scaleType='Log';
    end

end