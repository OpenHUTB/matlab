classdef ImportNodeHelper<slreq.internal.callback.CallbackHelper





    properties
ImportOptions
    end
    methods

        function setupCallback(this,type,text,options)
            setupCallback@slreq.internal.callback.CallbackHelper(this,type,text);
            this.ImportOptions=options;
            if strcmpi(type,'PreImportFcn')
                this.ErrorAction='Error';
            end
        end
    end

    methods(Access=protected)

        function setup(this)
            setup@slreq.internal.callback.CallbackHelper(this);

            slreq.internal.callback.CurrentInformation.setCurrentImportNodes(this.Object);
            slreq.internal.callback.CurrentInformation.setCurrentImportOptions(this.ImportOptions);
            if~isempty(this.Object)
                slreq.internal.callback.CurrentInformation.setCurrentReqSet(this.Object.getReqSet);
                dataReqs=this.Object;
                for index=1:length(dataReqs)
                    dataReqs(index).unlockAll
                end
            end
        end


        function cleanup(this)
            refs=this.Object;
            for index=1:length(refs)
                refs(index).lockAll();
            end

            cleanup@slreq.internal.callback.CallbackHelper(this);
        end
    end
end

