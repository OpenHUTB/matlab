function[thisLibRpt,libCat]=addLibraryRpt(this,libCat,varargin)







    if length(varargin)==1&&isa(varargin{1},'RptgenML.LibraryRpt')
        thisLibRpt=varargin{1};
    else
        thisLibRpt=RptgenML.LibraryRpt(varargin{:});
    end

    if isa(this.ReportList,'RptgenML.Library')
        if isempty(libCat)
            catName=thisLibRpt.PathName;
            if isempty(catName)
                catName=getString(message('rptgen:RptgenML_Root:unclassifiedLabel'));
            else
                [pathParent,pathDirName]=fileparts(catName);
                pathParent=strrep(pathParent,matlabroot,'');
                catName=sprintf('%s (%s)',pathDirName,pathParent);
            end

            if ispc

                isFileMatch=@(existLibCat)(strcmpi(existLibCat,catName));
                libCat=find(this.ReportList,...
                '-depth',1,...
                '-isa','RptgenML.LibraryCategory',...
                '-function','CategoryName',isFileMatch);
            else
                libCat=find(this.ReportList,...
                '-depth',1,...
                '-isa','RptgenML.LibraryCategory',...
                'CategoryName',catName);
            end

            if isempty(libCat)
                libCat=RptgenML.LibraryCategory(catName,...
                'HelpMapKey','obj.RptgenML.LibraryRpt');
                connect(libCat,this.ReportList,'up');
            else
                libCat=libCat(1);
            end
        end
        connect(thisLibRpt,libCat,'up');

    else
        rptLib=this.ReportList;
        if isempty(rptLib)
            rptLib=thisLibRpt;
        else
            rptLib(end+1)=thisLibRpt;
        end
        this.ReportList=rptLib;
        libCat=[];
    end

