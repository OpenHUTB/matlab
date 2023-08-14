function validateOverlaidVariables(tbl,validationInd,ind,isRecursiveCall)




    for i=1:length(validationInd)
        indc=validationInd{i};
        if length(indc)>1

            if any(varfun(@(v)isa(v,'tabular'),tbl(:,indc),'OutputFormat','uniform'))
                error(message('MATLAB:stackedplot:OverlaidNestedTable'));
            end

            try
                m=tbl{:,indc};
            catch

                msg=getIncompatibleOverlaidTypesMessage(tbl,indc);
                error(msg);
            end


            if isduration(m)
                if~all(varfun(@isduration,tbl(:,indc),'OutputFormat','uniform'))
                    msg=getIncompatibleOverlaidTypesMessage(tbl,indc);
                    error(msg);
                end
            end
        end
        if isRecursiveCall&&length(ind{i})>1


            if any(varfun(@(v)isa(v,'tabular'),tbl(:,indc),'OutputFormat','uniform'))
                error(message('MATLAB:stackedplot:OverlaidNestedTable'));
            end
        end
    end
end

function msg=getIncompatibleOverlaidTypesMessage(tbl,indc)
    vars=tbl.Properties.VariableNames(indc);
    vars=unique(vars,"stable");
    switch length(vars)
    case 2
        msg=message("MATLAB:stackedplot:TwoIncompatibleOverlaidTypes",vars{1},vars{2});
    case 3
        msg=message("MATLAB:stackedplot:ThreeIncompatibleOverlaidTypes",vars{1},vars{2},vars{3});
    otherwise
        msg=message("MATLAB:stackedplot:MoreIncompatibleOverlaidTypes",vars{1},vars{2},length(vars)-2);
    end
end
