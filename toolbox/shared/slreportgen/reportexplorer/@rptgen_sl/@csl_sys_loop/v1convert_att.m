function att=v1convert_att(h,att,varargin)





    if strcmp(att.SortBy,'$alphabetical')

        att.SortBy='systemalpha';
    else

        att.SortBy=att.SortBy(2:end);
    end


    att.LoopType=att.LoopType(2:end);
