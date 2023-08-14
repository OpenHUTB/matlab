function att=v1convert_att(this,att,varargin)





    att.SortBy=att.SortBy(2:end);


    if strcmp(att.SortBy,'findsys')
        att.SortBy='none';
    end


    att.LoopType=att.LoopType(2:end);