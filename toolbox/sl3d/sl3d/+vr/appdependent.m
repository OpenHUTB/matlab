function appset=appdependent(action)







    persistent deployed fullinstall;
    if isempty(deployed)
        deployed=isdeployed;
    end
    if isempty(fullinstall)
        fullinstall=exist(fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))),'sl3dext','sl3d','Contents.m'),'file')~=0;
    end


    isdemo=~deployed&&(~fullinstall||~license('test','Virtual_Reality_Toolbox'));
    onoff={'on','off'};


    if nargin==0
        appset.capture=onoff{1+isdemo};
        appset.filesave=onoff{1+isdemo};
        appset.fullinstall=fullinstall;
        appset.helpmenu=~deployed;
        appset.recording=onoff{1+(isdemo||deployed)};
        appset.showrecording=~deployed;
        appset.simulation=~deployed;
    else
        appset=feval(action,isdemo);
    end


    function ok=blockParamsCallback(isdemo)%#ok<DEFNU>
        ok=~isdemo;
        if(~ok)
            msg=message('sl3d:vrmfunc:notpermittedindemo');
            msgbox(msg.getString(),'Simulink 3D Animation Demo Version','none','modal');
        end
