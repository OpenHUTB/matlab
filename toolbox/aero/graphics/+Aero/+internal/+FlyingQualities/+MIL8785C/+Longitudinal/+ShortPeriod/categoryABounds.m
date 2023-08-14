function[bounds,tags]=categoryABounds(level)




    switch level
    case "1"
        bounds={
        Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.levelOneBounds("A");
        };
        tags="Level 1";
    case "2"
        bounds={
        Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.levelTwoBounds("A");
        };
        tags="Level 2";
    case "3"
        bounds={
        Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.levelThreeBounds("A");
        };
        tags="Level 3";
    case "all"
        [lvltwo,lvlthree,joint]=Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.levelTwoAndThreeBounds("A");
        bounds={
        Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.levelOneBounds("A");
        lvltwo;
        lvlthree;
        joint;
        };
        tags=["Level 1","Level 2","Level 3","Level 2 & 3"];
    end

end

