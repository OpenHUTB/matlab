function[iP,oP,param]=renamePortInfo(iP,oP,param)

    for i=1:length(iP.Name)
        if(strcmp(iP.DataType{i},'real32_T')||...
            strcmp(iP.DataType{i},'creal32_T'))
            iP.DataType{i}=...
            strrep(iP.DataType{i},'real32_T','single');
            iP.DataType{i}=strrep(iP.DataType{i},'c','');
        else
            iP.DataType{i}=strrep(iP.DataType{i},'real_T','double');
            iP.DataType{i}=...
            strrep(iP.DataType{i},'_T','');
            iP.DataType{i}=strrep(iP.DataType{i},'c','');
        end

        if(~isfield(iP,'IsSigned')||(length(iP.IsSigned)<length(iP.Name)))
            iP.IsSigned{i}='1';
            iP.WordLength{i}='12';
            iP.FixPointScalingType{i}='1';
            iP.FractionLength{i}='3';
            iP.Slope{i}='2^-3';
            iP.Bias{i}='0';
        end
    end
    for i=1:length(oP.Name)
        if(strcmp(oP.DataType{i},'real32_T')||...
            strcmp(oP.DataType{i},'creal32_T'))
            oP.DataType{i}=...
            strrep(oP.DataType{i},'real32_T','single');
            oP.DataType{i}=...
            strrep(oP.DataType{i},'c','');
        else
            oP.DataType{i}=...
            strrep(oP.DataType{i},'real_T','double');
            oP.DataType{i}=...
            strrep(oP.DataType{i},'_T','');
            oP.DataType{i}=...
            strrep(oP.DataType{i},'c','');
        end


        if(~isfield(oP,'IsSigned')||(length(oP.IsSigned)<length(oP.Name)))
            oP.IsSigned{i}='1';
            oP.WordLength{i}='12';
            oP.FixPointScalingType{i}='1';
            oP.FractionLength{i}='3';
            oP.Slope{i}='2^-3';
            oP.Bias{i}='0';
        end
    end

    for i=1:length(param.Name)
        if(strcmp(param.DataType{i},'real32_T')||...
            strcmp(param.DataType{i},'creal32_T'))
            param.DataType{i}=...
            strrep(param.DataType{i},'real32_T','single');
            param.DataType{i}=...
            strrep(param.DataType{i},'c','');
        else
            param.DataType{i}=...
            strrep(param.DataType{i},'real_T','double');
            param.DataType{i}=...
            strrep(param.DataType{i},'_T','');
            param.DataType{i}=...
            strrep(param.DataType{i},'c','');
        end
    end

    iP.Complexity=strrep(iP.Complexity,'COMPLEX_YES','complex');
    iP.Complexity=strrep(iP.Complexity,'COMPLEX_NO','real');
    oP.Complexity=strrep(oP.Complexity,'COMPLEX_YES','complex');
    oP.Complexity=strrep(oP.Complexity,'COMPLEX_NO','real');
    param.Complexity=strrep(param.Complexity,'COMPLEX_YES','complex');
    param.Complexity=strrep(param.Complexity,'COMPLEX_NO','real');

    iP.Frame=...
    strrep(iP.Frame,'FRAME_NO','off');
    iP.Frame=...
    strrep(iP.Frame,'FRAME_YES','on');
    iP.Frame=...
    strrep(iP.Frame,'FRAME_INHERITED','auto');
    oP.Frame=...
    strrep(oP.Frame,'FRAME_NO','off');
    oP.Frame=...
    strrep(oP.Frame,'FRAME_YES','on');
    oP.Frame=...
    strrep(oP.Frame,'FRAME_INHERITED','auto');
end