function[xn,yn]=eml_al_cordic_kernel_loop(x0,y0,z0,lut_values,num_iters)

%#codegen

    coder.allowpcode('plain');
    eml_prefer_const(lut_values,num_iters);


    [xn,yn]=fixed.internal.cordic_rotation_kernel_private(x0,y0,z0,lut_values,num_iters);

end
