function[dv,ind]=validateDisplayVariables(dv,tbl,funcname,varname)




    [dv,ind]=validateDisplayVariables_inner(dv,tbl,funcname,varname);

end

function[dv,ind,validDisplayVars]=validateDisplayVariables_inner(dv,tbl,funcname,varname,isRecursiveCall)
    import matlab.internal.datatypes.isText
    import matlab.internal.datatypes.throwInstead

    if nargin<5
        isRecursiveCall=false;
    end
    if iscell(tbl)
        validDisplayVars=false;
        try
            validateattributes(dv,{'cell','string'},{'vector'},funcname,varname);
        catch ME
            throwInstead(ME,'MATLAB:stackedplot:invalidType','MATLAB:stackedplot:DisplayVariablesInvalidTypeMultiTable');
        end
        if iscell(dv)
            for i=1:length(dv)
                if~(ischar(dv{i})||iscellstr(dv{i})||isstring(dv{i}))
                    error(message('MATLAB:stackedplot:DisplayVariablesInvalidTypeMultiTable'));
                end
            end
        elseif isstring(dv)
            dv=cellstr(dv);
        end
        ind=cell(1,numel(tbl));
        dvTmp=cell(1,numel(tbl));
        for k=1:numel(tbl)
            try
                [dvTmp{k},ind{k},validdv]=validateDisplayVariables_inner(dv,tbl{k},funcname,varname,true);
                validDisplayVars=validDisplayVars|validdv;
            catch ME
                if ismember(ME.identifier,strcat("MATLAB:stackedplot:",["TwoIncompatibleOverlaidTypes","ThreeIncompatibleOverlaidTypes","MoreIncompatibleOverlaidTypes"]))
                    vars=extract(ME.message,regexpPattern("'.*'(, and \d+ others)?"));
                    msg=message('MATLAB:stackedplot:IncompatibleOverlaidTypesMultiTable',k,vars{1});
                    error(msg);
                else
                    rethrow(ME);
                end
            end
        end

        if~all(validDisplayVars)
            if iscellstr(dv)
                varsflat=dv;
            else
                varsflat=[dv{:}];
            end
            firstInvalidVar=varsflat{find(~validDisplayVars,1)};
            error(message('MATLAB:stackedplot:InvalidDisplayVariablesMultiTable',firstInvalidVar));
        end









        dvValid=cell(size(dv));
        for k=1:numel(tbl)
            for i=1:numel(dvTmp{k})
                dvValid{i}=union(dvValid{i},cellstr(dvTmp{k}{i}));
            end
        end


        for i=1:numel(dvValid)
            dv_i=cellstr(dv{i});
            dvInvalid=setxor(dv_i,dvValid{i});
            dv_i(ismember(dv_i,dvInvalid))=[];
            if isscalar(dv_i)
                dv_i=dv_i{1};
            end
            dv{i}=dv_i;
        end
        return
    end

    validDisplayVars=true;
    if isnumeric(dv)
        validateattributes(dv,{'numeric'},{'vector','integer',...
        'positive','<=',width(tbl)},funcname,varname);
        ind=dv;
        dv=tbl.Properties.VariableNames(dv);
    elseif iscellstr(dv)||isstring(dv)
        validateattributes(dv,{'cell','string'},{'vector'},funcname,varname);

        dv=cellstr(dv);

        [lia,ind]=ismember(dv,tbl.Properties.VariableNames);
        if~all(lia)
            if~isRecursiveCall
                firstInvalidVar=dv{find(~lia,1)};
                error(message('MATLAB:stackedplot:InvalidDisplayVariables',firstInvalidVar));
            else
                validDisplayVars=lia;
            end
        end
    elseif islogical(dv)
        validateattributes(dv,{'logical'},{'vector'},funcname,varname);
        if length(dv)>width(tbl)
            error(message('MATLAB:stackedplot:LogicalArraySize',varname,width(tbl)));
        end
        ind=find(dv);
        dv=tbl.Properties.VariableNames(dv);
    elseif iscell(dv)
        validateattributes(dv,{'cell'},{'vector'},funcname,varname);


        if~isempty(dv)

            istextvar=false;
            isnumericvar=false;

            currvar=dv{1};

            if isempty(currvar)
                error(message('MATLAB:stackedplot:DisplayVariablesEmptyCells'));
            end

            if isText(currvar)
                istextvar=true;
            elseif isnumeric(currvar)
                isnumericvar=true;
            else
                error(message('MATLAB:stackedplot:DisplayVariablesInvalidType'));
            end

            for i=2:length(dv)
                currvar=dv{i};

                if isempty(currvar)
                    error(message('MATLAB:stackedplot:DisplayVariablesEmptyCells'));
                end



                if(istextvar&&~isText(currvar))||(isnumericvar&&~isnumeric(currvar))||~(istextvar||isnumericvar)
                    error(message('MATLAB:stackedplot:DisplayVariablesInvalidType'));
                end
            end
        end

        try
            varsflat=[dv{:}];
        catch
            error(message('MATLAB:stackedplot:DisplayVariablesInvalidType'));
        end
        if iscellstr(varsflat)||isstring(varsflat)

            [lia,ind]=ismember(varsflat,tbl.Properties.VariableNames);
            if~all(lia)
                if~isRecursiveCall
                    firstInvalidVar=char(varsflat(find(~lia,1)));
                    error(message('MATLAB:stackedplot:InvalidDisplayVariables',firstInvalidVar));
                else
                    validDisplayVars=lia;
                end
            end
            nplots=ones(size(dv));
            for i=1:length(dv)

                dv{i}=convertStringsToChars(dv{i});
                if iscell(dv{i})
                    nplots(i)=length(dv{i});
                end
            end
            ind=mat2cell(ind,1,nplots);
        else

            if any(varsflat<=0)||any(varsflat>width(tbl))||...
                ~isequal(floor(varsflat),varsflat)
                error(message('MATLAB:stackedplot:InvalidDisplayVariablesIndices',width(tbl)));
            end
            ind=dv;
            dv=cell(size(ind));
            for i=1:length(ind)
                if isscalar(ind{i})
                    dv{i}=tbl.Properties.VariableNames{ind{i}};
                else
                    dv{i}=tbl.Properties.VariableNames(ind{i});
                end
            end
        end
    elseif isa(dv,'vartype')
        temptable=tbl(:,dv);
        dv=temptable.Properties.VariableNames;
        [~,ind]=ismember(dv,tbl.Properties.VariableNames);
    else
        error(message('MATLAB:stackedplot:DisplayVariablesInvalidType'));
    end


    validationInd=ind;
    if isRecursiveCall
        if iscell(ind)
            validationInd=cellfun(@(x)x(x~=0),ind,'UniformOutput',false);
            validationInd=validationInd(~cellfun(@isempty,validationInd));
        else
            validationInd=ind(ind~=0);
        end
    end
    if~all(matlab.graphics.chart.internal.stackedplot.canBeDisplayVariables(tbl,false,validationInd))
        error(message('MATLAB:stackedplot:UnplottableDisplayVariables'));
    end


    if iscell(ind)
        matlab.graphics.chart.internal.stackedplot.validateOverlaidVariables(tbl,validationInd,ind,isRecursiveCall);
    end
end
