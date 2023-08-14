function displayCodeGenMsg(this,hC,fullpathname,fullfilename)%#ok







    msg=['Working on ',fullpathname,'/',hC.Name,' as ','<a href="matlab:edit(''',fullfilename,''')">',fullfilename,'</a>'];
    hdldisp(msg,1);

