function block=setBlock(this,block)







    switch class(block)
    case 'char'

        block=get_param(block,'Object');
    case 'double'
        block=get(block,'Object');
    end

