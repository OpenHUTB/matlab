function createListeners(p)








    deleteListeners(p);
    par=p.Parent;
    fig=p.hFigure;
    ax=p.hAxes;
    lis=p.hListeners;























    hClaMarker=text(...
    'Parent',ax,...
    'Visible','off',...
    'UserData',p,...
    'Tag','PolariObject');



    lis.ClaMarker=addlistener(hClaMarker,'ObjectBeingDestroyed',@(h,ev)destroyAxesContent(p));

    lis.Destroy=addlistener(ax,'ObjectBeingDestroyed',@(h,ev)destroyAxes(p));



    lis.AxesPos=addlistener(ax,'Position','PostSet',...
    @(h,ev)cacheChangeInAxesPosition(p));
    lis.AxesPos.Enabled=false;

    lis.AxesView=addlistener(ax,'View','PostSet',...
    @(h,ev)changeInAxesView(p));




    lis.AxesHold=addlistener(ax,'NextPlot','PostSet',...
    @(h,ev)changeAxesHoldState(p));










    lprops=addlistener(p,getSetObservableProps(p),...
    'PostSet',@(h,e)propChange(p));
    lprops.Enabled=false;
    lis.PropertyChanges=lprops;











    switch lower(par.Type)
    case 'figure'


        lis.ParentColor=addlistener(fig,'Color','PostSet',...
        @(h,ev)i_changeAngleTickLabelColor(p));


        lis.ParentResize=addlistener(fig,...
        'SizeChanged',@(h,ev)resizeAxes(p));
        lis.ParentResize.Enabled=false;
        if matlab.ui.internal.isUIFigure(par)
            par.AutoResizeChildren='off';
        end
    case{'uipanel','uicontainer'}


        lis.ParentColor=addlistener(par,...
        'BackgroundColor','PostSet',...
        @(h,ev)i_changeAngleTickLabelColor(p));





        lis.ParentResize=addlistener(par,...
        'SizeChanged',@(h,ev)resizeAxes(p));
        lis.ParentResize.Enabled=false;

    otherwise

    end






    e(1)=addlistener(fig,...
    'WindowKeyPress',@(~,ev)FigKeyEvent(p,ev));
    e(1).Enabled=true;

    e(2)=addlistener(fig,...
    'WindowKeyRelease',@(~,ev)FigKeyEvent(p,ev));
    e(2).Enabled=true;
    lis.WindowKeyPressEvents=e;










    kpf=fig.KeyPressFcn;
    if isempty(kpf)
        try %#ok<TRYNC>
            fig.KeyPressFcn=@(~,~)0;
        end
    end









    lisW(1)=addlistener(fig,'WindowMousePress',@(~,ev)mb_Dispatch(p,ev,'down'));
    lisW(2)=addlistener(fig,'WindowMouseMotion',@(~,ev)mb_Dispatch(p,ev,'motion'));
    lisW(3)=addlistener(fig,'WindowMouseRelease',@(~,ev)mb_Dispatch(p,ev,'up'));
    lisW(4)=addlistener(fig,'WindowScrollWheel',@(~,ev)mb_Dispatch(p,ev,'scroll'));



    lis.WindowButtonEvents=lisW;



    lis.LegendBeingDestroyed=[];
    lis.LegendStringChanged=[];
    lis.LegendMarkedClean=[];

    p.hListeners=lis;
