classdef MaskDisplayParams


    properties(Constant=true)
        POSITION=[235,110,320,150];
        ACTIVEGROUP_X_COORD=2;
        ACTIVEGROUP_Y_COORD=12;
        UPPER_LEFT_X_COORD=235;
        UPPER_LEFT_Y_COORD=110;
        LOWER_RIGHT_X_COORD=320;
        LOWER_RIGHT_Y_COORD=150;
        WIDTH=sigbldrblock.MaskDisplayParams.LOWER_RIGHT_X_COORD-...
        sigbldrblock.MaskDisplayParams.UPPER_LEFT_X_COORD;
        HEIGHT=sigbldrblock.MaskDisplayParams.LOWER_RIGHT_Y_COORD-...
        sigbldrblock.MaskDisplayParams.UPPER_LEFT_Y_COORD;
        W_TO_H_RATIO=sigbldrblock.MaskDisplayParams.WIDTH/sigbldrblock.MaskDisplayParams.HEIGHT;

        MARGIN=14;
        ICON=['plot(0, 0, 100, 100,'...
        ,'[2, 2, 32, 32, 2], [68, 8, 8, 68, 68],'...
        ,'[32, 2], [38, 38], '...
        ,'[32, 19, 2],[53, 60, 44], '...
        ,'[32, 17, 17, 2],[16, 16, 31, 31]);'];
        ACTIVEGROUP=['txt = getActiveGroup(gcbh);,'...
        ,'text(2, 88, txt);'];
        DISPCMD=[sigbldrblock.MaskDisplayParams.ICON,...
        sigbldrblock.MaskDisplayParams.ACTIVEGROUP];

    end

end
