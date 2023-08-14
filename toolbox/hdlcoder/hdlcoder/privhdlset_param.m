function privhdlset_param(varargin)




    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if mod(length(varargin),2)==0
        error(message('hdlcoder:makehdl:noobjectname'));
    end

    obj=varargin{1};
    params=varargin(2:end);

    if iscell(obj)
        for ii=1:length(obj)
            blkPath=obj{ii};
            hdlset_param_local(blkPath,params);
        end
    elseif ischar(obj)
        blkPath=obj;
        hdlset_param_local(blkPath,params);
    else
        error(message('hdlcoder:makehdl:invalidobj'));
    end
end


function hdlset_param_local(obj,params)
    narginchk(2,2);
    if isempty(strfind(obj,'/'))

        mdlName=obj;
        openSystems=find_system('flat');

        if isempty(openSystems)||isempty(strfind(openSystems,mdlName))
            error(message('hdlcoder:makehdl:noopenmodels',mdlName));
        end

        if isempty(params)
            error(message('hdlcoder:makehdl:invalidnumargs'));
        end
        setHDLCodeGenParams(mdlName,params)

    else

        blkName=obj;
        if(isBusElementPort(get_param(blkName,'Object')))
            error(message('hdlcoder:makehdl:BusElementPortBlockPropertiesNotSupported'));
        end
        setBlkHDLImplParams(blkName,params);
    end
end


function setHDLCodeGenParams(mdlName,newParams)


    cli=hdlcoderprops.CLI;





    transientCLIs=cli.getTransientPropNameList;
    transientCLIsToSet=intersect(lower(transientCLIs),lower(newParams(1:2:end)));
    dbgIdx=find(strcmpi(newParams(1:2:end),'debug'),1);
    if(~isempty(transientCLIsToSet)&&(isempty(dbgIdx)||newParams{dbgIdx*2}<=0))
        str=transientCLIsToSet{1};
        for i=2:length(transientCLIsToSet)
            str=sprintf('%s, %s',transientCLIsToSet{i});
        end
        error(message('hdlcoder:makehdl:cannotsettransientclis',str));
    end

    mdlProps=get_param(mdlName,'HDLParams');
    if isempty(mdlProps)
        mdlProps=slprops.hdlmdlprops;
    end
    currProps=mdlProps.getCurrentMdlProps;
    for k=1:2:length(currProps)
        try
            cli.set(currProps{k},currProps{k+1});
        catch mEx %#ok<NASGU>




        end
    end



    autoPlaceIdx=find(strcmpi(newParams(1:end),'autoplace'),1);
    autoRouteIdx=find(strcmpi(newParams(1:end),'autoroute'),1);
    if~isempty(autoPlaceIdx)

        if strcmpi(newParams(autoPlaceIdx+1),'off')
            newParams{end+1}='autoroute';
            newParams{end+1}='off';
        end
    else

        if strcmpi(newParams(autoRouteIdx+1),'on')
            newParams{end+1}='autoplace';
            newParams{end+1}='on';
            warning(message('HDLShared:CLI:AutoPlaceTurnOn'));
        end
    end



    generateMdlIdx=find(strcmpi(newParams(1:end),'generatemodel'),1);
    if~isempty(generateMdlIdx)
        if strcmpi(newParams(generateMdlIdx+1),'off')
            newParams{end+1}='generatevalidationmodel';
            newParams{end+1}='off';
            newParams{end+1}='autoplace';
            newParams{end+1}='off';
            newParams{end+1}='autoroute';
            newParams{end+1}='off';
        end
    end


    gmNamePrefixIdx=find(strcmpi(newParams(1:end),'GeneratedModelNamePrefix'),1);
    vnlNameSuffixIdx=find(strcmpi(newParams(1:end),'GeneratedValidationModelNameSuffix'),1);
    if~isempty(gmNamePrefixIdx)
        if isempty(newParams{gmNamePrefixIdx+1})
            error(message('hdlcoder:validate:InvalidGMPrefixName'));
        end
        gmMdlName=[newParams{gmNamePrefixIdx+1},mdlName];
        if length(gmMdlName)>namelengthmax
            error(message('hdlcoder:validate:ExceedNameLengthMaxSize',gmMdlName,'generated model'));
        end
        if~isvarname(gmMdlName)
            error(message('hdlcoder:validate:InvalidGMPrefixName'));
        end
    end
    if~isempty(vnlNameSuffixIdx)
        gmPrefix=hdlget_param(mdlName,'GeneratedModelNamePrefix');
        if isempty(newParams{vnlNameSuffixIdx+1})
            error(message('hdlcoder:validate:InvalidVNLSuffixName'));
        end
        vnlMdlName=[gmPrefix,mdlName,newParams{vnlNameSuffixIdx+1}];
        if length(vnlMdlName)>namelengthmax
            error(message('hdlcoder:validate:ExceedNameLengthMaxSize',vnlMdlName,'validation model'));
        end
        if~isvarname(vnlMdlName)
            error(message('hdlcoder:validate:InvalidVNLSuffixName'));
        end
    end


    for ii=1:2:length(newParams)
        param=newParams{ii};
        paramVal=newParams{ii+1};
        pvPair={param,paramVal};

        try
            if(~ischar(param)||(size(param,1)~=1))
                error(message('hdlcoder:makehdl:noparams'));
            end

            cli.set(pvPair{:})
        catch me
            getReport(me);
            error(message('hdlcoder:makehdl:badsetparam',param,me.message));
        end
    end

    excludeHidden=false;
    nonDefParams=cli.getNonDefaultHDLCoderProps(excludeHidden);
    nonDefParams=sort(nonDefParams);

    finalSettings={};
    for ii=1:length(nonDefParams)
        pName=nonDefParams{ii};
        pValue=cli.(pName);
        finalSettings{end+1}=pName;
        finalSettings{end+1}=pValue;
    end


    if~isequal(currProps,finalSettings)
        mdlProps.setCurrentMdlProps(finalSettings);


        set_param(mdlName,'HDLParams',mdlProps);
        Simulink.slx.setPartDirty(mdlName,'blockDiagram');




        hdlcc=gethdlcc(mdlName);
        if isempty(hdlcc)
            hdlcc=attachhdlcconfig(mdlName);
        end
        if~isempty(hdlcc.CLI)
            hdlcc.CLI=cli;
            if(isempty(cli.HDLSubsystem))
                cli.HDLSubsystem='';
            end
            hdlcc.CLI.HDLSubsystem=hdlfixblockname(cli.HDLSubsystem);
        end




        cs=getActiveConfigSet(mdlName);
        if~isempty(cs.getDialogHandle)
            cscache=cs.getConfigSetCache;
            hdlcccache=cscache.getComponent('HDL Coder');
            hdlcccache.CLI=cli;
            cs.refreshDialog;
        end
    end
