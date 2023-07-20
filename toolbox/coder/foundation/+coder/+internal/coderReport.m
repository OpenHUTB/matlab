







function varargout=coderReport(function_name,varargin)

    [varargout{1:nargout}]=feval(function_name,varargin{1:end});






    function destHTMLFileName=getDestHTMLFileName(htmlfiles,buildDir)%#ok<DEFNU>


        destHTMLFileName='';
        if isempty(htmlfiles)
            return;
        end
        if~iscell(htmlfiles)
            htmlfiles={htmlfiles};
        end
        destHTMLFileName=cell(size(htmlfiles));
        htmlRootPath=fullfile(buildDir,'html');
        for k=1:length(htmlfiles)
            htmlFileName=htmlfiles{k};
            destHTMLFileName{k}=rtwprivate('rtwGetRelativePath',htmlFileName,htmlRootPath);
        end





        function out=getOnloadJS(TagId)%#ok<DEFNU>
            out=['try {if (top) {if (top.rtwPageOnLoad) top.rtwPageOnLoad(''',TagId,'''); else local_onload();}} catch(err) {};'];





            function out=copyIcon(htmlDir,imgname)%#ok<DEFNU>


                imgfullname=fullfile(coder.report.ReportInfoBase.getResourceDir,imgname);
                if exist(imgfullname,'file')
                    coder.internal.coderCopyfile(imgfullname,fullfile(htmlDir,imgname));
                    out=imgname;
                else
                    out='';
                end




