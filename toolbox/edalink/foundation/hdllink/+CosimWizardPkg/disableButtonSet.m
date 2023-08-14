function onCleanupObj=disableButtonSet(this,dlg)



    if isempty(dlg)
        onCleanupObj=onCleanup(@()(disp('...done')));
    else
        setEnabled(dlg,'edaButtonSet',false);
        this.EnableButtons=false;
        onCleanupObj=onCleanup(@()l_myCleanupFcn(this,dlg));
    end

end

function l_myCleanupFcn(this,dlg)
    setEnabled(dlg,'edaButtonSet',true);
    this.EnableButtons=true;
end


