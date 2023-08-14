function[axispt1,axispt2,ang]=getAxisPoints(obj)








    listEdgeX={'spiralRectangular','invertedLcoplanar','invertedFcoplanar','slot'};
    if any(strcmpi(class(obj.Exciter),listEdgeX))

        axispt1=[0,0,0;0,0,0];axispt2=[0,1,0;0,0,1];
        ang=[90,90];
    elseif strcmpi(class(obj.Exciter),'spiralArchimedean')&&obj.Exciter.NumArms==2
        axispt1=[0,0,0;0,0,0];axispt2=[0,1,0;0,0,1];
        ang=[90,-45];
    else

        axispt1=[0,0,0];axispt2=[0,1,0];
        ang=90;
    end
end
