



function flattened=flattenInferenceReportForJava(report)
    if isstruct(report)&&isfield(report,'inference')
        inference=report.inference;
    else
        inference=report;
    end

    if isa(inference,'eml.InferenceReport')


        if isprop(inference,'MxArrays')
            arrayClassNames=cellfun(@class,inference.MxArrays,'UniformOutput',false);
        else
            arrayClassNames=[];
        end

        flattened=postProcessFunctionMessages(flattenForJava(removeNonFiMxArrays(inference),@postProcessMxInfos));

        if~isempty(arrayClassNames)
            flattened.MxArrays=postProcessMxArraysArray(flattened.MxArrays,arrayClassNames);
        else
            flattened.MxArrays=struct();
        end
    else
        flattened=flattenForJava(inference);
    end


    if~isempty(inference)
        cyclicInfoIds=codergui.evalprivate('findCyclicMxInfos',inference.Functions,inference.MxInfos);
        if~isempty(cyclicInfoIds)
            for i=1:numel(cyclicInfoIds)
                flattened.MxInfos{cyclicInfoIds(i)}.Cyclic=true;
            end
        end
    end
end


function flattened=postProcessMxInfos(obj,flattened)
    if~isa(obj,'eml.MxInfo')
        return;
    end

    assert(~isprop(obj,'original_matlab_type'));
    flattened.original_matlab_type=class(obj);

    if strcmp(flattened.Class,'coder.internal.indexInt')
        flattened.Class='double';
    elseif isa(obj,'eml.MxClassInfo')
        propFilter=codergui.evalprivate('createClassPropertyFilter',obj);
        flattened.ClassProperties=flattened.ClassProperties(propFilter);
    end
end


function inference=postProcessFunctionMessages(inference)
    for i=1:numel(inference.Functions)
        for j=1:numel(inference.Functions(i).Messages)
            infoLink=coder.internal.moreinfo(inference.Functions(i).Messages(j).MsgID);
            if~isempty(infoLink)
                inference.Functions(i).Messages(j).MsgText=[inference.Functions(i).Messages(j).MsgText,' ',infoLink];
            end
        end
    end
end


function exploded=postProcessMxArraysArray(mixed,classNames)




    exploded=struct();

    exploded.Fimaths=extractByType('embedded.fimath');
    exploded.NumericTypes=extractByType('embedded.numerictype');

    function matches=extractByType(className)
        indices=find(strcmp(classNames,className));

        if~isempty(indices)
            matches=[mixed{indices}];
            indices=num2cell(indices);

            [matches.Id_]=indices{:};
        else
            matches=[];
        end
    end
end


function infStruct=removeNonFiMxArrays(inference)


    infStruct=struct();
    for prop=reshape(string(properties(inference)),1,[])
        infStruct.(prop)=inference.(prop);
    end
    for i=1:numel(infStruct.MxArrays)
        value=infStruct.MxArrays{i};
        if~isfi(value)&&~isfimath(value)&&~isnumerictype(value)
            infStruct.MxArrays{i}=[];
        end
    end
end