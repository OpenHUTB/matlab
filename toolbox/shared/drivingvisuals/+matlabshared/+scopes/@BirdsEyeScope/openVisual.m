function openVisual(this)

    if(this.IsLaunching)
        return;
    end

    this.IsLaunching=true;

    if dig.isProductInstalled('Automated Driving Toolbox')
        if~builtin('license','checkout','Automated_Driving_Toolbox')
            error('driving:birdseyescope:licenseError',...
            getString(message('driving:birdseyescope:licenseError')));
        end
    else
        error('driving:birdseyescope:installError',...
        getString(message('driving:birdseyescope:installError')));
    end

    connector.ensureServiceOn;
    clientID=this.ClientID;







    URL=Simulink.scopes.BirdsEyeUtil.getURL(clientID);
    feature=slfeature('slBirdsEyeScopeApp');


    if feature>2
        hWebWindow=this.WebWindow;
        isObjectValid=isa(hWebWindow,'matlab.internal.webwindow')&&isvalid(hWebWindow);
        if~(isObjectValid&&hWebWindow.isWindowValid)



            if isObjectValid
                delete(hWebWindow);
            end





            hWebWindow=matlab.internal.webwindow(URL,matlab.internal.getDebugPort,...
            'Position',matlabshared.scopes.getWebWindowPosition);
            this.WebWindow=hWebWindow;
            hModel=matlabshared.scopes.clientIDToHandle(clientID);


            mdlObj=get_param(hModel,'Object');
            callBack=@()postModelNameChange(this);
            if(~mdlObj.hasCallback('PostNameChange',['BirdsEyeScope',num2hex(hModel)]))
                mdlObj.addCallback('PostNameChange',['BirdsEyeScope',num2hex(hModel)],callBack);
            end

            hWebWindow.Title=this.getWebWindowTitle(get_param(hModel,'Name'));

            iconFile=fullfile(matlabroot,'toolbox','shared','drivingvisuals','resources','birdseyescope','birdsEyeScope16.');
            if ispc
                iconFile=[iconFile,'ico'];
            else
                iconFile=[iconFile,'png'];
            end
            hWebWindow.Icon=iconFile;




            hWebWindow.CustomWindowClosingCallback=@(evt,src)closeImpl(this);




            hWebWindow.PageLoadFinishedCallback=@(evt,src)resetSimControlsState(this);

            hWebWindow.enableDragAndDrop();
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

    this.IsLaunching=false;



    this.open();




    resetSimControlsState(this);

end

function closeImpl(this)

    this.close();
    this.WebWindow.hide();

end


function resetSimControlsState(this)
    this.SimControlsState='';
end
