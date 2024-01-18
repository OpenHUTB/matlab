function show(moduleIdStr,objNum,option)

    persistent doorsVerNum;

    if~rmidoors.isAppRunning()

        return;
    end

    if nargin<2||isempty(objNum)
        objNum=-1;
    end

    if nargin<3
        option=false;
    end

    hDoors=rmidoors.comApp('get');

    if isempty(doorsVerNum)
        try
            hDoors.runStr('oleSetResult(doorsVersion())');
            doorsVerStr=hDoors.Result;
            doorsVerNum=sscanf(doorsVerStr,'DOORS %f',1);
        catch Mex %#ok<NASGU>
            doorsVerNum=-1;
        end
    end

    if ischar(objNum)
        objid=objNum;
    else
        objid=num2str(objNum);
    end

    switch class(option)

    case 'logical'
        if option

            editable='true';
        else

            editable='false';
        end
        cmdStr=['dmiObjOpen_("',moduleIdStr,'",',objid,',',editable,')'];

    case 'char'

        baselineNumberStr=option;
        cmdStr=['dmiObjOpenInBaseline_("',moduleIdStr,'",',objid,',"',baselineNumberStr,'")'];

    otherwise
        error('Slvnv:rmipref:InvalidArgument',class(option));
    end

    rmidoors.invoke(hDoors,cmdStr);
    commandResult=hDoors.Result;

    if strncmp(commandResult,'DMI Error:',10)
        error(message('Slvnv:reqmgt:DoorsApiError',commandResult));
    end

    if ispc()
        if(doorsVerNum>=8.2)
            moduleName=rmidoors.getModuleAttribute(moduleIdStr,'Name','get');
            winName=['^''',moduleName,''' .* \(Formal module\) - DOORS$'];
        else
            modulePath=rmidoors.getModuleAttribute(moduleIdStr,'FullName','get');
            winName=['.*Formal module ''',modulePath,''''];
        end
        reqmgt('winFocus',winName);
    end

end
