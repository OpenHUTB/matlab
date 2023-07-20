function generatehdlCoderTB(this)




    this.initHDLSignals((hdlgetparameter('ScalarizePorts')~=0)||hdlgetparameter('isverilog'));



    hdltbcode=this.hdltbcodercodeinit([],1,this.TestBenchName);



    hdldisp(message('HDLShared:hdlshared:TBCreatingStimulusVectors').getString());
    hdltbcode=this.hdlpackage(hdltbcode,this.tbPkgFileId,this.tbDataFileId);



    [oldcgmode,vhdlpkgreqd]=this.hdlSetMode('filtercoder');



    hdlentitysignalsinit;



    hdlsetcurrentclock([]);
    hdlsetcurrentreset([]);
    hdlsetcurrentclockenable([]);



    hdlsignals=this.hdldutsignaldecl;
    hdltbcode.arch_signals=[hdltbcode.arch_signals,hdlsignals];



    [hdlsignals,srcDone,snkDone,tb_enb,testFailure]=this.hdltbsignaldecl;
    hdltbcode.arch_signals=[hdltbcode.arch_signals,hdlsignals];



    [~,~,clkenb,hdlsignals]=this.hdlTbGetClockBundle;
    hdltbcode.arch_signals=[hdltbcode.arch_signals,hdlsignals];



    hdltbcode.arch_body_blocks=[hdltbcode.arch_body_blocks,this.hdltbenb(srcDone,snkDone,tb_enb,testFailure)];



    hdltbcode.arch_body_blocks=[hdltbcode.arch_body_blocks,this.hdlclkgenbeh(srcDone,snkDone)];



    hdltbcode.arch_body_blocks=[hdltbcode.arch_body_blocks,this.hdlresetgenbeh];



    [clkenbbody,clkenbsignal,tbenb_dly]=this.hdltbclkenb(tb_enb,clkenb,snkDone,srcDone);
    hdltbcode.arch_signals=[hdltbcode.arch_signals,clkenbsignal];
    hdltbcode.arch_body_blocks=[hdltbcode.arch_body_blocks,clkenbbody];



    rdEnb=[];
    if this.isDUTsingleClock
        hdlsetcurrentclock(hdlsignalfindname(this.ClockName));
        hdlsetcurrentreset(hdlsignalfindname(this.ResetName));
        [tcBody,tcSignals,rdEnb,dutEnb]=this.hdlTimingControllerComp(tbenb_dly,clkenb,snkDone,srcDone);
        hdltbcode.arch_signals=[hdltbcode.arch_signals,tcSignals];
        hdltbcode.arch_body_blocks=[hdltbcode.arch_body_blocks,tcBody];
    else
        dutEnb=tbenb_dly;
    end



    [stimBody,stimSignals]=this.hdlStimuliComp(this.clkrate,dutEnb,srcDone);
    hdltbcode.arch_signals=[hdltbcode.arch_signals,stimSignals];
    hdltbcode.arch_body_blocks=[hdltbcode.arch_body_blocks,stimBody];



    this.computeMinPortSampleTime;
    [checkerBody,checkerSignals]=this.hdlCheckerComp(clkenb,snkDone,testFailure);
    hdltbcode.arch_signals=[hdltbcode.arch_signals,checkerSignals];
    hdltbcode.arch_body_blocks=[hdltbcode.arch_body_blocks,checkerBody];



    [glbclkenbbody,glbclkenbsignal]=this.hdlglobalclkenb(dutEnb,clkenb,snkDone,srcDone,rdEnb);
    hdltbcode.arch_body_blocks=[hdltbcode.arch_body_blocks,glbclkenbbody];
    hdltbcode.arch_signals=[hdltbcode.arch_signals,glbclkenbsignal];



    [fpbody,fpsignal]=this.hdlReadDataFromFile();
    hdltbcode.arch_body_blocks=[hdltbcode.arch_body_blocks,fpbody];
    hdltbcode.arch_signals=[hdltbcode.arch_signals,fpsignal];




    tbfid=this.tbFileId;
    writeTBFile(tbfid,hdltbcode.entity_comment);
    writeTBFile(tbfid,hdltbcode.entity_library);
    writeTBFile(tbfid,hdltbcode.entity_package);
    writeTBFile(tbfid,hdltbcode.entity_decl);
    writeTBFile(tbfid,hdltbcode.entity_ports);
    writeTBFile(tbfid,hdltbcode.entity_end);

    writeTBFile(tbfid,hdltbcode.arch_decl);
    writeTBFile(tbfid,hdltbcode.arch_component_decl);
    writeTBFile(tbfid,this.hdlcomponentdecl);
    writeTBFile(tbfid,hdltbcode.arch_component_config);
    writeTBFile(tbfid,this.hdlcomponentconf);
    writeTBFile(tbfid,hdltbcode.arch_constants);
    writeTBFile(tbfid,this.hdlconstantdecl);
    writeTBFile(tbfid,hdltbcode.arch_signals);
    writeTBFile(tbfid,hdltbcode.arch_begin);
    writeTBFile(tbfid,hdltbcode.arch_body_component_instances);
    writeTBFile(tbfid,this.hdlcomponentinst);
    writeTBFile(tbfid,hdltbcode.arch_body_blocks);

    writeTBFile(tbfid,hdltbcode.arch_body_output_assignments);
    writeTBFile(tbfid,'\n\n\n');
    writeTBFile(tbfid,hdltbcode.arch_end);



    this.hdlRestoreMode(oldcgmode,vhdlpkgreqd);
end




function writeTBFile(hF,str)
    if iscell(str)
        for ii=1:length(str)
            if iscell(str{ii})
                for jj=1:length(str{ii})
                    fprintf('Doh!: %s\n',str{ii}{jj});
                end
            else
                fprintf(hF,str{ii});
            end
        end
    else
        fprintf(hF,str);
    end
end


