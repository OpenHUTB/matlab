function cacheHTMLdata(varargin)



    persistent cache;
    if strcmp(varargin{1},'set')
        cache=varargin{2};
    else
        sysFound=false;
        if~strcmp(varargin{1},'summaryReport')
            for i=1:length(cache)
                if strcmpi(varargin{2},cache{i}.system)
                    sysFound=true;
                    if strcmpi(varargin{3},cache{i}.getData('uniqueCode'))
                        cache{i}.CheckResultObjs(str2double(varargin{1})).view;
                    else
                        disp(DAStudio.message('ModelAdvisor:engine:CmdAPILinkOutOfDate'));
                    end
                end
            end
            if~sysFound
                disp(DAStudio.message('ModelAdvisor:engine:CmdAPILinkOutOfDate'));
            end
        else

            if(nargin==(numel(cache)+1))&&strcmpi(varargin{2},cache{1}.getData('uniqueCode'))
                ModelAdvisor.summaryReport(cache);
            else
                disp(DAStudio.message('ModelAdvisor:engine:CmdAPILinkOutOfDate'));
            end
        end
    end
