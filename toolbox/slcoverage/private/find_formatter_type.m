function num=find_formatter_type(str)




    persistent Caption_Type_Strings Caption_Type_Values;

    if isempty(Caption_Type_Strings)
        [~,names]=cv('subproperty','formatter.keyNum');
        [Caption_Type_Strings,I]=sort(names{1});
        Caption_Type_Values=I-1;
    end




    testCell{1}=str;
    Match=strcmp(testCell,Caption_Type_Strings);
    Index=find(Match);
    if isempty(Index),
        error(message('Slvnv:simcoverage:find_formatter_type:NoMatchFormatter'));
    end
    if length(Index)>1,
        error(message('Slvnv:simcoverage:find_formatter_type:MultipleMatch'));
    end
    num=Caption_Type_Values(Index);
