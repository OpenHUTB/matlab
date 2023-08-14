function objectiveFunctionParser(obj,newObjectiveFunction)


    validateattributes(newObjectiveFunction,{'cell','char','string'},...
    {'nonempty','scalartext'},...
    'optimize','objective function');


    f={};

    switch class(newObjectiveFunction)


































    case{'char','string'}

        validateattributes(newObjectiveFunction,{'char','string'},...
        {'nonempty'},...
        'optimize','objective function');
        validatestring(newObjectiveFunction,{'maximizeGain',...
        'frontToBackRatio','maximizeBandwidth','minimizeBandwidth',...
        'maximizeSLL','minimizeArea'},...
        'optimize','objective function');

        setObjectiveFunctionName(obj,newObjectiveFunction)
        f{end+1}=allocate(newObjectiveFunction);
        obj.OptimStruct.ObjectiveFunction=f{1};
    otherwise

    end
    function rtn=allocate(name)
        if strcmpi(name,'MaximizeGain')
            rtn=maximizeGain(obj);
        elseif strcmpi(name,'F/BLobeRatio')||strcmpi(name,'frontToBackRatio')
            rtn=maximizeFBr(obj);
        elseif strcmpi(name,'MaxBandwidth')||strcmpi(name,'maximizeBandwidth')
            rtn=maximizeBandwidth(obj);
        elseif strcmpi(name,'MinBandwidth')||strcmpi(name,'minimizeBandwidth')
            rtn=minimizeBandwidth(obj);




        elseif strcmpi(name,'MaximizeSLL')
            rtn=maximizeSLL(obj);


        elseif strcmpi(name,'MinimizeArea')
            rtn=minimizeArea(obj);
        end
    end
end