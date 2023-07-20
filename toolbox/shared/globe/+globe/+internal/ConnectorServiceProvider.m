classdef ConnectorServiceProvider<handle




























    properties(SetAccess=private)




        ChannelName char='globeviewer'





        ChannelID char=''





        RequestResponseChannel char=''
    end


    properties(SetAccess=private,Dependent)




URL





DebugURL
    end


    properties(Access=private)
        pURL char=''
    end


    properties(Access=private,Constant)
        BaseURL='/toolbox/shared/globe/globeviewer/'
    end


    methods
        function provider=ConnectorServiceProvider(channelName)










            if nargin>0
                provider.ChannelName=channelName;
            end



            connector.ensureServiceOn;


            [~,channelID]=fileparts(tempname);
            provider.ChannelID=channelID;


            provider.RequestResponseChannel=...
            ['/',provider.ChannelName,'/',channelID];
        end


        function url=get.URL(provider)
            if isempty(provider.pURL)
                toolboxURL=[provider.BaseURL,'index.html'];
                toolboxURL=[toolboxURL,'?clientid=',provider.ChannelID];
                url=connector.getUrl(toolboxURL);
                provider.pURL=url;
            else
                url=provider.pURL;
            end
        end


        function debugURL=get.DebugURL(provider)
            url=provider.URL;
            debugURL=replace(url,'index.html','index-debug.html');
        end
    end


    methods(Static)
        function url=getResourceURL(filePath,URLToken)
            [filePathFolder,fileName,fileExt]=fileparts(filePath);
            connector.ensureServiceOn;
            contentURL=connector.addStaticContentOnPath(URLToken,filePathFolder);
            url=[contentURL,'/',fileName,fileExt];
        end


        function url=addBasemapFolderToServer(location,basemapName,template)
            basemapURLRoute=['globemapdata',basemapName];
            basemapURL=connector.addStaticContentOnPath(basemapURLRoute,location);
            url=connector.getUrl([basemapURL,'/',template]);
        end
    end
end
