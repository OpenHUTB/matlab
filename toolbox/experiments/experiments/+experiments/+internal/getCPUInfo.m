function info=getCPUInfo()

    if isunix
        if ismac
            info=cpuInfoMac();
        else
            info=cpuInfoUnix();
        end
    else
        info=cpuInfoWindows();
    end

    function info=cpuInfoWindows()
        sysInfo=callWMIC('cpu');
        osInfo=callWMIC('os');
        [~,sys]=memory;
        info=struct(...
        'Name',sysInfo.Name,...
        'Clock',[sysInfo.MaxClockSpeed,' MHz'],...
        'Cache',[sysInfo.L2CacheSize,' KB'],...
        'NumProcessors',str2double(sysInfo.NumberOfCores),...
        'OSType','Windows',...
        'OSVersion',osInfo.Caption,...
        'Memory',sys.PhysicalMemory.Total);

        function info=callWMIC(alias)

            olddir=pwd();
            cd(tempdir);
            sysinfo=evalc(sprintf('!wmic %s get /value',alias));
            cd(olddir);
            fields=textscan(sysinfo,'%s','Delimiter','\n');fields=fields{1};
            fields(cellfun('isempty',fields))=[];

            values=cell(size(fields));
            for ff=1:numel(fields)
                idx=find(fields{ff}=='=',1,'first');
                if~isempty(idx)&&idx>1
                    values{ff}=strtrim(fields{ff}(idx+1:end));
                    fields{ff}=strtrim(fields{ff}(1:idx-1));
                end
            end


            numResults=sum(strcmpi(fields,fields{1}));
            if numResults>1

                numCoresEntries=find(strcmpi(fields,'NumberOfCores'));
                if~isempty(numCoresEntries)
                    cores=cellfun(@str2double,values(numCoresEntries));
                    values(numCoresEntries)={num2str(sum(cores))};
                end

                [fields,idx]=unique(fields,'first');
                values=values(idx);
            end

            info=cell2struct(values,fields);

            function info=cpuInfoMac()
                machdep=callSysCtl('machdep.cpu');
                hw=callSysCtl('hw');
                [~,cmdout]=system('sysctl hw.memsize | awk ''{print $2}''');
                info=struct(...
                'Name',machdep.brand_string,...
                'Clock',[num2str(str2double(hw.cpufrequency_max)/1e6),' MHz'],...
                'Cache',[machdep.cache.size,' KB'],...
                'NumProcessors',str2double(machdep.core_count),...
                'OSType','Mac OS/X',...
                'OSVersion',getOSXVersion(),...
                'Memory',cmdout);

                function info=callSysCtl(namespace)
                    infostr=evalc(sprintf('!sysctl -a %s',namespace));

                    infostr=strrep(infostr,[namespace,'.'],'');

                    infostr=textscan(infostr,'%s','delimiter','\n');
                    infostr=infostr{1};
                    info=struct();
                    for ii=1:numel(infostr)
                        colonIdx=find(infostr{ii}==':',1,'first');
                        if isempty(colonIdx)||colonIdx==1||colonIdx==length(infostr{ii})
                            continue
                        end
                        prefix=infostr{ii}(1:colonIdx-1);
                        value=strtrim(infostr{ii}(colonIdx+1:end));
                        while ismember('.',prefix)
                            dotIndex=find(prefix=='.',1,'last');
                            suffix=prefix(dotIndex+1:end);
                            prefix=prefix(1:dotIndex-1);
                            value=struct(suffix,value);
                        end
                        info.(prefix)=value;

                    end

                    function vernum=getOSXVersion()

                        ver=evalc('system(''sw_vers'')');
                        vernum=regexp(ver,'ProductVersion:\s([1234567890.]*)','tokens','once');
                        vernum=strtrim(vernum{1});

                        function info=cpuInfoUnix()
                            txt=readCPUInfo();
                            cpuinfo=parseCPUInfoText(txt);
                            txt=readOSInfo();
                            osinfo=parseOSInfoText(txt);
                            [~,cmdout]=system('cat /proc/meminfo');
                            allInfo=splitlines(cmdout);
                            memTotal=strsplit(allInfo{1},':');
                            ramSize=strtrim(memTotal{2});

                            info=cell2struct([struct2cell(cpuinfo);struct2cell(osinfo);{ramSize}],...
                            [fieldnames(cpuinfo);fieldnames(osinfo);{'Memory'}]);

                            function info=parseCPUInfoText(txt)

                                lookup={
                                'model name','Name'
                                'cpu Mhz','Clock'
                                'cpu cores','NumProcessors'
                                'cache size','Cache'
                                };
                                info=struct(...
                                'Name',{''},...
                                'Clock',{''},...
                                'Cache',{''});
                                for ii=1:numel(txt)
                                    if isempty(txt{ii})
                                        continue;
                                    end

                                    colon=find(txt{ii}==':',1,'first');
                                    if isempty(colon)||colon==1||colon==length(txt{ii})
                                        continue;
                                    end
                                    fieldName=strtrim(txt{ii}(1:colon-1));
                                    fieldValue=strtrim(txt{ii}(colon+1:end));
                                    if isempty(fieldName)||isempty(fieldValue)
                                        continue;
                                    end


                                    idx=find(strcmpi(lookup(:,1),fieldName));
                                    if~isempty(idx)
                                        newName=lookup{idx,2};
                                        info.(newName)=fieldValue;
                                    end
                                end

                                info.Clock=[info.Clock,' MHz'];

                                info.NumProcessors=str2double(info.NumProcessors);

                                function info=parseOSInfoText(txt)
                                    info=struct(...
                                    'OSType','Linux',...
                                    'OSVersion','');

                                    [~,b]=regexp(txt,'[^\(]*\(([^\)]*)\).*','match','tokens','once');
                                    info.OSVersion=b{1}{1};

                                    function txt=readCPUInfo()
                                        fid=fopen('/proc/cpuinfo','rt');
                                        if fid<0
                                            error('cpuinfo:BadPROCCPUInfo','Could not open /proc/cpuinfo for reading');
                                        end
                                        onCleanup(@()fclose(fid));
                                        txt=textscan(fid,'%s','Delimiter','\n');
                                        txt=txt{1};

                                        function txt=readOSInfo()
                                            fid=fopen('/proc/version','rt');
                                            if fid<0
                                                error('cpuinfo:BadProcVersion','Could not open /proc/version for reading');
                                            end
                                            onCleanup(@()fclose(fid));
                                            txt=textscan(fid,'%s','Delimiter','\n');
                                            txt=txt{1};
