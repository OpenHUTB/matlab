function removeTimePoints(this,varargin)




    try

        p=inputParser;
        p.addParameter('start',-inf,@(x)validateattributes(x,'numeric',{'scalar','real'}));
        p.addParameter('end',inf,@(x)validateattributes(x,'numeric',{'scalar','real'}));
        p.addParameter('splice',false,@(x)validateattributes(x,'logical',{'scalar'}));
        p.parse(varargin{:});
        params=p.Results;


        this.Repo_.removeSignalTimePoints(this.ID,params.start,params.end,params.splice)
    catch me
        me.throwAsCaller();
    end
end

