
classdef ReqEditorAppContext<dig.CustomContext


    properties(SetObservable=true)

        MyTriggerProperty;
        MyInitializedProp;



        isReqSetSelected;

        isInternalLinkStorage;

        isReqBrowserVisible;
        isDoorsEnabled;
        isExportWebviewEnabled;
    end

    methods
        function this=ReqEditorAppContext(app)
            this@dig.CustomContext(app);
            this.MyInitializedProp='Initialized';
            this.MyTriggerProperty=true;
            this.isReqSetSelected=false;
            this.isInternalLinkStorage=rmipref('StoreDataExternally');
            this.isReqBrowserVisible=true;
            this.isDoorsEnabled=false;
            this.isExportWebviewEnabled=true;
        end
    end
end