function varargout=cachedSettings(method)



    persistent useMC actxId customPicture;

    if strcmp(method,'reset')

        myVersion=sscanf(version('-release'),'%x');
        linkSettings=rmi.settings_mgr('get','linkSettings');


        if myVersion>=sscanf('2012a','%x')
            if~linkSettings.useActiveX&&rmiut.matlabConnectorOn()
                useMC=true;
            else
                useMC=false;
            end
        else
            useMC=false;
        end


        customPicture='';
        if myVersion>=sscanf('2010b','%x')
            if linkSettings.slrefCustomized
                customPicture=linkSettings.slrefUserBitmap;
            end
        end


        actxId='';
        if~useMC

            if myVersion>=sscanf('2010b','%x')
                [actxOk,actxId]=rmicom.actx_installed('SLRefButtonA');
                if~actxOk
                    actxId='';
                end
            else
                if rmicom.actx_installed();
                    actxId='mwSimulink1.SLRefButton';
                end
            end
        end

    elseif strcmp(method,'get')
        varargout={useMC,actxId,customPicture};
    else
        error(message('Slvnv:rmiref:insertRefs:InvalidMethodInCachedSettings',method));
    end

end
