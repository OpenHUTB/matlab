function safeRunPostReplacementCallBack(obj,blockInfo)




    if~isempty(obj.PostReplacementCallBack)
        nInputs=nargin(obj.PostReplacementCallBack);
        BlockH=blockInfo.ReplacementInfo.AfterReplacementH;
        BlockFullPath=getfullname(BlockH);










        ConfigSubsystemH=[];
        try
            if nInputs==1
                obj.PostReplacementCallBack(BlockH);
            elseif nInputs==2
                userblockInfo=blockInfo.infoForPostReplacement;
                obj.PostReplacementCallBack(BlockH,userblockInfo);
            elseif nInputs==3
                userblockInfo=blockInfo.infoForPostReplacement;
                obj.PostReplacementCallBack(BlockH,userblockInfo,blockInfo.SldvOptConfig);
            else
                userblockInfo=blockInfo.infoForPostReplacement;
                obj.PostReplacementCallBack(BlockH,userblockInfo,blockInfo.SldvOptConfig,ConfigSubsystemH);
            end
        catch Mex
            newExc=MException('Sldv:xform:BlkRepRule:safeRunPostReplacementCallBack:PostReplacementFailed',...
            'Execution of the PostReplacementCallBack of the rule ''%s'' failed for block ''%s''.',...
            obj.FileName,getfullname(BlockH));
            newExc=newExc.addCause(Mex);
            throw(newExc);
        end
        blockInfo.ReplacementInfo.AfterReplacementH=get_param(BlockFullPath,'handle');
    end
end

