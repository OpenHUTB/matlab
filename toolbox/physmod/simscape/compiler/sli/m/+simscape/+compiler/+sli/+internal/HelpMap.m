classdef HelpMap

















    properties(Constant,Access=private)
        RelativePathToMapFile='/simscape/helptargets.map';
    end
    properties(Access=private)
        Map;
    end
    methods
        function this=HelpMap(varargin)

            assert(nargin>0);
            assert(mod(nargin,2)==0);
            this.Map=containers.Map(varargin(1:2:end),varargin(2:2:end));
        end
        function[mapName,relativePathToMapFile,found]=getBlockHelpInfo(this,blockType)



















            mapName='User Defined';
            relativePathToMapFile=this.RelativePathToMapFile;
            found=false;
            if this.Map.isKey(blockType)
                mapName=this.Map(blockType);
                found=true;
            end
        end
    end
end
