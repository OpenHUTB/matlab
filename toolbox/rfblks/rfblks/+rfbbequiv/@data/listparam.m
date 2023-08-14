function list=listparam(varargin)





    h=varargin{1};


    plottype='';
    block='';
    param1='';


    list={};
    nport=getnport(h);

    if nargin==2
        plottype=varargin{2};
    elseif nargin==3
        plottype=varargin{2};
        if~isempty(strfind(upper(varargin{3}),'OUTPUT PORT'))
            block='OUTPUT PORT';
        end
    elseif nargin==4
        plottype=varargin{2};
        if~isempty(strfind(upper(varargin{3}),'OUTPUT PORT'))
            block='OUTPUT PORT';
        end
        param1=varargin{4};

        list(end+1)={'   '};
    end


    switch upper(plottype)
    case{'Z SMITH CHART','Y SMITH CHART','ZY SMITH CHART'}

        if~isempty(get(h,'Freq'))&&~isempty(get(h,'S_Parameters'))
            for i=1:nport
                if i>=10
                    parameter=strcat('S',num2str(i),',',num2str(i));
                else
                    parameter=strcat('S',num2str(i),num2str(i));
                end
                list(end+1)={parameter};
            end
            if nport==2
                if strcmp(block,'OUTPUT PORT')
                    list(end+1:end+2)={'GammaIn','GammaOut'};
                end
            end
        end

        if hasp2dreference(h)
            list(end+1:end+2)={'LS11','LS22'};
        end

    case 'POLAR PLANE'

        if~isempty(get(h,'Freq'))&&~isempty(get(h,'S_Parameters'))
            for i=1:nport
                for j=1:nport
                    if i>=10||j>=10
                        parameter=strcat('S',num2str(i),',',num2str(j));
                    else
                        parameter=strcat('S',num2str(i),num2str(j));
                    end
                    list(end+1)={parameter};
                end
            end
            if nport==2
                if strcmp(block,'OUTPUT PORT')
                    list(end+1:end+2)={'GammaIn','GammaOut'};
                end
            end
        end

        if hasp2dreference(h)
            list(end+1:end+4)={'LS11','LS12','LS21','LS22'};
        end

    case 'LINK BUDGET'
        list(end+1:end+8)={'S11','S12','S21','S22','OIP3','NF'...
        ,'NFactor','NTemp'};

    case 'X-Y PLANE'
        if isempty(param1)

            if~isempty(get(h,'Freq'))&&~isempty(get(h,'S_Parameters'))
                for i=1:nport
                    for j=1:nport
                        if i>=10||j>=10
                            parameter=strcat('S',num2str(i),',',...
                            num2str(j));
                        else
                            parameter=strcat('S',num2str(i),num2str(j));
                        end
                        list(end+1)={parameter};
                    end
                end
                if nport==2
                    if strcmp(block,'OUTPUT PORT')
                        list(end+1:end+10)={'Gt','GroupDelay','GammaIn'...
                        ,'GammaOut','VSWRIn','VSWROut','OIP3','NF'...
                        ,'NFactor','NTemp'};
                    else
                        list(end+1:end+5)={'GroupDelay','OIP3','NF'...
                        ,'NFactor','NTemp'};
                    end
                end
            end

            if hasnoisereference(h)
                list(end+1:end+3)={'Fmin','GammaOPT','RN'};
            end

            if haspowerreference(h)||hasp2dreference(h)
                list(end+1:end+4)={'Pout','Phase','AM/AM','AM/PM'};
            end

            if~isempty(h.FreqOffset)&&~isempty(h.PhaseNoiseLevel)
                list(end+1)={'PhaseNoise'};
            end

            if hasp2dreference(h)
                list(end+1:end+4)={'LS11','LS12','LS21','LS22'};
            end
        else
            switch category(h,param1)
            case 'Power Parameters'
                list(end+1:end+2)={'Pout','Phase'};
                if hasp2dreference(h)
                    list(end+1:end+4)={'LS11','LS12','LS21','LS22'};
                end
            case 'AMAM/AMPM Parameters'
                list(end+1:end+2)={'AM/AM','AM/PM'};
            case 'Phase Noise'
                return
            case 'Large Parameters'
                if haspowerreference(h)||hasp2dreference(h)
                    list(end+1:end+2)={'Pout','Phase'};
                end
                list(end+1:end+4)={'LS11','LS12','LS21','LS22'};
            case{'Noise Parameters','Network Parameters'}
                if~isempty(get(h,'Freq'))&&...
                    ~isempty(get(h,'S_Parameters'))
                    for i=1:nport
                        for j=1:nport
                            if i>=10||j>=10
                                parameter=strcat('S',num2str(i),...
                                ',',num2str(j));
                            else
                                parameter=strcat('S',num2str(i),...
                                num2str(j));
                            end
                            list(end+1)={parameter};
                        end
                    end
                    if nport==2
                        if strcmp(block,'OUTPUT PORT')
                            list(end+1:end+10)={'Gt','GroupDelay'...
                            ,'GammaIn','GammaOut','VSWRIn','VSWROut'...
                            ,'OIP3','NF','NFactor','NTemp'};
                        else
                            list(end+1:end+5)={'GroupDelay','OIP3'...
                            ,'NF','NFactor','NTemp'};
                        end
                    end
                end

                if hasnoisereference(h)
                    list(end+1:end+3)={'Fmin','GammaOPT','RN'};
                end

                if haspowerreference(h)||hasp2dreference(h)
                    list(end+1:end+2)={'Pout','Phase'};
                end

                if hasp2dreference(h)
                    list(end+1:end+4)={'LS11','LS12','LS21','LS22'};
                end
            end
        end
    otherwise

        if~isempty(get(h,'Freq'))&&~isempty(get(h,'S_Parameters'))
            for ii=1:nport
                for jj=1:nport
                    if ii>=10||jj>=10
                        parameter=strcat('S',num2str(ii),',',num2str(jj));
                    else
                        parameter=strcat('S',num2str(ii),num2str(jj));
                    end
                    list(end+1)={parameter};
                end
            end
            if nport==2
                list(end+1:end+9)={'GroupDelay','GammaIn','GammaOut'...
                ,'VSWRIn','VSWROut','OIP3','NF','NFactor','NTemp'};

                list(end+1:end+5)={'Gt','Ga','Gp','Gmag','Gmsg'};

                list(end+1:end+2)={'GammaMS','GammaML'};

                list(end+1:end+4)={'K','Delta','Mu','MuPrime'};
            end
        end


        if hasnoisereference(h)
            list(end+1:end+3)={'Fmin','GammaOPT','RN'};
        end


        if haspowerreference(h)||hasp2dreference(h)
            list(end+1:end+4)={'Pout','Phase','AM/AM','AM/PM'};
        end


        if~isempty(h.FreqOffset)&&~isempty(h.PhaseNoiseLevel)
            list(end+1)={'PhaseNoise'};
        end


        if hasp2dreference(h)
            list(end+1:end+4)={'LS11','LS12','LS21','LS22'};
        end
    end

    list=list';