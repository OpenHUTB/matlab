function constraintsParser(obj,newFunction)


    f={};
    constraintsFunctionName={};
    operator={};
    value={};

    numFeed=size(obj.FeedLocation,1);

    cellfun(@(x)validateattributes(x,{'char','string'},...
    {'nonempty'},...
    'optimize','Constraints'),newFunction,...
    'UniformOutput',false);

    switch class(newFunction)
    case 'cell'
        obj.OptimStruct.NoOfConstraints=length(newFunction);
        if isempty(obj.OptimStruct.Weights)
            makeEqualWeights(obj);
        end

        for i=1:length(newFunction)
            switch class(newFunction{i})
            case{'char','string'}

                constraintStatement=strsplit(newFunction{i});
                if numFeed==1
                    validatestring(constraintStatement{1},{'Area',...
                    'Volume','S11','Gain','F/B',...
                    'Correlation','SLL'},...
                    'optimize','constraints');
                else
                    validatestring(constraintStatement{1},{'Area',...
                    'Volume','S11','Gain','F/B',...
                    'Correlation','SLL','Sij','Sii'},...
                    'optimize','constraints');
                end

                f{end+1}=allocate(newFunction{i});






            otherwise

            end

            obj.OptimStruct.ConstraintsFunction=f;
        end















    otherwise

    end

    function rtn=allocate(name)
        constraintStatement=strsplit(name);
        if strcmpi(constraintStatement{1},'Sii')
            constraintsFunctionName{end+1}='S11';
        else
            constraintsFunctionName{end+1}=constraintStatement{1};
        end
        operator{end+1}=constraintStatement{2};
        valueNum=str2num(constraintStatement{3});%#ok<ST2NM>
        if isempty(valueNum)
            error(message("antenna:antennaerrors:InvalidConstraintsValue"));
        end
        value{end+1}=valueNum;
        setConstraintsFunctionName(obj,constraintsFunctionName);
        setOperator(obj,operator);
        setValue(obj,value);

        if strcmpi(constraintStatement{1},'Area')
            rtn=areaConstraint(obj);
        elseif strcmpi(constraintStatement{1},'Volume')
            rtn=volumeConstraint(obj);
        elseif strcmpi(constraintStatement{1},'S11')
            rtn=s11Constraint(obj);
        elseif strcmpi(constraintStatement{1},'Gain')
            rtn=gainConstraint(obj);
        elseif strcmpi(constraintStatement{1},'F/B')
            rtn=fBrConstraint(obj);


        elseif strcmpi(constraintStatement{1},'SLL')
            rtn=SLLConstraint(obj);
        elseif strcmpi(constraintStatement{1},'Sij')
            rtn=sijConstraint(obj);
        elseif strcmpi(constraintStatement{1},'Sii')
            rtn=s11Constraint(obj);
        end
    end
end
