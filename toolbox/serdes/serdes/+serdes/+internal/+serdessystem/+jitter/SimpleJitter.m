classdef SimpleJitter<handle




    properties
        Include(1,1)logical=false;
        Type='Float';
        Value(1,1){mustBeNumeric,mustBeFinite,mustBeNonnegative}=0;
        Flavor='Fixed';
    end

    properties(Hidden)

        Format{mustBeMember(Format,{'Value'})}='Value';
    end
    methods
        function obj=SimpleJitter(varargin)

            p=inputParser;
            p.CaseSensitive=false;
            p.addParameter('Include',[]);
            p.addParameter('Type',[]);
            p.addParameter('Format',[]);
            p.addParameter('Value',[]);
            p.addParameter('Flavor',[]);
            p.parse(varargin{:});
            args=p.Results;


            if~isempty(args.Include)
                obj.Include=args.Include;
            end
            if~isempty(args.Type)
                obj.Type=args.Type;
            end
            if~isempty(args.Format)
                obj.Format=args.Format;
            end
            if~isempty(args.Value)
                obj.Value=args.Value;
            end
            if~isempty(args.Flavor)
                obj.Flavor=args.Flavor;
            end
        end
        function set.Type(obj,val)
            validateattributes(val,...
            {'char','string'},...
            {},'','Type');

            if strncmpi(val,'seconds',3)
                val='Float';
            end
            mustBeMember(val,{'Float','UI'})
            obj.Type=val;
        end
        function set.Flavor(obj,val)
            validateattributes(val,...
            {'char','string'},...
            {},'','Flavor');
            mustBeMember(lower(val),lower({'DCD','DJ','SJ','RJ','Fixed'}))
            obj.Flavor=lower(val);
        end
        function distribution=pmf(obj,SymbolTime,t)













            narginchk(3,3)
            nargoutchk(0,1)
            fcnName='pmf';
            validateattributes(SymbolTime,{'numeric'},{'scalar','finite'},fcnName,'SymbolTime',2);
            validateattributes(t,{'numeric'},{'vector','finite','real'},fcnName,'t',3);


            if obj.Include&&obj.Value~=0
                if strcmp(obj.Type,'UI')
                    val=obj.Value*SymbolTime;
                else
                    val=obj.Value;
                end

                switch obj.Flavor
                case 'dcd'
                    distribution=serdes.internal.serdessystem.jitter.DCDPMF(t,val);
                case 'dj'
                    distribution=serdes.internal.serdessystem.jitter.DjPMF(t,val);
                case 'sj'
                    distribution=serdes.internal.serdessystem.jitter.SjPMF(t,val);
                case 'rj'
                    distribution=serdes.internal.serdessystem.jitter.RjPMF(t,val);
                otherwise
                    distribution=zeros(size(t));
                end
            else
                distribution=zeros(size(t));
            end

        end
    end
end

