function hBlk=getSelectedBlock(cbinfo)





    hBlk=[];
    s=cbinfo.getSelection();
    if isscalar(s)&&isa(s,'Simulink.Block')&&~isempty(s.Handle)
        hBlk=s.Handle;
    end

end