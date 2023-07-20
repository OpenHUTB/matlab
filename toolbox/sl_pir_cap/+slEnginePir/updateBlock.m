function newblk=updateBlock(fname,refblocks,libraryblockcolor)

    if strcmp(fname,refblocks)
        newblk=fname;
        return;
    end

    if nargin<3
        libraryblockcolor='White';
    end


    pos=get_param(fname,'Position');
    ori=get_param(fname,'Orientation');
    namepl=get_param(fname,'NamePlacement');


    pv=slEnginePir.getMaskDlgParams(fname);

    delete_block(fname);



    tmpnewblk=add_block(refblocks,[fname,num2str(rand)],'Position',[0,0,0,0]);

    slEnginePir.setMaskParams(tmpnewblk,pv);

    newblk=add_block(tmpnewblk,fname,'Position',pos,'Orientation',ori,'NamePlacement',namepl);



    delete_block(tmpnewblk);
end