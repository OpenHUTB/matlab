function setHDLParameter(this,varargin)





    if(rem(nargin-1,2)~=0)
        error(message('HDLShared:hdlfilter:pvpairsmismatch'));
    end





    pvvalues=varargin;






    for n=1:2:length(pvvalues)
        set(this.HDLParameters.CLI,pvvalues{n},pvvalues{n+1});
    end

    nstages=length(this.Stage);
    for stn=1:nstages

        vararginset=removeProp(this,varargin,'Name');


        vararginset=unpackPvvalues(this,vararginset,stn);
        this.stage(stn).setHDLParameter(vararginset{:});
    end


    function pvset=unpackPvvalues(this,pvvalues,indx)

        pvset={};
        for n=1:2:length(pvvalues)
            pvset=[pvset,pvvalues{n}];
            if isPropertyCascaded(this,pvvalues{n})&&iscell(pvvalues{n+1})

                pvset{end+1}=pvvalues{n+1}{indx};
            else
                pvset{end+1}=pvvalues{n+1};
            end
        end


        function pvvalues=removeProp(this,pvvalues,prop)

            props=pvvalues(1:2:end);
            indx=strmatch(lower(prop),lower(props));
            if~isempty(indx)
                pvvalues(2*indx-1)=[];
                pvvalues(2*indx-1)=[];
            end





