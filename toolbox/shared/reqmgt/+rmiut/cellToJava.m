function javaArray=cellToJava(cellArray,force2D)
    [totalRows,totalCols]=size(cellArray);
    if(nargin==1||~force2D)&&(totalRows==1||totalCols==1)
        totalItems=length(cellArray);
        javaArray=java.util.ArrayList(totalItems);
        for j=1:totalItems
            value=cellArray{j};
            if ischar(value)
                javaArray.add(java.lang.String(value));
            elseif islogical(value)
                javaArray.add(java.lang.String(loc_logicalToString(value)));
            else
                javaArray.add(java.lang.String(num2str(value)));
            end
        end
    else
        javaArray=java.util.ArrayList(totalRows);
        for i=1:totalRows
            iArray=java.util.ArrayList(totalCols);
            for j=1:totalCols
                value=cellArray{i,j};
                if ischar(value)
                    iArray.add(java.lang.String(value));
                elseif islogical(value)
                    iArray.add(java.lang.String(loc_logicalToString(value)));
                else
                    iArray.add(java.lang.String(num2str(value)));
                end
            end
            javaArray.add(iArray);
        end
    end
end

function out=loc_logicalToString(in)
    out=char(double('T')*ones(size(in)));
    if any(~in)
        out(~in)='F';
    end
end