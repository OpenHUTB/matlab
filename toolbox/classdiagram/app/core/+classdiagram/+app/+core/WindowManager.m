classdef WindowManager<handle


    properties(Constant)
        Instance(1,1)classdiagram.app.core.WindowManager=classdiagram.app.core.WindowManager();
    end

    properties(Access=private)
        OpenWindows(1,1)struct;
    end

    methods(Access=private)
        function obj=WindowManager()
            mlock;
        end
    end

    methods
        function apps=getOpenWindows(self)
            fieldvalues=@(MyStruct)(cellfun(@(fieldName)(MyStruct.(fieldName)),fieldnames(MyStruct)));
            apps=fieldvalues(self.OpenWindows);
        end

        function window=findAppForFile(self,filePath)
            filePath=string(filePath);
            window=[];
            windows=self.getOpenWindows();
            for i=1:numel(windows)
                app=windows(i);
                if string(app.activeFilePath)==filePath
                    window=app;
                    return;
                end
            end
        end

        function window=findAppByTag(self,tag)

            window=[];
            windows=self.getOpenWindows();
            for i=1:numel(windows)
                app=windows(i);
                if app.cdWindow.Tag==tag
                    window=app;
                    return;
                end
            end
        end
    end

    methods(Access=?classdiagram.app.core.ClassDiagramWindow)
        function registerOpenWindow(self,app)
            self.OpenWindows.(app.uid)=app;
        end

        function unregisterClosingWindow(self,app)
            if isfield(self.OpenWindows,app.uid)
                self.OpenWindows=rmfield(self.OpenWindows,app.uid);
            end
        end
    end

end

