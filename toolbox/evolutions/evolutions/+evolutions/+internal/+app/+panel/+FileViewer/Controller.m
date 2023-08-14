classdef Controller<handle




    properties(SetAccess=immutable)

AppController
AppModel
AppView
WebView

EventHandler
    end

    properties(SetAccess=protected)

FileListSelectionChangedListener
    end

    properties(Constant,Access=protected)
        PreviewFilePath=fullfile(matlabroot,'toolbox','evolutions',...
        'evolutions','+evolutions','+internal','resources','layout',...
        'ActiveEvolutionPreview.html');
    end

    methods
        function this=Controller(parentController)
            this.AppController=parentController.AppController;
            this.AppModel=getAppModel(this.AppController);
            this.AppView=getAppView(this.AppController);
            this.WebView=getSubView(this.AppView,'FileViewer');

            this.EventHandler=parentController.AppController.EventHandler;
        end

        function setup(this)

            installModelListeners(this);
            installViewListeners(this);
        end

        function delete(this)
            deleteListeners(this);
        end
    end

    methods
        function update(this,varargin)
            update(this.WebView,varargin{:});
        end

        function deleteListeners(this)

            listeners="FileListSelectionChangedListener";
            evolutions.internal.ui.deleteListeners(this,listeners);
        end

    end

    methods(Access=protected)
        function installModelListeners(~)
        end

        function installViewListeners(this)
            this.FileListSelectionChangedListener=...
            listener(this.EventHandler,'FileListSelectionChanged',@this.updateFileView);
        end
    end

    methods(Hidden,Access=protected)

        function updateFileView(this,~,ed)
            if~isempty(ed.EventData)&&~isempty(ed.EventData.WebView)

                htmlPath=ed.EventData.WebView;
            else

                htmlPath=this.PreviewFilePath;
            end
            update(this,htmlPath);
        end
    end
end


