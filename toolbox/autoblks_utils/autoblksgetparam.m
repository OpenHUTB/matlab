function[val]=autoblksgetparam(varargin)


    block=varargin{1};
    name=varargin{2};
    pname=varargin{3};
    dims=varargin{4};
    src=varargin{5};

    if isempty(block)
        param=name;
    else
        param=get_param(block,name);
    end

    if nargin==6
        chks=varargin{6};
    else
        chks={};
    end

    try
        tmp=evalin('base',param);
    catch
        tmp=str2double(param);
        if isnan(tmp)
            error(message(['autoblks:',src,':invalidExist'],pname));
        end
    end


    if isa(tmp,'mpt.Parameter')||isa(tmp,'Simulink.Parameter')
        if isempty(tmp.Value)
            error(message(['autoblks:',src,':invalidEmpty'],pname));
        elseif~all(isnumeric(tmp.Value(:)))
            error(message(['autoblks:',src,':invalidNumeric'],pname));
        elseif~all(isfinite(tmp.Value(:)))
            error(message(['autoblks:',src,':invalidFinite'],pname));
        elseif~all(isreal(tmp.Value(:)))
            error(message(['autoblks:',src,':invalidReal'],pname));
        elseif~(isequal(tmp.DataType,'single')||isequal(tmp.DataType,'double')||isequal(tmp.DataType,'auto'))
            error(message(['autoblks:',src,':invalidFloat'],pname));
        else
            [m,n]=size(tmp);
            if isfinite(dims(1))&&m~=dims(1)||isfinite(dims(2))&&n~=dims(2)
                error(message(['autoblks:',src,':invalidDims'],pname,dims(1),dims(2)));
            end

            if isequal(tmp.DataType,'single')
                val=single(tmp.Value);
            else
                val=tmp.Value;
            end
        end

    else
        if isempty(tmp)
            error(message(['autoblks:',src,':invalidEmpty'],pname));
        elseif~all(isnumeric(tmp(:)))
            error(message(['autoblks:',src,':invalidNumeric'],pname));
        elseif~all(isfinite(tmp(:)))
            error(message(['autoblks:',src,':invalidFinite'],pname));
        elseif~all(isreal(tmp(:)))
            error(message(['autoblks:',src,':invalidReal'],pname));
        elseif~all(isfloat(tmp(:)))
            error(message(['autoblks:',src,':invalidFloat'],pname));
        else
            [m,n]=size(tmp);
            if isfinite(dims(1))&&m~=dims(1)||isfinite(dims(2))&&n~=dims(2)
                error(message(['autoblks:',src,':invalidDims'],pname,dims(1),dims(2)));
            end

            val=tmp;
        end
    end

    if~isempty(chks)
        [rows,~]=size(chks);
        for j=1:rows
            chk=chks{j,1};
            bound=chks{j,2};
            switch chk
            case 'gt'
                if val<=bound
                    error(message(['autoblks:',src,':invalidParametergt'],pname,bound));
                end
            case 'gte'
                if val<bound
                    error(message(['autoblks:',src,':invalidParametergte'],pname,bound));
                end
            case 'eq'
                if val~=bound
                    error(message(['autoblks:',src,':invalidParametereq'],pname,bound));
                end
            case 'neq'
                if val==bound
                    error(message(['autoblks:',src,':invalidParameterneq'],pname,bound));
                end
            case 'lt'
                if val>=bound
                    error(message(['autoblks:',src,':invalidParameterlt'],pname,bound));
                end
            case 'lte'
                if val>bound
                    error(message(['autoblks:',src,':invalidParameterlte'],pname,bound));
                end
            case 'st'
                if val~=-1&&val<=0
                    error(message(['autoblks:',src,':invalidSampleTime'],pname));
                end
            otherwise
                error(message(['autoblks:',src,':invalidParameter'],pname));
            end
        end
    end
