function generatehdl(filterobj,varargin)




    for k=1:length(varargin)
        if iscell(varargin{k})
            [varargin{k}{:}]=convertStringsToChars(varargin{k}{:});
        else
            varargin{k}=convertStringsToChars(varargin{k});
        end
    end

    [cando,errstr]=ishdlable(filterobj);
    if~cando
        error(message('hdlfilter:filtergroup:usrp2:generatehdl:unsupportedarch',class(filterobj)));
    end


    if~any(strcmpi(varargin,'name'))
        varargin(end+1)={'name'};
        if~isempty(inputname(1))
            varargin(end+1)={inputname(1)};
        else
            error(message('hdlfilter:filtergroup:usrp2:generatehdl:genhdlcalledwithconst'));
        end
    end



    indices=strcmpi(varargin,'generatehdltestbench');
    pos=1:length(indices);
    pos=pos(indices);

    indices_name=strcmpi(varargin,'name');
    posname=1:length(indices_name);
    posname=posname(indices_name);

    if(~isempty(pos)&&~strcmpi(varargin{pos+1},'off'))&&...
        ~any(strcmpi(varargin,'testbenchname'))
        varargin(end+1)={'testbenchname'};
        if~isempty(pos)
            varargin(end+1)={[varargin{posname+1},'_tb']};
        else
            varargin(end+1)={[inputname(1),'_tb']};
        end
    end

    privgeneratehdl(filterobj,varargin{:});


