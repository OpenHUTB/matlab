classdef BlockPathInfoStorage<handle




    properties(Access=protected)
Map
Mdl
MdlHierInfo
    end
    methods
        function this=BlockPathInfoStorage(mdl,mdlhierinfo)
            this.Map=containers.Map('KeyType','double','ValueType','any');
            this.Mdl=mdl;
            this.MdlHierInfo=mdlhierinfo;
        end
        function s=getBlockPathInfo(this,bh)
            if isKey(this.Map,bh)
                s=this.Map(bh);
            else
                [gBlkPath,gParBlkPaths,isMultiInstanced]=...
                linearize.advisor.utils.getBlockPathInfo(this.Mdl,bh,this.MdlHierInfo);
                s.fullname=getfullname(bh);
                s.gBlkPath=gBlkPath;
                s.gParBlkPaths=gParBlkPaths;
                s.isMultiInstanced=isMultiInstanced;
                s.ParentMdl=bdroot(bh);
                [s.isSynth,s.origBlk]=LocalIsBlkSynth(bh);
                this.Map(bh)=s;
            end
        end
    end

end

function[val,origblk]=LocalIsBlkSynth(blkh)

    bObj=get_param(blkh,'Object');
    origblk=[];
    if bObj.isSynthesized
        if strcmp(bObj.getSyntReason,'SL_SYNT_BLK_REASON_BUSEXPANSION')
            val=strcmp(bObj.BlockType,'SignalConversion')||strcmp(bObj.BlockType,'ToWorkspace');
            origblk=getTrueOriginalBlock(bObj);
        else
            val=true;
        end
    else
        val=false;
    end
end