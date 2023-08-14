function att=v1convert_att(h,att,varargin)







    att.isFilterList=att.isSLFilterList;

    att.SFFilterTerms=att.FilterTerms{1};
    att.FilterTerms=att.FilterTerms{2};

    if~isempty(att.SFFilterTerms)&~isempty(att.SFFilterTerms{1})

        att.SFFilterTerms{1}=['.',att.SFFilterTerms{1}];
    end
