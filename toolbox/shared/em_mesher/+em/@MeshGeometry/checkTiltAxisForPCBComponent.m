function checkTiltAxisForPCBComponent(~,propVal)
    isError=false;
    if isnumeric(propVal)
        if size(propVal,1)==1
            if~isequal(propVal,[0,0,1])
                isError=true;
            end
        else
            for m=1:size(propVal,1)
                if~isequal(propVal(m,:),[0,0,1])&&~isequal(propVal(m,:),[0,0,0])
                    isError=true;
                    break;
                end
            end

        end
    else
        if~strcmpi(propVal,'Z')
            isError=true;
        end
    end

    if isError
        error(message('rfpcb:rfpcberrors:Unsupported','Axis other than Z','PCB Components'));
    end

end