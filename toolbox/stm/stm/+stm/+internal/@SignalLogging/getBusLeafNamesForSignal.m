function leafNames=getBusLeafNamesForSignal(hierStruct)



    import stm.internal.SignalLogging.*;

    if~isempty(hierStruct.Children)
        leafNames=arrayfun(@(hStruct)getBusLeafNamesForSignal(hStruct),...
        hierStruct.Children,'UniformOutput',false)';

        if any(cellfun(@(leaf)iscell(leaf),leafNames))
            leafNames=horzcat(leafNames{:});
        end


        leafNames=strcat([hierStruct.SignalName,'.'],leafNames);
    else




        leafNames=regexprep(hierStruct.SignalName,{'(',')',' '},{'_'});
    end

end
