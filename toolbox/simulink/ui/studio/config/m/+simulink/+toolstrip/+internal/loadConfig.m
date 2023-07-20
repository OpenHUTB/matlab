function loadConfig(loadType)




    if i_isLoading

        return;
    end
    i_isLoading(true);
    resetFlag=onCleanup(@()i_isLoading(false));

    c=dig.Configuration.get();

    if~c.Loaded
        c.UseConfigModel=true;
        c.load();
        c.initializeToolstripPool();
    end


    im=slCreateInterfaceManager;
    if im.isEmpty
        if nargin==0
            loadType='normal';
        end
        loader=DAS.InterfaceLoader(im);
        loader.loadModel(loadType);
    end
end

function b=i_isLoading(b)
    persistent isLoading;
    if nargin
        if b
            isLoading=1;
        else
            isLoading=[];
        end
    end
    b=~isempty(isLoading);
end

