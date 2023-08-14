


function v=validateBlock(~,hC)






    v=hdlvalidatestruct;



    v(end+1)=hdlvalidatestruct(1,...
    message('hdlcoder:engine:missingImplementation',getfullname(hC.SimulinkHandle)));

end
