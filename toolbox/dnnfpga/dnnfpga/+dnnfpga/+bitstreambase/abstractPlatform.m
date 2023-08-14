classdef abstractPlatform<handle



    properties(Access=private)
    end

    methods(Access=public,Hidden=true)
        function obj=abstractPlatform()
        end
    end

    methods(Access=public,Abstract=true)
        deploySanityCheck(this,data)
        executeSanityCheck(this,data)
        printAddress(this)
        deploy(this,data)
        output=execute(this,input)
    end

    methods(Access=protected,Abstract=true)
    end
end

