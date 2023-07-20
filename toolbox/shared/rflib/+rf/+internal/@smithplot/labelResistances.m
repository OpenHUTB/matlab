function labelResistances(p)


    values=p.GridValue;
    RR=values(1,:);
    RR=RR(1:end);
    switch lower(p.GridType)
    case{'z','zy'}
        sign=1;
    case{'y','yz'}
        sign=-1;
    end
    xc=(sign*RR)./(1+RR);
    rd=sign./(1+RR);
    xc=xc-rd;
    yc=zeros(size(xc));

    fmt='%g';
    N=numel(RR);
    cstrUser=cell(1,N);
    for i=1:N
        cstrUser{i}=sprintf(fmt,RR(i));
    end

    if ischar(cstrUser)
        cstrUser={cstrUser};
    end

    cstr=cstrUser;








    ht=p.hResistanceText;
    delete(ht);

    angleFontSize=getMagFontSize(p);

    z0=0.294;
    ht=text(...
    xc,yc,...
    z0*ones(size(xc)),cstr,...
    'Parent',p.hAxes,...
    'Tag',sprintf('CircleTicks%d',p.pAxesIndex),...
    'HandleVisibility','off',...
    'HorizontalAlignment','left',...
    'VerticalAlignment','bottom',...
    'FontName',p.FontName,...
    'FontSize',angleFontSize,...
    'Rotation',90,...
    'Clipping','on',...
    'Color',p.pCircleTickLabelColor);
    p.hResistanceText=ht;


    for i=1:numel(xc)
        b=hggetbehavior(ht(i),'Plotedit');
        b.Enable=false;
    end

    overrideResistanceTickLabelVis(p,'default');