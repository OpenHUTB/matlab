function adp=getConfigSetAdapter(cs,varargin)




    tlc=false;
    if nargin>1
        tlc=varargin{1};
    end

    hController=cs.getDialogController;
    adp=hController.csv2;
    if isempty(adp)
        if tlc


            adp=configset.internal.data.ConfigSetAdapter(cs);
        else


            adp=configset.internal.data.ConfigSetAdapter(cs,'noTLC');
        end
        adp.setup();
    elseif tlc

        adp.setupTLC(cs);
    end


