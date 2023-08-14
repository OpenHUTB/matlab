function msg=message(id,varargin)






    if iscell(id)
        msg=cell(size(id));
        for indx=1:numel(id)
            msg{indx}=FilterDesignDialog.message(id{indx},varargin{:});
        end
        return;
    end

    id=['FilterDesignLib:FilterDesignDialog:fb',id];


    mObj=message(id,varargin{:});


    msg=mObj.getString();


