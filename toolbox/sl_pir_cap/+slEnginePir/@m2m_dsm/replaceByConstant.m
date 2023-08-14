function replaceByConstant(this,newRead,newNtwPath,newMemory)



    cH=add_block('simulink/Sources/Constant',[newNtwPath,'/Constant'],'MakeNameUnique','on');
    blkPos=get_param(cH,'Position');


    initValue=get_param(newMemory,'InitialValue');
    set_param(cH,'Value',initValue);


    dataTypeStr=get_param(newMemory,'OutDataTypeStr');
    if~strcmp(dataTypeStr,'Inherit: auto')
        set_param(cH,'OutDataTypeStr',dataTypeStr);
    end


    dimStr=get_param(newMemory,'Dimensions');
    if~strcmp(dimStr,'-1')
        set_param(cH,'Value',[initValue,'*','ones(',dimStr,')']);
    end


    readPortConn=get_param(newRead,'portconnectivity');
    readPortPos=readPortConn.Position;
    constPortConn=get_param(cH,'portconnectivity');
    constPortPos=constPortConn.Position;
    vec=constPortPos-readPortPos;

    newBlkPos=blkPos-[vec(1),vec(2),vec(1),vec(2)];
    delete_block(newRead);
    set_param(cH,'Position',newBlkPos);

end

