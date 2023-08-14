



classdef CodeInfoFileInfo<handle
    methods(Abstract)







        out=getDataMemberName(this);





        out=getClassName(this);
    end

    methods


        function codeDb=createCodeDb(this)
            codeDb=feval(this.getClassName());
        end
    end
end
