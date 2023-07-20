function out=configSetRenderer(in)





















    persistent RENDERER;
    mlock;



    if isempty(RENDERER)
        RENDERER=@(~,~)[];
    end



    if nargin>0&&isa(in,'function_handle')
        RENDERER=in;
    end


    out=RENDERER;

end
