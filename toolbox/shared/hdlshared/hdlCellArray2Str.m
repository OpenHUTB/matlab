function outVal=hdlCellArray2Str(cellVal)









    if isempty(cellVal)

        outVal='';
    else
        outVal='{';

        for oindex=1:length(cellVal)

            cellValElem=cellVal{oindex};
            if iscell(cellValElem)
                outVal=[outVal,'{'];%#ok<*AGROW>

                for iindex=1:length(cellValElem)-1
                    outVal=[outVal,'''',cellValElem{iindex},'''',','];
                end
                if oindex==length(cellVal)

                    outVal=[outVal,'''',cellValElem{length(cellValElem)},'''','}'];
                else
                    outVal=[outVal,'''',cellValElem{length(cellValElem)},'''','},'];
                end
            else
                if oindex<length(cellVal)
                    outVal=[outVal,'''',cellValElem,'''',','];
                else
                    outVal=[outVal,'''',cellValElem,''''];
                end
            end
        end
        outVal=[outVal,'}'];
    end

end