function colheader=getDimsPropTableColHeader(this)





    block=this.getBlock;

    [idxopt_head,~]=DAStudio.message('Simulink:blocks:IndexOptionPromp');
    colheader{this.getColId('idxopt')}=idxopt_head;
    colheader{this.getColId('idx')}=block.IntrinsicDialogParameters.IndexParamArray.Prompt;
    colheader{this.getColId('outsize')}=block.IntrinsicDialogParameters.OutputSizeArray.Prompt;

end

