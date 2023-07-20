function harnessList=find(harnessOwner,varargin)
    try

        [systemModel,harnessOwnerHandle]=Simulink.harness.internal.parseForSystemModel(harnessOwner);


        harnessList=[];
        if Simulink.harness.isHarnessBD(systemModel)
            return;
        end

        try
            Simulink.harness.internal.validateOwnerHandle(systemModel,harnessOwnerHandle);
        catch ME






            if~(strcmp(ME.identifier,'Simulink:Harness:UnsupportedSubsystemHandle'))
                rethrow(ME)
            end
        end


        p=inputParser;
        p.CaseSensitive=false;
        p.KeepUnmatched=false;
        p.PartialMatching=false;
        p.addParameter('Name','.*',@(x)validateattributes(x,{'string','char'},{'nonempty','scalartext'}));
        p.addParameter('RegExp','off',@(x)validate_input_args(x));
        p.addParameter('SearchDepth',Inf,@(x)validateattributes(x,{'numeric'},{'nonempty','nonnegative','integer'}));
        p.addParameter('OpenOnly','off',@(x)validate_input_args(x));
        p.addParameter('UUID','.*',@(x)validateattributes(x,{'string','char'},{'nonempty','scalartext'}));
        p.addParameter('FunctionInterfaceName','.*',@(x)validateattributes(x,{'string','char'},{'nonempty','scalartext'}));
        p.parse(varargin{:});

        Simulink.harness.internal.ensureNoRepeatedParams(varargin)


        if strcmp(p.Results.OpenOnly,'on')
            harnessList=Simulink.harness.internal.getHarnessList(systemModel,'loaded');
            if~isempty(harnessList)
                if p.Results.SearchDepth==0&&harnessList.ownerHandle~=harnessOwnerHandle

                    harnessList(:)=[];
                    return;
                end
            end
        end


        if isempty(harnessList)
            if p.Results.SearchDepth==0

                harnessList=Simulink.harness.internal.getHarnessList(systemModel,'all',harnessOwnerHandle);

            else
                args={systemModel,'all',[]};
                if~ismember('Name',p.UsingDefaults)&&strcmp(p.Results.RegExp,'off')

                    args=[args,'HarnessName',p.Results.Name];
                end
                harnessList=Simulink.harness.internal.getHarnessList(args{:});
            end



            if strcmp(p.Results.OpenOnly,'on')
                harnessList=harnessList(find([harnessList.isOpen],1));
            end
        end

        if isempty(harnessList)
            return;
        end


        if~ismember('UUID',p.UsingDefaults)
            [~,loc]=ismember(p.Results.UUID,{harnessList.uuid});
            if loc==0
                loc=[];
            end
            harnessList=harnessList(loc);
        end


        if~ismember('FunctionInterfaceName',p.UsingDefaults)
            loc=ismember({harnessList.functionInterfaceName},p.Results.FunctionInterfaceName);
            harnessList=harnessList(loc);
        end

        if isempty(harnessList)
            return;
        end


        if~ismember('Name',p.UsingDefaults)
            if strcmp(p.Results.RegExp,'off')
                harnessList=harnessList(strcmpi({harnessList.name},p.Results.Name));
            else
                harnessList=harnessList(cellfun(@(x)~isempty(x),regexp({harnessList.name},p.Results.Name,'once')));
            end
        end

        if isempty(harnessList)
            return;
        end


        if p.Results.SearchDepth~=0

            harnessOwnerName=getfullname(harnessOwnerHandle);


            re=['^',regexptranslate('escape',harnessOwnerName)];
            if ismember('SearchDepth',p.UsingDefaults)

                re=[re,'(?:$|/[^/])'];
            else




                re=[re,'(?:/[^/](?:[^/]|//)*){0,',num2str(p.Results.SearchDepth),'}$'];
            end

            harnessList=harnessList(cellfun(@(x)~isempty(x),regexp({harnessList.ownerFullPath},re,'once')));
        end

    catch ME
        ME.throwAsCaller();
    end

end

function validate_input_args(ip)


    validateattributes(ip,{'string','char'},{'nonempty','scalartext'});
    validatestring(ip,{'on','off'});
end








