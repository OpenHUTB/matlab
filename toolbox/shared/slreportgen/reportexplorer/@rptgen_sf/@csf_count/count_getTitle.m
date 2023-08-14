function t=count_getTitle(this,ps,rootObj,d)









    t=d.createDocumentFragment(getString(message('RptgenSL:rsf_csf_count:countLabel')));

    ps.makeLink(rootObj,'','link',d,t,', ');
