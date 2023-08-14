function outobj=cascadesparams(varargin)




    if isnumeric(varargin{end})&&...
        (isreal(varargin{end})&&isvector(varargin{end}))

        numsparams=nargin-1;
        nconn=varargin{end};
    else

        numsparams=nargin;
        nconn='default';
    end


    for n=1:numsparams
        nth_obj=varargin{n};

        validateattributes(nth_obj,{'sparameters','numeric'},{},...
        'cascadesparams','',n)

        if isnumeric(nth_obj)

            error(message('rf:shared:ObjVsNumericNonUniform'))
        end
    end

    sobj1=varargin{1};
    freq=sobj1.Frequencies;
    z0=sobj1.Impedance;


    sparamdata=cell(1,numsparams);
    sparamdata{1}=sobj1.Parameters;
    for n=2:numsparams
        nth_obj=varargin{n};
        if(~isequal(freq,nth_obj.Frequencies))||(z0~=nth_obj.Impedance)

            error(message('rf:shared:AllSparamObjsUseSameProps'))
        end

        sparamdata{n}=nth_obj.Parameters;
    end

    cascdata=rf.internal.cascadesparams(sparamdata,nconn);
    outobj=sparameters(cascdata,freq,z0);