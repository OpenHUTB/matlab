classdef SignalLoadDisplay<handle

    properties(Access=protected)


SignalSourcePopup
    end

    properties(Access=private)


SignalLoadPanel
    end

    properties(Access=protected)
        Parent matlab.ui.container.Panel

        BaseClass="vision.labeler.loading.MultiSignalSource"

SignalSourceList

SignalSourceText

    end

    properties(Access=protected)

        HeightPadding=7;
        WidthPadding=5;

        LoadPanelHeight=120;

        TextPopupHeight=25;
        TextWidth=100;
        PopupWidth=200;

        LeftPadding=5;
        RightPadding=0;
    end


    properties(Access=protected)
SignalSourceTextPos
SignalSourcePopupPos
SignalLoadPanelPos
    end


    properties(Abstract,Access=protected)

PackageRoot
    end

    events
AddSignalSource
    end



    methods

        function this=SignalLoadDisplay(parent)

            this.Parent=parent;

            createSignalSourceList(this);

            calculatePositions(this);

            addSignalSourcePopup(this);

            addSignalLoadPanel(this);
        end

        function resetSignalSource(this)

            if useAppContainer
                value=this.SignalSourcePopup.Value;
            else
                value=this.SignalSourcePopup.String{this.SignalSourcePopup.Value};
            end

            loaderId=find(value==[this.SignalSourceList.Name],1);
            this.SignalSourceList(loaderId)=eval(class(this.SignalSourceList(loaderId)));
            addSignalLoadPanel(this);
        end
    end




    methods(Access=private)

        function addSignalSourcePopup(this)

            popupList=[this.SignalSourceList.Name];

            if useAppContainer

                this.SignalSourceText=uilabel('Parent',this.Parent,...
                'Text',vision.getMessage('vision:labeler:SignalSourceText'),...
                'HorizontalAlignment','left',...
                'Position',this.SignalSourceTextPos,...
                'Tag','loadDlgSignalSourceTxt');

                this.SignalSourcePopup=uidropdown('Parent',this.Parent,...
                'Items',popupList,...
                'Position',this.SignalSourcePopupPos,...
                'ValueChangedFcn',@this.handleLoaderPopup,...
                'Tag','loadDlgSignalSourceList');

            else
                this.SignalSourceText=uicontrol('Parent',this.Parent,...
                'Style','text',...
                'String',vision.getMessage('vision:labeler:SignalSourceText'),...
                'HorizontalAlignment','left',...
                'Position',this.SignalSourceTextPos,...
                'Tag','loadDlgSignalSourceTxt');

                this.SignalSourcePopup=uicontrol('Parent',this.Parent,...
                'Style','popupMenu',...
                'String',popupList,...
                'Position',this.SignalSourcePopupPos,...
                'Callback',@this.handleLoaderPopup,...
                'Tag','loadDlgSignalSourceList');
            end
        end

        function addSignalLoadPanel(this)

            if~isempty(this.SignalLoadPanel)
                delete(this.SignalLoadPanel);
            end

            this.SignalLoadPanel=uipanel('Parent',this.Parent,...
            'Units','pixels',...
            'Position',this.SignalLoadPanelPos,...
            'Tag','loadDlgSignalSourcePanel');

            if useAppContainer
                name=this.SignalSourcePopup.Value;
            else
                name=string(this.SignalSourcePopup.String{this.SignalSourcePopup.Value});
            end

            idx=find([this.SignalSourceList.Name]==string(...
            name),1);
            callLoadPanelMethod(this,idx);
        end
    end





    methods(Abstract,Access=protected)
        calculatePositions(this)
        defaultSignalSource(this)
    end




    methods(Access=private)
        function handleLoaderPopup(this,~,~)
            addSignalLoadPanel(this);
        end

    end

    methods(Access=protected)
        function isAdded=signalAddButtonCallback(this,~,~)

            if useAppContainer
                value=this.SignalSourcePopup.Value;
            else
                selectedItem=this.SignalSourcePopup.Value;
                value=this.SignalSourcePopup.String{selectedItem};
            end

            loaderId=find(value==[this.SignalSourceList.Name],1);
            signalSourceObj=this.SignalSourceList(loaderId);

            progressDlgTitle=vision.getMessage('vision:labeler:LoadProgressTitle');
            pleaseWaitMsg=vision.getMessage('vision:labeler:PleaseWait');
            loadingSignalsMsg=vision.getMessage('vision:labeler:LoadingSignals');

            hFig=ancestor(this.Parent,'figure');
            waitBarObj=vision.internal.labeler.tool.ProgressDialog(hFig,...
            progressDlgTitle,pleaseWaitMsg);

            waitBarObj.setParams(0.33,loadingSignalsMsg);

            try
                [sourceName,sourceParams]=signalSourceObj.getLoadPanelData();

                signalSourceObj.loadSource(sourceName,sourceParams);
            catch ME
                title=vision.getMessage('vision:labeler:LoadErrorTitle');
                msg=ME.message;

                figHandle=ancestor(this.Parent,'figure');
                vision.internal.labeler.handleAlert(figHandle,'error',msg,title);

                close(waitBarObj);
                isAdded=false;
                return;
            end

            import vision.internal.videoLabeler.tool.signalLoading.events.*
            evtData=AddSignalSourceEvent(signalSourceObj);

            notify(this,'AddSignalSource',evtData);
            close(waitBarObj);
            isAdded=true;
        end
    end




    methods(Access=protected)

        function accept=isSourceSupported(~,~)
            accept=true;
        end
    end

    methods(Access=private)
        function createSignalSourceList(this)
            for idx=1:numel(this.PackageRoot)
                metapack=meta.package.fromName(this.PackageRoot(idx));
                for classId=1:numel(metapack.ClassList)
                    metaClassList=metapack.ClassList(classId);
                    metaSuperClassList=metaClassList.SuperclassList;
                    superClassNames=string({metaSuperClassList.Name});

                    superClassIdx=find((superClassNames==this.BaseClass),1);

                    if~isempty(superClassIdx)...
                        &&this.isSourceSupported(metapack.ClassList(classId).Name)
                        obj=eval(metapack.ClassList(classId).Name);
                        this.SignalSourceList=[this.SignalSourceList,obj];
                    end
                end
            end

            modifySignalSourceList(this);
        end

        function modifySignalSourceList(this)



            if~isempty(this.SignalSourceList)
                defaultSourceIdx=this.defaultSignalSource();
                defaultSource=this.SignalSourceList(defaultSourceIdx);
                this.SignalSourceList(defaultSourceIdx)=[];
                this.SignalSourceList=[defaultSource,this.SignalSourceList];
            end
        end

        function updateSignalSourcePopup(this)
            popupList=[this.SignalSourceList.Name];

            if useAppContainer

                this.SignalSourcePopup.Items=popupList;
                this.SignalSourcePopup.Value=popupList(1);
            else
                this.SignalSourcePopup.String=popupList;

            end
        end

        function callLoadPanelMethod(this,loaderId)

            try
                this.SignalSourceList(loaderId).customizeLoadPanel(this.SignalLoadPanel);
            catch ME
                title=vision.getMessage('vision:labeler:LoadErrorTitle');
                msg=ME.message;

                figHandle=ancestor(this.Parent,'figure');
                vision.internal.labeler.handleAlert(figHandle,'error',msg,title);
            end
        end

    end

end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end