classdef CurrentInformation<handle









    properties(Access=private)
        CurrentObject=[]
        CurrentReqSet=[]
        CurrentImportNodes=[]
        CurrentImportOptions=[]
        IsCallbackRunning=false
CallbackType
    end

    methods(Access=private)
        function this=CurrentInformation()

        end

        function reset(this)
            this.CurrentImportOptions=[];
            this.CurrentImportNodes=[];
            this.CurrentReqSet=[];
            this.CurrentObject=[];
            this.IsCallbackRunning=false;
            this.CallbackType='';
        end
    end

    methods(Static,Access=?slreq.internal.callback.CallbackHelper)


        function setRunningFlag(tf)
            cbInfoIns=slreq.internal.callback.CurrentInformation.getInstance();
            cbInfoIns.IsCallbackRunning=tf;
        end


        function setCallbackType(type)
            cbInfoIns=slreq.internal.callback.CurrentInformation.getInstance();
            cbInfoIns.CallbackType=type;
        end


        function setCurrentObject(obj)
            cbInfoIns=slreq.internal.callback.CurrentInformation.getInstance();
            cbInfoIns.CurrentObject=obj;
        end


        function setCurrentReqSet(obj)
            cbInfoIns=slreq.internal.callback.CurrentInformation.getInstance();
            cbInfoIns.CurrentReqSet=obj;
        end


        function setCurrentImportNodes(refs)
            cbInfoIns=slreq.internal.callback.CurrentInformation.getInstance();
            cbInfoIns.CurrentImportNodes=refs;
        end


        function setCurrentImportOptions(opts)
            cbInfoIns=slreq.internal.callback.CurrentInformation.getInstance();
            cbInfoIns.CurrentImportOptions=opts;
        end


        function cleanup()
            cbInfoIns=slreq.internal.callback.CurrentInformation.getInstance();
            cbInfoIns.reset();
        end
    end

    methods(Static)


        function out=getCurrentReqSet()

            cbInfoIns=slreq.internal.callback.CurrentInformation.getInstance();
            out=[];

            if cbInfoIns.IsCallbackRunning
                out=cbInfoIns.CurrentReqSet;
                if isa(out,'slreq.data.RequirementSet')
                    out=slreq.utils.dataToApiObject(out);
                end
            end
        end


        function options=getCurrentImportOptions()

            cbInfoIns=slreq.internal.callback.CurrentInformation.getInstance();

            options=[];

            if cbInfoIns.IsCallbackRunning
                options=cbInfoIns.CurrentImportOptions;
            end
        end


        function refs=getCurrentImportNodes()
            cbInfoIns=slreq.internal.callback.CurrentInformation.getInstance();
            refs=[];

            if cbInfoIns.IsCallbackRunning

                dataRefs=cbInfoIns.CurrentImportNodes;
                refs=slreq.Reference.empty();
                for index=1:length(dataRefs)
                    if isa(dataRefs(index),'slreq.data.Requirement')&&dataRefs(index).external
                        refs(end+1)=slreq.utils.dataToApiObject(dataRefs(index));%#ok<AGROW>
                    end
                end
            end

        end


        function obj=getCurrentObject()
            cbInfoIns=slreq.internal.callback.CurrentInformation.getInstance();


            obj={};

            if cbInfoIns.IsCallbackRunning&&~isempty(cbInfoIns.CurrentObject)
                allObjs=cbInfoIns.CurrentObject;
                for index=1:length(allObjs)
                    obj{end+1}=slreq.utils.dataToApiObject(allObjs(index));%#ok<AGROW> 
                end
            end
            obj=[obj{:}];
        end


        function cbInfoInstance=getInstance()
            persistent callbackInfo
            if isempty(callbackInfo)
                callbackInfo=slreq.internal.callback.CurrentInformation();
            end
            cbInfoInstance=callbackInfo;
        end


        function tf=isCallbackRunning()
            cbInfoIns=slreq.internal.callback.CurrentInformation.getInstance();
            tf=cbInfoIns.IsCallbackRunning;
        end


        function callbackType=getCallbackType()
            cbInfoIns=slreq.internal.callback.CurrentInformation.getInstance();
            callbackType=cbInfoIns.CallbackType;
        end


    end
end

