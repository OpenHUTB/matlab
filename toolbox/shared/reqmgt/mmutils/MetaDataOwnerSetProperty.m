function MetaDataOwnerSetProperty(this,propertyName,value)



    if isempty(this.data)
        this.data=this.addData();
    end

    if isempty(value)

        for n=1:this.data.names.size
            if strcmp(this.data.names.at(n),propertyName)
                this.data.names.erase(n);
                this.data.values.erase(n);
                return;
            end
        end
    else

        for n=1:this.data.names.size
            if strcmp(this.data.names.at(n),propertyName)
                this.data.values.erase(n);
                this.data.values.insert(n,value);
                return;
            end
        end


        this.data.names.append(propertyName);
        this.data.values.append(value);
    end
end


