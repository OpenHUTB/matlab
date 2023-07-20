function changeInAxesView(p)







    aTop=p.AngleAtTop;
    temp=p.hAxes.View(1);
    p.hAxes.View=[0,90];
    warning('siglib:polarpattern:ViewInvalid',getString(message('siglib:polarpattern:ViewInvalid')));
    p.AngleAtTop=temp+aTop;
end
