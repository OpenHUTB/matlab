function dataVersion=getVersionFor(release,version)









    assert(isequal(length(release),5),'Release must be specified as 5-character string');
    assert(int32(str2num(release(1:4)))>=2016,'Release must be equal or greater than 2015');%#ok<ST2NM>
    assert(isequal(release(5),'a')||isequal(release(5),'b'),'Release must end with a or b');
    assert(~isinteger(version),'Version must be specified as an integer');
    dataVersion=[release(1:4),'.'...
    ,num2str(int8(release(5))-int8('a'))...
    ,num2str(version)];
end
