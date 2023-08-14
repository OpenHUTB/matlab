function[out,conditions]=smartprocess(h,varargin)





    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end


    table=0;if strcmpi(varargin{end},'table');table=1;end

    new_varargin={};
    ninputs=numel(varargin)-table;
    for ii=1:ninputs
        if~iscell(varargin{ii})
            new_varargin={new_varargin{:},varargin{ii}};
        else
            [varargin{ii}{:}]=convertStringsToChars(varargin{ii}{:});
            new_varargin={new_varargin{:},varargin{ii}{:}};
        end
    end
    varargin=new_varargin;


    [flag_param,~,flag_paramorformat]=getflag(h,varargin{:});
    flag_xparam=getxflag(h,varargin{:});
    loc_param=find(flag_param);
    if isempty(loc_param)
        error(message('rf:rfdata:data:smartprocess:NoValidParam'))
    elseif loc_param(1)~=1&&ischar(varargin{1})
        error(message('rf:rfdata:data:smartprocess:InvalidParam',varargin{1}))
    elseif loc_param(1)~=1
        error(message('rf:rfdata:data:smartprocess:NoValidParam'))
    end
    end_of_paramandformat=find(diff(flag_paramorformat));
    if isempty(end_of_paramandformat)
        end_of_paramandformat=numel(varargin);
    else
        end_of_paramandformat=end_of_paramandformat(1);
    end

    temp=numel(varargin)-end_of_paramandformat;
    if mod(temp,2)&&end_of_paramandformat>=2

        end_of_paramandformat=end_of_paramandformat-1;
    elseif mod(temp,2)
        if ischar(varargin{end})
            error(message('rf:rfdata:data:smartprocess:InvalidFormat',varargin{end}))
        else
            error(message('rf:rfdata:data:smartprocess:LastArgNotFormat'))
        end
    end

    flag_xparam=flag_xparam(1:end_of_paramandformat);
    loc_xparam=find(flag_xparam);
    if numel(loc_xparam)>0&&all(flag_xparam)
        error(message('rf:rfdata:data:smartprocess:NoYParam'))
    end
    if numel(loc_xparam)>1
        error(message('rf:rfdata:data:smartprocess:TooManyXParam'))
    end
    if numel(loc_xparam)==1&&~isequal(loc_xparam,numel(flag_xparam))&&...
        ~isequal(loc_xparam,numel(flag_xparam)-1)
        error(message('rf:rfdata:data:smartprocess:XParamWrongPosition'))
    end
    if numel(loc_xparam)==1
        if flag_param(loc_xparam-1)
            temp=mylistformat(h,varargin{loc_xparam-1});
            varargin={varargin{1:loc_xparam-1},temp{1},varargin{loc_xparam:end}};
            end_of_paramandformat=end_of_paramandformat+1;
        end
    end

    conditions=varargin(end_of_paramandformat+1:end);
    varargin=varargin(1:end_of_paramandformat);
    if any(strcmpi(varargin{end},listparam(h)))||any(strcmpi(varargin{end},listxparam(h)))
        temp=mylistformat(h,varargin{end});
        varargin{end+1}=temp{1};
    end


    [flag_param,flag_format]=getflag(h,varargin{:});
    loc_param=find(flag_param);
    loc_format=find(flag_format);
    paramcell=varargin(loc_param);

    formatcell=cell(size(paramcell));
    ycell=cell(1,2*numel(paramcell));
    if table
        count=numel(paramcell);
        for ii=1:count

            idx=find(loc_param(ii)==(loc_format-1));
            if isempty(idx)
                tempformats=listformat(h,paramcell{ii});
                formatcell(ii)=tempformats(1);
            else
                formatcell(ii)=varargin(loc_format(idx));
            end
        end
        ycell(1:2:end)=paramcell;
        ycell(2:2:end)=formatcell;

    elseif loc_format(1)>loc_param(1)&&loc_format(end)>loc_param(end)&&...
        all(diff(loc_format)~=1)

        idx=1;
        count=numel(loc_format);
        for ii=1:count

            if ii~=1
                temp=numel(find(loc_param<loc_format(ii)&...
                loc_param>loc_format(ii-1)));
            else
                temp=numel(find(loc_param<loc_format(ii)));
            end
            formatcell(idx:idx+temp-1)=varargin(loc_format(ii));
            idx=idx+temp;
        end
        ycell(1:2:end)=paramcell;
        ycell(2:2:end)=formatcell;
    else
        error(message('rf:rfdata:data:smartprocess:WrongOrderOfParam'))
    end


    flag_xparam=getxflag(h,paramcell{:});
    loc_xparam=find(flag_xparam);
    if numel(loc_xparam)==0
        xparam=findxparam(h,paramcell{:});
        temp=mylistformat(h,xparam);
        ycell{end+1}=xparam;
        ycell{end+1}=temp{1};
    end

    out=ycell;


    function xparam=findxparam(h,varargin)

        xparam='Pin';
        power_indep={'Noise Parameters','Phase Noise','Network Parameters'};
        am_dep={'AMAM/AMPM Parameters'};
        ninputs=numel(varargin);
        for ii=1:ninputs
            temp=category(h,varargin{ii});
            if any(strcmpi(temp,power_indep))
                xparam='Freq';
                break
            end
            if any(strcmpi(temp,am_dep))
                xparam='AM';
                break
            end
        end


        function[flag_param,flag_format,flag_paramorformat]=getflag(h,varargin)

            num_input=numel(varargin);
            flag_param=false(1,num_input);
            flag_format=false(1,num_input);
            paramslist=listparam(h);
            formatslist=listformat(h);
            xparamslist=listxparam(h);
            xformatslist=listxformat(h);
            ninputs=numel(varargin);
            for ii=1:ninputs
                flag_param(ii)=any(strcmpi(varargin{ii},paramslist))||...
                any(strcmpi(varargin{ii},xparamslist));
                flag_format(ii)=any(strcmpi(varargin{ii},formatslist))||...
                any(strcmpi(varargin{ii},xformatslist));
            end
            flag_paramorformat=flag_param|flag_format;

            function[flag_xparam,flag_xformat,flag_xparamorxformat]=getxflag(h,varargin)

                num_input=numel(varargin);
                flag_xparam=false(1,num_input);
                flag_xformat=false(1,num_input);
                xparamslist=listxparam(h);
                xformatslist=listxformat(h);
                ninputs=numel(varargin);
                for ii=1:ninputs
                    flag_xparam(ii)=any(strcmpi(varargin{ii},xparamslist));
                    flag_xformat(ii)=any(strcmpi(varargin{ii},xformatslist));
                end
                flag_xparamorxformat=flag_xparam|flag_xformat;

                function list=mylistformat(h,parameter)
                    if any(strcmpi(parameter,listxparam(h)))
                        list=listxformat(h,parameter);
                    else
                        list=listformat(h,parameter);
                    end