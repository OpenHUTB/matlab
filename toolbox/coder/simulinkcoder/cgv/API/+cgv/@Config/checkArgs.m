









function args=checkArgs(beginAt,ObjName,validParams,displayParams,argCell)

    args=[];
    errorFound=false;

    if isempty(argCell)
        return;
    end



    inputargs='';
    origIndex=beginAt;
    for i=1:length(argCell)
        if ischar(argCell{i})
            if i==1
                inputargs=['''',char(argCell{i}),''''];
            else
                inputargs=[inputargs,', ''',char(argCell{i}),''''];
            end
        else
            disp(DAStudio.message('RTW:cgv:NotAString',origIndex));
            errorFound=true;
        end
        origIndex=origIndex+1;
    end

    if errorFound
        DAStudio.error('RTW:cgv:BadParams');
    end

    if mod(length(argCell),2)
        DAStudio.error('RTW:cgv:OddNumberOfParams',inputargs);
    end




    OKParams=lower(cellfun(@(c)(c{1}),validParams,'UniformOutput',false));
    for i=1:2:length(argCell)
        param=argCell{i};
        value=argCell{i+1};
        [common,ia,ib]=intersect(OKParams,lower(param));
        if isempty(common)
            errorFound=true;
            disp(DAStudio.message('RTW:cgv:InvalidParam',param));
            continue;
        end


        OKValues=lower(validParams{ia}{2});
        if isempty(intersect(OKValues,lower(value)))
            errorFound=true;
            disp(DAStudio.message('RTW:cgv:InvalidParam',value));
        end
    end

    if errorFound
        reportError(ObjName,displayParams,inputargs);
    end

    for i=1:2:length(argCell)



        if isfield(args,lower(argCell{i}))
            if strcmpi(args.(lower(argCell{i})),argCell{i+1})
                disp(DAStudio.message('RTW:cgv:DuplicateParameter',argCell{i}));
            else
                DAStudio.error('RTW:cgv:ConflictingParameter',argCell{i},...
                args.(lower(argCell{i})),argCell{i+1});
            end
        end
        args.(lower(argCell{i}))=argCell{i+1};
    end


    function reportError(ObjName,validParams,inputargs)

        validArgs='';
        for i=1:length(validParams)
            validArgs=[validArgs,validParams{i}{1},': '];
            validValues=validParams{i}{2};
            validArgs=[validArgs,validValues{1}];
            for j=2:length(validValues)
                validArgs=[validArgs,', ',validValues{j}];
            end
            validArgs=[validArgs,'; '];
        end
        DAStudio.error('RTW:cgv:ConstructorParameter',inputargs,ObjName,validArgs);

