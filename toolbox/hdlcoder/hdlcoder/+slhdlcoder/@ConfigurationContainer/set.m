function set(this,varargin)





    if mod(length(varargin),2)~=0
        disp(sprintf('Invalid configuration ''set'' statement in file: %s',this.fileName));
        disp(varargin);
    end

    if isempty(this.settings)
        this.settings=varargin;
    else
        this.settings={this.settings{:},varargin{:}};
    end

