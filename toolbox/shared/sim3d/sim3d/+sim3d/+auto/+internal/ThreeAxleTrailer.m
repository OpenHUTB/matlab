classdef ThreeAxleTrailer




    properties(Constant=true)
        RearCenter=struct(...
        'translation',single([-12.0,0,4.0]),...
        'rotation',single([0,deg2rad(-15),pi]),...
        'scale',single([1,1,1]));
    end

end