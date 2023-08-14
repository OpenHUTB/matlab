function pt_applyPresetTable(this,tableName)








    switch lower(tableName)
    case 'default'
        title='%<Name> Block Information';
        colWid=[1,2];
        singleVal=true;
        pnames={
'%<OutDataTypeStr>'
'%<Precision>'
'%<Description>'
        };

    case 'fixed-point binary-point scaling'
        title='%<Name> Fixed-Point Scaling';
        colWid=[1,2];
        singleVal=true;
        pnames=getPropList(rptgen_fp.propsrc_fp_blk,'fixpoint-binary-point');
        pnames=strcat('%<',pnames,'>');

    case 'fixed-point slope-bias scaling'
        title='%<Name> Fixed-Point Scaling';
        colWid=[1,2];
        singleVal=true;
        pnames=getPropList(rptgen_fp.propsrc_fp_blk,'fixpoint-slope-bias');
        pnames=strcat('%<',pnames,'>');

    case 'block limits'
        title='';
        colWid=[1.5,1,1.5,1];
        singleVal=true;
        pnames={
        '%<Name>','%<OutDataTypeStr>'
        '%<Slope>','%<Bias>'
        '%<RepresentableMinimum>','%<RepresentableMaximum>'
        '%<OutputMinimum>','%<OutputMaximum>'
        '%<SimMin>','%<SimMax>'
        };

    case 'out-of-range errors'
        title='%<Name> Out-Of-Range Errors';
        colWid=[1,2];
        singleVal=true;
        pnames=getPropList(rptgen_fp.propsrc_fp_blk,'errors');
        pnames=strcat('%<',pnames,'>');

    case 'all fixed-point properties'
        title='%<Name> Fixed Point Information';
        colWid=[1,2];
        singleVal=true;
        pnames=getPropList(rptgen_fp.propsrc_fp_blk,'all');
        pnames=strcat('%<',pnames,'>');

    otherwise
        title='Title';
        singleVal=false;
        colWid=[1,1,1,1];
        [pnames{1:4,1:4}]=deal('');
    end

    this.setTableStrings(pnames,singleVal,title);
    this.ColWidths=colWid;