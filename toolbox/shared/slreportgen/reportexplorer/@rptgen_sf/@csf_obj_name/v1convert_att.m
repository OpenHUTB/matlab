function att=v1convert_att(h,att,varargin)




    if att.isfullname
        if att.issimulinkname
            nameType='slsfname';
        else
            nameType='sfname';
        end
    else
        nameType='name';
    end

    att.NameType=nameType;

