function names=hdlfixblockname(names)










    names=strrep(names,char(9),' ');
    names=strrep(names,char(10),' ');
    names=strrep(names,char(12),' ');
    names=strrep(names,char(13),' ');

end
