function topNetFullPath=getTopNetFullPath(topNet,hDI)


    topNetFullPath=topNet.FullPath;


    if(~hDI.isMLHDLC)
        hdlcoder=hDI.hCodeGen.hCHandle;
        if hdlcoder.DUTMdlRefHandle>0
            snnH=get_param(hdlcoder.OrigStartNodeName,'handle');
            if isprop(snnH,'BlockType')&&~strcmp(get_param(snnH,'BlockType'),'ModelReference')
                topNetFullPath=hDI.hCodeGen.hCHandle.OrigStartNodeName;
            end
        end
    end
end