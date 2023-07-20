function MutualInductanceCback(block)






    switch get_param(block,'TypeOfMutual')

    case 'Two or three windings with equal mutual terms'

        WantThreeWindings=strcmp('on',get_param(block,'ThreeWindings'));
        ports=get_param(block,'ports');
        HaveThreeWindings=ports(7)==3;

        Winding3=get_param(block,'SelfImpedance3');

        if strcmp('0',Winding3)||strcmp('[0]',Winding3)
            set_param(block,'ThreeWindings','off');
            WantThreeWindings=0;
            w2=get_param(block,'SelfImpedance2');
            set_param(block,'SelfImpedance3',w2);
        end

        if WantThreeWindings
            set_param(block,'maskvisibilities',{'on','off','on','on','on','on','on','off','off','on'});
            PlotIcon='plot(x,y+5,x,y+10,x,y+15,bx,by+10,bx,by+15);port_label(''LConn'', 1, ''1'');port_label(''LConn'', 2, ''2'');port_label(''LConn'', 3, ''3'')';
        else
            set_param(block,'maskvisibilities',{'on','off','on','on','on','off','on','off','off','on'});
            PlotIcon='plot(x,y+5,x,y+10,bx,by+11);port_label(''LConn'', 1, ''1'');port_label(''LConn'', 2, ''2'');';
        end
        set_param(block,'MaskDisplay',PlotIcon);

        if WantThreeWindings&&~HaveThreeWindings

            set_param(block,'LConntags',{'a','b','c'});
            set_param(block,'RConntags',{'A','B','C'});

        elseif~WantThreeWindings&&HaveThreeWindings

            set_param(block,'LConntags',{'a','b'});
            set_param(block,'RConntags',{'A','B'});

        end

    case 'Generalized mutual inductance'

        set_param(block,'maskvisibilities',{'on','on','off','off','off','off','off','on','on','on'});

        NumberOfWindings=getSPSmaskvalues(block,{'NumberOfWindings'});
        if isnan(NumberOfWindings)

            return
        end
        RConnTags{1}='A';
        LConnTags{1}='a';
        if NumberOfWindings>1
            RConnTags{2}='B';
            LConnTags{2}='b';
        end
        if NumberOfWindings>2
            RConnTags{3}='C';
            LConnTags{3}='c';
        end
        for i=4:NumberOfWindings
            RConnTags{i}=['R',num2str(i)];
            LConnTags{i}=['L',num2str(i)];
        end

        ports=get_param(block,'ports');
        CurrentNumberOfWindings=ports(7);

        if length(LConnTags)~=CurrentNumberOfWindings
            set_param(block,'LConntags',LConnTags);
            set_param(block,'RConntags',RConnTags);
        end

        PlotIcon='plot(x,y+5,';
        for i=2:NumberOfWindings
            PlotIcon=[PlotIcon,'x,y+',num2str(5*i),','];
        end
        for i=2:NumberOfWindings
            PlotIcon=[PlotIcon,'bx,by+',num2str(5*i),','];
        end
        PlotIcon(end)=')';
        set_param(block,'MaskDisplay',PlotIcon);
    end