function checksum=simrf_checksum(solver,inputs,outputs)






    allOutputs=cell(1,nargout('simrf_solverparam'));
    [allOutputs{:}]=simrf_solverparam(solver);
    checksum=cell2mat(cellfun(@(x)double(x),allOutputs,...
    'UniformOutput',false));




    persistent ndMap;
    if isempty(ndMap)

        choices={'none','white','pwl'};
        for i=1:length(choices)
            ndMap.(choices{i})=i;
        end
    end

    for i=1:length(inputs)







        inputInfo.src.block=inputs{i};
        inputInfo.dim=[1,1];
        inputInfo.dst.index=1;
        outputInfo=[];
        dae.Input=1;
        dae.Output=[];
        inputData=simrf_inputoutputparam(dae,inputInfo,outputInfo);

        checksum=[checksum,cell2mat(cellfun(@(x)lReshape(double(x)),...
        struct2cell(inputData{1})','UniformOutput',false))];%#ok<AGROW>
    end

    for i=1:length(outputs)







        inputInfo=[];
        outputInfo.dst{1}.block=outputs{i};
        outputInfo.src.index=1;
        dae.Input=[];
        dae.Output=1;
        [~,outputData]=simrf_inputoutputparam(dae,inputInfo,outputInfo);

        checksum=[checksum,cell2mat(cellfun(@(x)lReshape(double(x)),...
        struct2cell(outputData{1})','UniformOutput',false))];%#ok<AGROW>
    end
end

function ln=lReshape(p)
    ln=reshape(p,1,numel(p));
end


