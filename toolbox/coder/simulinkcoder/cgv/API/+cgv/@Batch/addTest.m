





















function addTest(this,cgvObj,varargin)

    narginchk(2,4);
    if~isa(cgvObj,'cgv.CGV')
        DAStudio.error('RTW:cgv:BadParams');
    end
    test.cgvObj1=cgvObj;
    if nargin>2
        if~isa(varargin{1},'cgv.CGV')
            DAStudio.error('RTW:cgv:BadParams');
        end
        test.cgvObj2=varargin{1};
    else
        test.cgvObj2={};
    end

    if nargin>3
        if~isa(varargin{2},'char')
            DAStudio.error('RTW:cgv:BadParams');
        end
        test.tolFile=varargin{2};
    else
        test.tolFile=[];
    end
    test.result=[];
    test.errorPlotFile{1}{1}=[];

    this.TestList{end+1}=test;
end

