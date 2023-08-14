function synthesizedBlks=getSynthesizedBlocks(blkHdls)




    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    synthesizedBlks=[];
    numObjects=numel(blkHdls);
    for k=1:numObjects
        blkObj=get_param(blkHdls(k),'Object');
        if blkObj.isSynthesized
            synthesizedBlks(end+1)=blkHdls(k);%#ok
        end
    end

    synthesizedBlks=synthesizedBlks(:);

end
