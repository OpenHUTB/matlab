function populate(h,noderoot,varargin)










    if~isempty(varargin{1})

        h.Type='TflEntry';
        input=varargin{1};
        if~isempty(input.ConceptualArgs)
            h.Name=h.getEnumString(input.Key);
        else
            h.Name='';
        end
        h.parentnode=noderoot;
        noderoot.isDirty=true;
        h.EntryType=class(input);
        h.object=input;


        if~isempty(h.object.Key)&&isa(input,'RTW.TflCFunctionEntry')
            h.apSet=h.object.getAlgorithmParameters;
        elseif isa(input,'RTW.TflCSemaphoreEntry')
            if~isempty(input.DWorkArgs)&&isempty(input.DWorkAllocatorEntry)
                h.allocatesdwork=true;
            end
        end

        if~isa(input,'RTW.TflCustomization')
            if~isempty(input.Implementation.Arguments)||...
                ~isempty(input.Implementation.Return)

                if~isempty(input.Implementation.ArgumentDescriptor)
                    align=input.Implementation.ArgumentDescriptor.AlignmentBoundary;

                    if isempty(input.Implementation.Return.Descriptor)&&...
                        (isa(input.Implementation.Return,'RTW.TflArgMatrix')||...
                        isa(input.Implementation.Return,'RTW.TflArgPointer'))
                        des=RTW.ArgumentDescriptor;
                        des.AlignmentBoundary=align;
                        input.Implementation.Return.Descriptor=des;
                    end

                    for i=1:length(input.Implementation.Arguments)
                        arg=input.Implementation.Arguments(i);
                        if isa(arg,'RTW.TflArgPointer')&&isempty(arg.Descriptor)
                            des=RTW.ArgumentDescriptor;
                            des.AlignmentBoundary=align;
                            arg.Descriptor=des;
                        end
                    end
                end
                for i=1:length(input.Implementation.Arguments)
                    arg=input.Implementation.Arguments(i);
                    if isa(arg,'RTW.TflArgPointer')
                        names={input.Implementation.Arguments.Name};
                        if~isempty(arg.ArgumentForInPlaceUse)
                            index=find(ismember(names,arg.ArgumentForInPlaceUse),1);
                            if~isempty(index)
                                if isa(input.Implementation.Arguments(index),'RTW.TflArgPointer')
                                    if isempty(input.Implementation.Arguments(index).ArgumentForInPlaceUse)
                                        input.Implementation.Arguments(index).ArgumentForInPlaceUse=arg.Name;
                                    end
                                end
                            end
                        end
                    end
                end
                h.copyconcepargsettings=0;
            end
        end
    else
        DAStudio.error('RTW:tfl:invalidNumOfInput');
    end

