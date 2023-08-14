function param=stripComments(param)




    if contains(param,'%')
        param=extractBefore(param,'%');
    end
    param=strip(param);

end