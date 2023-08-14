classdef DefaultCompInfo<handle








    properties(GetAccess=public,SetAccess=private)
DefaultMexCompInfo
ToolchainInfo
    end

    properties(GetAccess=public,SetAccess=private,Dependent=true)
        DefaultMexCompilerKey;
    end

    methods

        function lDefaultMexCompilerKey=get.DefaultMexCompilerKey(this)

            if isempty(this.DefaultMexCompInfo)
                lDefaultMexCompilerKey='';
            else
                lDefaultMexCompilerKey=this.DefaultMexCompInfo.compStr;
            end

        end

    end

    methods(Access=public,Static=true)

        function lCompInfo=createDefaultCompInfo
            lCompInfo=coder.internal.DefaultCompInfo;
        end

    end

    methods(Access=private)

        function this=DefaultCompInfo

            lDefaultMexCompInfo=coder.make.internal.getMexCompilerInfo();

            if ispc&&(isempty(lDefaultMexCompInfo)||sfpref('UseLCC64ForSimulink'))
                lDefaultMexCompInfo=coder.make.internal.getMexCompInfoFromKey('LCC-x');
            end

            if~isempty(lDefaultMexCompInfo)
                lMexCompilerKey=lDefaultMexCompInfo.compStr;
                lToolchainInfo=coder.make.internal.getToolchainInfoFromRegistry('',lMexCompilerKey);
            else
                lToolchainInfo=[];
            end

            this.DefaultMexCompInfo=lDefaultMexCompInfo;
            this.ToolchainInfo=lToolchainInfo;
        end

    end
end
