function[fPath,id]=getBookmark(varargin)





    switch nargin
    case 2

        [fPath,id]=rmiml.locationToId(false,varargin{:});
    case 1

        if isempty(regexp(varargin{1},'.+\|\d+\.[\d\.]+$','once'))

            fPath='';
            id='';
        else

            [fPath,remainder]=strtok(varargin{1},'|');
            id=remainder(2:end);
        end
    case 0

        [fPath,id]=rmiml.locationToId(false);
    otherwise
        error(message('Slvnv:reqmgt:rmi:InvalidArgumentNumber'));
    end
end
