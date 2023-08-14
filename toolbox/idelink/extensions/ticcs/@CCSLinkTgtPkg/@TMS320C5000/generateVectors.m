function hresult=generateVectors(h,filename,tgtinfo,mdlinfo)




    hresult=0;
    fid=fopen(filename,'w');

    fprintf(fid,'; This file defines the reset vectors for the TMS320C55xx.\n');
    fprintf(fid,'; It handles the reset and interrupts.\n');
    printSeparatorLine(fid);

    fprintf(fid,'\t.ref        _c_int00\n');
    fprintf(fid,'\n');
    for i=1:mdlinfo.numInterrupts
        fprintf(fid,'\t.ref       _isr_num%d_vec\n',mdlinfo.interrupts{i});
    end
    fprintf(fid,'\n');

    fprintf(fid,'\t.sect       .vectors\n');
    fprintf(fid,'\t.align      256\n');

    fprintf(fid,'\t.global     _VECSTART\n');
    fprintf(fid,'_VECSTART:\n');

    generateRESETIV(fid,tgtinfo,mdlinfo);
    generateNMIV(fid,tgtinfo,mdlinfo);
    generateINT2(fid,tgtinfo,mdlinfo);
    generateINT3(fid,tgtinfo,mdlinfo);
    generateINT4(fid,tgtinfo,mdlinfo);
    generateINT5(fid,tgtinfo,mdlinfo);
    generateINT6(fid,tgtinfo,mdlinfo);
    generateINT7(fid,tgtinfo,mdlinfo);
    generateINT8(fid,tgtinfo,mdlinfo);
    generateINT9(fid,tgtinfo,mdlinfo);
    generateINT10(fid,tgtinfo,mdlinfo);
    generateINT11(fid,tgtinfo,mdlinfo);
    generateINT12(fid,tgtinfo,mdlinfo);
    generateINT13(fid,tgtinfo,mdlinfo);
    generateINT14(fid,tgtinfo,mdlinfo);
    generateINT15(fid,tgtinfo,mdlinfo);
    generateINT16(fid,tgtinfo,mdlinfo);
    generateINT17(fid,tgtinfo,mdlinfo);
    generateINT18(fid,tgtinfo,mdlinfo);
    generateINT19(fid,tgtinfo,mdlinfo);
    generateINT20(fid,tgtinfo,mdlinfo);
    generateINT21(fid,tgtinfo,mdlinfo);
    generateINT22(fid,tgtinfo,mdlinfo);
    generateINT23(fid,tgtinfo,mdlinfo);
    generateINT24(fid,tgtinfo,mdlinfo);
    generateINT25(fid,tgtinfo,mdlinfo);
    generateINT26(fid,tgtinfo,mdlinfo);
    generateINT27(fid,tgtinfo,mdlinfo);
    generateINT28(fid,tgtinfo,mdlinfo);
    generateINT29(fid,tgtinfo,mdlinfo);
    generateINT30(fid,tgtinfo,mdlinfo);
    generateINT31(fid,tgtinfo,mdlinfo);



    printSeparatorLine(fid);

    fprintf(fid,'\n\t.text\n\n');

    defineResetIsr(fid);
    defineNoHandler(fid);

    fprintf(fid,'\t.end');
    fclose(fid);

    hresult=1;


    function generateRESETIV(fid,tgtinfo,mdlinfo)





        resetStkConfig='C54X_STK';
        printSeparatorLine(fid);
        fprintf(fid,'\t.def    RESETIV\n');
        fprintf(fid,'RESETIV:\t\t\t\t\t; Point Reset Vector to C Environment Entry Point\n');
        fprintf(fid,'\t.ivec RESET_ISR, %s\n',resetStkConfig);



        function generateNMIV(fid,tgtinfo,mdlinfo)
            INTNUM=1;
            fprintf(fid,'NMIV:\t\t\t\t\t\t; Non-maskable hardware interrupt\n');
            generateIsr(fid,INTNUM,tgtinfo,mdlinfo);


            function generateINT2(fid,tgtinfo,mdlinfo)
                INTNUM=2;
                generateIsrLabel(fid,INTNUM);
                generateIsr(fid,INTNUM,tgtinfo,mdlinfo);


                function generateINT3(fid,tgtinfo,mdlinfo)
                    INTNUM=3;
                    generateIsrLabel(fid,INTNUM);
                    generateIsr(fid,INTNUM,tgtinfo,mdlinfo);


                    function generateINT4(fid,tgtinfo,mdlinfo)
                        INTNUM=4;
                        generateIsrLabel(fid,INTNUM);
                        generateNoHandler(fid);












                        function generateINT5(fid,tgtinfo,mdlinfo)
                            INTNUM=5;
                            generateIsrLabel(fid,INTNUM);
                            generateIsr(fid,INTNUM,tgtinfo,mdlinfo);


                            function generateINT6(fid,tgtinfo,mdlinfo)
                                INTNUM=6;
                                generateIsrLabel(fid,INTNUM);
                                generateIsr(fid,INTNUM,tgtinfo,mdlinfo);


                                function generateINT7(fid,tgtinfo,mdlinfo)
                                    INTNUM=7;
                                    generateIsrLabel(fid,INTNUM);
                                    generateIsr(fid,INTNUM,tgtinfo,mdlinfo);


                                    function generateINT8(fid,tgtinfo,mdlinfo)
                                        INTNUM=8;
                                        generateIsrLabel(fid,INTNUM);
                                        generateIsr(fid,INTNUM,tgtinfo,mdlinfo);


                                        function generateINT9(fid,tgtinfo,mdlinfo)
                                            INTNUM=9;
                                            generateIsrLabel(fid,INTNUM);
                                            generateIsr(fid,INTNUM,tgtinfo,mdlinfo);


                                            function generateINT10(fid,tgtinfo,mdlinfo)
                                                INTNUM=10;
                                                generateIsrLabel(fid,INTNUM);
                                                generateIsr(fid,INTNUM,tgtinfo,mdlinfo);


                                                function generateINT11(fid,tgtinfo,mdlinfo)
                                                    INTNUM=11;
                                                    generateIsrLabel(fid,INTNUM);
                                                    generateIsr(fid,INTNUM,tgtinfo,mdlinfo);


                                                    function generateINT12(fid,tgtinfo,mdlinfo)
                                                        INTNUM=12;
                                                        generateIsrLabel(fid,INTNUM);
                                                        generateIsr(fid,INTNUM,tgtinfo,mdlinfo);


                                                        function generateINT13(fid,tgtinfo,mdlinfo)
                                                            INTNUM=13;
                                                            generateIsrLabel(fid,INTNUM);
                                                            generateIsr(fid,INTNUM,tgtinfo,mdlinfo);


                                                            function generateINT14(fid,tgtinfo,mdlinfo)
                                                                INTNUM=14;
                                                                generateIsrLabel(fid,INTNUM);
                                                                generateIsr(fid,INTNUM,tgtinfo,mdlinfo);


                                                                function generateINT15(fid,tgtinfo,mdlinfo)
                                                                    INTNUM=15;
                                                                    generateIsrLabel(fid,INTNUM);
                                                                    generateIsr(fid,INTNUM,tgtinfo,mdlinfo);


                                                                    function generateINT16(fid,tgtinfo,mdlinfo)
                                                                        INTNUM=16;
                                                                        generateIsrLabel(fid,INTNUM);
                                                                        generateIsr(fid,INTNUM,tgtinfo,mdlinfo);


                                                                        function generateINT17(fid,tgtinfo,mdlinfo)
                                                                            INTNUM=17;
                                                                            generateIsrLabel(fid,INTNUM);
                                                                            generateIsr(fid,INTNUM,tgtinfo,mdlinfo);


                                                                            function generateINT18(fid,tgtinfo,mdlinfo)
                                                                                INTNUM=18;
                                                                                generateIsrLabel(fid,INTNUM);
                                                                                generateIsr(fid,INTNUM,tgtinfo,mdlinfo);


                                                                                function generateINT19(fid,tgtinfo,mdlinfo)
                                                                                    INTNUM=19;
                                                                                    generateIsrLabel(fid,INTNUM);
                                                                                    generateIsr(fid,INTNUM,tgtinfo,mdlinfo);


                                                                                    function generateINT20(fid,tgtinfo,mdlinfo)
                                                                                        INTNUM=20;
                                                                                        generateIsrLabel(fid,INTNUM);
                                                                                        generateIsr(fid,INTNUM,tgtinfo,mdlinfo);


                                                                                        function generateINT21(fid,tgtinfo,mdlinfo)
                                                                                            INTNUM=21;
                                                                                            generateIsrLabel(fid,INTNUM);
                                                                                            generateIsr(fid,INTNUM,tgtinfo,mdlinfo);


                                                                                            function generateINT22(fid,tgtinfo,mdlinfo)
                                                                                                INTNUM=22;
                                                                                                generateIsrLabel(fid,INTNUM);
                                                                                                generateNoHandler(fid);












                                                                                                function generateINT23(fid,tgtinfo,mdlinfo)
                                                                                                    INTNUM=23;
                                                                                                    generateIsrLabel(fid,INTNUM);
                                                                                                    generateIsr(fid,INTNUM,tgtinfo,mdlinfo);


                                                                                                    function generateINT24(fid,tgtinfo,mdlinfo)
                                                                                                        INTNUM=24;
                                                                                                        fprintf(fid,'BERRIV:\t\t\t\t\t\t; Bus error interrupt\n');
                                                                                                        generateIsrLabel(fid,INTNUM);
                                                                                                        if 0

                                                                                                        else
                                                                                                            generateNoHandler(fid);
                                                                                                        end

                                                                                                        function generateINT25(fid,tgtinfo,mdlinfo)
                                                                                                            INTNUM=25;
                                                                                                            fprintf(fid,'DLOGIV:\t\t\t\t\t\t; Data log (RTDX) interrupt\n');
                                                                                                            generateIsrLabel(fid,INTNUM);
                                                                                                            generateNoHandler(fid);


                                                                                                            function generateINT26(fid,tgtinfo,mdlinfo)
                                                                                                                INTNUM=26;
                                                                                                                fprintf(fid,'RTOSIV:\t\t\t\t\t\t; Real-time OS interrupt\n');
                                                                                                                generateIsrLabel(fid,INTNUM);
                                                                                                                generateNoHandler(fid);



                                                                                                                function generateINT27(fid,tgtinfo,mdlinfo)
                                                                                                                    INTNUM=27;
                                                                                                                    generateIsrLabel(fid,INTNUM);
                                                                                                                    generateNoHandler(fid);



                                                                                                                    function generateINT28(fid,tgtinfo,mdlinfo)
                                                                                                                        INTNUM=28;
                                                                                                                        generateIsrLabel(fid,INTNUM,'; General-purpose software-only interrupt');
                                                                                                                        generateNoHandler(fid);



                                                                                                                        function generateINT29(fid,tgtinfo,mdlinfo)
                                                                                                                            INTNUM=29;
                                                                                                                            generateIsrLabel(fid,INTNUM,'; General-purpose software-only interrupt');
                                                                                                                            generateNoHandler(fid);



                                                                                                                            function generateINT30(fid,tgtinfo,mdlinfo)
                                                                                                                                INTNUM=30;
                                                                                                                                generateIsrLabel(fid,INTNUM,'; General-purpose software-only interrupt');
                                                                                                                                generateNoHandler(fid);



                                                                                                                                function generateINT31(fid,tgtinfo,mdlinfo)
                                                                                                                                    INTNUM=31;
                                                                                                                                    generateIsrLabel(fid,INTNUM,'; General-purpose software-only interrupt');
                                                                                                                                    generateNoHandler(fid);


                                                                                                                                    function generateIsrLabel(fid,interruptNum,opt)
                                                                                                                                        if nargin==3
                                                                                                                                            fprintf(fid,'IN%0.2d:\t\t\t\t\t\t%s\n',interruptNum,opt);
                                                                                                                                        else
                                                                                                                                            fprintf(fid,'IN%0.2d:\n',interruptNum);
                                                                                                                                        end



                                                                                                                                        function generateIsr(fid,interruptNum,tgtinfo,mdlinfo)
                                                                                                                                            isrNeeded=(mdlinfo.numInterrupts>0)&&any(cell2mat(mdlinfo.interrupts)==interruptNum);
                                                                                                                                            if isrNeeded
                                                                                                                                                generateIsrNumVec(fid,interruptNum);
                                                                                                                                            else
                                                                                                                                                generateNoHandler(fid);
                                                                                                                                            end


                                                                                                                                            function generateIsrNumVec(fid,interruptNum)
                                                                                                                                                fprintf(fid,'\t.ivec _isr_num%d_vec\n',interruptNum);


                                                                                                                                                function generateNoHandler(fid)
                                                                                                                                                    fprintf(fid,'\t.ivec _no_handler\n');


                                                                                                                                                    function defineResetIsr(fid)
                                                                                                                                                        fprintf(fid,'\t; This ISR makes IVPD/IVPH point to the vector table.\n');
                                                                                                                                                        fprintf(fid,'\t; - Hardware Reset forces IVPD/IVPH = 0xFFFF.\n');
                                                                                                                                                        fprintf(fid,'\t.def RESET_ISR\n');
                                                                                                                                                        fprintf(fid,'RESET_ISR:  \n');
                                                                                                                                                        fprintf(fid,'\tMOV #RESETIV >> 8, mmap(IVPD)\n');
                                                                                                                                                        fprintf(fid,'\tMOV #RESETIV >> 8, mmap(IVPH)\n');
                                                                                                                                                        fprintf(fid,'\tB _c_int00\n');
                                                                                                                                                        fprintf(fid,'\n');


                                                                                                                                                        function defineNoHandler(fid)
                                                                                                                                                            printSeparatorLine(fid);
                                                                                                                                                            fprintf(fid,'\t.def _no_handler\n');
                                                                                                                                                            fprintf(fid,'_no_handler:\n');
                                                                                                                                                            fprintf(fid,'\tB _no_handler\n');
                                                                                                                                                            fprintf(fid,'\n');


                                                                                                                                                            function printSeparatorLine(fid)
                                                                                                                                                                fprintf(fid,';---------------------------------------------------------\n');

