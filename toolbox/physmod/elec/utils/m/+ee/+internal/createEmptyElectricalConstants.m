function ElectricalConstants=createEmptyElectricalConstants()%#codegen




    coder.allowpcode('plain')

    ElectricalConstants=struct('a',complex(0),...
    'a2',complex(0),...
    'C',complex(zeros(3,3)),...
    'A',complex(zeros(3,3)),...
    'j',complex(0),...
    'oneOverSqrt2',0,...
    'oneOverSqrt3',0,...
    'shift_3ph',zeros(1,3),...
    'sqrt2',0,...
    'sqrt2OverSqrt3',0,...
    'sqrt3',0,...
    'sqrt3OverSqrt2',0,...
    'twoPi',0,...
    'twoPiOver3',0);

end
