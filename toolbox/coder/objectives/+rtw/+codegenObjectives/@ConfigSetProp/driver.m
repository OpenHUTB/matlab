function obj=driver(obj,objName,controlCode,cs)










    if nargin<4
        cs=Simulink.ConfigSet;
        cs.switchTarget('ert.tlc','');
    elseif isa(cs,'Simulink.BlockDiagram')
        cs=getActiveConfigSet(cs);
    end

    if isempty(objName)||isempty(objName{1})
        obj.error=1;
        return;
    end


    obj.nOfCC=4;
    states=cell(1,1);

    if controlCode==-1
        nOfStateOfCC=2^obj.nOfCC;

        for i=1:nOfStateOfCC
            states{i}=i-1;
        end
    else
        bits=bitget(controlCode,obj.nOfCC:-1:1);

        len=length(bits);

        if len>obj.nOfCC
            obj.error=4;
            fprintf('\nError(%d): invalid control code. \n',obj.error);
            return;
        else
            for i=1:len
                if bits(i)||(i==len)
                    nOfStateOfCC=len-i+1;
                    break;
                end
            end

            for i=1:nOfStateOfCC
                states{i}=bits(len-i+1);
            end
        end
    end

    scriptLists=cell(nOfStateOfCC,1);
    lenOfLists=cell(nOfStateOfCC,1);

    includeCustomization=true;
    obj.construction(objName);
    obj.appendParameter(cs);
    obj.objectiveReader(objName,includeCustomization,cs);

    if obj.error
        switch(obj.error)
        case 1
            fprintf('\nError(%d): variable objName should be a cell array. \n',obj.error);
        case 2
            fprintf('\nError(%d): parameter names are not correct, check \''dependencies.xml\''\n',obj.error);
        case 3
            fprintf('\nError(%d): objective name is not correct. \n',obj.error);
        end

        return;
    end

    for i=1:nOfStateOfCC
        obj.process(states{i},controlCode);

        if obj.error
            if obj.error==6
                fprintf('warning(%d): stateOfCC{%d} is not specified.\n',obj.error,i);
                continue;
            else
                fprintf('Error(%d): process error.\n',obj.error);
                return;
            end
        end
        obj.removeFlaggedRecommendations(cs);

        scriptLists{i}=obj.scriptList;
        lenOfLists{i}=obj.lenOfList;

        for pIdx=1:lenOfLists{i}
            id=scriptLists{i}{pIdx}.id;
            scriptLists{i}{pIdx}.name=obj.Parameters(id).name;
        end
    end

    obj.nOfStateOfCC=nOfStateOfCC;
    obj.scriptLists=scriptLists;
    obj.lenOfLists=lenOfLists;

    return;

end
