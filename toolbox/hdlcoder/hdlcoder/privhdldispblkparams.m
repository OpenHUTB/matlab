function privhdldispblkparams(blkName,allParams)


    if~isempty(blkName)
        obj=blkName;
        if~isempty(strfind(obj,'/'))

            dispBlkParams(blkName,allParams);
        end
    end
end


function dispBlkParams(blkNameWithPath,allParams)

    hd=slprops.hdlblkdlg(blkNameWithPath);

    hdrTxt=sprintf('HDL Block Parameters (''%s'')',blkNameWithPath);
    repStr=repmat('%',1,length(hdrTxt)+3);
    str=sprintf('\n%s\n%s\n%s\n\n',repStr,hdrTxt,repStr);

    if~allParams
        cd=get_param(blkNameWithPath,'HDLData');
        if isempty(cd)
            str=[str,sprintf('No Custom HDL settings found\n')];
        else
            ca=cd.getCurrentArch;
            cp=cd.getCurrentArchImplParams;

            str=[str,sprintf('Implementation\n\n')];
            str=[str,sprintf('\tArchitecture : %s\n\n',ca)];
            paramStr=getParamStr(cp);
            if~isempty(paramStr)
                str=[str,sprintf('Implementation Parameters\n\n')];
                str=[str,paramStr];
            end
        end
    else

        archName=hd.getCurrentArchName;
        if~isempty(archName)
            str=[str,sprintf('Implementation\n\n')];
            str=[str,sprintf('\tArchitecture  : %s\n\n',archName)];
            str=[str,sprintf('Implementation Parameters\n\n')];

            cpMap=hd.getCurrentArchImplParams;
            if~isempty(cpMap)
                k=cpMap.keys;
                cp={};
                for ii=1:length(k)
                    pN=k{ii};
                    pSettings=cpMap(pN);
                    cp{end+1}=pSettings.ImplParamName;
                    cp{end+1}=pSettings.Value;
                end
                str=[str,getParamStr(cp)];
            end
        end

    end

    disp(str);

end


function str=getParamStr(cp)

    str='';
    if isempty(cp)
        return;
    end

    if~iscell(cp)||mod(length(cp),2)~=0
        error(message('hdlcoder:makehdl:invalidparam'));
    end

    for ii=1:2:length(cp)
        pName=cp{ii};
        pVal=cp{ii+1};

        if ischar(pVal)
            str=[str,sprintf('\t%s : %s\n',pName,pVal)];%#ok<*AGROW>
        elseif isnumeric(pVal)
            if isscalar(pVal)
                str=[str,sprintf('\t%s : %d\n',pName,pVal)];
            else
                valStr=sprintf('%d ',pVal);
                str=[str,sprintf('\t%s : %s\n',pName,valStr)];
            end
        end
    end

end