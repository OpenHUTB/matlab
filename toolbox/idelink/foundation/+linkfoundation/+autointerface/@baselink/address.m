function addr=address(h,symname,vscope)
































    narginchk(2,3);
    linkfoundation.util.errorIfArray(h);

    if nargin==2
        vscope='global';
    end

    if~ischar(vscope),
        error(message('ERRORHANDLER:autointerface:InvalidNonCharSymbolScope'));
    end
    if~any(strcmpi(vscope,{'global','local'}))
        error(message('ERRORHANDLER:autointerface:InvalidSymbolScopeValue',vscope));
    end


    addr=h.mIdeModule.GetAddress(symname,vscope);


    if~isempty(addr)&&addr(2)<0
        error(message('ERRORHANDLER:autointerface:MethodNotApplicable',symname));
    end

