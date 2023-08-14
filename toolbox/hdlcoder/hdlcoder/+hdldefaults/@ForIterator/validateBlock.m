
function v=validateBlock(~,hC)






    v=hdlvalidatestruct;


    if strcmp(hdlfeature('EnableForIterator'),'off')
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:engine:missingImplementation',getfullname(hC.SimulinkHandle)));
    end

end
