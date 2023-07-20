function options=parseQueryFunctionArgs(fcnName,allowedArgs,varargin)



    narginchk(2,inf);

    validateattributes(allowedArgs,{'numeric'},{'numel',4});


    if(nargin==3)&&isstruct(varargin{1})

        options=assignMissingOptions(varargin{1});
    else
        options=assignMissingOptions([]);
        maxArgs=numel(find(allowedArgs));
        ignoreDescendantSeen=false;
        includeAllSizeSeen=false;
        covModeSeen=false;
        cvMetricsSeen=false;
        for ii=1:numel(varargin)
            argPos=2+ii;
            if ii>maxArgs
                warning(message('Slvnv:simcoverage:ignoreArgument',argPos));
                continue
            end
            arg=convertStringsToChars(varargin{ii});


            if~covModeSeen&&allowedArgs(4)
                if ischar(arg)
                    validateattributes(arg,{'char'},{'nonempty','vector','nrows',1},fcnName,'',argPos);
                    covMode=SlCov.CovMode.fixTopMode(SlCov.CovMode.fromString(arg));
                    options.CovMode=SlCov.CovMode.toString(covMode);
                    covModeSeen=true;
                elseif isa(arg,'SlCov.CovMode')
                    validateattributes(arg,{'SlCov.CovMode'},{'scalar'},fcnName,'',argPos);
                    covMode=SlCov.CovMode.fixTopMode(arg);
                    options.CovMode=SlCov.CovMode.toString(covMode);
                    covModeSeen=true;
                end
                if covModeSeen
                    continue
                end
            end



            if~cvMetricsSeen&&allowedArgs(1)
                if isa(arg,'cvmetric.Sldv')||isa(arg,'cvmetric.Structural')
                    validateattributes(arg,{'cvmetric.Sldv','cvmetric.Structural'},{'scalar'},fcnName,'',argPos);
                    options.CvMetrics=arg;
                    cvMetricsSeen=true;
                elseif iscell(arg)
                    validateattributes(arg,{'cell'},{'nonempty','vector'},fcnName,'',argPos);
                    for jj=1:numel(arg)
                        validateattributes(arg{jj},{'cvmetric.Sldv','cvmetric.Structural'},{'scalar'},fcnName,'',argPos);
                    end
                    options.CvMetrics=arg;
                    cvMetricsSeen=true;
                end
                if cvMetricsSeen
                    continue
                end
            end


            if~ignoreDescendantSeen&&allowedArgs(2)
                validateattributes(arg,{'numeric','logical'},{},fcnName,'',argPos);
                ignoreDescendantSeen=true;
                options.IgnoreDescendants=arg;
                continue
            end


            if~includeAllSizeSeen&&allowedArgs(3)
                validateattributes(arg,{'numeric','logical'},{},fcnName,'',argPos);
                includeAllSizeSeen=true;
                options.IncludeAllSizes=arg;
                continue
            end
        end
    end


    if isempty(options.IgnoreDescendants)
        options.IgnoreDescendants=0;
    end

    if isempty(options.IncludeAllSizes)
        options.IncludeAllSizes=0;
    end

    if isempty(options.TextDetailLevel)
        options.TextDetailLevel=1;
    end


    function options=assignMissingOptions(options)

        availableOpts={...
        'CvMetrics',...
        'IgnoreDescendants',...
        'IncludeAllSizes',...
        'TextDetailLevel',...
'CovMode'...
        };

        for i=1:length(availableOpts)
            if~isfield(options,availableOpts{i})
                options.(availableOpts{i})=[];
            end
        end
