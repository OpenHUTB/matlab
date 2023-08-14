function hout=copy(h),




    hout=Simulink.FrameInfo;

    set(hout,'Framesize',h.Framesize,...
    'FrameStart',h.FrameStart,...
    'FrameEnd',h.FrameEnd,...
    'FrameIncrement',h.FrameIncrement);
