function setModelName(this,name)






    if isempty(name)
        error(message('hdlcoder:engine:MdlNameError'));
    end

    this.ModelName=name;



