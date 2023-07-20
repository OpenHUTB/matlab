function h=plot(this,varargin)
















    if isempty(varargin)

        series=this;
        remainingArgs={};
    else





        if iscell(varargin{1})



            series={this,varargin{1}{:}};%#ok<CCAT>


            remainingArgs=varargin(2:end);

        elseif isa(varargin{1},'simscape.logging.series')







            series={this,varargin{1}};


            remainingArgs=varargin(2:end);
        else


            series=this;
            remainingArgs=varargin;
        end
    end


    h=simscape.logging.plot(series,remainingArgs{:});

end
