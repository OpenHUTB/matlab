function app=newArch(name)



    if nargin<1
        name='untitled_swarch';
        idx=1;
        while(bdIsLoaded(name))
            name=['untitled_arch',num2str(idx)];
        end
    end

    try
        bdH=new_system(name,'SoftwareArchitecture');
    catch ME
        if strcmpi(ME.identifier,'Simulink:LoadSave:InvalidBlockDiagramName')


            error('SystemArchitecture:LoadSave:InvalidArchName','Invalid architecture name');
        else
            rethrow(ME);
        end
    end

    app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);

end


