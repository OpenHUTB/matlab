function status=db2dom_on(varargin)





    mlock;

    persistent ENABLED;

    if isempty(ENABLED)
        try
            mlreportgen.db2dom.DocBook('foo');
            ENABLED=true;
        catch

            ENABLED=[];
            status=false;
        end
    end

    if~isempty(ENABLED)

        if nargin==0
            status=feature('db2dom');
        else
            onoff=varargin{1};
            feature('db2dom',onoff);
            status=feature('db2dom');
        end
    end

end

