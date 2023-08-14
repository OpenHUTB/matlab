




function[status,msg]=checkCompatibilityForTopOffCoverage(~,covData,varargin)

    narginchk(2,inf);

    persistent argParser;
    if isempty(argParser)
        argParser=inputParser;
        addOptional(argParser,'FilterExistingCov',true);
    end

    parse(argParser,varargin{:});


    status=true;
    msg='';


    allowedModes={'SIL';'ModelRefSIL'};

    if argParser.Results.FilterExistingCov

        cvdg=cv.cvdatagroup(covData);
        allSimModes=cvdg.allSimulationModes();
        if all(ismember(allSimModes,allowedModes))
            return
        end

        if any(~ismember(allSimModes,allowedModes))

            msg=getString(message('sldv_sfcn:sldv_sfcn:compatUnsupportedMixedMode'));
        else
            status=false;
            msg=getString(message('sldv_sfcn:sldv_sfcn:compatStartSILCovData'));
        end
    end

