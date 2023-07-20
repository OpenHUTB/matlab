function arch=getArchitecture()




    switch(computer)
    case 'PCWIN'
        arch='win32';
    case 'PCWIN64'
        arch='win64';
    otherwise
        arch=lower(computer);
    end

end