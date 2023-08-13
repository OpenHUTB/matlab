classdef TwoAxleTrailer

    properties(Constant=true)
        RearCenter=struct(...
        'translation',single([-15.5,0,4.15]),...
        'rotation',single([0,deg2rad(-15),pi]),...
        'scale',single([1,1,1]));
    end

end