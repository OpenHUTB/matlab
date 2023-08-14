function att=v1convert_att(h,att,varargin)




    att.ShowNamePrompt=att.isNamePrompt;
    att=rmfield(att,'isNamePrompt');



    att.Title=att.TitleString;
    att=rmfield(att,'TitleString');

    switch att.TitleType
    case 'blkname'
        att.TitleType='name';
    case 'other'
        att.TitleType='manual';
    end

    switch att.HeaderType
    case 'blkname'
        att.HeaderType='typename';
    end


    att.ObjectType='Block';