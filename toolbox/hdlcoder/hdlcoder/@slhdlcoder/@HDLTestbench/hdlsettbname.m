function hdlsettbname(this,entityName)


    hD=hdlcurrentdriver;
    tbname=hdluniqueentityname([entityName,this.TestBenchPostfix]);

    hD.setParameter('tb_name',tbname);



    this.TestBenchName=tbname;
end
