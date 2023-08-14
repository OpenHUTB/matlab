












function args=getFunctionArgSpec(fcn,mdl)
    args={};


    try
        fcn=['SimulinkFunction:',fcn];
        cm=coder.mapping.api.get(mdl);
        argStr=getFunction(cm,fcn,'Arguments');
    catch ME %#ok



        return;
    end







    retArg=[];
    args={};
    if~isempty(argStr)
        argCells=strtrim(split(argStr,'='));
        assert(numel(argCells)<=2)
        if numel(argCells)==2

            retArg=argCells{1};
            inputArg=string(extractBetween(argCells{2},'(',')'));
        else

            inputArg=string(extractBetween(argCells{1},'(',')'));
        end
        argArray=strtrim(split(inputArg,','));
        for i=1:numel(argArray)
            spec=split(argArray(i),' ');
            if strcmpi(spec{1},'const')

                argName=spec{4};
                argSpec='CONSTPOINTER';
            elseif strcmp(spec{1},'*')

                argName=spec{2};
                argSpec='POINTER';
            else

                argName=spec{1};
                argSpec='AUTO';
            end
            args{end+1}={argName,argSpec};%#ok
        end
        if~isempty(retArg)




            args{end+1}={retArg,'POINTER'};
        end
    end
end





