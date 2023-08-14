function linkType=linktype_TEMPLATE
























    linkType=ReqMgr.LinkType;








    linkType.Registration=mfilename;


    linkType.Label='MY CUSTOM DOC TYPE';



    linkType.IsFile=1;






    linkType.Extensions={};












    linkType.LocDelimiters='@#?';



















    linkType.NavigateFcn=@NavigateFcn;

















end



function NavigateFcn(document,location)
    disp([mfilename,': Navigating to ',location,' in ',document]);














end

function[LABELS,DEPTHS,LOCATIONS]=ContentsFcn(DOCUMENT)%#ok<*DEFNU>






    LABELS={['Dummy Header in',DOCUMENT];'Dummy sub-header'};
    DEPTHS=[0;1];
    LOCATIONS={'dummy_location_1';'dummy_location_2'};
end

function DOCUMENT=BrowseFcn()



    [filename,pathname]=uigetfile({...
    '.ext1','My Custom Doc sub-type1';...
    '.ext2','My Custom Doc sub-type2'},...
    'Pick a requirement file');
    DOCUMENT=fullfile(pathname,filename);
end

function URL=CreateURLFcn(DOCPATH,DOCURL,LOCATION)


    if~isempty(DOCURL)
        URL=[DOCURL,'#',LOCATION(2:end)];
    else
        URL=['file:///',DOCPATH,'#',LOCATION(2:end)];
    end
end

function SUCCESS=IsValidDocFcn(DOCUMENT,REFPATH)



    SUCCESS=exist(DOCUMENT,'file')==2||...
    exist(fullfile(REFPATH,DOCUMENT),'file')==2;
end

function SUCCESS=IsValidIdFcn(DOCUMENT,LOCATION)




    SUCCESS=true;
end

function[SUCCESS,DOC_DESCRIPTION]=IsValidDescFcn(DOCUMENT,LOCATION,LINK_DESCRIPTION)






    SUCCESS=true;
end

function[DEPTHS,ITEMS]=DetailsFcn(DOCUMENT,LOCATION,LEVEL)








    ITEMS={'DetailsFcn not implemented','Need to query the document'};
    DEPTHS=[0,1];
end

function REQ=SelectionLinkFcn(OBJECT,MAKE2WAY)




    REQ=rmi('createempty');
    REQ.description='SelectionLinkFcn not implemented';
    REQ.doc='CurrentDoc';
end

function HTML=HtmlViewFcn(DOC,LOCATION,OPT_DETAILS_LEVEL)

    HTML='<p><b>Bold parag</b></p><p><i>Italic parag</i></p>';
end

function VALUE=GetAttributeFcn(DOC,LOCATION,ATTRIBUTENAME)

    VALUE=app.API.getAttribute(DOC,LOCATION,ATTRIBUTENAME);
end

function text=TextViewFcn(DOC,LOCATION)


    text=app.API.getText(DOC,LOCATION);
end

function RESULT=GetResultFcn(LINK)











    RESULT.status=slreq.verification.Status.Pass;
    RESULT.timestamp=datetime(now,'ConvertFrom','datenum','TimeZone','Local');
end
