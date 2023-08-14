function outData=transformPSLookupTable2DR2016a(inData)



    outData.NewBlockPath='';
    outData.NewInstanceData=[];

    instanceData=inData.InstanceData;



    [parameterNames{1:length(instanceData)}]=instanceData.Name;


    if ismember('interp_method',parameterNames)

        interp_method_index=strcmp('interp_method',parameterNames);
        interp_method=instanceData(interp_method_index).Value;



        if str2double(interp_method)~=1
            instanceData(interp_method_index).Value='2';
        end
    end




    if(ismember('x_t',parameterNames))...
        &&(~ismember('x1',parameterNames))

        x_t_index=strcmp('x_t',parameterNames);
        x_t=instanceData(x_t_index).Value;

        y_t_index=strcmp('y_t',parameterNames);
        y_t=instanceData(y_t_index).Value;

        z_t_index=strcmp('z_t',parameterNames);
        z_t=instanceData(z_t_index).Value;


        instanceData(end+1).Name='x1';
        instanceData(end).Value=x_t;


        instanceData(end+1).Name='x2';
        instanceData(end).Value=y_t;


        instanceData(end+1).Name='f';
        instanceData(end).Value=z_t;
    end

    outData.NewInstanceData=instanceData;

end
