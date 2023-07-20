function[minLength,maxLength]=getNameLength(group)







    switch group
    case 'JMAAB'
        minLength='0';
        maxLength='63';
    case 'MAAB'
        minLength='2';
        maxLength='64';
    otherwise
        minLength='3';
        maxLength='63';
    end
end
