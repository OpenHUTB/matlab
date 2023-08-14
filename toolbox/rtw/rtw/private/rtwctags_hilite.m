function rtwctags_hilite(varargin)







    persistent last_system;
    persistent last_ssid;
    persistent last_chart;

    if nargin<1||nargin>3
        DAStudio.error('RTW:utility:invalidArgCount',...
        'rtwctags_hilite','1-3');
    end






    system=varargin{1};
    scheme='find';
    cont=false;
    isSf=false;
    ssid=[];
    if nargin>1
        for i=2:nargin
            arg=varargin{i};
            invalidArg=false;
            if iscell(arg)
                invalidArg=true;
            elseif arg(1)=='-'
                switch arg(2:end)
                case{'fade','find'}
                    scheme=arg(2:end);
                case 'cont'
                    cont=true;
                otherwise
                    invalidArg=true;
                end
            else
                if~isempty(sscanf(arg,'%d'))
                    ssid=arg;
                    isSf=true;
                else
                    invalidArg=true;
                end
            end
            if invalidArg
                DAStudio.error('RTW:utility:invalidInputArgs',arg)
            end
        end
    end

    system=strrep(system,'#-NL-#',sprintf('\n'));
    system=strrep(system,'#-SP-#',' ');
    system=strrep(system,'#-LT-#','<');
    system=strrep(system,'#-GT-#','>');
    system=strrep(system,'#-OB-#','(');
    system=strrep(system,'#-CB-#',')');
    system=strrep(system,'#-OC-#','{');
    system=strrep(system,'#-CC-#','}');
    system=strrep(system,'#-OA-#','[');
    system=strrep(system,'#-CA-#',']');
    system=strrep(system,'#-AN-#','&');
    system=strrep(system,'#-MO-#','%');
    system=strrep(system,'#-DQ-#','"');
    system=strrep(system,'#-QM-#','?');
    system=strrep(system,'#-CM-#',',');
    system=strrep(system,'#-SC-#',';');
    system=strrep(system,'#-SQ-#','''');
    system=strrep(system,'#-BS-#','\');

    isSameSf=isSf&&~iscell(last_system)&&~iscell(system)...
    &&strcmp(last_system,system);

    root=get_param(0,'Object');
    if~isempty(last_system)&&~cont&&~isSameSf
        if root.isValidSlObject(last_system)
            if iscell(last_system)
                for k=1:length(last_system),
                    set_param(last_system{k},'HiliteAncestors','none');
                end
            else
                set_param(last_system,'HiliteAncestors','none')
            end
        end
    end
    if~isempty(last_ssid)

        if root.isValidSlObject(last_chart)
            lastSSId=sfprivate('traceabilityManager','makeSSId',last_chart,last_ssid,'');
            sfprivate('traceabilityManager','unHighlightObject',lastSSId);
        end
        last_ssid='';
    end
    if all(isspace(system))&&~cont
        last_system='';
        last_ssid='';
        last_chart='';
        return
    end
    try

        if~root.isValidSlObject(system)
            open_system(strtok(system,'/'));
        end
        if isempty(strfind(system,'/'))



            open_system(system);
        elseif~isSf||any(~strcmp(get_param(system,'HiliteAncestors'),scheme))
            tryagain=0;
            try
                hilite_system(system,scheme);
            catch
                tryagain=1;
            end
            if tryagain
                try
                    system=strrep(system,'//+','//*');
                    system=strrep(system,'+//','*//');
                    hilite_system(system,scheme);
                catch me
                    rethrow(me);
                end
            end
        end
        if cont
            if iscell(system)
                last_system=[last_system,system];
            else
                last_system=[last_system,{system}];
            end
        else
            last_system=system;
        end

        isSimFcn=false;
        if~isSf&&~iscell(system)
            parent=get_param(system,'Parent');

            if~isempty(parent)&&...
                strcmp(get_param(parent,'type'),'block')&&...
                slprivate('is_stateflow_based_block',parent)
                isSimFcn=true;

                ssid=num2str(get_param(system,'UserData'));
                system=parent;
            end
        end
        if isSf||isSimFcn

            curSSId=sfprivate('traceabilityManager','makeSSId',system,ssid,'');
            sfprivate('sfOpenObjectBySSId',curSSId);
            last_ssid=ssid;
            last_chart=system;
        end
    catch me
        if iscell(system)
            system=[system{1},',...'];
        end
        DAStudio.error('RTW:utility:objectNotFound',system);
    end


