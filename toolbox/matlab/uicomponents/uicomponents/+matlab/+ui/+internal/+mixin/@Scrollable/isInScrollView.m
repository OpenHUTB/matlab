function result=isInScrollView(container,component)


























    viewport=getpixelposition(container,true);

    if isa(container,'matlab.ui.Figure')




        viewport(1:2)=container.ScrollableViewportLocation(1:2);
    end



    scrollbars=container.getScrollbarsInset();
    viewport(3:4)=viewport(3:4)-[scrollbars(3),scrollbars(2)];

    componentRelPos=arrayfun(...
    @(c)getpixelposition(c,true),...
    component,'UniformOutput',false);

    result=cellfun(@(p)positionsIntersect(p,viewport),componentRelPos);
end


function result=positionsIntersect(p1,p2)




    positionsDisjoint=(p1(1)+p1(3))<=p2(1)||...
    (p1(2)+p1(4))<=p2(2)||...
    p1(1)>=(p2(1)+p2(3))||...
    p1(2)>=(p2(2)+p2(4));
    result=~positionsDisjoint;
end
