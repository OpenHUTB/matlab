function[bounds,tags]=categoryBBounds(level)




    switch level
    case "1"
        bounds={
        Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.levelOneBounds("B");
        };
        tags="Level 1";
    case "2"
        bounds={
        Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.levelTwoBounds("B");
        };
        tags="Level 2";
    case "3"
        bounds={
        Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.levelThreeBounds("B");
        };
        tags="Level 3";
    case "all"
        [lvltwo,~,joint]=Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.levelTwoAndThreeBounds("B");
        bounds={
        Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.levelOneBounds("B");
        lvltwo;
        joint;
        };
        tags=["Level 1","Level 2","Level 2 & 3"];
    end

end

