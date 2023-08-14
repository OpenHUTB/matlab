function mustBeSameLength(a,b,name1,name2)




    if numel(a)~=numel(b)
        error(message('aero:validators:mustBeSameLength',name1,name2))
    end

end

