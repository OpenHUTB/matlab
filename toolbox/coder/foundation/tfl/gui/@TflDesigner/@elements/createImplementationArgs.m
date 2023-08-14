function createImplementationArgs(this)







    this.object.Implementation.Arguments=[];
    this.object.Implementation.Return=[];

    num_output=0;

    for id=1:length(this.object.ConceptualArgs)

        if strcmpi(this.object.ConceptualArgs(id).IOType,'RTW_IO_OUTPUT')
            num_output=num_output+1;
        end
    end

    if isa(this.object,'RTW.TflBlasEntryGenerator')||...
        isa(this.object,'RTW.TflCBlasEntryGenerator')
        type='double*';
    else
        type='double';
    end

    for num=num_output+1:length(this.object.ConceptualArgs)
        name=this.object.ConceptualArgs(num).Name;
        if~(strcmp(this.object.ConceptualArgs(num).toString,'void'))
            arg=this.parentnode.object.getTflArgFromString(name,type);
            this.object.Implementation.addArgument(arg);
        end
    end



    for num=1:num_output
        name=this.object.ConceptualArgs(num).Name;
        arg=this.parentnode.object.getTflArgFromString(name,type);
        arg.IOType='RTW_IO_OUTPUT';
        if num==num_output
            this.object.Implementation.setReturn(arg);
        else
            this.object.Implementation.addArgument(arg);
        end
    end

    impl=this.object.Implementation;
    cargs=this.object.ConceptualArgs;
    if~isempty(impl.Return)
        returnargname=impl.Return.Name;

        for i=1:length(cargs)
            if strcmp(cargs(i).Name,returnargname)
                if isa(cargs(i),'RTW.TflArgMatrix')&&...
                    isa(impl.Return,'RTW.TflArgPointer')
                    impl.Arguments(end+1)=impl.Return;
                    newarg=this.object.getTflArgFromString('unused','void');
                    newarg.IOType='RTW_IO_OUTPUT';
                    impl.Return=newarg;
                    break;
                end
            end
        end
    end

    this.firepropertychanged;

