function datatip(~,fig,hLines)




    if fig==-1
        fig=gcf;
    end

    nhLines=numel(hLines);
    for k=1:nhLines

        hBehavior=hggetbehavior(hLines(k),'DataCursor');
        lineinfo=get(hLines(k),'UserData');
        switch lineinfo.Type
        case ''
            switch upper(lineinfo.Name)
            case{'S11','LS11'}
                set(hBehavior,'UpdateFcn',{@localStringFcn11,hLines(k)});
            case 'GAMMAIN'
                set(hBehavior,'UpdateFcn',{@localStringFcn11,hLines(k)});
            case{'S22','LS22'}
                set(hBehavior,'UpdateFcn',{@localStringFcn11,hLines(k)});
            case 'GAMMAOUT'
                set(hBehavior,'UpdateFcn',{@localStringFcn11,hLines(k)});
            otherwise
                set(hBehavior,'UpdateFcn',{@localStringFcn10,hLines(k)});
            end
        case 'Budget'
            set(hBehavior,'UpdateFcn',{@localStringFcn5,hLines(k)});
        case 'Polar'
            set(hBehavior,'UpdateFcn',{@localStringFcn6,hLines(k)});
        case 'MixerSpur2'
            set(hBehavior,'UpdateFcn',{@localStringFcn7,hLines(k)});
        case 'MixerSpur3'
            set(hBehavior,'UpdateFcn',{@localStringFcn8,hLines(k)});
        otherwise
            if strncmpi(lineinfo.Name,'S',1)||...
                strncmpi(lineinfo.Name,'GAMMA',5)||...
                strncmpi(lineinfo.Name,'LS',2)||...
                strncmpi(lineinfo.Name,'LargeS',6)
                set(hBehavior,'UpdateFcn',{@localStringFcn2,hLines(k)});
            elseif isempty(lineinfo.YUnit)||strcmpi(lineinfo.YUnit,'NONE')
                set(hBehavior,'UpdateFcn',{@localStringFcn3,hLines(k)});
            else
                set(hBehavior,'UpdateFcn',{@localStringFcn4,hLines(k)});
            end
        end
    end



    hDataCursorTool=datacursormode(fig);
    set(hDataCursorTool,'SnapToDataVertex','off');







    function[str]=localStringFcn2(~,hDataCursor,hLine)

        pos=get(hDataCursor,'Position');
        dindex=get(hDataCursor,'DataIndex');
        dfactor=get(hDataCursor,'InterpolationFactor');

        lineinfo=get(hLine,'UserData');
        name=lineinfo.Name;
        xdata=lineinfo.XData;
        xunit=lineinfo.XUnit;
        xname=lineinfo.Xname;
        yunit=lineinfo.YUnit;
        other=lineinfo.OtherInfo;
        if abs(dfactor)<=eps
            xd=xdata(dindex);
        elseif dfactor<0.0&&dindex>1
            xd=xdata(dindex)+dfactor*(xdata(dindex)-xdata(dindex-1));
        elseif dfactor>0.0&&dindex<numel(xdata)
            xd=xdata(dindex)+dfactor*(xdata(dindex+1)-xdata(dindex));
        else
            xd=xdata(dindex);
        end

        str{1}=sprintf('%s(%s) = %s',yunit,name,num2str(pos(2)));
        str{2}=sprintf('%s = %s %s',xname,num2str(xd),xunit);
        if~isempty(other)
            str{3}=other;
        end

        function[str]=localStringFcn3(~,hDataCursor,hLine)

            pos=get(hDataCursor,'Position');
            dindex=get(hDataCursor,'DataIndex');
            dfactor=get(hDataCursor,'InterpolationFactor');

            lineinfo=get(hLine,'UserData');
            name=lineinfo.Name;
            xdata=lineinfo.XData;
            xunit=lineinfo.XUnit;
            xname=lineinfo.Xname;
            other=lineinfo.OtherInfo;
            if abs(dfactor)<=eps
                xd=xdata(dindex);
            elseif dfactor<0.0&&dindex>1
                xd=xdata(dindex)+dfactor*(xdata(dindex)-xdata(dindex-1));
            elseif dfactor>0.0&&dindex<numel(xdata)
                xd=xdata(dindex)+dfactor*(xdata(dindex+1)-xdata(dindex));
            else
                xd=xdata(dindex);
            end

            str{1}=sprintf('%s = %s',name,num2str(pos(2)));
            str{2}=sprintf('%s = %s %s',xname,num2str(xd),xunit);
            if~isempty(other)
                str{3}=other;
            end

            function[str]=localStringFcn4(~,hDataCursor,hLine)

                pos=get(hDataCursor,'Position');
                dindex=get(hDataCursor,'DataIndex');
                dfactor=get(hDataCursor,'InterpolationFactor');

                lineinfo=get(hLine,'UserData');
                name=lineinfo.Name;
                xdata=lineinfo.XData;
                xunit=lineinfo.XUnit;
                xname=lineinfo.Xname;
                yunit=lineinfo.YUnit;
                other=lineinfo.OtherInfo;
                if abs(dfactor)<=eps
                    xd=xdata(dindex);
                elseif dfactor<0.0&&dindex>1
                    xd=xdata(dindex)+dfactor*(xdata(dindex)-xdata(dindex-1));
                elseif dfactor>0.0&&dindex<numel(xdata)
                    xd=xdata(dindex)+dfactor*(xdata(dindex+1)-xdata(dindex));
                else
                    xd=xdata(dindex);
                end

                str{1}=sprintf('%s = %s [%s]',name,num2str(pos(2)),yunit);
                str{2}=sprintf('%s = %s %s',xname,num2str(xd),xunit);
                if~isempty(other)
                    str{3}=other;
                end

                function[str]=localStringFcn5(~,hDataCursor,hLine)

                    pos=get(hDataCursor,'Position');
                    dindex=get(hDataCursor,'DataIndex');
                    dfactor=get(hDataCursor,'InterpolationFactor');

                    lineinfo=get(hLine,'UserData');
                    name=lineinfo.Name;
                    xdata=lineinfo.XData;
                    xunit=lineinfo.XUnit;
                    xname=lineinfo.Xname;
                    yunit=lineinfo.YUnit;
                    other=lineinfo.OtherInfo;
                    if abs(dfactor)<=eps
                        xd=xdata(dindex);
                        if isnan(xd)
                            nxdata=numel(xdata);
                            for k=2:nxdata
                                if isnan(xdata(k))
                                    len=k-1;
                                    break
                                end
                            end
                            if(dindex/len+1)>=pos(2)
                                xd=xdata(dindex+1);
                            else
                                xd=xdata(dindex-1);
                            end
                        end
                    elseif dfactor<0.0&&dindex>1
                        if isnan(xdata(dindex))
                            xd=xdata(dindex-1);
                        elseif isnan(xdata(dindex-1))
                            xd=xdata(dindex);
                        else
                            xd=xdata(dindex)+dfactor*(xdata(dindex)-xdata(dindex-1));
                        end
                    elseif dfactor>0.0&&dindex<numel(xdata)
                        if isnan(xdata(dindex))
                            xd=xdata(dindex+1);
                        elseif isnan(xdata(dindex+1))
                            xd=xdata(dindex);
                        else
                            xd=xdata(dindex)+dfactor*(xdata(dindex+1)-xdata(dindex));
                        end
                    else
                        xd=xdata(dindex);
                        if isnan(xd)
                            nxdata=numel(xdata);
                            for k=2:nxdata
                                if isnan(xdata(k))
                                    len=k-1;
                                    break
                                end
                            end
                            if(dindex/len+1)>=pos(2)
                                xd=xdata(dindex+1);
                            else
                                xd=xdata(dindex-1);
                            end
                        end
                    end

                    str{1}=sprintf('%s = %s[%s]',name,num2str(pos(3)),yunit);
                    str{2}=sprintf('%s = %s %s',xname,num2str(xd),xunit);
                    str{3}=sprintf('%s = %s','Stage of cascade',num2str(pos(2)));
                    if~isempty(other)
                        str{4}=other;
                    end

                    function[str]=localStringFcn6(~,hDataCursor,hLine)

                        pos=get(hDataCursor,'Position');
                        dindex=get(hDataCursor,'DataIndex');
                        dfactor=get(hDataCursor,'InterpolationFactor');

                        lineinfo=get(hLine,'UserData');
                        name=lineinfo.Name;
                        xdata=lineinfo.XData;
                        xunit=lineinfo.XUnit;
                        xname=lineinfo.Xname;
                        other=lineinfo.OtherInfo;
                        if abs(dfactor)<=eps
                            xd=xdata(dindex);
                        elseif dfactor<0.0&&dindex>1
                            xd=xdata(dindex)+dfactor*(xdata(dindex)-xdata(dindex-1));
                        elseif dfactor>0.0&&dindex<numel(xdata)
                            xd=xdata(dindex)+dfactor*(xdata(dindex+1)-xdata(dindex));
                        else
                            xd=xdata(dindex);
                        end

                        if pos(2)>0.0
                            str{1}=sprintf('%s = %s + j%s',...
                            name,num2str(pos(1)),num2str(pos(2)));
                        else
                            str{1}=sprintf('%s = %s - j%s',...
                            name,num2str(pos(1)),num2str(-pos(2)));
                        end
                        str{2}=sprintf('%s = %s %s',xname,num2str(xd),xunit);
                        if~isempty(other)
                            str{3}=other;
                        end

                        function[str]=localStringFcn7(~,hDataCursor,hLine)

                            pos=get(hDataCursor,'Position');
                            dindex=get(hDataCursor,'DataIndex');

                            lineinfo=get(hLine,'UserData');
                            xdata=lineinfo.XData;
                            xunit=lineinfo.XUnit;
                            yunit=lineinfo.YUnit;
                            indexes=lineinfo.Indexes;
                            other=lineinfo.OtherInfo;
                            xd=xdata(dindex);

                            str{1}=sprintf('%s = %s %s',indexes{dindex},num2str(xd),xunit);
                            str{2}=sprintf('%s %s',num2str(pos(2)),yunit);
                            if~isempty(other)
                                str{3}=other;
                            end

                            function[str]=localStringFcn8(~,hDataCursor,hLine)

                                pos=get(hDataCursor,'Position');
                                dindex=get(hDataCursor,'DataIndex');

                                lineinfo=get(hLine,'UserData');
                                xdata=lineinfo.XData;
                                xunit=lineinfo.XUnit;
                                yunit=lineinfo.YUnit;
                                indexes=lineinfo.Indexes;
                                other=lineinfo.OtherInfo;
                                xd=xdata(int16(dindex));

                                str{1}=sprintf('%s = %s %s',indexes{dindex},num2str(xd),xunit);
                                str{2}=sprintf('%s [%s]',num2str(pos(3)),yunit);
                                if~isempty(other)
                                    str{3}=other;
                                end

                                function[str]=localStringFcn10(~,hDataCursor,hLine)

                                    pos=get(hDataCursor,'Position');
                                    dindex=get(hDataCursor,'DataIndex');
                                    dfactor=get(hDataCursor,'InterpolationFactor');

                                    lineinfo=get(hLine,'UserData');
                                    name=lineinfo.Name;
                                    xdata=lineinfo.XData;
                                    xunit=lineinfo.XUnit;
                                    xname=lineinfo.Xname;
                                    other=lineinfo.OtherInfo;
                                    if abs(dfactor)<=eps
                                        xd=xdata(dindex);
                                    elseif dfactor<0.0&&dindex>1
                                        xd=xdata(dindex)+dfactor*(xdata(dindex)-xdata(dindex-1));
                                    elseif dfactor>0.0&&dindex<numel(xdata)
                                        xd=xdata(dindex)+dfactor*(xdata(dindex+1)-xdata(dindex));
                                    else
                                        xd=xdata(dindex);
                                    end

                                    if pos(2)>0.0
                                        str{1}=sprintf('%s = %s + j%s',...
                                        name,num2str(pos(1)),num2str(pos(2)));
                                    else
                                        str{1}=sprintf('%s = %s - j%s',...
                                        name,num2str(pos(1)),num2str(-pos(2)));
                                    end
                                    str{2}=sprintf('%s = %s %s',xname,num2str(xd),xunit);
                                    if~isempty(other)
                                        str{3}=other;
                                    end

                                    function str=localStringFcn11(~,hDataCursor,hLine)


                                        pos=get(hDataCursor,'Position');
                                        dindex=get(hDataCursor,'DataIndex');
                                        dfactor=get(hDataCursor,'InterpolationFactor');


                                        lineinfo=get(hLine,'UserData');
                                        name=lineinfo.Name;
                                        xdata=lineinfo.XData;
                                        xunit=lineinfo.XUnit;

                                        xname=lineinfo.Xname;
                                        other=lineinfo.OtherInfo;
                                        if abs(dfactor)<=eps
                                            xd=xdata(dindex);
                                        elseif dfactor<0.0&&dindex>1
                                            xd=xdata(dindex)+dfactor*(xdata(dindex)-xdata(dindex-1));
                                        elseif dfactor>0.0&&dindex<numel(xdata)
                                            xd=xdata(dindex)+dfactor*(xdata(dindex+1)-xdata(dindex));
                                        else
                                            xd=xdata(dindex);
                                        end


                                        data=pos(1)+1i*pos(2);
                                        str{1}=sprintf('%s = |%s|, %s [deg]',name,num2str((abs(data))),...
                                        num2str(angle(data)*180/pi));
                                        str{2}=sprintf('VSWR = %s',num2str(vswr(data)));
                                        str{3}=sprintf('%s = %s %s',xname,num2str(xd),xunit);
                                        if~isempty(other)
                                            str{4}=other;
                                        end