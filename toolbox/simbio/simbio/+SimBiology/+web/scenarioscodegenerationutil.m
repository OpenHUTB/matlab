function varargout=scenarioscodegenerationutil(action,varargin)












    switch(action)
    case 'generateProbabilityDistributionCode'
        [varargout{1},varargout{2}]=generateProbabilityDistributionCode(varargin{:});
    case 'generateSamplingOptionCode'
        [varargout{1},varargout{2},varargout{3}]=generateSamplingOptionCode(varargin{:});
    end


end

function[code,pdCount]=generateProbabilityDistributionCode(data,varName,pdCount)


    arg=['pd',num2str(pdCount)];
    numBlanks=length(varName)-length(arg);
    blankStr='';
    if numBlanks>0
        blankStr=blanks(numBlanks);
    end

    code=[arg,blankStr,' = makedist(''',data.distributionClassName,''', '];


    children=data.children;
    if iscell(children)
        children=[children{:}];
    end
    props={children.name};


    propsToConfigure=data.distributionProperties;
    for i=1:length(propsToConfigure)
        next=propsToConfigure{i};
        nextValue=getDistributionValue(children(strcmp(next,props)).value);
        code=[code,'''',next,''', ',nextValue,', '];%#ok<AGROW> 
    end

    code=[code(1:end-2),');'];


    pdCount=pdCount+1;

end

function[code,optionsIncluded,optionsName]=generateSamplingOptionCode(code,set,samplingType,nameIdx)


    if isnumeric(nameIdx)
        nameIdx=num2str(nameIdx);
    end


    if startsWith(samplingType,'halton')&&~strcmp(set.samplingOptions.scrambleMethodHalton,'none')
        next=['method',nameIdx,'  = struct(''Type'', ''',set.samplingOptions.scrambleMethodHalton,''', ''Options'', {{}});'];
        code=appendCode(code,next);
    elseif startsWith(samplingType,'sobol')&&~strcmp(set.samplingOptions.scrambleMethodSobol,'none')
        next=['method',nameIdx,'  = struct(''Type'', ''',set.samplingOptions.scrambleMethodSobol,''', ''Options'', {{}});'];
        code=appendCode(code,next);
    end

    skip=set.samplingOptions.skip;
    leap=set.samplingOptions.leap;
    iterations=set.samplingOptions.iterations;

    if ischar(skip)
        skip=str2double(skip);
    end

    if ischar(leap)
        leap=str2double(leap);
    end

    if ischar(iterations)
        iterations=str2double(iterations);
    end


    samplingOptions={};
    if startsWith(samplingType,'halton')
        smethod=set.samplingOptions.scrambleMethodHalton;

        if(skip~=1)
            samplingOptions{end+1}='Skip';
            samplingOptions{end+1}=num2str(skip);
        end

        if(leap~=0)
            samplingOptions{end+1}='Leap';
            samplingOptions{end+1}=num2str(leap);
        end

        if~strcmp(smethod,'none')
            samplingOptions{end+1}='ScrambleMethod';
            samplingOptions{end+1}=['method',nameIdx];
        end
    elseif startsWith(samplingType,'sobol')
        pointOrder=set.samplingOptions.pointOrder;
        smethod=set.samplingOptions.scrambleMethodSobol;

        if(skip~=1)
            samplingOptions{end+1}='Skip';
            samplingOptions{end+1}=num2str(skip);
        end

        if(leap~=0)
            samplingOptions{end+1}='Leap';
            samplingOptions{end+1}=num2str(leap);
        end

        if~strcmp(pointOrder,'standard')
            samplingOptions{end+1}='PointOrder';
            samplingOptions{end+1}=['''',pointOrder,''''];
        end

        if~strcmp(smethod,'none')
            samplingOptions{end+1}='ScrambleMethod';
            samplingOptions{end+1}=['method',nameIdx];
        end

    elseif startsWith(samplingType,'latin')
        smooth=set.samplingOptions.smooth;
        criterion=set.samplingOptions.criterion;
        useLHSDesign=set.samplingOptions.useLHSDesign;

        if strcmp(useLHSDesign,'true')

            samplingOptions{end+1}='UseLhsdesign';
            samplingOptions{end+1}=useLHSDesign;

            if~strcmp(smooth,'on')
                samplingOptions{end+1}='Smooth';
                samplingOptions{end+1}=['''',smooth,''''];
            end

            if~strcmp(criterion,'maximin')
                samplingOptions{end+1}='Criterion';
                samplingOptions{end+1}=['''',criterion,''''];
            end

            if(iterations~=5)
                samplingOptions{end+1}='Iterations';
                samplingOptions{end+1}=num2str(iterations);
            end
        end
    end

    optionsName='';
    optionsIncluded=~isempty(samplingOptions);
    if~isempty(samplingOptions)
        optionsName=['options',nameIdx];
        next=[optionsName,' = struct('];

        for i=1:2:numel(samplingOptions)
            property=samplingOptions{i};
            value=samplingOptions{i+1};
            next=[next,'''',property,''', ',value,', '];%#ok<AGROW> 
        end

        next=next(1:end-2);
        next=[next,');'];
        code=appendCode(code,next);
    end

end

function value=getDistributionValue(value)

    if isnumeric(value)
        value=num2str(value);
    end

end

function code=appendCode(code,newCode)

    code=SimBiology.web.codegenerationutil('appendCode',code,newCode);
end
