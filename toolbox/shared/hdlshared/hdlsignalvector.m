function vector=hdlsignalvector(idx)


    if hdlispirbased
        if length(idx)>1
            error(message('HDLShared:directemit:vectorinput'));
        end



        sigtype=hdlissignaltype(idx,'all');


        tpinfo=pirgetdatatypeinfo(idx.Type);
        if sigtype.isscalar
            vector=double(tpinfo.vector);
        elseif sigtype.isrowvec
            vector=[1,double(tpinfo.vector(1))];
        elseif sigtype.iscolvec
            vector=[double(tpinfo.vector(1)),1];
        elseif sigtype.isunordvec
            vector=double(tpinfo.vector(1));
        elseif sigtype.ismatrix
            assert(tpinfo.numdims<=3,'Matrix Num of Dimensions > 3 is not supported');
            vector=tpinfo.vector;
        else
            assert(false);
        end

    else
        signalTable=hdlgetsignaltable;
        signalTable.checkSignalIndices(idx);
        vector=signalTable.getVector(idx);
    end
end
