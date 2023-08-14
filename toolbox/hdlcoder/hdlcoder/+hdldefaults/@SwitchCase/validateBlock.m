function v=validateBlock(~,hC)




    v=hdlvalidatestruct;
    blkH=hC.SimulinkHandle;


    if strcmp(hdlfeature('EnableConditionalSubsystem'),'off')
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:engine:missingImplementation',getfullname(blkH)));
    end

end