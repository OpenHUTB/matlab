function disp(hCSCAttributes)


    disp(class(hCSCAttributes));
    temp=hCSCAttributes.get;%#ok<NASGU>
    out=evalc('builtin(''disp'',temp);');
    if slfeature('BackFoldSafeCSC')<3

        out=regexprep(out,'ConcurrentAccess: 0.*?\n','');
    end
    disp(out);

