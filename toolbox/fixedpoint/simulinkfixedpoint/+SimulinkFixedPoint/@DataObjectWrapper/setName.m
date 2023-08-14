function setName(this,name)





    if nargin>1
        name=convertStringsToChars(name);
    end

    this.Name=name;
end