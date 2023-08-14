function modelFiles=findModelFiles(varargin)

















    p=inputParser();
    addOptional(p,'name',pwd(),@(x)(ischar(x)||isstring(x)));
    addParameter(p,'RecurseFolder',false,@islogical);
    parse(p,varargin{:});
    args=p.Results;

    if isfile(args.name)
        [~,~,fExt]=fileparts(args.name);
        if(strcmp(fExt,'.mdl')||strcmp(fExt,'.slx'))
            listing=dir(args.name);
            modelFiles=string(fullfile(listing.folder,listing.name));
        end

    elseif isfolder(args.name)

        wildcard='';
        if args.RecurseFolder
            wildcard='**';
        end
        baseFolder=char(args.name);
        mdl=fullfile(baseFolder,wildcard,'*.mdl');
        slx=fullfile(baseFolder,wildcard,'*.slx');


        listings=[dir(mdl);dir(slx)];


        nListings=numel(listings);
        modelFiles=string.empty(0,nListings);
        for i=1:nListings
            listing=listings(i);
            modelFiles(i)=fullfile(listing.folder,listing.name);
        end

    else
        error(message('slreportgen:utils:error:invalidFileOrFolder'));
    end
end

