function out=utilhandler(action,varargin)

    out=[];

    switch(action)
    case 'cleanupPVPairs'
        out=cleanupPVPairs(varargin{:});
    case 'createUndoStruct'
        out=createUndoStruct(varargin{:});
    case 'getGetDisplay'
        out=getGetDisplay(varargin{:});
    case 'getPropertyValues'
        out=getPropertyValues(varargin{:});
    case 'matchProperty'
        out=matchProperty(varargin{:});
    case 'updateColorValueForGet'
        out=updateColorValueForGet(varargin{:});
    case 'updateColorValueForSet'
        out=updateColorValueForSet(varargin{:});
    case 'updateReadOnlyProperty'
        updateReadOnlyProperty(varargin{:});
    case 'verifyPVPairSizes'
        verifyPVPairSizes(varargin{:});
    end



    function pvpairs=cleanupPVPairs(displayProps,props,varargin)

        pvpairs={};
        args=varargin;
        next=args{1};
        count=1;

        while~isempty(next)
            [next,count]=getNextArgument(next,args,count);

            for i=1:2:numel(next)
                propertyList=next{i};
                valueList=next{i+1};

                if iscell(propertyList)&&~iscell(valueList)
                    error('MATLAB:class:BadParamValuePairs','Invalid parameter/value pair arguments.');
                elseif ischar(propertyList)&&iscell(valueList)
                    error('MATLAB:class:BadParamValuePairs','Invalid parameter/value pair arguments.');
                end

                if~iscell(propertyList)
                    propertyList={propertyList};
                end

                if~iscell(valueList)
                    valueList={valueList};
                end

                numProps=numel(propertyList);
                numValues=size(valueList,2);
                if(numProps~=numValues)
                    error('MATLAB:class:ValueCellDimension','Value cell array handle dimension must match handle vector length.');
                end


                for j=1:numel(propertyList)
                    property=matchProperty(propertyList{j},displayProps,props);
                    pvpairs{end+1}=property;%#ok<AGROW>
                    pvpairs{end+1}=valueList(:,j);%#ok<AGROW>                
                end
            end

            if length(args)>=count
                next=args{count};
            else
                next=[];
            end
        end


        function out=createUndoStruct(pvpairs)

            out=struct;
            for i=1:2:numel(pvpairs)
                out.(pvpairs{i})=pvpairs{i+1};
            end


            function out=getGetDisplay(models,gobj,props,fcnhandle)

                out=struct;

                for i=1:length(props)
                    for j=1:length(gobj)
                        next=fcnhandle(models(j),gobj(j),props{i});
                        out(j).(props{i})=next;
                    end
                end


                out=out';


                function values=getPropertyValues(models,gobj,props,fcnhandle)

                    propChar=ischar(props);
                    if isstring(props)
                        props=cellstr(props);
                    end

                    if~iscell(props)
                        props={props};
                    end

                    values=cell(numel(gobj),numel(props));

                    for i=1:length(props)
                        for j=1:length(gobj)
                            values{j,i}=fcnhandle(models(j),gobj(j),props{i});
                        end
                    end

                    if numel(gobj)==1&&propChar
                        values=values{1};
                    end


                    function value=matchProperty(value,displayProps,props)

                        idx=find(startsWith(displayProps,value,'IgnoreCase',true));

                        if numel(idx)>1
                            error('MATLAB:class:InvalidProperty',['Ambiguous property: ''',value,'''.']);
                        elseif isempty(idx)
                            error('MATLAB:class:InvalidProperty',['The name ''',value,''' is not an accessible property.']);
                        else
                            value=props{idx};
                        end


                        function value=updateColorValueForGet(value)

                            if startsWith(value,'rgb')

                                idx=strfind(value,'(');
                                value=value(idx+1:end-1);
                                value=split(value,',');
                                value=[str2double(value{1}),str2double(value{2}),str2double(value{3})];
                                value=value/255;
                            else
                                value=SimBiology.internal.plotting.sbioplot.SBioPlotObject.convertHexToRGB(value);
                            end


                            function value=updateColorValueForSet(prop,value)

                                id='MATLAB:datatypes:RGBAColor:ValueMustBe3or4ElementVector';
                                msg=['Error setting property ''',prop,'''. Invalid RGB triplet. Specify a three-element vector of values between 0 and 1.'];

                                for i=1:numel(value)
                                    next=value{i};
                                    if ischar(next)||isstring(next)
                                        next=convertColorStringToRGB(next);
                                    end

                                    if strcmp(next,'none')

                                    elseif~isnumeric(next)
                                        error(id,msg);
                                    elseif numel(next)~=3
                                        error(id,msg);
                                    else
                                        for j=1:numel(next)
                                            if(next(j)<0||next(j)>1)
                                                error(id,msg);
                                            end
                                        end
                                    end

                                    if strcmp(next,'none')
                                        value{i}='none';
                                    else
                                        value{i}=SimBiology.internal.plotting.sbioplot.SBioPlotObject.convertRGBToHex(next);
                                    end
                                end


                                function updateReadOnlyProperty(property,displayProps,props)

                                    idx=startsWith(props,property,'IgnoreCase',true);
                                    property=displayProps{idx};

                                    error('MATLAB:class:SetProhibited',['You cannot set the read-only property ''',property,'''.']);


                                    function verifyPVPairSizes(gobjList,pvpairs)

                                        numGobjs=numel(gobjList);
                                        for i=1:2:numel(pvpairs)
                                            value=pvpairs{i+1};
                                            if numel(value)~=1&&size(value,1)~=numGobjs
                                                error('MATLAB:class:ValueCellDimension','Value cell array handle dimension must match handle vector length.');
                                            end
                                        end


                                        function[next,count]=getNextArgument(next,args,count)

                                            if isstruct(next)
                                                next=convertStructToPVPairArray(next);
                                                count=count+1;
                                            elseif ischar(next)||iscellstr(next)||isstring(next)
                                                if length(args)>=count+1
                                                    next={next,args{count+1}};
                                                else
                                                    error('MATLAB:class:BadParamValuePairs','Invalid parameter/value pair arguments.');
                                                end

                                                count=count+2;
                                            else
                                                error('MATLAB:class:BadParamValuePairs','Invalid parameter/value pair arguments.');
                                            end


                                            function value=convertStructToPVPairArray(obj)

                                                props=fieldnames(obj);
                                                value=cell(1,numel(props));
                                                count=1;

                                                for i=1:numel(props)
                                                    if numel(obj)>1
                                                        nextProp=props(i);
                                                        nextValue={obj.(props{i})};
                                                        nextValue=reshape(nextValue,numel(nextValue),1);
                                                    else
                                                        nextProp=props{i};
                                                        nextValue=obj.(props{i});
                                                    end

                                                    value{count}=nextProp;
                                                    value{count+1}=nextValue;
                                                    count=count+2;
                                                end


                                                function out=convertColorStringToRGB(value)

                                                    out='';
                                                    next='';
                                                    options={'red','green','blue','cyan','magenta','yellow','black','white','none'};
                                                    idx=find(startsWith(options,value,'IgnoreCase',true));

                                                    if numel(idx)==1
                                                        next=options{idx};
                                                    else
                                                        options2={'r','g','b','c','m','y','k','w'};
                                                        idx=find(startsWith(options2,value,'IgnoreCase',true));
                                                        if numel(idx)==1
                                                            next=options{idx};
                                                        end
                                                    end

                                                    switch(next)
                                                    case 'red'
                                                        out=[1,0,0];
                                                    case 'green'
                                                        out=[0,1,0];
                                                    case 'blue'
                                                        out=[0,0,1];
                                                    case 'cyan'
                                                        out=[0,1,1];
                                                    case 'magenta'
                                                        out=[1,0,1];
                                                    case 'yellow'
                                                        out=[1,1,0];
                                                    case 'black'
                                                        out=[0,0,0];
                                                    case 'white'
                                                        out=[1,1,1];
                                                    case 'none'
                                                        out='none';
                                                    end
