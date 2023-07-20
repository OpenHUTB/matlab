function isAccepted=spLicenseDialog




    isAccepted=false;

    f=uifigure('Position',[100,100,686,480],"Name","QNX End-User License Agreement");


    haccept=uibutton(f,"ButtonPushedFcn",@acceptbutton_Callback,"Position",[203,9,100,22],"Text",'Accept');
    hreject=uibutton(f,"ButtonPushedFcn",@rejectbutton_Callback,"Position",[409,9,100,22],"Text",'Reject');






    licenseFile=which('slrealtimeqnx_License.txt');



    if~exist(licenseFile,'file')
        licenseFile=fullfile(ctfroot,'slrealtimeqnx_License.txt');
    end

    licenseText=fileread(licenseFile);

    htext=uitextarea(f,'Position',[16,54,655,375],"Value",licenseText,"Editable","off");

    hlabel=uilabel(f,'Position',[16,441,355,22],"Text",'Please accept the QNX End-User License Agreement to proceed');


    uiwait(f);


    delete(f);

    function acceptbutton_Callback(source,eventdata)
        isAccepted=true;
        uiresume(f);
    end
    function rejectbutton_Callback(source,eventdata)
        isAccepted=false;
        uiresume(f);
    end

end

