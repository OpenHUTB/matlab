function retval=forceElabModelGen(this,hN,hPreElabC)











    retval=false;

    addpipe=this.getImplParams('AddPipelineRegisters');
    if isempty(addpipe)
        addpipe=0;
    else
        addpipe=strcmpi(addpipe,'on');
    end

    hasInternalPipe=addpipe;



    if hN.isInConditionalHierarchy&&hasInternalPipe
        retval=true;
    end