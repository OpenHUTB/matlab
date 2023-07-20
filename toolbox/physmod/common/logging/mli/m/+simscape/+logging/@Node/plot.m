function h=plot(this,varargin)















    if isempty(varargin)

        node=this;
        remainingArgs={};
    else





        if iscell(varargin{1})



            node={this,varargin{1}{:}};%#ok<CCAT>


            remainingArgs=varargin(2:end);

        elseif isa(varargin{1},'simscape.logging.Node')







            node={this,varargin{1}};


            remainingArgs=varargin(2:end);
        else


            node=this;
            remainingArgs=varargin;
        end
    end


    remainingArgs{end+1}='runname';
    remainingArgs{end+1}=inputname(1);


    try
        h=simscape.logging.plot(node,remainingArgs{:});
    catch ME
        ME.throwAsCaller();
    end

end
