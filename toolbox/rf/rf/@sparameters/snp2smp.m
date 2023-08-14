function S_out=snp2smp(sobj,varargin)




    narginchk(1,3)

    if~isscalar(sobj)
        validateattributes(sobj,{'sparameters'},{'scalar'},'snp2smp','',1)
    end

    z0=sobj.Impedance;
    s_data=snp2smp(sobj.Parameters,z0,varargin{:});

    S_out=sparameters(s_data,sobj.Frequencies,z0);