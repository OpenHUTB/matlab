classdef DirectDeployModel < handle
    %DIRECTDEPLOYMODEL Summary of this class goes here
    
    properties (Access=public)
        webAppFullPath;
        webAppArchiveName;  
        cefInstance;  % current cef window instance
    end
    
    properties (Access=private)
        deployServerUrlList; % list of user entered server urls
        userSelectedServerURL; 
        urlSelectedInDropdown % server url selected in the deploy dropdown
    end
    
    properties (Access=private, Constant)
        DirectDeployToken = "directDeployToken";
        UploadFolder = "uploadFolderLocation";
        AppHash = "appHash";
        WebAppName = "webAppName";
        DirectDeployPath = "/webapps/home/direct-deploy.html";
        ManageAppsPath = "/webapps/home/manage-apps.html";
        ExampleServerURL = "https://www.example.com:8080";
        WebAppsHomePath = "/webapps/home/";
    end
    
    methods(Access=public)
        function obj = DirectDeployModel(webAppOutputPath, webAppName)
            %DIRECTDEPLOYMODEL Construct an instance of this class
            obj.webAppFullPath = webAppOutputPath;
            obj.webAppArchiveName = webAppName;
        end
             
        % Fetch the server url list from Settings to show in deploy dropdown
        % Last 5 server entered urls are stored in Settings
        function url = fetchServerUrlListFromSettings(obj)
            s = settings();
            if ~s.hasGroup('matlabCompiler')
                s.addGroup('matlabCompiler')
            end
            if ~s.matlabCompiler.hasSetting('serverUrlList')
                s.matlabCompiler.addSetting('serverUrlList');
                s.matlabCompiler.serverUrlList.PersonalValue = {};
            end            
            url = s.matlabCompiler.serverUrlList.PersonalValue;
            obj.deployServerUrlList = url;
        end
        
        % Function to validate user entered server url format
        % Valid server url format - https://<host-name>:<port-no>
        function valid = validateServerUrl(obj, serverUrl)
             exp = '(http|https):(\/\/)[\w-_.]+:[0-9]+([\/webapps\/home\/]?)';
             if regexp(serverUrl, exp)
                 valid = true;
             else
                 valid = false;
             end
        end
        
        % Create server url selected in dropdown callback
        function userEnteredUrlCallback(obj, urlDropdown, event)
            serverURL = event.Value;
            serverURL = regexprep(serverURL, ...
                matlab.internal.compiler.ui.DirectDeployModel.WebAppsHomePath,'');
            if endsWith(serverURL, '/')
                serverURL = strip(serverURL, 'right', '/');
            end
            obj.userSelectedServerURL = serverURL;
            % Add user entered url to deploy url list in settings if not already present  
            if ~any(strcmp(urlDropdown.Items, obj.userSelectedServerURL))
                urlDropdown.Items = [obj.userSelectedServerURL urlDropdown.Items];
                urlDropdown.Items = obj.addURLToServerList(urlDropdown.Items);
            end
        end
        
        % Check if given server URL is valid
        function checkIfURLValidAndLaunchCef(obj)
            try
                webread(obj.userSelectedServerURL);
            catch 
                error(getString(message('compiler_ui:packagingDialog:DEPLOY_SERVER_URL_NOT_EXISTS')));
            end 
            obj.checkifValidDirectDeployURL(); 
        end
        
        % Check if direct-deploy.html exists in given Server URL
        function checkifValidDirectDeployURL(obj)
            deployURL = strcat(obj.userSelectedServerURL, obj.DirectDeployPath);
            try
                webread(deployURL);
            catch 
                error(getString(message('compiler_ui:packagingDialog:DEPLOY_SERVER_INCOMPATIBILE')));
            end
            % Generate app hash and launch web apps in CEF           
            hash = obj.createAppHash();            
            obj.launchCEFAndGetTokenFromServer(deployURL, hash);
        end
        
        % Deploy button pressed callback
        function deployButtonPressedCallback(obj, event, currentURL) 
            % Redirect to top most server url if url field is empty  
            currentURL = regexprep(currentURL, ...
                matlab.internal.compiler.ui.DirectDeployModel.WebAppsHomePath, '');
            if endsWith(currentURL, '/')
                currentURL = strip(currentURL, 'right', '/');
            end
            if obj.validateServerUrl(currentURL)
                obj.userSelectedServerURL = currentURL;
                obj.checkIfURLValidAndLaunchCef();
            else
                error(getString(message('compiler_ui:packagingDialog:DEPLOY_INVALID_SERVER_URL')));
            end            
        end
        
        % Function to set initial server value in dropdown       
        function initialValue = getInitialValueForDropdown(obj, serverUrlList)
            if isempty(serverUrlList)
                initialValue = obj.ExampleServerURL;
            else
                initialValue = serverUrlList{1,1};
            end
        end      
    end
    
    methods(Access=private)
        % User entered url is add to server list in Settings
        % If server list has 5 urls already, least recent url is deleted
        % and newly entered url is added to the top of the server list
        function updatedList = addURLToServerList(obj, serverUrlList)
            numOfElemInList = numel(serverUrlList);
            if numOfElemInList > 5
                serverUrlList{1, end} = {};
                serverUrlList = serverUrlList(~cellfun('isempty',serverUrlList));
            end
            s = settings();
            s.matlabCompiler.serverUrlList.PersonalValue = serverUrlList;
            updatedList = s.matlabCompiler.serverUrlList.PersonalValue;
        end
        
        % Generate app hash from the web app using the SHA512 algorithm     
        function hash = createAppHash(obj)
            digester = matlab.internal.crypto.SecureDigester('SHA512');
            binaryCode = digester.computeFileDigest(obj.webAppFullPath);
            hash = matlab.internal.crypto.base64Encode(binaryCode);
        end
        
        % Function to get value from localStorage given a key     
        function value = getItemFromStorage(obj, key)
            jsCommand = sprintf('window.localStorage.getItem(''%s'');', key);
            value = obj.cefInstance.executeJS(jsCommand);
        end
        
        % Function to set item to localStorage
        function setItemToStorage(obj, key, value)
            jsCommand = sprintf('window.localStorage.setItem(''%s'', ''%s'');', key, value);
            obj.cefInstance.executeJS(jsCommand);
        end
        
        % Function to remove item from localStorage
        function removeAllItemsFromStorage(obj)
            itemsArr = [matlab.internal.compiler.ui.DirectDeployModel.AppHash ...
                matlab.internal.compiler.ui.DirectDeployModel.WebAppName ...
                matlab.internal.compiler.ui.DirectDeployModel.DirectDeployToken ...
                matlab.internal.compiler.ui.DirectDeployModel.UploadFolder];
            for i = 1:length(itemsArr)
                jsCommand = sprintf('window.localStorage.removeItem(''%s'');', itemsArr(i));
                obj.cefInstance.executeJS(jsCommand);
            end            
        end
        
        % Function to redirect to URL in CEF browser
        function redirectToURL(obj, uri)
            jsCommand = sprintf('window.location.replace(''%s'');', uri);
            obj.cefInstance.executeJS(jsCommand);
        end
        
        % Launch web app server in cef browser           
        function launchCEFAndGetTokenFromServer(obj, serverURL, appHash)
            % Open cef browser with user selected server url
            remoteDebuggingPort = matlab.internal.getDebugPort;
            obj.closeOldCefWindows();
            obj.cefInstance = matlab.internal.webwindow(serverURL, remoteDebuggingPort);
            obj.cefInstance.CustomWindowClosingCallback = @obj.handleCEFWindowClosingEvent;
            obj.cefInstance.MATLABWindowExitedCallback = @obj.onCefWindowClose;
            obj.cefInstance.maximize();
            obj.cefInstance.show();
            obj.checkIfLinuxClient();                    
            obj.setNewTokenstoStorage(appHash);         
        end

        % Web App Server using self signed certificates does not work on
        % Linux clients. Show error message in Package Dialog.
        function checkIfLinuxClient(obj)
            if isunix
                try
                    if isobject(obj.cefInstance) 
                       obj.removeAllItemsFromStorage(); 
                    end
                catch
                    obj.cefInstance.close();
                    obj.onCefWindowClose(); 
                    error(getString(message('compiler_ui:packagingDialog:DEPLOY_LINUX_CEF_ERROR')));
                end
            end
        end

        % Function to clear old tokens from storage and set new ones
        function setNewTokenstoStorage(obj, appHash)
            try
                if isobject(obj.cefInstance)
                    obj.removeAllItemsFromStorage();
                    obj.setItemToStorage(...
                        matlab.internal.compiler.ui.DirectDeployModel.AppHash, ...
                        appHash);
                    obj.setItemToStorage(...
                        matlab.internal.compiler.ui.DirectDeployModel.WebAppName, ...
                        obj.webAppArchiveName);
                    obj.waitForTokenFromServer();     
                end  
            catch 
                error(getString(message('compiler_ui:packagingDialog:DEPLOY_BROWSER_CLOSED')));
            end           
        end
        
        % Find previously active web apps cef windows and close them before
        % launching a new cef window
        function closeOldCefWindows(obj)
            windows = matlab.internal.webwindowmanager.instance();
            cefList = windows.findAllWebwindows;
            for i = 1:numel(cefList)
                if contains(cefList(i).URL, obj.userSelectedServerURL)
                    obj.cefInstance = cefList(i);
                    obj.cefInstance.close();
                    obj.onCefWindowClose();
                end
            end
        end

        function waitForTokenFromServer(obj)
           [token, uploadLocation] = obj.getAuthTokenFromServer();
           if isempty(token)
               error(getString(message('compiler_ui:packagingDialog:DEPLOY_BROWSER_CLOSED')));
           elseif token(2: end-1) == "canceled"
               obj.removeAllItemsFromStorage();
               obj.handleCEFWindowClosingEvent();
           else
               obj.sendUploadRequestToServer(token, uploadLocation);
           end           
        end

        % Function to fetch available tokens from localStorage
        function [directDeployToken, uploadFolderLocation] = getItemsFromLocalStorage(obj)
            directDeployToken = '';
            uploadFolderLocation = '';
            if isobject(obj.cefInstance)
                directDeployToken = obj.getItemFromStorage(...
                    matlab.internal.compiler.ui.DirectDeployModel.DirectDeployToken);
                uploadFolderLocation = obj.getItemFromStorage(...
                    matlab.internal.compiler.ui.DirectDeployModel.UploadFolder);
            end
        end
        
        % Function call to send upload app request when directDeployToken is available
        function [directDeployToken, uploadFolderLocation] = getAuthTokenFromServer(obj)
            [directDeployToken, uploadFolderLocation] = obj.getItemsFromLocalStorage();            
            % wait until directDeployToken is available in localStorage                  
            while directDeployToken == "null"
                [directDeployToken, uploadFolderLocation] = obj.getItemsFromLocalStorage();
            end
        end
        
        function sendUploadRequestToServer(obj, token, folderLocation)
            fileName = strcat(obj.webAppArchiveName, '.ctf');
            folderLocation = folderLocation(2: end-1);
            if folderLocation ~= ' '
                fileName = strcat(folderLocation, '/', fileName);
            else
                folderLocation = 'none';
            end
            
            %  construct request headers        
            request = matlab.net.http.RequestMessage();
            request.Method = 'POST';
            acceptHeader = matlab.net.http.field.AcceptField('application/json');
            directDeployTokenHeader = matlab.net.http.HeaderField('X-MDWAS-DirectDeploy', token(2: end-1));
            request.Header = [acceptHeader, directDeployTokenHeader];
            webAppFileContents = matlab.net.http.io.FileProvider(obj.webAppFullPath); 
            formProvider = matlab.net.http.io.MultipartFormProvider(...
                "command", "uploadApp", ...
                "filename", fileName, ...
                "file", webAppFileContents);
            request.Body =  formProvider;
            serverUploadEndpoint = strcat(obj.userSelectedServerURL, '/services/mdwas/ctfupload');
            
            % send request to server        
            uri = matlab.net.URI(serverUploadEndpoint);
            response = request.send(uri);
            uriManageAppsPath = strcat(obj.userSelectedServerURL, obj.ManageAppsPath);
            if response.StatusCode == "OK"            
                queryParams = sprintf('?appName=%s&folder=%s', obj.webAppArchiveName, folderLocation);
                manageAppsFullPath = strcat(uriManageAppsPath, queryParams);                
            else
                queryParams = sprintf('?appName=%s&error=%s', obj.webAppArchiveName, response.StatusLine);
                manageAppsFullPath = strcat(uriManageAppsPath, queryParams);                
            end
            obj.removeAllItemsFromStorage();
            obj.redirectToURL(manageAppsFullPath);           
        end
        
        function handleCEFWindowClosingEvent(obj, ~, ~)            
            obj.cefInstance.close();
            obj.onCefWindowClose();
        end
        
        function onCefWindowClose(obj)   
            obj.cefInstance = [];
            return;
        end
    end
end

