function[lvltwo,lvlthree,joint]=levelTwoAndThreeBounds(category)




    switch category
    case "A"

        joint{1}=[...
        2.5,0.6;
        100,4;
        ];
        joint{2}=[];


        lvltwo{1}=[...
        1,0.6;
        2.5,0.6;
        ];

        lvltwo{2}=[...
        100,33;
        1,3.2;
        ];


        lvlthree{1}=[...
        1,0.38;
        2.5,0.6;
        ];

        lvlthree{2}=[];
    case "B"


        joint{1}=[...
        1,0.2;
        100,1.9;
        ];
        joint{2}=[];



        lvltwo=Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.levelTwoBounds("A");
        lvltwo(1)=[];



        lvlthree{1}=[];
    case "C"
        lvltwo=Aero.internal.FlyingQualities.MIL8785C.Longitudinal.ShortPeriod.levelTwoBounds("C");

        joint=lvltwo(1);
        lvltwo(1)=[];



        lvlthree{1}=[];
    end
end