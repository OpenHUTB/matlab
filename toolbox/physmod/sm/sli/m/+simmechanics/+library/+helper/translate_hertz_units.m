function outData=translate_hertz_units(inData)



































































































    outData.NewBlockPath='';
    outData.NewInstanceData=[];


    if isfield(inData,'InstanceData')
        outData.NewInstanceData=arrayfun(@lHzTranslate,inData.InstanceData);
    else
        outData.NewInstanceData=arrayfun(@lHzTranslate,inData.NewInstanceData);
    end


    outData=simmechanics.library.body_elements.sl_postprocess2(outData);


    outData=simmechanics.library.joints.constant_velocity_joint_sl_postprocess(outData);


    function param=lHzTranslate(param)
        if length(param.Name)>4&&strcmp(param.Name(end-4:end),'Units')...
            &&~isempty(strfind(param.Value,'Hz'))






            param.Value=lReplaceHertz(param.Value);
        end

        function value=lReplaceHertz(value)

            persistent unit_map
            persistent regex

            if isempty(unit_map)
                unit_map=containers.Map({'Hz','kHz','MHz','GHz'},...
                {'rev/s','rev/ms','rev/us','rev/ns'});
                regex='\<[kMG]?Hz\>';
            end

            value=strtrim(value);

            if isKey(unit_map,value)
                value=unit_map(value);
            else


                value=regexprep(value,regex,'(${unit_map($0)})');
            end
