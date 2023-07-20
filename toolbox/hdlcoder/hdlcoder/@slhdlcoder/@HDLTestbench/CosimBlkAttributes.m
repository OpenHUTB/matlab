function[tbname,blksize]=CosimBlkAttributes(this)







    tbname=hdlentitytop;

    origPos=get_param(this.ModelConnection.System,'Position');
    sizeX=origPos(3)-origPos(1);
    sizeY=origPos(4)-origPos(2);
    blksize=[sizeX,sizeY];


