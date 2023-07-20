function tlmvec2sllog(this)







    this.TlmOutVec=load(fullfile('vectors',[this.TlmOutVecName,'.mat']));

    sigs=fieldnames(this.TlmOutVec.(this.TlmOutVecName));

    for sig=sigs'


        curSig=sig{:};
        curSl=this.TlmInVec.(this.TlmInVecName).(curSig);
        curTlm=this.TlmOutVec.(this.TlmOutVecName).(curSig);
        ns=curSl.SampleInfo.numSamples;
        elps=curSl.SampleInfo.elemsPerSample;
        eldt=curSl.SampleInfo.elemDataType;
        ntpv=[];%#ok<NASGU>
        ntobj=[];
        dout=[];%#ok<NASGU>

        switch(eldt)
        case 'embedded.fi'
            ipe=curSl.SampleInfo.intsPerElem;
            eit=curSl.SampleInfo.elemIntType;
            ntpv=lutils('PvStruct2Cell',curSl.DataTypeInfo.numerictype);
            ntobj=numerictype(ntpv{:});
            dout=repmat(fi(0,ntobj),[1,elps*ns]);
        case 'logical'
            ipe=curSl.SampleInfo.intsPerElem;
            eit=curSl.SampleInfo.elemIntType;
            dout=false([1,elps*ns]);
        otherwise
            ipe=1;
            eit=eldt;
            dout=zeros(1,elps*ns,eldt);
        end

        soi=l_sizeOfElemInt(eit);
        soel=soi*ipe;


        for ii=1:ns
            for jj=1:elps
                diStartIdx=((elps*soel*(ii-1))+(soel*(jj-1)+1));
                diEndIdx=diStartIdx+soel-1;
                doIdx=(elps*(ii-1)+jj);
                elemAsBytes=curTlm.Data(diStartIdx:diEndIdx);

                switch(eldt)
                case 'embedded.fi'
                    elemAsInts=typecast(elemAsBytes,eit);



                    dout(doIdx)=sim2fi(elemAsInts',ntobj);
                case 'logical'
                    dout(doIdx)=logical(elemAsBytes);
                otherwise
                    dout(doIdx)=typecast(elemAsBytes,eit);
                end
            end
        end


        this.TlmSllog.(this.TlmSllogName).(curSig).Data=dout;
    end

end




function soi=l_sizeOfElemInt(itype)
    d=zeros(1,1,itype);%#ok<NASGU>
    dwhos=whos('d');
    soi=dwhos.bytes;
end
