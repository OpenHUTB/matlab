















function dataType=populateDataType(dlconfig,dlCodegenOptionsCallback,networkIdentifier)






    if isprop(dlconfig,'DataType')
        if strcmpi(dlconfig.DataType,'fp16')||...
            strcmpi(dlconfig.DataType,'int8')
            dataType=dlconfig.DataType;
        elseif~isempty(dlCodegenOptionsCallback)


            codegenOptionsCallbackClass=feval(dlCodegenOptionsCallback);
            dataType=codegenOptionsCallbackClass.getDataType(networkIdentifier);
        else
            dataType='fp32';
        end
    else


        dataType='fp32';
    end
end
