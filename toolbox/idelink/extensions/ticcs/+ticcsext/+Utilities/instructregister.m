function instructregister





    server=ticcsext.Utilities.LfCProperty('inprocFile-current-server');
    client=ticcsext.Utilities.LfCProperty('inprocFile-current-client');


    filename=tempname;


    [fid,fmsg]=fopen(filename,'a');
    if(fid<0)
        error(message('TICCSEXT:util:CannotCreateTempTextFile',fmsg));
    end
    fprintf(fid,'%s\r\n',linkfoundation.util.getProductName);
    fprintf(fid,'---------------------------------\r\n\r\n');
    fprintf(fid,'To register the %s components:\r\n\r\n',linkfoundation.util.getProductName);
    fprintf(fid,'The following instructions show you how to register components required by %s.\r\n\r\n',linkfoundation.util.getProductName);
    fprintf(fid,'      NOTE: Before you register the components, you must have write permission to modify the registry.\r\n');
    fprintf(fid,'             If you do not have this permission, look for someone who has (e.g. system administrator) and have this person perform the registration.\r\n\r\n');
    fprintf(fid,'1. Close all instances of CCS.\r\n\r\n');
    fprintf(fid,'2. Close MATLAB.\r\n\r\n');
    fprintf(fid,'3. Open a Microsoft Windows Command Prompt by clicking Start and then Programs > Accessories > Command Prompt.\r\n\r\n');
    fprintf(fid,'4. In the Command Prompt, enter the following commands to register the LinkCCS.dll and MWCCSStu.ocx components.\r\n\r\n');
    fprintf(fid,'   a. regsvr32 %s\r\n\r\n',server);
    fprintf(fid,'   Entering the above command opens a dialog box. Verify that the following message appears:\r\n');
    fprintf(fid,'   ''DllRegisterServer in %s succeeded''\r\n\r\n',server);
    fprintf(fid,'   b. regsvr32 %s\r\n\r\n',client);
    fprintf(fid,'   Entering the above command opens a dialog box. Verify that the following message appears:\r\n');
    fprintf(fid,'   ''DllRegisterServer in %s succeeded''\r\n\r\n',client);
    fprintf(fid,'\r\n');
    fprintf(fid,'After you register the components, you must enable the CCS component before you can use %s.\r\n\r\n',linkfoundation.util.getProductName);
    fprintf(fid,'To enable the %s components:\r\n\r\n',linkfoundation.util.getProductName);
    fprintf(fid,'1. Open MATLAB (at %s).\r\n\r\n',matlabroot);
    fprintf(fid,'2. Enter cc = ticcs at the MATLAB prompt.\r\n\r\n');
    fprintf(fid,'   CCS starts and prompts that ''New components were detected.'' \r\n\r\n');
    fprintf(fid,'3. Click ''Yes'' to enable components for all compatible CCS releases.\r\n\r\n');
    fprintf(fid,'Important: You must click ''Yes'' or ''OK'' to enable the new component.\r\n\r\n');
    fprintf(fid,'For more information on TICCS or to see the FAQ, enter ''help ticcs'' at the MATLAB prompt.\r\n');
    fclose(fid);


    dos(['notepad ',filename,' &']);


