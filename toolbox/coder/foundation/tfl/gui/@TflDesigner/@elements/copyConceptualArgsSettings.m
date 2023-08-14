function copyConceptualArgsSettings(this)







    cargs=this.object.ConceptualArgs;
    impl=this.object.Implementation;
    if isempty(cargs)
        return;
    end

    for idx=1:length(cargs)
        currentArg=this.object.ConceptualArgs(idx);
        if~isempty(impl.Return)&&...
            strcmp(impl.Return.Name,currentArg.Name)
            isConst=~isempty(strfind(impl.Return.toString,'const'));
            isVolatile=~isempty(strfind(impl.Return.toString,'volatile'));

            des=[];
            if~isempty(impl.Return.Descriptor)
                des=impl.Return.Descriptor;
            end

            impl.Return=[];
            impl.Return=createImplFromConceptual(this,currentArg,true);
            if isConst
                arg=impl.Return;
                if isa(arg,'RTW.TflArgPointer')||isa(arg,'RTW.TflArgComplex')
                    if isa(arg.Type.BaseType,'RTW.TflArgPointer')||...
                        isa(arg.Type.BaseType,'RTW.TflArgComplex')
                        arg.Type.BaseType.BaseType.ReadOnly=true;
                    else
                        arg.Type.BaseType.ReadOnly=true;
                    end
                else
                    arg.Type.ReadOnly=true;
                end
            end
            if isVolatile
                impl.Return.Type.Volatile=true;
            end

            if~isempty(des)
                impl.Return.Descriptor=des;
            end
        else
            for jdx=1:length(impl.Arguments)
                if strcmp(impl.Arguments(jdx).Name,currentArg.Name)
                    remainingargs=impl.Arguments(jdx+1:end);
                    isConst=~isempty(strfind(impl.Arguments(jdx).toString,'const'));
                    isVolatile=~isempty(strfind(impl.Arguments(jdx).toString,'volatile'));
                    argInPlace='';
                    if isprop(impl.Arguments(jdx),'ArgumentForInPlaceUse')
                        argInPlace=impl.Arguments(jdx).ArgumentForInPlaceUse;
                    end
                    des=[];
                    if~isempty(impl.Arguments(jdx).Descriptor)
                        des=impl.Arguments(jdx).Descriptor;
                    end

                    impl.Arguments(jdx:end)=[];
                    arg=createImplFromConceptual(this,currentArg,false);
                    if isConst
                        if isa(arg,'RTW.TflArgPointer')||isa(arg,'RTW.TflArgComplex')
                            if isa(arg.Type.BaseType,'RTW.TflArgPointer')||...
                                isa(arg.Type.BaseType,'RTW.TflArgComplex')
                                arg.Type.BaseType.BaseType.ReadOnly=true;
                            else
                                arg.Type.BaseType.ReadOnly=true;
                            end
                        else
                            arg.Type.ReadOnly=true;
                        end
                    end
                    if isVolatile
                        arg.Type.Volatile=true;
                    end
                    if~isempty(argInPlace)
                        arg.ArgumentForInPlaceUse=argInPlace;
                    end
                    if~isempty(des)
                        arg.Descriptor=des;
                    end
                    impl.addArgument(arg);
                    impl.Arguments=[impl.Arguments;remainingargs];
                    break;
                end
            end
        end
    end

    if~isempty(impl.Return)
        returnargname=impl.Return.Name;

        for i=1:length(cargs)
            if strcmp(cargs(i).Name,returnargname)
                if(isa(cargs(i),'RTW.TflArgMatrix')||...
                    isa(cargs(i),'RTW.TflArgStruct'))&&...
                    isa(impl.Return,'RTW.TflArgPointer')
                    if isempty(impl.Arguments)
                        impl.Arguments=impl.Return;
                    else
                        impl.Arguments(end+1)=impl.Return;
                    end
                    arg=this.object.getTflArgFromString('unused','void');
                    arg.IOType='RTW_IO_OUTPUT';
                    impl.Return=arg;
                    break;
                end
            end
        end
    end


    function arg=createImplFromConceptual(this,carg,isreturn)

        if isa(carg,'RTW.TflArgStruct')&&this.isStructSpecEnabled
            arg=createImplStructFromConceptualStruct(this,carg);

            this.iargstructfields={};
            return;
        end


        type=carg.toString(true);

        type=strrep(type,'const ','');
        type=strrep(type,'volatile ','');
        type=strrep(type,' ','');

        type(find(type=='['):find(type==']'))=[];
        type=formatFixpointString(type);

        if isa(carg,'RTW.TflArgMatrix')||...
            (strcmp(carg.IOType,'RTW_IO_OUTPUT')&&~isreturn)
            type=strcat(type,'*');
        end

        arg=this.object.getTflArgFromString(carg.Name,type);
        arg.IOType=carg.IOType;


        function arg=createImplStructFromConceptualStruct(~,carg)

            emStructType=carg.Type;

            implStructElements=[];

            for idx=1:numel(emStructType.Elements)
                currElement=emStructType.Elements(idx);

                tempArg=RTW.TflArgNumeric;
                tempArg.Type=currElement.Type;
                elemTypeStr=tempArg.toString(true);

                elemTypeStr=strrep(elemTypeStr,' ','');
                elemTypeStr=formatFixpointString(elemTypeStr);

                numericType=numerictype(elemTypeStr);
                structElement=embedded.structelement;
                structElement.Type=numericType;
                structElement.Identifier=currElement.Identifier;

                implStructElements=[implStructElements,structElement];%#ok
            end

            implStructType=embedded.structtype;
            implStructType.Identifier=emStructType.Identifier;
            implStructType.Elements=implStructElements;

            implPtrType=embedded.pointertype;
            implPtrType.BaseType=implStructType;

            arg=RTW.TflArgPointer;
            arg.Name=carg.Name;
            arg.Type=implPtrType;
            arg.IOType=carg.IOType;


            function type=formatFixpointString(dttype)

                if isempty(strfind(dttype,'fix'))
                    type=dttype;
                else
                    dtype=dttype(strfind(dttype,'(')+1:strfind(dttype,')')-1);

                    [signbit,r]=strtok(dtype,',');
                    signbit=logical(eval(signbit));
                    wordLength=strtok(r,',');

                    if isempty(str2num(wordLength))%#ok
                        type=wordLength;
                        return;
                    end

                    allowableLengths={'8','16','32','64'};

                    if isempty(find(strcmp(allowableLengths,wordLength),1))
                        wordLength='32';
                    end

                    if signbit
                        type=strcat('int',wordLength);
                    else
                        type=strcat('uint',wordLength);
                    end

                    type=strcat(dttype(1:strfind(dttype,'fix')-1),type);
                    type=strcat(type,dttype((strfind(dttype,')')+1):end));
                end


