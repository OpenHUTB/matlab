function schema()




    mlock;

    reqIntPackage=findpackage('ReqMgr');
    linktypeClass=schema.class(reqIntPackage,'LinkType');










    p=schema.prop(linktypeClass,'Registration','string');





    p=schema.prop(linktypeClass,'Label','ustring');





    p=schema.prop(linktypeClass,'IsFile','bool');






    p=schema.prop(linktypeClass,'Extensions','string vector');








    p=schema.prop(linktypeClass,'LocDelimiters','string');






    p=schema.prop(linktypeClass,'Icon','string');






    p=schema.prop(linktypeClass,'Version','string');












    p=schema.prop(linktypeClass,'NavigateFcn','MATLAB callback');









    p=schema.prop(linktypeClass,'BrowseFcn','MATLAB callback');









    p=schema.prop(linktypeClass,'ContentsFcn','MATLAB callback');








    p=schema.prop(linktypeClass,'AtExitFcn','MATLAB callback');











    p=schema.prop(linktypeClass,'CreateURLFcn','MATLAB callback');






    p=schema.prop(linktypeClass,'UrlLabelFcn','MATLAB callback');






    p=schema.prop(linktypeClass,'DocDateFcn','MATLAB callback');






    p=schema.prop(linktypeClass,'ResolveDocFcn','MATLAB callback');











    p=schema.prop(linktypeClass,'DetailsFcn','MATLAB callback');














    p=schema.prop(linktypeClass,'IsValidIdFcn','MATLAB callback');








    p=schema.prop(linktypeClass,'IsValidDocFcn','MATLAB callback');










    p=schema.prop(linktypeClass,'IsValidDescFcn','MATLAB callback');








    p=schema.prop(linktypeClass,'ItemIdFcn','MATLAB callback');










    p=schema.prop(linktypeClass,'SelectionLinkLabel','ustring');









    p=schema.prop(linktypeClass,'SelectionLinkFcn','MATLAB callback');





    p=schema.prop(linktypeClass,'BacklinkCheckFcn','MATLAB callback');


    p=schema.prop(linktypeClass,'BacklinkInsertFcn','MATLAB callback');


    p=schema.prop(linktypeClass,'BacklinkDeleteFcn','MATLAB callback');


    p=schema.prop(linktypeClass,'BacklinksCleanupFcn','MATLAB callback');










    p=schema.prop(linktypeClass,'HtmlViewFcn','MATLAB callback');






    p=schema.prop(linktypeClass,'GetAttributeFcn','MATLAB callback');






    p=schema.prop(linktypeClass,'TextViewFcn','MATLAB callback');






    p=schema.prop(linktypeClass,'SummaryFcn','MATLAB callback');

















    p=schema.prop(linktypeClass,'LinkedIdToImportedIdFcn','MATLAB callback');






    p=schema.prop(linktypeClass,'ModificationInfoFcn','MATLAB callback');







    p=schema.prop(linktypeClass,'BeforeUpdateFcn','MATLAB callback');


    p=schema.prop(linktypeClass,'BeforeImportFcn','MATLAB callback');








    p=schema.prop(linktypeClass,'DefaultClassification','string');

    p=schema.prop(linktypeClass,'GetResultFcn','MATLAB callback');

    p=schema.prop(linktypeClass,'GetSourceTimestampFcn','MATLAB callback');

    p=schema.prop(linktypeClass,'RunTestsFcn','MATLAB callback');

    p=schema.prop(linktypeClass,'ResultNavigateFcn','MATLAB callback');

