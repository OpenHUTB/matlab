function makeQe_Test(h)




    if(h.isWriteHeader)


        fid=h.openFile('qe_test.m');

        fwrite(fid,sprintf('function ok=qe_test(this,d)\n%%QE_TEST tests the component\n'));

        h.writeHeader(fid);

        fwrite(fid,sprintf('ok=true;\nd.appendPoint(this);\nqe_test_outlinestring(this);\n'));

        fclose(fid);

        h.viewFile('qe_test.m');
    end
