function bounds=levelTwoBounds(category)




    switch category
    case "A"
        bounds{1}=[...
        1,0.6;
        2.5,0.6;
        100,4;
        ];

        bounds{2}=[...
        100,33;
        1,3.2;
        ];
    case "B"
        bounds=Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.levelTwoBounds("A");
        bounds{1}=[...
        1,0.2;
        100,1.9;
        ];
    case "C"
        lvlone=Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.levelOneBounds("C");
        lvltwo=Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.levelTwoBounds("A");

        bounds(1)=Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.levelThreeBounds("C");




        p2=Aero.internal.math.loginterp(bounds{1}(:,2),bounds{1}(:,1),0.4);

        bounds{2}=[...
        lvltwo{2}(2,:);
        1,0.4;
        p2,0.4;
        ];

        bounds{3}=[...
        p2,Aero.internal.math.loginterp(lvlone{1}(:,1),lvlone{1}(:,2),p2);
        p2,0.6;
        Aero.internal.math.loginterp(bounds{1}(:,2),bounds{1}(:,1),0.6),0.6;
        ];
        bounds(4)=lvltwo(2);
    end

end