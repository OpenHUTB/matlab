function refresh(this,varargin)









    mdlObj=getParent(this);
    if~isempty(mdlObj)
        this.ModelName=mdlObj.name;
        this.DisplayName=this.ModelName;
    end

    if~sldvshareprivate('util_is_analyzing_for_fixpt_tool')
        this.HTMLText=Constructhtml(this);
    end
    this.dummyToggle=~this.dummyToggle;


end



function htmltext=Constructhtml(this)

    htmltext='';

    try
        modelH=get_param(this.ModelName,'Handle');
        currentResults=sldvprivate('mdl_current_results',modelH);
    catch Mex;
        currentResults=[];
    end


    if~isempty(currentResults)&&isfield(currentResults,'DataFile')&&exist(currentResults.DataFile,'file')

        try
            s=load(currentResults.DataFile);
            sldvData=s.sldvData;
            sldvData=Sldv.DataUtils.convertToCurrentFormat(modelH,sldvData);

            htmltext=Sldv.ReportUtils.getHTMLsummary(sldvData,...
            currentResults,...
            get_param(modelH,'Name'),...
            false);

            htmltext=[htmltext,htmlLogStr(currentResults)];
        catch Mex;
        end
    end

    if isempty(htmltext)
        htmltext=default_html_text;
    end
end


function str=htmlLogStr(currentResults)
    if~isempty(currentResults)&&~isempty(currentResults.LogFile)
        mlURL=sprintf('matlab:edit(urldecode(''%s''))',urlencode(currentResults.LogFile));
        [~,nm,ext]=fileparts(currentResults.LogFile);

        str=sprintf('\n<br>\n%s: %s<br>\n',...
        getString(message('Simulink:SldvNode:LogFile')),link(mlURL,[nm,ext]));

    end
end


function str=link(url,label)
    str=sprintf('<A HREF=%s>%s</A>',url,label);
end




function htmlText=default_html_text()

    helpUrl='matlab:helpview(fullfile(docroot,''toolbox'',''sldv'',''sldv.map''),''sldv_product_page'');';

    htmlText=[
    sprintf('<h3>%s</h3>\n',getString(message('Simulink:SldvNode:DesignVerifier')))...
    ,sprintf('%s<br>\n',getString(message('Simulink:SldvNode:DvResultsCreation')))...
    ,sprintf('\n<br>\n<A HREF="%s">%s</A>.<br>',helpUrl,getString(message('Simulink:SldvNode:DvMoreInfo')))];

end



