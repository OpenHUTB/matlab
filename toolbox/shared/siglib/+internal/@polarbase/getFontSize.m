function pt=getFontSize(p)


    switch p.FontSizeMode
    case 'auto'
        pt=bestFontSize(p);
    otherwise
        pt=p.pFontSize;
    end
