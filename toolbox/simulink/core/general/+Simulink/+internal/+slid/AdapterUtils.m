classdef AdapterUtils




    methods(Static=true)

        function slidFcn=createFunction(source,functionName,visibility,inArgNames,inArgsSpec,outArgNames,outArgsSpec)






































            slidFcn=slid.Function(Simulink.internal.slid.AdapterUtils.getModel());

            slidFcn.Name=functionName;
            slidFcn.Visibility=visibility;

            args=slidFcn.Argument;

            if(length(inArgNames)~=length(inArgsSpec))
                msg='The input argument names and specification lengths must be same.';
                error(msg);
            end

            if(length(outArgNames)~=length(outArgsSpec))
                msg='The output argument names and specification lengths must be same.';
                error(msg);
            end

            Simulink.internal.slid.AdapterUtils.populateFunctionArgs(args,inArgNames,inArgsSpec,slid.Direction.INPUT);
            Simulink.internal.slid.AdapterUtils.populateFunctionArgs(args,outArgNames,outArgsSpec,slid.Direction.OUTPUT);


            cache=slid.broker.Cache.getInstance('dummyVar');
            cache.insert(slidFcn,source,slidFcn.Name);

        end
    end

    methods(Static=true,Access=private)
        function populateFunctionArgs(args,argNames,argSpec,argDirection)

            for i=1:length(argNames)
                if(~isempty(argNames{i}))
                    if(isempty(argSpec{i}))
                        error('The argument specification for argument %s cannot be empty',argNames{i});
                    end
                    arg=Simulink.internal.slid.AdapterUtils.createArgument(argNames{i},argDirection,Simulink.internal.slid.AdapterUtils.createArgDataType(argSpec{i}));
                    args.add(arg);
                end
            end

        end

        function argDatatype=createArgDataType(argSpec)

            argDatatype=slid.DataType(Simulink.internal.slid.AdapterUtils.getModel());

            argDatatype.NumericType=argSpec.Type;
            argDatatype.Dimensions=argSpec.Dimension;
            argDatatype.Complexity=argSpec.Complexity;
        end


        function arg=createArgument(argName,argDirection,argDataType)

            arg=slid.Signal(Simulink.internal.slid.AdapterUtils.getModel());

            arg.Name=argName;
            arg.Identifier=argName;
            arg.Direction=argDirection;
            arg.Type=argDataType;
        end

        function model=getModel()

            cache=slid.broker.Cache.getInstance('dummyVar');
            model=mf.zero.getModel(cache);
        end
    end

end
