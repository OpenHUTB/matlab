function displayEmlCodegenMessage(this,hC)




    slbh=hC.SimulinkHandle;
    if(slbh>0)
        try
            blkName=this.localGetBlockName(slbh);
        catch mEx
            blkName=getfullname(slbh);
        end
    else
        blkName=':unknown:';
    end

    fprintf('Creating CGIR using MATLABImplementation for ''%s''\n',blkName);

end
