



classdef Dialog<handle
    properties(Access=private)

fStudio

fChannel

fUrl
fDebugUrl

        fSubscribe={}

        fListeners={};
    end

    methods




        function obj=Dialog(st,varargin)
            obj.fStudio=st;
            if(~isempty(varargin))
                resultReviewId=varargin{1};
                obj.init(resultReviewId)
            else
                obj.init()
            end
        end


        function delete(obj)
            for i=1:numel(obj.fSubscribe)
                message.unsubscribe(obj.fSubscribe{i});
            end
            obj.fSubscribe={};


            for i=1:numel(obj.fListeners)
                delete(obj.fListeners{i});
            end
            obj.fListeners={};




        end
    end

    methods


        url=getUrl(obj);
        receive(obj,msg);


        function out=getStudio(obj)
            out=obj.fStudio;
        end
    end

    methods(Access=protected)

        function setUrl(obj,url)
            obj.fUrl=url;
        end


        function setDebugUrl(obj,url)
            obj.fDebugUrl=url;
        end


        function setChannel(obj,channel)
            obj.fChannel=channel;
        end


        function out=getChannel(obj)
            out=obj.fChannel;
        end

        function subscribe(obj,msg)
            obj.fSubscribe{end+1}=msg;
        end

        function addListeners(obj,listener)
            obj.fListeners{end+1}=listener;
        end
    end

    methods(Access=protected)
        init(obj);
    end

end
