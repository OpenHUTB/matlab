function setAsMxArray(this,newValue,units,jsIndex)


    dirty=false;

    this.usage.propertyDef.type.validateValue(newValue);


    if isempty(this.value)

        this.cachedValue=newValue;
        dirty=true;
    else


        if isempty(this.cachedValue)
            currentValue=jsondecode(this.value);
        else
            currentValue=this.cachedValue;
        end


        if nargin>3

            if length(newValue)==1

                index=prod(jsIndex+1);
                if newValue~=currentValue(index)
                    this.cachedValue(index)=newValue;
                    dirty=true;
                end
            else

                index=jsIndex+1;
                indexStr="("+string(index(1));
                for i=2:length(index)
                    indexStr=indexStr+","+string(index(i));
                end

                indexStr=indexStr+",:)";
                if~all(newValue~=eval("currentValue"+indexStr))
                    eval("this.cachedValue"+indexStr+"= newValue;");
                    dirty=true;
                end
            end
        else
            if~isequal(newValue,currentValue)
                this.cachedValue=newValue;
                dirty=true;
            end
        end
    end



    if nargin>2&&(ischar(units)||isstring(units))
        this.units=units;
    end

    if dirty

        if(isenum(this.cachedValue))
            if(length(this.cachedValue)==1)
                this.value=jsonencode(char(this.cachedValue));
            else
                charEnum={};
                for e=this.cachedValue
                    charEnum{end+1}=char(e);
                end
                this.value=jsonencode(charEnum);
            end
        else
            this.value=jsonencode(this.cachedValue);
        end


        s=size(this.cachedValue);
        this.dimensions.clear
        for d=s
            this.dimensions.add(uint64(d));
        end
        this.isDirty=true;
    end
end