function openVisual(this)







    isDSP_InstalledAndLic=dig.isProductInstalled('DSP System Toolbox');
    isSoCB_InstalledAndLic=dig.isProductInstalled('SoC Blockset');


    if~isDSP_InstalledAndLic&&~isSoCB_InstalledAndLic
        error('Spcuilib:logicanalyzer:installError',...
        getString(message('Spcuilib:logicanalyzer:installError')));
    end


    if isDSP_InstalledAndLic&&~isSoCB_InstalledAndLic
        if~builtin('license','checkout','Signal_Blocks')
            error('Spcuilib:logicanalyzer:licenseError',...
            getString(message('Spcuilib:logicanalyzer:licenseError')));
        end
    end


    if~isDSP_InstalledAndLic&&isSoCB_InstalledAndLic
        if~builtin('license','checkout','SoC_Blockset')
            error('Spcuilib:logicanalyzer:licenseError',...
            getString(message('Spcuilib:logicanalyzer:licenseError')));
        end
    end


    if isDSP_InstalledAndLic&&isSoCB_InstalledAndLic

        if~builtin('license','checkout','Signal_Blocks')&&~builtin('license','checkout','SoC_Blockset')
            error('Spcuilib:logicanalyzer:licenseError',...
            getString(message('Spcuilib:logicanalyzer:licenseError')));
        end
    end

    connector.ensureServiceOn;
    clientID=this.ClientID;







    URL=Simulink.scopes.LAScope.getURL(clientID);
    feature=slfeature('slLogicAnalyzerApp');


    if feature>2
        hWebWindow=this.WebWindow;
        isObjectValid=isa(hWebWindow,'matlab.internal.webwindow')&&isvalid(hWebWindow);
        if~(isObjectValid&&hWebWindow.isWindowValid)



            if isObjectValid
                delete(hWebWindow);
            end





            hWebWindow=matlab.internal.webwindow(URL,matlab.internal.getDebugPort,...
            'Position',getWebWindowPosition);
            this.WebWindow=hWebWindow;
            hModel=str2double(clientID);


            mdlObj=get_param(hModel,'Object');
            callBack=@()postModelNameChange(this);
            if(~mdlObj.hasCallback('PostNameChange',['LogicAnalyzer',num2hex(hModel)]))
                mdlObj.addCallback('PostNameChange',['LogicAnalyzer',num2hex(hModel)],callBack);
            end

            hWebWindow.Title=getString(message('Spcuilib:logicanalyzer:WebWindowTitle',get_param(hModel,'Name')));

            iconFile=fullfile(matlabroot,'toolbox','shared','spcuilib','logicanalyzer','resources','logicanalyzer','la_visualize_16.');
            if ispc
                iconFile=[iconFile,'ico'];
            else
                iconFile=[iconFile,'png'];
            end
            hWebWindow.Icon=iconFile;




            hWebWindow.CustomWindowClosingCallback=@(evt,src)close(this);




            hWebWindow.PageLoadFinishedCallback=@(evt,src)resetSimControlsState(this);

        end

        hWebWindow.show;
        hWebWindow.bringToFront;

    else
        if strcmpi(computer,'maci64')
            system(['open -a Google\ Chrome "',URL,'" --args --incognito']);
        elseif strcmpi(computer,'pcwin64')
            system(['start chrome "',URL,'" --incognito']);
        elseif strcmpi(computer,'glnxa64')
            system(['chromium "',URL,'"&']);
        end
    end

end


function ret=getWebWindowPosition

    width=1200;
    height=800;

    r=groot;
    screenWidth=r.ScreenSize(3);
    screenHeight=r.ScreenSize(4);
    maxWidth=0.8*screenWidth;
    maxHeight=0.8*screenHeight;
    if maxWidth>0&&width>maxWidth
        width=maxWidth;
    end
    if maxHeight>0&&height>maxHeight
        height=maxHeight;
    end

    xOffset=(screenWidth-width)/2;
    yOffset=(screenHeight-height)/2;

    ret=[xOffset,yOffset,width,height];

end

function resetSimControlsState(this)






    this.SimControlsState='';
end

