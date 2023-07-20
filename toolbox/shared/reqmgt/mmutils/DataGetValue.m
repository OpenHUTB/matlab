function value=DataGetValue(this,name)

    value='';

    for n=1:this.names.size
        if strcmp(this.names.at(n),name)
            if n>this.values.size

            else
                value=this.values.at(n);
            end
            return;
        end
    end

end

