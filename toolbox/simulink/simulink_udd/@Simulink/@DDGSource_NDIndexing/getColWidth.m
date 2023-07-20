function colWidth=getColWidth(this,col)





    colheader=this.getDimsPropTableColHeader;
    switch col
    case 'idxopt'
        block=this.getBlock;
        lstIdxOpts=block.getPropAllowedValues('IdxOptString',true);
        colWidth=length(colheader{this.getColId(col)});
        for i=1:length(lstIdxOpts)
            colWidth=max(colWidth,length(lstIdxOpts{i}));
        end
    case{'idx','outsize'}
        colWidth=length(colheader{this.getColId(col)});
    otherwise
        colWidth=-1;
    end

end
