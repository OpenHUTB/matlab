function str=figureDataCursorUpdateFcn(p,e)


    if~isempty(e.Target.UserData.Name)
        str=localStringFcn01(e,p);
    else
        str=localStringFcn02(e);
    end



    function[str]=localStringFcn02(hDataCursor)

        hLine=hDataCursor.Target;

        pos=get(hDataCursor,'Position');


        pos=pos(1)+1i*pos(2);


        str{1}=getComplexStringMA(pos,'Magnitude');
        linedata=hDataCursor.Target.UserData;

        if~isempty(linedata.Xname)
            str{2}=getComplexStringFQ(hDataCursor,hLine);
            if~isempty(linedata.OtherInfo)
                str{3}=linedata.OtherInfo;
            end
        end

        function outstr=getComplexStringMA(input,name)

            mag=abs(input);ang=angle(input)*180/pi;
            outstr=sprintf('%s = |%6.4f|, %4.1f [deg]',name,mag,ang);

            function str=localStringFcn01(hDataCursor,p)

                hLine=hDataCursor.Target;

                pos=get(hDataCursor,'Position');

                pos=pos(1)+1i*pos(2);


                lineinfo=get(hLine,'UserData');
                name=lineinfo.Name;

                str{1}=getComplexStringMA(pos,name);
                str{2}=getComplexStringFQ(hDataCursor,hLine);



                if strcmpi(lineinfo.Type,'gamma')
                    str{3}=sprintf('VSWR = %s',num2str(vswr(pos)));
                    z=gamma2z(pos,1);
                    y=g2y(pos);
                    charttype=p.GridType;
                    switch lower(charttype)
                    case 'z'
                        str{4}=getComplexStringRI(z,'Z',lineinfo.Z0,'ohms');
                    case 'y'
                        str{4}=getComplexStringRI(y,'Y',1/lineinfo.Z0,'S');
                    otherwise
                        str{4}=getComplexStringRI(z,'Z',lineinfo.Z0,'ohms');
                        str{5}=getComplexStringRI(y,'Y',1/lineinfo.Z0,'S');
                    end
                end

                function outstr=getComplexStringFQ(hDataCursor,hLine)

                    dindex=get(hDataCursor,'DataIndex');
                    dfactor=get(hDataCursor,'InterpolationFactor');
                    lineinfo=get(hLine,'UserData');
                    xunit=lineinfo.XUnit;
                    xdata=lineinfo.XData;
                    xname=lineinfo.Xname;
                    if abs(dfactor)<=eps
                        xd=xdata(dindex);
                    elseif dfactor<0.0&&dindex>1
                        xd=xdata(dindex)+dfactor*(xdata(dindex)-xdata(dindex-1));
                    elseif dfactor>0.0&&dindex<numel(xdata)
                        xd=xdata(dindex)+dfactor*(xdata(dindex+1)-xdata(dindex));
                    else
                        xd=xdata(dindex);
                    end
                    outstr=sprintf('%s = %s %s',xname,num2str(xd),xunit);


                    function outstr=getComplexStringRI(input,name,z0,units)

                        r=real(input);x=imag(input);
                        if strcmpi(units,'S')
                            units='mS';
                            z0=z0*1000;
                        end
                        if x>0
                            outstr=sprintf('%s = %5.3f + j%5.3f',name,r,x);
                        elseif x<0
                            outstr=sprintf('%s = %5.3f - j%5.3f',name,r,-x);
                        else
                            outstr=sprintf('%s = %5.3f',name,r);
                        end


                        function y=g2y(g)

                            y=(1-g)./(1+g);