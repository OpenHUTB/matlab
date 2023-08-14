function[success,message]=exportReport(varargin)




    this=varargin{1};
    dstFileName=varargin{2};
    if(nargin==3)
        report=[this.getWorkDir('CheckOnly'),filesep,varargin{3}];
    else
        report=[this.getWorkDir('CheckOnly'),filesep,'report.html'];
    end

    if(exist(report,'file'))
        [success,message]=copyfile(report,dstFileName);
    else
        success=false;
        message=DAStudio.message('ModelAdvisor:engine:NoReportFound');
    end