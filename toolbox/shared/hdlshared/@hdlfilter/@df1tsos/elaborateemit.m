function elaborateemit(hF,hN,hC)%#ok<INUSD>











    pirNetworkForFilterComp('reset');


    pirNetworkForFilterComp('push',hN);

    hF.emit;


    pirNetworkForFilterComp('pop');

end
