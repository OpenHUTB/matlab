function anchorstr=makeAnchorStr(userstr,lengthLimit)







    if~ischar(userstr)
        error('rmiut.makevalidname() expects a character string input');
    end

    if nargin<2
        lengthLimit=40;
    end


    userstr=strtrim(userstr);


    userstr(isspace(userstr))='_';


    anchorstr=regexprep(userstr,'\W','');

    if length(anchorstr)>lengthLimit
        anchorstr(lengthLimit+1:end)=[];
    end

end
