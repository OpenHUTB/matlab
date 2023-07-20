classdef(Hidden)PPTController<mlreportgen.utils.internal.OfficeController







    properties(Constant)
        FileExtensions=mlreportgen.utils.PPTPres.FileExtensions;
        Name=mlreportgen.utils.PPTApp.Name;
    end

    properties(Access=private)
IsAvailable
    end

    methods(Static)
        function this=instance()
            persistent INSTANCE

            mlock();
            if isempty(INSTANCE)
                INSTANCE=mlreportgen.utils.internal.PPTController();
            end
            this=INSTANCE;
        end
    end

    methods
        function tf=isAvailable(this)




            if isempty(this.IsAvailable)
                try
                    NET.addAssembly("microsoft.office.interop.powerpoint");
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
            hApp=mlreportgen.utils.PPTApp();
        end

        function hDoc=createDoc(fullPath)
            hDoc=mlreportgen.utils.PPTPres(fullPath);
        end
    end

    methods(Access=protected)
        function this=PPTController()
            this@mlreportgen.utils.internal.OfficeController();
        end
    end
end



