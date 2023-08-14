function pass=passcode(username,isRetry)






















    persistent lastUser lastPasscode timestamp

    if isempty(username)
        lastUser='';
        lastPasscode='';
        timestamp=0;
        pass='';
        return;
    end

    if nargin<2||~isRetry
        if~isempty(lastUser)&&~isempty(lastPasscode)
            if strcmp(username,lastUser)
                if~hasTimedOut(timestamp)
                    pass=lastPasscode;
                    timestamp=now();
                    return;
                end
            end
        end
    end

    if strcmp(username,'mw_automated_test')
        pass=confuse('matlab',username);
        return;
    end

    ScreenSize=get(0,'ScreenSize');
    hfig=figure('Menubar','none',...
    'Units','Pixels',...
    'Resize','off',...
    'NumberTitle','off',...
    'Name',getString(message('Slvnv:oslc:LoginPassword')),...
    'Position',[(ScreenSize(3)-250)/2,(ScreenSize(4)-75)*2/3,250,75],...
    'Color',[0.95,0.95,0.95],...
    'WindowStyle','modal');
    huser=uicontrol('Parent',hfig,...
    'Style','Text',...
    'Tag','uname',...
    'Units','Pixels','Position',[0,45,250,20],...
    'FontSize',8,...
    'String',['OSLC login password for ',username,':'],...
    'ForeGroundColor',[0,0,0],...
    'BackGroundColor',[0.95,0.95,0.95]);%#ok<NASGU>
    hedit=uicontrol('Parent',hfig,...
    'Style','Edit',...
    'Enable','inactive',...
    'Units','Pixels','Position',[49,28,152,22],...
    'FontSize',12,...
    'String',[],...
    'BackGroundColor',[0.7,0.7,0.7]);
    hpass=uicontrol('Parent',hfig,...
    'Style','Text',...
    'Tag','password',...
    'Units','Pixels','Position',[51,30,148,18],...
    'FontSize',12,...
    'String','|',...
    'BackGroundColor',[1,1,1]);
    hwarn=uicontrol('Parent',hfig,...
    'Style','Text',...
    'Tag','error',...
    'Units','Pixels','Position',[50,2,150,20],...
    'FontSize',8,...
    'String','character not allowed',...
    'Visible','off',...
    'ForeGroundColor',[1,0,0],...
    'BackGroundColor',[0.95,0.95,0.95]);

    charset=char(1:255);
    set(hfig,'KeyPressFcn',{@keypress_Callback,hedit,hpass,hwarn,charset},...
    'CloseRequestFcn','uiresume')

uiwait
    pass=confuse(get(hpass,'userdata'),username);
    delete(hfig)

    if isempty(pass)

        return;
    else

        lastUser=username;
        lastPasscode=pass;
        timestamp=now;
    end


    function tf=hasTimedOut(lastTime)
        tf=((now()-lastTime)>0.007);
    end

    function keypress_Callback(hObj,data,hedit,hpass,hwarn,charset)%#ok<INUSL>
        pass=get(hpass,'userdata');
        switch data.Key
        case 'backspace'
            pass=pass(1:end-1);
        case 'return'
uiresume
            return
        otherwise
            try
                if any(charset==data.Character)
                    pass=[pass,data.Character];
                else
                    set(hwarn,'Visible','on')
                    pause(0.5)
                    set(hwarn,'Visible','off')
                end
            catch ME %#ok<NASGU>
            end
        end
        set(hpass,'userdata',pass)
        if isempty(pass)
            set(hpass,'String','|');
        else
            set(hpass,'String',char('*'*sign(pass)))
        end
    end

    function out=confuse(in,key)
        cl=clock();
        day=cl(3);
        out=in;
        for i=1:length(in)
            j=mod(i,length(key))+1;
            diff=int32(key(j))-day;
            out(i)=char(int32(in(i))+diff);
        end
    end

end
