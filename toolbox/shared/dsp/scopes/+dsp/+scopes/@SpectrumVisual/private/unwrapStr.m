function strOut=unwrapStr(strIn)



    if iscell(strIn)
        strOut=[];
        for idx=1:numel(strIn)
            strOut=[strOut,strIn{idx}];%#ok<AGROW>
        end
    else
        strOut=strIn;
    end

end
