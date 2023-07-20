function[LVParam,hasErrors,hasWarnings]=consolidateCheckErrors(checks)



    LVParam={};
    hasWarnings=false;
    hasErrors=false;

    for i=1:numel(checks)

        path=checks(i).path;
        level=checks(i).level;
        if strcmpi(level,'message')



            message=hdlRemoveHtmlonlyTags(checks(i).message);
        else
            message=checks(i).message;
        end

        name=[level,': ',message];
        if~isempty(LVParam)
            index=findDuplicate(LVParam,name);
            if~isempty(index)&&~isempty(path)
                LVParam{index}.Data{end+1}=path;%#ok<AGROW>
                continue;
            end
        end

        myLVParam=ModelAdvisor.ListViewParameter;
        myLVParam.Name=name;
        if~isempty(path)
            myLVParam.Data{end+1}=path;
        end
        LVParam{end+1}=myLVParam;%#ok<AGROW>
        if strcmpi(level,'error')
            hasErrors=true;
        end
        if strcmpi(level,'warning')
            hasWarnings=true;
        end
    end
end

function index=findDuplicate(LVParam,name)
    index=[];
    for i=1:length(LVParam)
        if strcmpi([LVParam{i}.Name],name);
            index=i;
            return;
        end
    end
end

