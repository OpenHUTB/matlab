classdef(Hidden)WordController<mlreportgen.utils.internal.OfficeController







    properties(Constant)
        FileExtensions=mlreportgen.utils.WordDoc.FileExtensions;
        Name=mlreportgen.utils.WordApp.Name;
    end

    properties(Access=private)
IsAvailable
    end

    methods(Static)
        function this=instance()
            persistent INSTANCE

            mlock();
            if isempty(INSTANCE)
                INSTANCE=mlreportgen.utils.internal.WordController();
            end
            this=INSTANCE;
        end
    end

    methods
        function tf=isAvailable(this)




            if isempty(this.IsAvailable)
                try
                    NET.addAssembly("microsoft.office.interop.word");
                    this.IsAvailable=true;
                catch
                    this.IsAvailable=false;
                end
            end
            tf=this.IsAvailable;
        end
    end

    methods(Static,Access=protected)
        function hApp=createApp()
            hApp=mlreportgen.utils.WordApp();
        end

        function hDoc=createDoc(fullPath)
            hDoc=mlreportgen.utils.WordDoc(fullPath);
        end
    end

    methods(Access=protected)
        function this=WordController()
            this@mlreportgen.utils.internal.OfficeController();
        end
    end
end
