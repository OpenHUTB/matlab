function UpdateBusType

    maskObj=Simulink.Mask.get(gcb);
    temp={maskObj.Parameters.Name};
    paramIdx=find(ismember(temp,'BusTypeMask'));
    if(strcmpi(maskObj.Parameters(paramIdx).Value,'<-- Refresh -->')||(isempty(maskObj.Parameters(paramIdx).Value)))
        baseVars=evalin('base','whos');
        varNames={baseVars(ismember({baseVars.class},'Simulink.Bus')).name};
        entries=[varNames,'<-- Refresh -->'];
        maskObj.Parameters(paramIdx).TypeOptions=entries;
    else
        selectedBusType=evalin('base',maskObj.Parameters(paramIdx).Value);
        if(isa(selectedBusType,'Simulink.Bus'))
            nBusElements=numel(selectedBusType.Elements);
            for idx=1:nBusElements
                if(strfind(selectedBusType.Elements(idx).DataType,'Bus:'))
                    error(message('ssm:block:NestedBusError',value,this.mBlock.BlockType));
                elseif(strcmpi(selectedBusType.Elements(idx).Complexity,'complex'))
                    error(message('ssm:dialog:ComplexTypeError',selectedBusType.Elements(idx).Name,value));
                else

                end
            end
            set_param(gcb,'BusType',maskObj.Parameters(paramIdx).Value);
        end
    end

end

