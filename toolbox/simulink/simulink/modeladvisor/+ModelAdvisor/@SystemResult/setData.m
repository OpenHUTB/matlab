function setData(this,inp)




    if nargin>1
        inp=convertStringsToChars(inp);
    end

    DatabaseHandle=ModelAdvisor.Repository(fullfile(inp,'ModelAdvisorData'));
    this.mdladvinfo=DatabaseHandle.loadLatestData('MdladvInfo');
    this.geninfo=DatabaseHandle.loadLatestData('geninfo');
    if exist(fullfile(inp,'report.html'),'file')
        this.reportFileName=fullfile(inp,'report.html');
        [fid,~]=fopen(this.reportFileName,'r','n','utf-8');
        this.htmlreport=fread(fid,'*char')';
        fclose(fid);
    end
end
