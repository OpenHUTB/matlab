function[hdlbody,hdlsignals]=hdlReadDataFromFile(this)




    hdlsignals=[];
    hdlbody=[];


    if~isTextIOSupported(this,1)
        return;
    end





    if hdlgetparameter('isvhdl')
        return;
    else

        hdlbody=['   initial\n',...
        '     begin\n'];

        for ii=1:length(this.InportSrc)
            src=this.InportSrc(ii);
            vectorPortSize=this.InportSrc(ii).VectorPortSize;
            portDataConst=src.dataIsConstant;
            inSignals=this.getHDLSignals('in',ii);
            sigvtype=this.InportSrc(ii).PortVType;
            sigsltype=this.InportSrc(ii).PortSLType;

            [~,fpScanMap]=this.getFpMap(inSignals,vectorPortSize,src);
            ScanValueSet=fpScanMap.values;
            ScanKeySet=fpScanMap.keys;
            [hdlsignals,hdlbody]=fpHelper1(this,hdlsignals,hdlbody,ScanKeySet,portDataConst);
            hdlsignals=fpHelper2(hdlsignals,ScanValueSet,portDataConst,sigvtype,sigsltype);
        end

        for ii=1:length(this.OutportSnk)
            snk=this.OutportSnk(ii);
            vectorPortSize=this.OutportSnk(ii).VectorPortSize;
            portDataConst=snk.dataIsConstant;
            outSignals=this.getHDLSignals('out',ii);
            sigvtype=this.OutportSnk(ii).PortVType;
            sigsltype=this.OutportSnk(ii).PortSLType;

            [~,fpScanMap]=this.getFpMap(outSignals,vectorPortSize,snk);
            ScanValueSet=fpScanMap.values;
            ScanKeySet=fpScanMap.keys;
            [hdlsignals,hdlbody]=fpHelper1(this,hdlsignals,hdlbody,ScanKeySet,portDataConst);
            hdlsignals=fpHelper2(hdlsignals,ScanValueSet,portDataConst,sigvtype,sigsltype);
        end

        hdlbody=[hdlbody,...
        '     end\n\n'];
    end
end






function[hdlsignals,hdlbody]=fpHelper1(this,hdlsignals,hdlbody,ScanKeySet,portDataConst)




    if~portDataConst
        for jj=1:numel(ScanKeySet)


            [fpName,fpIndex]=hdlnewsignal(['fp_',char(ScanKeySet{jj})],...
            'block',-1,0,0,'integer','uint32');
            hdlregsignal(fpIndex);
            hdlsignals=[hdlsignals,makehdlsignaldecl(fpIndex)];


            hdlbody=[hdlbody...
            ,'        ',fpName...
            ,' = $fopen("',char(ScanKeySet{jj}),'.dat", "r");\n'];
            fullfilename=fullfile(this.CodeGenDirectory,[char(ScanKeySet{jj}),'.dat']);
            msg=message('HDLShared:hdlshared:gentbdatafile',hdlgetfilelink(fullfilename));
            hdldisp(msg.getString,1);


            [~,rewindFpStatusIndex]=hdlnewsignal(['rewindFpStatus_',char(ScanKeySet{jj})],...
            'block',-1,0,0,'integer','uint32');
            hdlregsignal(rewindFpStatusIndex);
            hdlsignals=[hdlsignals,makehdlsignaldecl(rewindFpStatusIndex)];
        end
    end
end

function hdlsignals=fpHelper2(hdlsignals,ScanValueSet,portDataConst,portSigvtype,portSigsltype)



    if~portDataConst
        for jj=1:numel(ScanValueSet)
            flatVal=cellstr(ScanValueSet{jj});
            for kk=1:numel(flatVal)


                [~,rStatusIndex]=hdlnewsignal(['rStatus_',char(flatVal{kk})],...
                'block',-1,0,0,'integer','uint32');
                hdlregsignal(rStatusIndex);
                hdlsignals=[hdlsignals,makehdlsignaldecl(rStatusIndex)];


                [~,fpValIndex]=hdlnewsignal(['fpVal_',char(flatVal{kk})],...
                'block',-1,0,0,portSigvtype,portSigsltype);
                hdlregsignal(fpValIndex);
                hdlsignals=[hdlsignals,makehdlsignaldecl(fpValIndex)];
            end
        end
    end
end





