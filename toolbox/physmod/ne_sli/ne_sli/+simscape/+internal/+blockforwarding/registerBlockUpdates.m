function registerBlockUpdates(libraryHandle,varargin)













































    ft=get_param(libraryHandle,'ForwardingTable');
    xform='simscape.internal.blockforwarding.transform';
    for idx=1:numel(varargin)

        assert(iscell(varargin{idx}),'All inputs must be cell arrays.');

        if numel(varargin{idx})==2

            newEntry=[varargin{idx},{xform}];
        elseif numel(varargin{idx})==3

            newEntry=[varargin{idx}(1),varargin{idx}(1),varargin{idx}(2:3),xform];
        end
        ft{end+1}=newEntry;%#ok<AGROW>

    end

    set_param(libraryHandle,'ForwardingTable',ft);

end
