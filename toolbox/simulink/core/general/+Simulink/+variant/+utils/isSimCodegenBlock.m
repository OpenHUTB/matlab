function flag=isSimCodegenBlock(varBlockPath)





    flag=false;


    try %#ok<TRYNC>
        flag=strcmp('sim codegen switching',get_param(varBlockPath,'VariantControlMode'));
    end

end
