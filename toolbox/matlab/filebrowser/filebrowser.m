function filebrowser
%   FILEBROWSER 打开当前文件夹浏览器，如果已经打开就选中它。
%   FILEBROWSER 打开并选中当前文件夹浏览器，如果已经打开就选中它。

    import matlab.internal.lang.capability.Capability;

    if desktop('-inuse') && (feature('webui') || ~Capability.isSupported(Capability.LocalClient)) 
        try 
            rootApp = matlab.ui.container.internal.RootApp.getInstance();
                if rootApp.hasPanel('Current Folder')
                    cfbPanel = rootApp.getPanel('Current Folder');
                    setPanelProperties(cfbPanel);
                else
                    % 等待面板状态成为可得。
                    rootAppListener = addlistener(rootApp, 'PropertyChanged', @(event, data)handleRootAppPropertyChange(data));
                end
        catch
            error(message('MATLAB:filebrowser:filebrowserFailed'));
        end
    
    elseif feature('webui') && ~desktop('-inuse') % In JSD mode but JSD is not yet running
        error(message('MATLAB:desktop:desktopNotFoundCommandFailure'));
    else
        err = javachk('mwt', 'The Current Folder Browser');
        if ~isempty(err)
            error(err);
        end
    
        try
            % 启动当前文件夹浏览器
            hDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
            adapter = javaObject('com.mathworks.mde.desk.DesktopExplorerAdapterImpl', hDesktop);
            %javaMethod('createInstance', 'com.mathworks.mde.explorer.Explorer', adapter);
            
            classLoader = java.lang.ClassLoader.getSystemClassLoader();
            explorerClass = java.lang.Class.forName('com.mathworks.mde.explorer.Explorer', 1, classLoader);
            adapterClass = java.lang.Class.forName('com.mathworks.explorer.DesktopExplorerAdapter', 1, classLoader);
            
            paramtypes = javaArray('java.lang.Class', 1);
            paramtypes(1) = adapterClass;
            
            method = explorerClass.getMethod(java.lang.String('createInstance'), paramtypes);
            arglist = javaArray('java.lang.Object', 1);
            arglist(1) = adapter;
            
            com.mathworks.mwswing.MJUtilities.invokeLater(explorerClass, method, arglist);
            
            com.mathworks.mde.explorer.Explorer.invoke;    
        catch
            % Failed. Bail
            error(message('MATLAB:filebrowser:filebrowserFailed'));
        end
    end


    function handleRootAppPropertyChange(data)
        if data.PropertyName=="PanelLayout"
            cfbPanel = rootApp.getPanel('Current Folder');
            setPanelProperties(cfbPanel);
            delete(rootAppListener)
        end
    end


    function setPanelProperties(hPanel)
        if ~hPanel.Opened
            hPanel.Opened = true;
        end
        hPanel.Selected = true;
    end

end
