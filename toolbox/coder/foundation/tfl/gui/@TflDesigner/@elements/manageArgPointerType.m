function newarg=manageArgPointerType(h,arg,action)





    if strcmp(action,'add')
        if isa(arg,'RTW.TflArgPointer')
            newarg=arg;
            return;
        end

        type=arg.toString(true);

        mtype=strrep(type,'const ','');
        mtype=strrep(mtype,'volatile ','');
        mtype=strrep(mtype,' ','');
        mtype=strcat(mtype,'*');

        newarg=createArg(h,arg,mtype);

    elseif strcmp(action,'remove')
        if~isa(arg,'RTW.TflArgPointer')
            newarg=arg;
            return;
        end

        type=arg.toString(true);

        mtype=strrep(type,'const ','');
        mtype=strrep(mtype,'volatile ','');
        mtype=strrep(mtype,' ','');
        if strcmp(mtype(end),'*')
            mtype(end)=[];
        end
        newarg=createArg(h,arg,mtype);
    end


    function newarg=createArg(h,oldarg,type)
        origtype=oldarg.toString(true);

        newarg=h.object.getTflArgFromString(oldarg.Name,type);
        if strcmp(origtype,'const')
            newarg.Type.ReadOnly=true;
        end
        if strcmp(origtype,'volatile')
            newarg.Type.Volatile=true;
        end

        newarg.IOType=oldarg.IOType;
        newarg.Descriptor=oldarg.Descriptor;
        newarg.CheckType=oldarg.CheckType;
        if isa(newarg,'RTW.TflArgPointer')
            if isprop(oldarg,'IsUnsizedInt')
                newarg.BaseTypeIsUnsizedInt=oldarg.IsUnsizedInt;
                newarg.BaseTypeIsUnsizedLong=oldarg.IsUnsizedLong;
                newarg.BaseTypeIsUnsizedLongLong=oldarg.IsUnsizedLongLong;
            end
        else
            if isprop(oldarg,'BaseTypeIsUnsizedInt')
                newarg.IsUnsizedInt=oldarg.BaseTypeIsUnsizedInt;
                newarg.IsUnsizedLong=oldarg.BaseTypeIsUnsizedLong;
                newarg.IsUnsizedLongLong=oldarg.BaseTypeIsUnsizedLongLong;
            end
        end

