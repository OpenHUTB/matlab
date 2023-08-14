function setFunctionArrayLayout(obj,hMdl)

    fcnArrLayoutExceptions=struct('FunctionName',{},'ArrayLayout',{});
    for fcn=obj.ParseInfo.Functions
        if fcn.ArrayLayout~=internal.CodeImporter.FunctionArrayLayout.NotSpecified...
            &&fcn.ArrayLayout~=obj.qualifiedSettings.CustomCode.FunctionArrayLayout
            arrayLayout=strrep(char(fcn.ArrayLayout),'Major','-major');
            fcnArrLayoutExceptions(end+1)=struct('FunctionName',fcn.Name,'ArrayLayout',arrayLayout);
        end
    end

    globalFunctionArrayLayout=strrep(char(obj.qualifiedSettings.CustomCode.FunctionArrayLayout),'Major','-major');
    set_param(hMdl,'DefaultCustomCodeFunctionArrayLayout',globalFunctionArrayLayout);
    set_param(hMdl,'CustomCodeFunctionArrayLayout',fcnArrLayoutExceptions);
end
