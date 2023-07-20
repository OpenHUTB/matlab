function load(this,varargin)




    while~isempty(this.down)
        this.down.disconnect;
    end
