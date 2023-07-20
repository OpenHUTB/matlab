function replaceByTerminator(this,newWritePath,newNtwPath,drivingPortStr,termStr)



    tH=add_block('simulink/Sinks/Terminator',[newNtwPath,'/',termStr]);

    writePos=get_param(newWritePath,'Position');
    writeCtrVer=(writePos(4)-writePos(2))/2+writePos(2);
    writeCtrHor=(writePos(3)-writePos(1))/2+writePos(1);


    blkPos=get_param(tH,'Position');
    blkHeight=blkPos(4)-blkPos(2);
    blkWidth=blkPos(3)-blkPos(1);

    newBlkPos=[writeCtrHor-blkWidth/2,writeCtrVer-blkHeight/2,writeCtrHor+blkWidth/2,writeCtrVer+blkHeight/2];
    set_param(tH,'Position',newBlkPos);

    tPortStr=[get_param(tH,'Name'),'/1'];
    add_line(newNtwPath,drivingPortStr,tPortStr,'autorouting','smart');

end

