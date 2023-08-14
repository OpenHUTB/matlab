classdef BaseCustomizer







    methods(Access=private)
        function this=BaseCustomizer()
        end
        function delete(this)%#ok<INUSD>
        end
    end

    methods(Access=public,Static,Hidden)
        function this=getInstance()
            persistent localStaticObj;
            if isempty(localStaticObj)
                localStaticObj=slreq.custom.BaseCustomizer();
            end
            this=localStaticObj;
        end
    end

    methods(Access=public,Hidden)
        function clear(this)

            if~slreq.data.ReqData.exists()

                return;
            end
            reqData=slreq.data.ReqData.getInstance();

            reqData.unresolveCustomLinkTypes();
            reqData.unresolveCustomRequirementTypes();
        end
    end

    methods
        function addCustomLinkType(this,typeName,superTypeName,forwardName,backwardName,description)%#ok<INUSL>


            if strcmp(superTypeName,'Unset')

                error(message('Slvnv:slreq:InvalidSuperTypeNameReserved',superTypeName));
            end

            reqData=slreq.data.ReqData.getInstance();
            try
                reqData.addCustomLinkType(typeName,superTypeName,forwardName,backwardName,description);
            catch ex
                throw(ex);
            end
            if slreq.app.MainManager.exists

                slreq.app.MainManager.getInstance.update();
            end
        end


        function addCustomRequirementType(this,name,superTypeName,description)%#ok<INUSL>

            if strcmp(superTypeName,'Unset')

                error(message('Slvnv:slreq:InvalidSuperTypeNameReserved',superTypeName));
            end

            reqData=slreq.data.ReqData.getInstance();
            try
                reqData.addCustomRequirementType(name,superTypeName,description);
            catch ex
                throw(ex);
            end
            if slreq.app.MainManager.exists

                slreq.app.MainManager.getInstance.update();
            end
        end
    end
end
