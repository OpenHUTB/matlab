function[objs,nObjs]=getSimulinkObjects(objNames)






    if ischar(objNames)
        objNames={objNames};
    end
    nObjs=length(objNames);


    if iscell(objNames)
        objs=cell(1,nObjs);
        for i=1:nObjs
            objs{i}=get_param(objNames{i},'Object');
        end
        objs=[objs{:}];

    elseif isa(objNames,'double')
        objs=cell(1,nObjs);
        for i=1:nObjs
            objs{i}=get_param(objNames(i),'Object');
        end
        objs=[objs{:}];

    elseif isa(objNames,'Simulink.Object')
        objs=objNames;

    else
        error(message('Simulink:rptgen_sl:UnexpectedObjectNames'));

    end
