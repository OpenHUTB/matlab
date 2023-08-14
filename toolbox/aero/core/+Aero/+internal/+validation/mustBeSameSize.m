function mustBeSameSize(a,b,name1,name2)




    if~Aero.internal.validation.isSameSize(a,b)
        error(message('aero:validators:mustBeSameSize',name1,name2))
    end

end

