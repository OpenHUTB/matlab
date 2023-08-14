function mpcg=finishConnectivity(this,p)

    mpcg=[];
    hCD=hdlconnectivity.getConnectivityDirector;

    if hdlconnectivity.genConnectivity
        hdldisp(message('hdlcoder:hdldisp:FinishMulticycle'));
        this.addPIRConnectivity(hCD,p);
    end





    if(this.getParameter('multicyclepathinfo'))
        mpcg=hdlconnectivity.MulticyclePathConstraintGenerator(hCD);
    end

end