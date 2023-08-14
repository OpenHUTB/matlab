function checkHeterogeneousElementForConformal(obj,propVal)

    expvalue=prod(obj.ArraySize);
    if iscell(propVal)
        for i=1:numel(propVal)
            if any(strcmpi(class(propVal{i}),...
                {'linearArray','rectangularArray','circularArray'}))
                actualvalue=expvalue;
                break;
            else
                actualvalue=numel(propVal);
            end
        end
    else
        actualvalue=numel(propVal);
    end
    if~isequal(actualvalue,expvalue)
        error(message('antenna:antennaerrors:InvalidEntries',...
        'Element',num2str(expvalue),num2str(actualvalue)));



    end
end