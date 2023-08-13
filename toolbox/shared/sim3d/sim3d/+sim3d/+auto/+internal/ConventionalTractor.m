classdef ConventionalTractor


    properties(Constant=true)
        FrontBumper=struct(...
        'translation',single([7.73,0,0.69]),...
        'rotation',single([0,0,0]),...
        'scale',single([1,1,1]));
        RightMirror=struct(...
        'translation',single([5.41,1.52,1.86]),...
        'rotation',single([0,-pi/2,0]),...
        'scale',single([1,1,1]));
        LeftMirror=struct(...
        'translation',single([5.41,-1.52,1.86]),...
        'rotation',single([0,-pi/2,0]),...
        'scale',single([1,1,1]));
        RearviewMirror=struct(...
        'translation',single([5.74,0,2.52]),...
        'rotation',single([0,0,0]),...
        'scale',single([1,1,1]));
        RearCenter=struct(...
        'translation',single([3.42,0,3.43]),...
        'rotation',single([0,deg2rad(-40),pi]),...
        'scale',single([1,1,1]));
    end

end