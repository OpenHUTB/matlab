function A=cellline(orientation,frameA,frameB)





    if nargin==0
        A.Class='cellline';
        A.LowerChild=[];
        A.UpperChild=[];
        A.Orientation=[];
        A=class(A,'cellline',axischild);
        return
    end

    posA=get(frameA,'Position');
    posB=get(frameB,'Position');

    switch orientation
    case 'horizontal'
        X=[posB(1),posB(1)+posB(3)];
        Y=[posB(2),posB(2)];
        dragconstraint='fixX';
    case 'vertical'
        X=[posB(1),posB(1)];
        Y=[posB(2),posB(2)+posB(4)];
        dragconstraint='fixY';
    end
    l=line(X,Y,'ButtonDownFcn','doclick(gcbo)','Color',[0,0,0]);
    set(l,'PickableParts','all')

    axischildObj=axischild(l);
    axischildObj=set(axischildObj,'DragConstraint',dragconstraint);
    axischildObj=set(axischildObj,'AutoDragConstraint',0);


    set(l,'uicontextmenu','');

    A.Class='cellline';
    A.LowerChild=frameA;
    A.UpperChild=frameB;

    A.Orientation=orientation;
    A=class(A,'cellline',axischildObj);

    AH=scribehandle(A);
    set(frameA,'MaxLine',AH);
    set(frameB,'MinLine',AH);





