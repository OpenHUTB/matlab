function this=copyStorageIfNeededBeforeWrite(this)













    if isa(this.Storage_,'matlab.mixin.Copyable')
        this.Storage_=copy(this.Storage_);
    end
end
