function y=tablelookupND(fd,varargin)
%#codegen



    coder.allowpcode('plain');






    dims=(numel(varargin)-2)/2;






    if(dims==1)
        validateattributes(fd,{'single','double'}...
        ,{'vector','nonempty','nonsparse','finite','nonnan','real'},'','"Table data"',1);
        validateattributes(numel(fd),{'double'},{'>',1},'','"Number of elements in Table Data"');
    else
        validateattributes(fd,{'single','double'},...
        {'ndims',dims,'nonempty','nonsparse','finite','nonnan','real'},'','"Table data"');
        validateattributes(size(fd),{'double'},{'>',1},'','"Size of Table Data"');
    end




    argumentClass={class(fd)};



    if(dims==1)


        validateattributes(varargin{1},argumentClass,...
        {'vector','numel',numel(fd),'nonempty','nonsparse','finite','nonnan','real'},...
        '','"Breakpoints"',2);
    else
        for i=1:dims
            validateattributes(varargin{i},argumentClass,...
            {'vector','numel',size(fd,i),'nonempty','nonsparse','finite','nonnan','real'}...
            ,'','"Breakpoint"',1+i);
        end
    end




    totalElements=numel(varargin{dims+1});
    for i=1:dims
        validateattributes(varargin{dims+i},argumentClass,...
        {'vector','numel',totalElements,'nonempty','nonsparse','finite','nonnan','real'},'','',1+dims+i);
    end



    coder.internal.assert((strcmp('linear',varargin{2*dims+1})&&strcmp('linear',varargin{2*dims+2})),...
    'hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:ValidateTLUAlgorithm');
    y=varargin{dims+1};

end
