function circletip(hdata,hLines,type,info,hsm)






    if isa(hsm,'rf.internal.smithplot')
        hLines=hsm.hDataLine(end);
    end
    info.z0=get(hdata,'Z0');
    nhLines=numel(hLines);
    switch lower(type)
    case 'stab'
        for k=1:nhLines
            hBehavior=hggetbehavior(hLines(k),'DataCursor');
            set(hBehavior,'UpdateFcn',...
            {@localStringFcnStab,hLines(k),info,hsm});
        end

    case 'ga'
        for k=1:nhLines
            hBehavior=hggetbehavior(hLines(k),'DataCursor');
            set(hBehavior,'UpdateFcn',...
            {@localStringFcnGa,hLines(k),info,hsm});
        end

    case 'gp'
        for k=1:nhLines
            hBehavior=hggetbehavior(hLines(k),'DataCursor');
            set(hBehavior,'UpdateFcn',...
            {@localStringFcnGp,hLines(k),info,hsm});
        end

    case 'nf'
        for k=1:nhLines
            hBehavior=hggetbehavior(hLines(k),'DataCursor');
            set(hBehavior,'UpdateFcn',...
            {@localStringFcnGa,hLines(k),info,hsm});
        end

    case{'r','x','g','b','gamma'}
        for k=1:nhLines
            hBehavior=hggetbehavior(hLines(k),'DataCursor');
            set(hBehavior,'UpdateFcn',...
            {@localStringFcnR,hLines(k),info,hsm});
        end
    end


    function[str]=localStringFcnGp(hHost,hDataCursor,hLine,info,hsm)


        sparam=info.sparam;
        center=info.center;
        radius=info.radius;
        matchingcircle=info.matchingcircle;
        if isa(hsm,'rf.internal.smithplot')
            charttype=hsm.GridType;
        else
            charttype=get(hsm,'Type');
        end
        pos=get(hDataCursor,'Position');


        gammal=pos(1)+1i*pos(2);
        normzl=gamma2z(gammal,1);
        input_gamma=gammain(sparam,1,normzl);
        gp=10*log10(powergain(sparam,1,normzl,'Gp'));


        xdata=real(input_gamma);ydata=-imag(input_gamma);


        idx=current_circle(center,radius,gammal);
        xcircle=real(matchingcircle{idx});
        ycircle=imag(matchingcircle{idx});


        str{1}=sprintf('%s = %5.2f [dB]','Gp',gp);
        str{2}=getComplexStringMA(gammal,'GammaL');
        str{3}=getComplexStringMA(input_gamma,'GammaIn');
        normyl=g2y(gammal);
        switch lower(charttype)
        case 'z'
            str{4}=getComplexStringRI(normzl,'ZL',info.z0,'ohms');
        case 'y'
            str{4}=getComplexStringRI(normyl,'YL',1/info.z0,'S');
        otherwise
            str{4}=getComplexStringRI(normzl,'ZL',info.z0,'ohms');
            str{5}=getComplexStringRI(normyl,'YL',1/info.z0,'S');
        end

        Indicator=get_indicator(hLine);
        set(Indicator(1),'xdata',xdata,'ydata',ydata,'Marker','*')
        set(Indicator(2),'xdata',xcircle,'ydata',ycircle,'LineStyle',':')
        setappdata(hLine,'Indicator',Indicator)

        hList=addlistener(hHost,'ObjectBeingDestroyed',...
        @(h,e)deleteDataTipFcn(h,e,hLine));
        setappdata(hLine,'Listener',hList)


        function[str]=localStringFcnGa(hHost,hDataCursor,hLine,info,hsm)


            sparam=info.sparam;
            nfmin=info.nfmin;
            gammaopt=info.gammaopt;
            rn=info.rn;
            center=info.center;
            radius=info.radius;
            matchingcircle=info.matchingcircle;
            if isa(hsm,'rf.internal.smithplot')
                charttype=hsm.GridType;
            else
                charttype=get(hsm,'Type');
            end
            pos=get(hDataCursor,'Position');


            gammas=pos(1)+1i*pos(2);
            if~isempty(nfmin)&&~isempty(gammaopt)&&~isempty(rn)
                nf=calcnf(nfmin,gammaopt,rn,gammas);
            else
                nf=[];
            end
            normzs=gamma2z(gammas,1);
            output_gamma=gammaout(sparam,1,normzs);
            ga=10*log10(powergain(sparam,1,normzs,'Ga'));

            xdata=real(output_gamma);ydata=-imag(output_gamma);


            idx=current_circle(center,radius,gammas);
            xcircle=real(matchingcircle{idx});
            ycircle=imag(matchingcircle{idx});


            str{1}=sprintf('%s = %5.2f [dB]','Ga',ga);
            if~isempty(nf)
                str{2}=sprintf('%s = %5.2f [dB]','NF',nf);
                k=2;
            else
                k=1;
            end
            str{k+1}=getComplexStringMA(gammas,'GammaS');
            str{k+2}=getComplexStringMA(output_gamma,'GammaOut');
            normys=g2y(gammas);
            switch lower(charttype)
            case 'z'
                str{k+3}=getComplexStringRI(normzs,'ZS',info.z0,'ohms');
            case 'y'
                str{k+3}=getComplexStringRI(normys,'YS',1/info.z0,'S');
            otherwise
                str{k+3}=getComplexStringRI(normzs,'ZS',info.z0,'ohms');
                str{k+4}=getComplexStringRI(normys,'YS',1/info.z0,'S');
            end

            Indicator=get_indicator(hLine);
            set(Indicator(1),'xdata',xdata,'ydata',ydata,'Marker','*')
            set(Indicator(2),'xdata',xcircle,'ydata',ycircle,'LineStyle',':')
            setappdata(hLine,'Indicator',Indicator)

            hList=addlistener(hHost,'ObjectBeingDestroyed',...
            @(h,e)deleteDataTipFcn(h,e,hLine));
            setappdata(hLine,'Listener',hList)


            function[str]=localStringFcnR(hHost,hDataCursor,hLine,info,hsm)


                if isa(hsm,'rf.internal.smithplot')
                    charttype=hsm.GridType;
                else
                    charttype=get(hsm,'Type');
                end
                pos=get(hDataCursor,'Position');

                gammal=pos(1)+1i*pos(2);


                str{1}=getComplexStringMA(gammal,'Gamma');
                z=gamma2z(gammal,1);
                y=g2y(gammal);
                switch lower(charttype)
                case 'z'
                    str{2}=getComplexStringRI(z,'Z',info.z0,'ohms');
                case 'y'
                    str{2}=getComplexStringRI(y,'Y',1/info.z0,'S');
                otherwise
                    str{2}=getComplexStringRI(z,'Z',info.z0,'ohms');
                    str{3}=getComplexStringRI(y,'Y',1/info.z0,'S');
                end


                function[str]=localStringFcnStab(hHost,hDataCursor,hLine,info,hsm)


                    if isa(hsm,'rf.internal.smithplot')
                        charttype=hsm.GridType;
                    else
                        charttype=get(hsm,'Type');
                    end
                    value=info.value;
                    pos=get(hDataCursor,'Position');

                    gammal=pos(1)+1i*pos(2);

                    z=gamma2z(gammal,1);
                    y=g2y(gammal);

                    if strcmpi(value,'in')||strcmpi(value,'source')
                        gammastr='GammaS';
                        zstr='ZS';
                        ystr='YS';
                    else
                        gammastr='GammaL';
                        zstr='ZL';
                        ystr='YL';
                    end
                    str{1}=getComplexStringMA(gammal,gammastr);
                    switch lower(charttype)
                    case 'z'
                        str{2}=getComplexStringRI(z,zstr,info.z0,'ohms');
                    case 'y'
                        str{2}=getComplexStringRI(y,ystr,1/info.z0,'S');
                    otherwise
                        str{2}=getComplexStringRI(z,zstr,info.z0,'ohms');
                        str{3}=getComplexStringRI(y,ystr,1/info.z0,'S');
                    end


                    set(info.sregion,'FaceColor',get(hLine,'Color'),'Visible','on')

                    hList=addlistener(hHost,'ObjectBeingDestroyed',...
                    @(h,e)hideStableRegionFcn(h,e,info.sregion));
                    setappdata(hLine,'Listener',hList)


                    function deleteDataTipFcn(hHost,hEventData,hLine,tag)

                        if nargin<4
                            tag='Indicator';
                        end
                        if isappdata(hLine,'Indicator')
                            myindicator=getappdata(hLine,tag);
                            try
                                if numel(myindicator)==2
                                    type=get(myindicator,'Type');
                                end
                                if all(strcmpi(type,'line'))
                                    delete(myindicator);
                                    rmappdata(hLine,tag);
                                    rmappdata(hLine,'Listener');
                                end
                            catch
                            end
                        end


                        function hideStableRegionFcn(hHost,hEventData,hPatch)

                            set(hPatch,'Visible','off')


                            function myindicator=get_indicator(hLine,tag)

                                if nargin<2
                                    tag='Indicator';
                                end
                                need_new_indicator=true;
                                if isappdata(hLine,tag)
                                    myindicator=getappdata(hLine,tag);
                                    try
                                        if numel(myindicator)==2
                                            type=get(myindicator,'Type');
                                        end
                                        if all(strcmpi(type,'line'))
                                            need_new_indicator=false;
                                        end
                                    catch
                                    end
                                end

                                if need_new_indicator
                                    hold_state=ishold;
                                    hold all
                                    myindicator=plot(NaN,[NaN,NaN],'Color',get(hLine,'Color'),...
                                    'HandleVisibility','off');
                                    if~hold_state
                                        hold off
                                    end
                                end


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


                                    function outstr=getComplexStringMA(input,name)

                                        mag=abs(input);ang=angle(input)*180/pi;
                                        outstr=sprintf('%s = |%6.4f|, %4.1f [deg]',name,mag,ang);


                                        function nf=calcnf(nfmin,gopt,rn,gs)

                                            nfmin=(10.^(nfmin/10));
                                            N=abs(gs-gopt)^2/(1-abs(gs)^2);
                                            nf=nfmin+4*rn*N/(abs(1+gopt)^2);
                                            nf=10*log10(nf);


                                            function idx=current_circle(c,r,gamma)

                                                dist=abs(abs(gamma-c)-r);
                                                [dummy,idx]=min(dist);


                                                function y=g2y(g)

                                                    y=(1-g)./(1+g);