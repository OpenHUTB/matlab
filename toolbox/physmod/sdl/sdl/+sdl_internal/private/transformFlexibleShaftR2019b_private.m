function out=transformFlexibleShaftR2019b_private(in)





    out=in;



    length=getValue(in,'length');
    length_unit=getValue(in,'length_unit');
    d_bearing_trans=getValue(in,'d_bearing_trans');
    d_bearing_trans_unit=getValue(in,'d_bearing_trans_unit');
    d_bearing_rotation=getValue(in,'d_bearing_rotation');
    d_bearing_rotation_unit=getValue(in,'d_bearing_rotation_unit');
    KtransC_row=getValue(in,'KtransC_row');
    KtransC_row_unit=getValue(in,'KtransC_row_unit');
    KtransR_row=getValue(in,'KtransR_row');
    KtransR_row_unit=getValue(in,'KtransR_row_unit');
    userMode_shape=getValue(in,'userMode_shape');



    out=setValue(out,'boundaryB1',getValue(in,'boundaryC'));
    out=setValue(out,'boundaryF1',getValue(in,'boundaryR'));
    out=setValue(out,'KrotB1_row',getValue(in,'KrotC_row'));
    out=setValue(out,'KrotB1_row_unit',getValue(in,'KrotC_row_unit'));

    out=setValue(out,'KrotF1_row',getValue(in,'KrotR_row'));
    out=setValue(out,'KrotF1_row_unit',getValue(in,'KrotR_row_unit'));





    KtransC_row_value=str2num(KtransC_row);%#ok<*ST2NM>
    if~isempty(KtransC_row_value)
        KtransB1_row_char=['[',num2str(KtransC_row_value(1)),', 0, 0, ',num2str(KtransC_row_value(2)),']'];
    elseif isvarname(KtransC_row)
        KtransB1_row_char=['[',KtransC_row,'(1), 0, 0, ',KtransC_row,'(2)]'];
    else
        KtransB1_row_char=['[getfield(',KtransC_row,',{1}), 0, 0, ','getfield(',KtransC_row,',{2})]'];
    end
    out=setValue(out,'KtransB1_row',KtransB1_row_char);
    out=setValue(out,'KtransB1_row_unit',KtransC_row_unit);


    KtransR_row_value=str2num(KtransR_row);%#ok<*ST2NM>
    if~isempty(KtransR_row_value)
        KtransF1_row_char=['[',num2str(KtransR_row_value(1)),', 0, 0, ',num2str(KtransR_row_value(2)),']'];
    elseif isvarname(KtransR_row)
        KtransF1_row_char=['[',KtransR_row,'(1), 0, 0, ',KtransR_row,'(2)]'];
    else
        KtransF1_row_char=['[getfield(',KtransR_row,',{1}), 0, 0, ','getfield(',KtransR_row,',{2})]'];
    end
    out=setValue(out,'KtransF1_row',KtransF1_row_char);
    out=setValue(out,'KtransF1_row_unit',KtransR_row_unit);





    out=setValue(out,'z_support',['[0, ',length,']']);
    out=setValue(out,'z_support_unit',length_unit);


    d_bearing_trans_value=str2num(d_bearing_trans);%#ok<*ST2NM>
    if~isempty(d_bearing_trans_value)
        DtransB1_row_char=['[',num2str(d_bearing_trans_value(1)),', 0, 0, ',num2str(d_bearing_trans_value(1)),']'];
        DtransF1_row_char=['[',num2str(d_bearing_trans_value(2)),', 0, 0, ',num2str(d_bearing_trans_value(2)),']'];
    elseif isvarname(d_bearing_trans)
        DtransB1_row_char=['[',d_bearing_trans,'(1), 0, 0, ',d_bearing_trans,'(1)]'];
        DtransF1_row_char=['[',d_bearing_trans,'(2), 0, 0, ',d_bearing_trans,'(2)]'];
    else
        DtransB1_row_char=['[getfield(',d_bearing_trans,',{1}), 0, 0, ','getfield(',d_bearing_trans,',{1})]'];
        DtransF1_row_char=['[getfield(',d_bearing_trans,',{2}), 0, 0, ','getfield(',d_bearing_trans,',{2})]'];
    end
    out=setValue(out,'DtransB1_row',DtransB1_row_char);
    out=setValue(out,'DtransB1_row_unit',d_bearing_trans_unit);
    out=setValue(out,'DtransF1_row',DtransF1_row_char);
    out=setValue(out,'DtransF1_row_unit',d_bearing_trans_unit);



    d_bearing_rotation_value=str2num(d_bearing_rotation);%#ok<*ST2NM>
    if~isempty(d_bearing_rotation_value)
        DrotB1_row_char=['[',num2str(d_bearing_rotation_value(1)),', ',num2str(d_bearing_rotation_value(1)),']'];
        DrotF1_row_char=['[',num2str(d_bearing_rotation_value(2)),', ',num2str(d_bearing_rotation_value(2)),']'];
    elseif isvarname(d_bearing_rotation)
        DrotB1_row_char=['[',d_bearing_rotation,'(1), ',d_bearing_rotation,'(1)]'];
        DrotF1_row_char=['[',d_bearing_rotation,'(2), ',d_bearing_rotation,'(2)]'];
    else
        DrotB1_row_char=['[getfield(',d_bearing_rotation,',{1}), ','getfield(',d_bearing_rotation,',{1})]'];
        DrotF1_row_char=['[getfield(',d_bearing_rotation,',{2}), ','getfield(',d_bearing_rotation,',{2})]'];
    end
    out=setValue(out,'DrotB1_row',DrotB1_row_char);
    out=setValue(out,'DrotB1_row_unit',d_bearing_rotation_unit);
    out=setValue(out,'DrotF1_row',DrotF1_row_char);
    out=setValue(out,'DrotF1_row_unit',d_bearing_rotation_unit);


    userMode_shape_value=str2num(userMode_shape);%#ok<*ST2NM>
    if~isempty(userMode_shape_value)
        userMode_shapeX_char=mat2str(userMode_shape_value(:,1:2:end));
        userMode_shapeY_char=mat2str(userMode_shape_value(:,2:2:end));
    elseif isvarname(d_bearing_rotation)
        userMode_shapeX_char=[userMode_shape,'(:,1:2:end)'];
        userMode_shapeY_char=[userMode_shape,'(:,2:2:end)'];
    else
        userMode_shapeX_char=['getfield(',userMode_shape,',{ [1:size(',userMode_shape,',1)],[1:2:size(',userMode_shape,',2)] })'];
        userMode_shapeY_char=['getfield(',userMode_shape,',{ [1:size(',userMode_shape,',1)],[2:2:size(',userMode_shape,',2)] })'];
    end
    out=setValue(out,'userMode_shapeX',userMode_shapeX_char);
    out=setValue(out,'userMode_shapeY',userMode_shapeY_char);


end


