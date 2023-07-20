function this=FILSfunctionDialogT(blkH,dummy)%#ok<INUSD>

    this=eda.FILSfunctionDialogT(blkH);



    switch(class(blkH))
    case 'char'
        this.block=get_param(blkH,'Object');
    case 'double'
        this.block=get(blkH,'Object');
    otherwise
        error(message('EDALink:FILSfunctionDialogT:BackBlockArg'));
    end


    parent=this.block.getParent;
    while(~isa(parent,'Simulink.BlockDiagram'))
        parent=parent.getParent;
    end
    this.root=parent;

    this.params=this.block.UserData;
    this.buildInfo=this.params.buildInfo;
    this.dialogState=this.params.dialogState;

end
