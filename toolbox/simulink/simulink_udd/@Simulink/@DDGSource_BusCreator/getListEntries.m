function[varargout]=getListEntries(source,block)




    inputs=source.state.Inputs;
    hierarchy=source.getCachedSignalHierarchy(block,false);


    if~isempty(hierarchy)
        entries={hierarchy(:).name};
    else
        entries={};
    end
    entries=refactor(source,hierarchy,entries,inputs,false);
    varargout{1}=entries;
    varargout{2}=source.cellArr2Str(entries);
end


function signals=refactor(source,busStruct,signals,inputs,isTree)

    if isempty(inputs);return;end

    if isempty(signals);return;end

    num=source.str2doubleNoComma(inputs);
    if isnan(num)
        num=length(strfind(inputs,','))+1;
        isStr=true;
    else
        isStr=false;
    end

    if~isTree&&isStr
        signals=source.str2CellArr(inputs);
        return;
    end

    if isfinite(num)&&num>0&&num~=length(busStruct)
        if isStr&&~isTree
            signalNames=source.str2CellArr(inputs);
        else
            signalNames={busStruct(:).name};
        end


        currentNum=length(signalNames);
        if currentNum<num
            for i=1:num-currentNum
                signals=[signals,{['signal',num2str(currentNum+i)]}];%#ok
            end
        elseif currentNum>num
            count=1;
            for i=1:length(signals)
                if ischar(signals{i})
                    count=count+1;
                end
                if count>num+1
                    signals(i:end)=[];
                    break;
                end
            end
        end
    end
end
