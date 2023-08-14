function addtextinfo(hfig,str1,str2,str3)




    if numel(str1)==3
        pos1=[0.01,0.88,0.15,.1];
        pos2=[0.16,0.88,0.01,.1];
        pos3=[0.17,0.88,0.10,.1];
        fontsize=0.25;
    else
        pos1=[0.01,0.78,0.14,0.2];
        pos2=[0.15,0.78,0.01,0.2];
        pos3=[0.16,0.78,0.12,0.2];
        fontsize=0.11;
    end
    parentpos=hfig.Position;
    try

        h1=uicontrol('Parent',hfig,'Style','text','Units','Normalized',...
        'Position',pos1,'String',str1,...
        'FontUnits','Normalized','FontSize',fontsize,...
        'HorizontalAlignment','right','Tag','FirstColumn');
    catch
        pos1([1,3])=pos1([1,3]).*parentpos(3);
        pos1([2,4])=pos1([2,4]).*parentpos(4);


        h1=uilabel('Parent',hfig,...
        'Position',pos1,'Text',str1,'FontSize',10,...
        'HorizontalAlignment','right','Tag','FirstColumn');
    end
    try

        h2=uicontrol('Parent',hfig,'Style','text','Units','Normalized',...
        'Position',pos2,'String',str3,...
        'FontUnits','Normalized','FontSize',fontsize,...
        'HorizontalAlignment','center','Tag','SecondColumn');
    catch
        pos2([1,3])=pos2([1,3]).*parentpos(3);
        pos2([2,4])=pos2([2,4]).*parentpos(4);


        h2=uilabel('Parent',hfig,...
        'Position',pos2,'Text',str3,'FontSize',10,...
        'HorizontalAlignment','right','Tag','SecondColumn');
    end
    try

        h3=uicontrol('Parent',hfig,'Style','text','Units','Normalized',...
        'Position',pos3,'String',str2,...
        'FontUnits','Normalized','FontSize',fontsize,...
        'HorizontalAlignment','left','Tag','ThirdColumn');

        hfig.AutoResizeChildren='off';
        hfig.SizeChangedFcn=@sbar;
    catch

        pos3([1,3])=pos3([1,3]).*parentpos(3);
        pos3([2,4])=pos3([2,4]).*parentpos(4);

        h3=uilabel('Parent',hfig,...
        'Position',pos3,'Text',str2,'FontSize',10,...
        'HorizontalAlignment','right','Tag','ThirdColumn');
    end

    val=0.94;
    set(h1,'BackgroundColor',[val,val,val]);
    set(h2,'BackgroundColor',[val,val,val]);
    set(h3,'BackgroundColor',[val,val,val]);
    try
        set(hfig,'InvertHardCopy','off');
    catch
    end


end

function sbar(src,callbackdata)%#ok<INUSD>          

    u1=findobj(gcbo,'Tag','FirstColumn');
    if isempty(u1)
        return;
    end
    u2=findobj(gcbo,'Tag','SecondColumn');
    u3=findobj(gcbo,'Tag','ThirdColumn');
    src.Units='Normalized';
    width=src.Position(3);
    height=src.Position(4);
    ratio=width/height;
    if ratio<0.75&&ratio>0.7
        u1.FontSize=0.07;
        u2.FontSize=0.07;
        u3.FontSize=0.07;
        u1.Visible='on';
        u2.Visible='on';
        u3.Visible='on';
    elseif ratio<0.7
        u1.Visible='off';
        u2.Visible='off';
        u3.Visible='off';
    else
        u1.FontSize=0.09;
        u2.FontSize=0.09;
        u3.FontSize=0.09;
        u1.Visible='on';
        u2.Visible='on';
        u3.Visible='on';
    end

end

