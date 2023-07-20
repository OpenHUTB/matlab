function OutputName=NameFilter(name)


    NameNoSpace=name(~isspace(name));


    NameNoSpace=erase(NameNoSpace,'(');
    NameNoSpace=erase(NameNoSpace,')');
    OutputName=erase(NameNoSpace,'-');

