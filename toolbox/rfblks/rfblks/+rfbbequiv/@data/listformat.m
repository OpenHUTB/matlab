function list=listformat(varargin)







    list={};


    h=varargin{1};
    if nargin==1
        parameter='ALL';
    else
        parameter=varargin{2};
    end

    if nargin==3&&(~isempty(strfind(upper(varargin{3}),'SMITH CHART'))...
        ||~isempty(strfind(upper(varargin{3}),'POLAR PLANE')))
        list{1}='None';
        return
    end


    format_complexdata={'Magnitude (decibels)','Magnitude (linear)'...
    ,'Angle (degrees)','Angle (radians)','Real','Imaginary'};


    switch upper(parameter)
    case 'ALL'
        list={'Magnitude (decibels)','Magnitude (linear)'...
        ,'Angle (degrees)','Angle (radians)','Real','Imaginary'...
        ,'dBm','dBW','W','mW','dBc/Hz','ns','us','ms','s','ps'...
        ,'Kelvin','None'};

    case{'OIP3'}
        list={'dBm','dBW','W','mW'};

    case{'POUT'}
        if haspowerreference(h)||hasp2dreference(h)
            list={'dBm','dBW','W','mW'};
        end

    case{'PHASE'}
        if haspowerreference(h)||hasp2dreference(h)
            list={'Angle (degrees)','Angle (radians)'};
        end

    case{'AM/AM'}
        if haspowerreference(h)||hasp2dreference(h)
            list={'Magnitude (decibels)','None'};
        end

    case{'AM/PM'}
        if haspowerreference(h)||hasp2dreference(h)
            list={'Angle (degrees)','Angle (radians)'};
        end

    case{'PHASENOISE'}
        list={'dBc/Hz'};

    case{'FMIN'}
        if hasnoisereference(h)
            list={'Magnitude (decibels)','None'};
        end

    case{'GAMMAIN','GAMMAOUT'}
        nport=getnport(h);
        if(~isempty(get(h,'Freq'))&&...
            ~isempty(get(h,'S_Parameters')))&&nport==2
            list=format_complexdata;
        end

    case{'GAMMAOPT'}
        if hasnoisereference(h)
            list=format_complexdata;
        end

    case{'RN'}
        if hasnoisereference(h)
            list={'None'};
        end

    case{'VSWRIN','VSWROUT'}
        nport=getnport(h);
        if(~isempty(get(h,'Freq'))&&~isempty(get(h,'S_Parameters')))...
            &&nport==2
            list={'Magnitude (decibels)','None'};
        end

    case{'NF'}
        nport=getnport(h);
        if(~isempty(get(h,'Freq'))&&~isempty(get(h,'S_Parameters')))...
            &&nport==2
            list={'Magnitude (decibels)'};
        end

    case{'LS11','LS12','LS21','LS22'}
        if hasp2dreference(h)
            list=format_complexdata;
        end

    case{'GA','GT','GP','GMAG','GMSG'}
        list={'Magnitude (decibels)','None'};

    case{'GAMMAMS','GAMMAML'}
        list=format_complexdata;

    case{'TF1','TF2'}
        list=format_complexdata;

    case{'K','MU','MUPRIME','NFACTOR'}
        list={'None'};

    case{'NTEMP'}
        list={'Kelvin'};

    case{'GROUPDELAY'}
        list={'ns','us','ms','s','ps'};

    case{'DELTA'}
        list=format_complexdata;

    otherwise
        if strncmpi(parameter,'S',1)
            idx=strfind(parameter,',');
            if numel(idx)==1
                nport=getnport(h);
                index1=str2double(parameter(2:idx-1));
                index2=str2double(parameter(idx+1:end));
                if(~isempty(get(h,'Freq'))&&...
                    ~isempty(get(h,'S_Parameters')))
                    if((0<index1)&&(index1<=nport)&&...
                        (0<index2)&&(index2<=nport))
                        list=format_complexdata;
                    end
                end
            elseif(numel(parameter)==3)
                nport=getnport(h);
                index1=str2double(parameter(2));
                index2=str2double(parameter(3));
                if(~isempty(get(h,'Freq'))&&...
                    ~isempty(get(h,'S_Parameters')))
                    if((0<index1)&&(index1<=nport)&&...
                        (0<index2)&&(index2<=nport))
                        list=format_complexdata;
                    end
                end
            end
        end
    end

    list=list';