end


function paramVal=setBlkHDLImplParams(blkNameWithPath,newParams)
    archParams={};
    archImplParams={};
    for ii=1:2:length(newParams)
        paramName=newParams{ii};
        paramVal=newParams{ii+1};

        if strcmpi(paramName,'Architecture')
            archParams{end+1}=paramName;%#ok<*AGROW>
            archParams{end+1}=paramVal;
        else
            archImplParams{end+1}=paramName;
            archImplParams{end+1}=paramVal;
        end
    end

    hd=slprops.hdlblkdlg(blkNameWithPath);


    if~isempty(archParams)
        archNameInfo=hd.getArchitectureNames;
        archSelection=archParams{end};

        asel=strmatch(lower(archSelection),lower(archNameInfo));%#ok<MATCH2>

        if isempty(asel)

            supportedArchs=enum2str(archNameInfo);
            error(message('hdlcoder:makehdl:badarchparam',supportedArchs));
        end


        asel=asel(1);

        if~strcmp(archNameInfo{asel},archSelection)


            archSelection=archNameInfo{asel};

            supportedArchs=enum2str(archNameInfo);
            warning(message('hdlcoder:makehdl:badarchparamcase',archSelection,supportedArchs));
        end


        hd.setCurrentArch(archSelection);
    end

    if~isempty(archImplParams)
        implInfo=hd.getCurrentArchImplParams;
        if isempty(implInfo)
            error(message('hdlcoder:makehdl:invalidimplparams'));
        end


        for ii=1:2:length(archImplParams)
            paramName=archImplParams{ii};
            paramVal=archImplParams{ii+1};

            if~implInfo.isKey(lower(paramName))
                error(message('hdlcoder:makehdl:invalidimplparam',paramName));
            end

            pInfo=implInfo(lower(paramName));


            [validateStruct,pInfo.Value]=validateParamValue(paramVal,pInfo);

            switch validateStruct.Status
            case 1
                error(validateStruct.MessageID,...
                validateStruct.Message);
            otherwise

            end

            implInfo(lower(paramName))=pInfo;
        end
        hd.setCurrentArchImplParams(implInfo);
    end

    hd.writeInfoToSLBlk;
end


