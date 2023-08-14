function bounds=levelOneBounds(category)




    switch category
    case "A"
        bounds{1}=[...
        1,1;
        3.5,1;
        100,5.5;
        ];

        bounds{2}=[...
        100,19;
        1,1.8;
        ];
    case "B"
        bounds=Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.levelOneBounds("A");
        bounds{1}=[...
        1,0.3;
        100,2.9;
        ];
    case "C"
        bounds=Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.levelOneBounds("A");
        bounds(1)=[];
        bounds{2}=[
        3,0.7;
        100,4;
        ];
        bounds{3}=[...
        2,Aero.internal.math.loginterp(bounds{1}(:,1),bounds{1}(:,2),2);
        2,0.7;
        3,0.7;
        ];
        bounds{4}=[...
        2.7,Aero.internal.math.loginterp(bounds{1}(:,1),bounds{1}(:,2),2.7);
        2.7,0.88;
        Aero.internal.math.loginterp(bounds{2}(:,2),bounds{2}(:,1),0.88),0.88
        ];
    end
end