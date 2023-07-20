classdef releasemanager<handle


    properties(SetAccess=protected)
releaseManagerHTML
releaseManagerModel
    end

    methods

        function obj=releasemanager()
            obj.releaseManagerModel=multivercosim.internal.releasemanagerModel.getInstance();
        end


        function delete(~)

        end


        function createReleaseManagerHTML(obj)

            if isempty(obj.releaseManagerHTML)
                obj.releaseManagerHTML=multivercosim.internal.releasemanagerHTML.getInstance();
            end
        end



        function updateData(obj,msg)
            obj.releaseManagerModel.update(msg);
        end


        function view(obj)
            obj.releaseManagerHTML.view();
        end


        function initializeRM(obj,viewChannel)
            obj.releaseManagerModel.initializeView(viewChannel);
        end

    end

    methods(Static)
        function releaseListInstance=getInstance
            persistent localObj;
            if isempty(localObj)||~isvalid(localObj)
                localObj=multivercosim.internal.releasemanager;
            end
            releaseListInstance=localObj;
        end


    end



end
