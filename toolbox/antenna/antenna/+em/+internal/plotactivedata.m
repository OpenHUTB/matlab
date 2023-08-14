function plotactivedata(data,freq,isvswr)



    error1=[
    219,219,219,225,219,219,219,219,219,219,219,219,219,219
    219,219,219,219,219,219,219,219,219,219,219,226,219,219
    219,219,219,219,219,219,255,255,219,219,219,219,226,219
    219,219,219,219,219,219,255,255,219,219,219,219,219,219
    219,219,219,219,219,219,255,255,219,219,219,219,219,224
    219,219,219,219,219,219,255,255,219,219,219,219,219,219
    219,219,219,219,219,219,255,255,219,219,219,219,219,219
    219,219,219,219,219,219,255,255,219,219,219,219,219,219
    219,219,219,219,219,219,219,219,219,219,219,219,219,219
    219,219,219,219,219,219,255,255,219,219,219,219,219,219
    219,219,219,219,219,219,219,219,219,219,219,219,219,219
    219,219,219,217,219,219,219,219,219,219,219,219,219,219
    219,219,219,219,219,219,219,219,219,219,219,219,219,219];


    error2=[
    60,60,60,60,60,60,60,60,60,60,60,60,60,60
    60,60,60,60,60,60,60,60,60,60,60,60,60,60
    60,60,60,60,60,60,255,255,60,60,60,60,60,60
    60,60,60,60,60,60,255,255,60,60,60,60,60,60
    60,60,60,60,60,60,255,255,60,60,60,60,60,60
    60,60,60,60,60,60,255,255,60,60,60,60,60,60
    60,60,60,60,60,60,255,255,60,60,60,60,60,60
    60,60,60,60,60,60,255,255,60,60,60,60,60,60
    60,60,60,60,60,60,60,60,60,60,60,60,60,60
    60,60,60,60,60,60,255,255,60,60,60,60,60,60
    60,60,60,60,60,60,60,60,60,60,60,60,60,60
    60,60,60,60,60,60,60,60,60,60,60,60,60,60
    60,60,60,60,60,60,60,60,60,60,60,60,60,60];


    error3=[
    48,48,48,48,48,48,48,48,48,48,48,48,48,48
    48,48,48,48,48,48,48,48,48,48,48,48,48,48
    48,48,48,48,48,48,255,255,48,48,48,48,48,48
    48,48,48,48,48,48,255,255,48,48,48,48,48,48
    48,48,48,48,48,48,255,255,48,48,48,48,48,48
    48,48,48,48,48,48,255,255,48,48,48,48,48,48
    48,48,48,48,48,48,255,255,48,48,48,48,48,48
    48,48,48,48,48,48,255,255,48,48,48,48,48,48
    48,48,48,48,48,48,48,48,48,48,48,48,48,48
    48,48,48,48,48,48,255,255,48,48,48,48,48,48
    48,48,48,48,48,48,48,48,48,48,48,48,48,48
    48,48,48,48,48,48,48,48,48,48,48,48,48,48
    48,48,48,48,48,48,48,48,48,48,48,48,48,48];

    if nargin==2
        isvswr=0;
    end

    error=zeros(13,14,3,'uint8');
    error(:,:,1)=error1;
    error(:,:,2)=error2;
    error(:,:,3)=error3;
    numelems=size(data,2);
    hfig=gcf;

    clf(hfig);
    vals=cell(1,numelems);
    for m=1:numelems
        vals{m}=sprintf('element %d',m);
    end
    ax=gca(hfig);
    haxes=ax;
    haxes.Position=[0.12,0.22,0.82,0.72];
    freq=unique(freq,'stable');
    [freqval,~,U]=engunits(freq);
    if~isreal(data)
        em.internal.plotdatacomplex(freqval,data,U,1,vals(1),...
        haxes,numelems);
    else
        em.internal.plotdatareal(freqval,data,U,1,vals(1),...
        haxes,numelems,isvswr);
    end

    try
        hedit=uicontrol(hfig,'style','edit','unit','normalized',...
        'position',[0.22,0.05,0.15,0.06],'String',1,'Tag','ElementNumber');

        str=sprintf('Elements (%s-%s)',num2str(1),num2str(numelems));
        uicontrol(hfig,'style','text','unit','normalized','position',...
        [0.08,0.05,0.13,0.05],'String',str);
        herror=uicontrol(hfig,'Style','checkbox',...
        'HorizontalAlignment','right','Tag','Error',...
        'Visible','off','position',[210,25,15,20]);
        set(hedit,'Callback',{@myplotfcn,haxes,data,...
        freqval,U,vals(1:numelems),numelems,herror,error,isvswr});
    catch
        hedit=uieditfield(hfig,'Value','1','Tag','ElementNumber','Position',[230,25,100,22]);

        str=sprintf('Elements (%s-%s)',num2str(1),num2str(numelems));
        uilabel(hfig,'position',...
        [110,25,100,22],'Text',str);

        herror=uiimage(hfig,...
        'HorizontalAlignment','right','Tag','Error',...
        'Visible','off','position',[210,25,15,20]);
        set(hedit,'ValueChangedFcn',{@myplotfcn,haxes,data,...
        freqval,U,vals(1:numelems),numelems,herror,error,isvswr});

    end

    try
        if antennashared.internal.figureForwardState(hfig)&&~matlab.ui.internal.isUIFigure(hfig)
            shg;
        end
    catch
    end

    function myplotfcn(hobj,~,haxes,data,freq,U,legstr,numelems,herror,error,isvswr)


        try
            val=evalin('base',hobj.String);
        catch
            val=evalin('base',hobj.Value);
        end
        try

            validateattributes(val,{'numeric'},{'nonempty',...
            'finite','real','positive','vector','<=',numelems});
            herror.Visible='off';
            try
                if isequal(hobj.ForegroundColor,[1,0,0])
                    hobj.ForegroundColor=[0,0,0];
                    hobj.BackgroundColor=[1,1,1];
                    hobj.Tooltip='';
                end
            catch
                if isequal(hobj.FontColor,[1,0,0])
                    hobj.FontColor=[0,0,0];
                    hobj.BackgroundColor=[1,1,1];
                    hobj.Tooltip='';
                end
            end

            if~isreal(data)
                em.internal.plotdatacomplex(freq,data,U,val,...
                legstr(val),haxes,numelems);
            else
                em.internal.plotdatareal(freq,data,U,val,...
                legstr(val),haxes,numelems,isvswr);
            end
        catch ME
            try
                hobj.ForegroundColor='r';
            catch
                hobj.FontColor='r';
            end
            hobj.BackgroundColor=[0.999,0.9,0.9];
            hobj.Tooltip=ME.message;

            herror.Visible='on';
            if strcmpi(herror.Type,'uiimage')
                set(herror,'ImageSource',error);
            else
                set(herror,'CData',error);
            end
            herror.Tooltip=ME.message;
        end
    end

end
