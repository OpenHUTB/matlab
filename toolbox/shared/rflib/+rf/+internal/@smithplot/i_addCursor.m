function m=i_addCursor(p,pt,datasetIndex)

















    hold on;













    ht_i=plot3(pt(1,1),pt(1,2),pt(1,3),...
    'Parent',p.hAxes,...
    'Tag',sprintf('SmithPoint%d',p.pAxesIndex),...
    'Marker','*',...
    'Color','r');


    hold off;
    set(ht_i,'uicontextmenu',p.UIContextMenu_Point);








