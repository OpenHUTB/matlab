function[bounds,tags]=categoryCBounds(level)




    switch level
    case "1"
        bounds=num2cell(Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.levelOneBounds("C"));
        tags=[
        "Level 1";
        "Level 1";
        "Level 1 - Classes II-L, III";
        "Level 1 - Classes I, II-C, IV";
        ];
    case "2"
        bounds=num2cell(Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.levelTwoBounds("C"));
        tags=[
        "Level 2";
        "Level 2 - Classes II-L, III";
        "Level 2 - Classes I, II-C, IV";
        "Level 2";
        ];
    case "3"
        bounds={
        Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.levelThreeBounds("C");
        };
        tags="Level 3";
    case "all"
        [bounds,tags]=Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.categoryCBounds("1");
        [lvltwo,lvlthree,joint]=Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.levelTwoAndThreeBounds("C");

        [~,tags2]=Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.categoryCBounds("2");

        tags2(1)=[];

        bounds=[bounds,num2cell(lvltwo),{lvlthree},{joint}];
        tags=[
        tags;
        tags2;
        "Level 3";
        "Level 2 & 3";
        ];
    end

end
