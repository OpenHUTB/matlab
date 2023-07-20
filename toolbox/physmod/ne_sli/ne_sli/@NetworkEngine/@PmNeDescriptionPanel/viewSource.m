function viewSource(hThis)




    hBlk=pmsl_getdoublehandle(hThis.BlockHandle);
    openSource=nesl_private('nesl_opensourcefile');
    openSource(hBlk);

end
