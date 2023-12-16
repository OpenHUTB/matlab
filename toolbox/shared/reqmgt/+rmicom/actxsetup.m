function status=actxsetup(interactive)

    if~ispc
        disp(getString(message('Slvnv:reqmgt:actx_installed:ActiveXWindowsOnly')));
        return;
    end

    if nargin<1
        interactive=false;
    end

    disp(getString(message('Slvnv:reqmgt:actx_installed:EnsuringRequiredActiveXControls')));
    status=true;
    status=status&&rmicom.actx_installed('SLRefButton');
    status=status&&rmicom.actx_installed('SLRefButtonA');


    rmicom.actxinit(interactive);
end

