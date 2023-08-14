

























function generateConfigurationParameterDataFile(filename,source,varargin)
    if nargin>0
        filename=convertStringsToChars(filename);
    end

    if nargin>1
        source=convertStringsToChars(source);
    end

    if nargin>2
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    status=-1;

    opts=parseinputs(varargin{:});

    if~ischar(filename)
        DAStudio.error('Advisor:engine:UnsupportedMethodInput','generateModelParameterDataFile');
    end


    dataFile=Advisor.authoring.DataFile(filename);
    doc=dataFile.getXMLDoc();

    if isa(source,'Simulink.ConfigSet')
        status=generateDataFileFromConfigSetObj(doc,dataFile,source,opts);

    elseif ischar(source)&&exist(source,'file')==4
        closeIt=false;
        if~bdIsLoaded(source)
            load_system(source);
            closeIt=true;
        end

        cs=getActifConfigSet(source);
        status=generateDataFileFromConfigSetObj(doc,dataFile,cs,opts);

        if closeIt
            close_system(source);
        end
    elseif isa(source,'Simulink.BlockDiagram')
        cs=getActifConfigSet(source);
        status=generateDataFileFromConfigSetObj(doc,dataFile,cs,opts);

    elseif ishandle(source)
        try
            system=bdroot(source);
            sysObj=get_param(system,'object');
        catch
            DAStudio.error('Advisor:engine:DataFileGenInvalidSource');
        end

        if isa(sysObj,'Simulink.BlockDiagram')
            cs=getActifConfigSet(sysObj);
            status=generateDataFileFromConfigSetObj(doc,dataFile,cs,opts);
        end

    else
        DAStudio.error('Advisor:engine:DataFileGenInvalidSource');
    end


    if status==0
        dataFile.write();
    end
end

function status=generateDataFileFromConfigSetObj(doc,dataFile,cs,options)
    status=-1;%#ok<NASGU>

    if isa(cs,'Simulink.ConfigSetRef')
        DAStudio.error('Advisor:engine:DataFileGenConfisSetRef');
    end


    parameters={};
    data=configset.internal.getConfigSetStaticData;
    components=data.ComponentList;

    for n=1:length(components)
        co=components{n};

        if~strcmp(co.Name,'ConfigSet')&&...
            ~strcmp(co.Name,'HDL Coder')&&...
            (isempty(options.PaneName)||...
            strcmpi(regexprep(co.Name,'\W',''),regexprep(options.PaneName,'\W','')))

            paramObjs=co.ParamList;
            temParameterNames=cell(1,length(paramObjs));

            for ni=1:length(paramObjs)
                temParameterNames{ni}=paramObjs{ni}.Name;
            end

            parameters=[parameters,temParameterNames];%#ok<AGROW>
        end
    end


    parameters=unique(parameters);


    for ni=1:length(parameters)

        try



            d=configset.getParameterInfo(cs,parameters{ni});


            if d.IsUI&&d.IsWritable

                prompt=d.Description;


                if~strncmpi(prompt,'RTW:configset:',14)
                    prompt=regexprep(prompt,':','');
                    commentNode=doc.createComment([prompt,' (',parameters{ni},')']);
                else
                    commentNode=doc.createComment(parameters{ni});
                end



                def.ParameterName=parameters{ni};

                value=cs.get_param(parameters{ni});
                if isnumeric(value)
                    value=num2str(value);
                end

                if isempty(value)
                    value='';
                end

                def.SupportedParameterValues={value};


                if options.FixValues
                    def.FixValue=value;
                end

                constraint=Advisor.authoring.PositiveModelParameterConstraint(def);
                node=constraint.getXMLNode(doc);


                dataFile.appendConstraintNode(commentNode);
                dataFile.appendConstraintNode(node);


                lb=doc.createTextNode(sprintf('\n'));
                dataFile.appendConstraintNode(lb);
            else

            end
        catch err %#ok<NASGU>


        end
    end
    status=0;
end

function cs=getActifConfigSet(system)
    if~isa(system,'Simulink.BlockDiagram')
        sysObj=get_param(system,'object');
    else
        sysObj=system;
    end
    cs=sysObj.getActiveConfigSet();
end

function opts=parseinputs(varargin)


    opts.PaneName='';
    opts.FixValues=false;


    if rem(length(varargin),2)~=0
        DAStudio.error('Advisor:engine:invalidArgPairing','generateConfigurationParameterDataFile');
    end

    for n=1:2:length(varargin)
        if~ischar(varargin{n})
            DAStudio.error('Advisor:engine:NonStringPropertyName');
        end

        switch varargin{n}
        case{'Pane','pane'}
            if~ischar(varargin{n+1})
                DAStudio.error('Advisor:engine:CCUnsupportedInput');
            end
            opts.PaneName=varargin{n+1};
        case{'FixValues','fixvalues','fixValues','Fixvalues'}
            if~islogical(varargin{n+1})
                DAStudio.error('Advisor:engine:CCUnsupportedInput');
            end
            opts.FixValues=varargin{n+1};
        otherwise
            DAStudio.error('Advisor:engine:UnknownProperty',varargin{n});
        end
    end
end
