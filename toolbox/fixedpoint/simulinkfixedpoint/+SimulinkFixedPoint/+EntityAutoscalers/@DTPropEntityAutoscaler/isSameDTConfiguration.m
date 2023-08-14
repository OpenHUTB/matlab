function isSameDT=isSameDTConfiguration(this,blkObj)






    isSameDT=false;
    ph=blkObj.PortHandles;
    sourcePortA=getAllSourceSignal(this,get_param(ph.Inport(1),'Object'),false);
    sourcePortB=getAllSourceSignal(this,get_param(ph.Inport(2),'Object'),false);
    if isequal(sourcePortA,sourcePortB)
        signedness=~ismember(blkObj.IsSigned,{'TRUE','FALSE'});
        numBits=~isequal(blkObj.NumBitsBase,'NumBits1+NumbBits2');
        numBitsMul=isequal(blkObj.NumBitsMult,'1');
        numBitsAdd=isequal(blkObj.NumBitsAdd,'0');
        slopeBase=~contains(blkObj.SlopeBase,{'*','/'});
        biasBase=~contains(blkObj.BiasBase,{'*','/','+','-'});
        slopeMult=isequal(blkObj.SlopeMult,'1');
        slopeAdd=isequal(blkObj.SlopeAdd,'0');
        biasMult=isequal(blkObj.BiasMult,'1');
        biasAdd=isequal(blkObj.BiasAdd,'0');



        isSameDT=...
        signedness&&numBits&&numBitsMul&&numBitsAdd&&...
        slopeBase&&biasBase&&slopeMult&&slopeAdd&&biasMult&&biasAdd;
    end
end