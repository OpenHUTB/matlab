classdef GalleryController<sltemplate.internal.Controller






    properties(Access=private)
        Subscriptions;
        ReadyListeners;
        Channel;
        Browser;
    end

    events
        ClientReady;
    end

    methods(Access=public)

        function obj=GalleryController(channelRoot,varargin)
            obj.Subscriptions={};
            obj.ReadyListeners={};
            obj.Channel=channelRoot;


            obj.Subscriptions{end+1}=message.subscribe(...
            [obj.Channel,'ClientReady'],...
            @obj.onClientReady);

            obj.Browser=sltemplate.internal.GalleryBrowserFactory.create(...
            obj.Channel,varargin{:});
        end

        function unsubscribeAll(obj)
            if connector.isRunning&&~isempty(obj.Subscriptions)

                cellfun(@(s)message.unsubscribe(s),obj.Subscriptions,'UniformOutput',false);
                obj.Subscriptions={};
            end

            obj.ReadyListeners={};
        end

        function delete(obj)
            obj.unsubscribeAll();
        end

        function runOnceAfterReady(obj,readyFunction)
            obj.ReadyListeners{end+1}=sltemplate.internal.RunOnceListener(readyFunction,obj,'ClientReady');
        end

        function onClientReady(varargin)
            obj=varargin{1};
            obj.notify('ClientReady');
            obj.onCompletedRequest([]);
        end

        function openTemplate(obj,templateFilePath)
            obj.registerFile(templateFilePath);
            obj.customizeView('OpenTemplate',templateFilePath);
        end

        function customizeView(obj,name,value)
            customizeRequest.Name=name;
            customizeRequest.Value=value;
            obj.broadcast('CustomizeView',customizeRequest);
        end

        function registerFile(obj,fullFilePath)



            try
                onPath=sltemplate.internal.Registrar.addTemplate(fullFilePath);
                if~onPath
                    obj.onWarning(message('sltemplate:Registry:TemplateNotOnPath',fullFilePath))
                end
            catch ME
                obj.onError(ME.message);
            end
        end

        function visible=isClientVisible(obj)
            visible=obj.Browser.isVisible();
        end


        function showDialog(obj,~)
            if nargin<2
                sltemplate.internal.Registrar.refresh();
            end
            obj.Browser.show();
        end

        function hideDialog(obj)
            obj.Browser.hide();
        end

        function closeDialog(obj)
            obj.Browser.close();
            obj.Browser=[];
        end

        function broadcast(obj,eventName,eventData)

            message.publish([obj.Channel,eventName],eventData);
        end

        function onError(obj,m)
            if isa(m,'message')
                m=m.getString();
            end

            obj.broadcast('ServerError',m);
        end

        function onWarning(obj,m)
            if isa(m,'message')
                m=m.getString();
            end

            obj.broadcast('ServerWarning',m);
        end

        function onCompletedRequest(obj,result)
            obj.broadcast('ServerCompletedRequest',result);
        end

        function url=getURL(obj)
            url=obj.Browser.getAbsoluteURL;
        end
    end

end
