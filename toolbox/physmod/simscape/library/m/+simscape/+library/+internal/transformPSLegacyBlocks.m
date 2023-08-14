function outData=transformPSLegacyBlocks(inData)





    outData=lLookupTable16a(inData);





    srcIdx=find(strcmp({outData.NewInstanceData.Name},'SourceFile'),1);
    if isempty(srcIdx)
        srcIdx=find(strcmp({outData.NewInstanceData.Name},'ComponentPath'),1);
        if isempty(srcIdx)
            return;
        end
    end


    persistent list oldPths;
    if isempty(list)
        list=simscape.compiler.mli.internal.PSLegacyList;
        oldPths={list.oldPth};
    end

    sourceFile=inData.InstanceData(srcIdx).Value;
    listIdx=find(strcmp(oldPths,sourceFile),1);
    if isempty(listIdx)
        return;
    end

    if list(listIdx).auto


        outData.NewInstanceData(srcIdx).Value=list(listIdx).newPth;
        outData.NewBlockPath=list(listIdx).newLib;
    else


        outData.NewBlockPath=list(listIdx).legacyLib;
    end

end


function outData=lLookupTable16a(inData)





    oldVersion=inData.ForwardingTableEntry.('__slOldVersion__');

    if(oldVersion<'8007000.1')
        oldBlk=inData.ForwardingTableEntry.('__slOldName__');
        if strcmp(oldBlk,'fl_lib/Physical Signals/Lookup Tables/PS Lookup Table (1D)')
            outData=simscape.library.internal.transformPSLookupTable1DR2016a(inData);
        elseif strcmp(oldBlk,'fl_lib/Physical Signals/Lookup Tables/PS Lookup Table (2D)')
            outData=simscape.library.internal.transformPSLookupTable2DR2016a(inData);
        else
            outData.NewInstanceData=inData.InstanceData;
        end
    else
        outData.NewInstanceData=inData.InstanceData;
    end
    outData.NewBlockPath=inData.ForwardingTableEntry.('__slOldName__');
end
