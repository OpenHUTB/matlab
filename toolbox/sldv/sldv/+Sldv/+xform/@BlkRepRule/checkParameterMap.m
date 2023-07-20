function checkParameterMap(obj,ParameterMap)




    if~isempty(ParameterMap)&&isempty(strfind(obj.ReplacementBlk,'Subsystem'))
        fields=fieldnames(ParameterMap);
        for i=1:length(fields)
            replacementfield=fields{i};
            try
                get_param(obj.ReplacementPath,replacementfield);
            catch Mex
                error(message('Sldv:xform:BlkRepRule:setParameterMap:NoParameter',obj.ReplacementPath,obj.FileName,replacementfield));
            end

            sourcefield=ParameterMap.(replacementfield);

            var_locations=strfind(sourcefield,'$');
            if mod(length(var_locations),2)~=0
                error(message('Sldv:xform:BlkRepRule:setParameterMap:WrongParamStructure',obj.FileName));
            end
        end
    end
end