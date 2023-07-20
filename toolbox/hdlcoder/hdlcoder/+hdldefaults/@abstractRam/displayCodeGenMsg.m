function displayCodeGenMsg(~,hC,fullpathname,fullfilename)


    link=hdlgetfilelink(fullfilename);
    hdldisp(message('hdlcoder:hdldisp:WorkingOnBlock',[fullpathname,'/',hC.Name],link));
