function isTabbed(obj)





    if isR2019aOrEarlier(obj.ver)



        obj.appendRule('<Object<IsTabbed|0>:remove>');

        obj.appendRule('<IsTabbed:remove>');
    end

end
