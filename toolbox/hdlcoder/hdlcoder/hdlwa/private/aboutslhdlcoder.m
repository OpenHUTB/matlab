function aboutslhdlcoder







    tlbx=ver('hdlcoder');
    companyName=DAStudio.message('HDLShared:hdldialog:CompanyName');


    str=sprintf(DAStudio.message('HDLShared:hdldialog:HDLWAAboutFormatStr'),...
    tlbx.Name,tlbx.Version,datestr(tlbx.Date,10),companyName);
    msgbox(str,tlbx.Name,'modal');