function[success,message]=verifyHTML(this,htmlName,varargin)





    success=false;%#ok<PREALL> % standard initialization
    message='';
    opts.verifyxml=true;


    lang=get(0,'language');
    if strncmpi(lang,'ja',2)
        opts.verifyxml=false;
    end
    opts=slprivate('parseArgs',opts,varargin{:});

    if~exist(this.AtticData.DiagnoseRightFrame,'file')
        message=DAStudio.message('ModelAdvisor:engine:NoReportWasFound');
        success=false;
        return
    end


    if this.BaselineMode
        [success,message]=this.exportReport(htmlName);
        return
    end


    if~exist(htmlName,'file')
        message=DAStudio.message('ModelAdvisor:engine:CannotFindHTMLFile');
        success=false;
        return
    end

    if opts.verifyxml==true
        try
            h=ModelAdvisor.DocObject(this.AtticData.DiagnoseRightFrame);%#ok<NASGU>
        catch e
            message=DAStudio.message('ModelAdvisor:engine:HTMLNotXMLCompliant',e.message);
            success=false;
            return
        end
    end


    current_rptContents=modeladvisorprivate('modeladvisorutil2','filereadutf8',this.AtticData.DiagnoseRightFrame);

    current_rptContents=modeladvisorprivate('modeladvisorutil2','shuffleReport',current_rptContents);

    current_rptContents=loc_UnifyFullPaths(current_rptContents);
    current_rptContents=slprivate('removeHyperLinksFromMessage',current_rptContents);

    saved_rptContents=modeladvisorprivate('modeladvisorutil2','filereadutf8',htmlName);
    saved_rptContents=loc_LowerTags(saved_rptContents);
    saved_rptContents=loc_FixBugs(saved_rptContents);

    saved_rptContents=modeladvisorprivate('modeladvisorutil2','shuffleReport',saved_rptContents);

    saved_rptContents=loc_UnifyFullPaths(saved_rptContents);
    saved_rptContents=slprivate('removeHyperLinksFromMessage',saved_rptContents);


    current_rptContents_oLineBreaks=regexprep(current_rptContents,'\n','');
    saved_rptContents_oLineBreaks=regexprep(saved_rptContents,'\n','');

    if~strcmp(current_rptContents_oLineBreaks,saved_rptContents_oLineBreaks)
        caller=dbstack;
        internalTestingMode=false;
        for i=1:length(caller)
            if~isempty(strfind(caller(i).file,'hMdlAdvVerify'))
                internalTestingMode=true;
                break;
            end
        end
































        message=DAStudio.message('ModelAdvisor:engine:MismatchModelAdvisor');

        success=false;
    else
        success=true;
    end



    function out=loc_LowerTags(out)

        out=modeladvisorprivate('modeladvisorutil2','MakeTagLowercase',out);

        function out=loc_FixBugs(out)


            out=regexprep(out,'<meta([^<>]+?)">','<meta$1"/>');

            out=regexprep(out,'<a([^<>]+?)"</a>','<a$1" />');

            out=regexprep(out,'<font (\w+)=([\-+#]?\w+)>','<font $1="$2">');
            out=regexprep(out,'<table (\w+)=(\w+),? (\w+)=(\w+)>','<table $1="$2" $3="$4">');
            out=regexprep(out,'<td (\w+)=(\w+)>','<td $1="$2">');
            out=regexprep(out,'<a name=([\w:]+)>','<a name="$1">');


            out=regexprep(out,'<img ([^<>]+?)([^/]{1,1})>','<img $1$2/>');


            out=strrep(out,'<tr><tr ','<tr ');

            function out=loc_UnifyFullPaths(in)


                lin=regexprep(in,'>[ \w/\.\-]+/matlab/test/toolbox/','>CURRENT_LOCATION/matlab/test/toolbox/');
                out=regexprep(lin,'>[ \w\\:\.\-]+\\matlab\\test\\toolbox','>CURRENT_LOCATION\\matlab\\test\\toolbox');

