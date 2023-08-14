function validate3DVectorProperty(value,propertyName,exampleValue)




    if length(value)~=3
        error(message('dnnfpga:config:VectorProperty3D',...
        propertyName,sprintf('[%s]',num2str(exampleValue))));
    end

end


