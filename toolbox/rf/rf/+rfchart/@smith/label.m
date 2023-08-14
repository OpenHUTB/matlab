function label(h,src,eventData)







    nlablehandles=length(h.LabelHandles);
    for k=1:nlablehandles
        set(h.LabelHandles(k),'Visible','off');
    end


    values=get(h,'Values');
    RR=values(1,:);
    XX=values(1,:);
    Axes=get(h,'Axes');
    tc=get(h,'LabelColor');
    fs=get(h,'LabelSize');
    tv=get(h,'LabelVisible');
    if strcmpi(tv,'off')
        tv='off';
    elseif strcmpi(tv,'on')
        tv='on';
    else
        tv='on';
        warning(message('rf:rfchart:smith:label:WrongSettingforVisible'));
    end


    format='%.1f';
    positiveformat='+j%.1f';
    negativeformat='-j%.1f';

    ts=[];

    switch lower(get(h,'Type'))
    case{'z','zy'}
        ts=labelchart(RR,XX,Axes,tc,format,positiveformat,...
        negativeformat,tv,fs,1);
    case{'y','yz'}
        ts=labelchart(RR,XX,Axes,tc,format,positiveformat,...
        negativeformat,tv,fs,-1);
    end
    set(h,'LabelHandles',ts);


    function ts=labelchart(RR,XX,Axes,tc,format,positiveformat,...
        negativeformat,tv,fs,sign)


        index=0;
        for rcircle=RR
            index=index+1;
            xc=sign*rcircle/(1+rcircle);
            rd=sign/(1+rcircle);
            ts(index)=text('Position',[xc-rd,0],...
            'String',num2str(rcircle,format),'Parent',Axes,...
            'horizontalalignment','left','VerticalAlignment','bottom',...
            'color',tc,'Visible',tv,'FontSize',fs,'Rotation',90);
        end
        index1=length(RR);
        index2=2*length(RR);
        for xcircle=XX
            index1=index1+1;
            index2=index2+1;
            alpha_xx=2*atan(1/xcircle);
            ts(index1)=text(...
            'Position',[1.1*sign*cos(alpha_xx),1.1*sign*sin(alpha_xx)],...
            'String',num2str(xcircle,positiveformat),'Parent',Axes,...
            'horizontalalignment','center','VerticalAlignment','middle',...
            'color',tc,'Visible',tv,'FontSize',fs);
            ts(index2)=text(...
            'Position',[1.1*sign*cos(alpha_xx),-1.1*sign*sin(alpha_xx)],...
            'String',num2str(xcircle,negativeformat),'Parent',Axes,...
            'horizontalalignment','center','VerticalAlignment','middle',...
            'color',tc,'Visible',tv,'FontSize',fs);
        end
        index1=index2+1;
        index2=index2+2;
        ts(index1)=text('Position',[-1.1*sign,0],'String','0.0',...
        'Parent',Axes,'horizontalalignment','center',...
        'VerticalAlignment','middle','color',tc,'Visible',tv,...
        'FontSize',fs);
        ts(index2)=text('Position',[1.1*sign,0],'String','\infty',...
        'Parent',Axes,'horizontalalignment','center',...
        'VerticalAlignment','middle','color',tc,'Visible',tv,...
        'FontSize',fs);
