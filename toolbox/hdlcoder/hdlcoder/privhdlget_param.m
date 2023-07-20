function paramVal=privhdlget_param(varargin)


    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if(length(varargin)~=2)
        error(message('hdlcoder:makehdl:invalidnumargs'));
    end

    obj=varargin{1};

    if(~ischar(obj)||(size(obj,1)~=1))
        error(message('hdlcoder:makehdl:invalidobj'));
    end

    param=varargin{2};

    if(~ischar(param)||(size(param,1)~=1))
        error(message('hdlcoder:makehdl:invalidgetparam'));
    end

    if isempty(strfind(obj,'/'))

        mdlName=obj;
        openSystems=find_system('flat');

        if isempty(openSystems)||isempty(strfind(openSystems,mdlName))
            error(message('hdlcoder:makehdl:noopenmodels',mdlName));
        end

        paramVal=getHDLCodeGenParams(mdlName,param);
    else

        blkName=obj;
        paramVal=getBlkHDLImplParams(blkName,param);
    end
end


function paramVal=getHDLCodeGenParams(mdlName,paramName)

    cli=hdlcoderprops.CLI;
    mdlProps=get_param(mdlName,'HDLParams');
    if isempty(mdlProps)
        mdlProps=slprops.hdlmdlprops;
    end
    currProps=mdlProps.getCurrentMdlProps;


    for k=1:2:length(currProps)
        try
            cli.set(currProps{k},currProps{k+1});
        catch me %#ok<NASGU>

        end
    end


    try
        if strcmpi(paramName,'all')

            paramNames=cli.getAllHDLCoderProps(false);
            paramNames=sort(paramNames);
            params={};
            if~isempty(paramNames)
                for ii=1:length(paramNames)
                    pName=paramNames{ii};
                    pValue=cli.(pName);

                    params{end+1}=pName;
                    params{end+1}=pValue;
                end
            end
            paramVal=params;

        else


            paramVal=cli.get(paramName);
        end

    catch me
        getReport(me)
        error(message('hdlcoder:makehdl:badparam',paramName));
    end
end


function paramVal=getBlkHDLImplParams(blkNameWithPath,paramName)

    hd=slprops.hdlblkdlg(blkNameWithPath);

    if strcmpi(paramName,'all')

        paramVal={};

        implInfo=hd.getCurrentArchImplParams;
        if~isempty(implInfo)

            paramVal{end+1}='Architecture';
            paramVal{end+1}=hd.getCurrentArchName;

            keys=implInfo.keys;
            for ii=1:length(keys)
                k=keys{ii};
                p=implInfo(k);
                paramVal{end+1}=p.ImplParamName;%#ok<*AGROW>
                paramVal{end+1}=p.Value;
            end
        end

    elseif strcmpi(paramName,'Architecture')

        paramVal=hd.getCurrentArchName;
    else

        implInfo=hd.getCurrentArchImplParams;
        pname=lower(paramName);
        if isKey(implInfo,pname)
            currParamInfo=implInfo(pname);
            paramVal=currParamInfo.Value;
        else
            error(message('hdlcommon:hdlcommon:badparam',paramName,blkNameWithPath));
        end
    end
end
