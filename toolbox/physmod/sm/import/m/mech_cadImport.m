function mech_cadImport(varargin)















    load_system('sm_lib');

    if nargin<1
        disp('Requires file argument');
        return;
    end

    args=containers.Map;
    for idx=1:2:nargin
        args(varargin{idx})=varargin{idx+1};
    end
    inFileName=args('-file');

    outFileName='';
    if(args.isKey('-outputXML'))
        outFileName=args('-outputXML');
    end

    modelSimpOpt='';
    if(args.isKey('-ModelSimplificationOpt'))
        modelSimpOpt=args('-ModelSimplificationOpt');
    end


    verMech=ver('mech');
    versionStr=verMech.Version;

    [p,f,e]=fileparts(inFileName);
    if isempty(e)
        inFileName=fullfile(p,[f,'.xml']);
    end

    builtin('mech_cadImportBuiltin',inFileName,outFileName,versionStr,modelSimpOpt);
