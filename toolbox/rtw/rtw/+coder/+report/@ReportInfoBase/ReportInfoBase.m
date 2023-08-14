classdef ReportInfoBase<handle





    properties(Hidden)
        CodeGenFolder=''
        Config=[]
        Pages={}
TimeStamp
        FileInfo=[]
    end

    properties(Transient)
        BuildDirectory=''
    end

    properties(Transient,Hidden)
        Dirty=false
    end

    methods
    end

    methods(Abstract=true)
        convertCode2HTML(obj)
        registerPages(obj)
        getHelpMethod(obj)
        getLicenseRequirements(obj)
    end

    methods(Hidden=true)
        checkoutLicense(obj)
    end

    methods(Static=true,Hidden=true)
        out=getResourceDir
        out=getRelativePathToFile(cFileName,htmlFileName)
        copyFiles(srcFolder,srcFiles,destFolder)
    end
end


