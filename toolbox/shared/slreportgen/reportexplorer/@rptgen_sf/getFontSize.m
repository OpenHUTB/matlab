function fontSize=getFontSize(obj)




    fontSize=12;
    objType=strsplit(class(obj),'.');
    objType=objType{end};
    switch objType
    case 'Chart'










    case{'State','Box','Function'}













    case 'Transition'
        fontSize=obj.FontSize;
    case 'Junction'
        fontSize=obj.position.radius;
    end

