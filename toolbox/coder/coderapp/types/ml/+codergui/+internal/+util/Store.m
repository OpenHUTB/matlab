classdef(Abstract)Store<handle




    methods(Abstract)
        value=read(this,key)

        exists=has(this,key)

        write(this,key,value)

        remove(this,key)

        flush(this)
    end
end
