
function[net,comp]=makeLNet(reactancesShuntSeries,frequency)








    [type,comp]=arrayfun(@(r)(calcComponent(r,frequency)),reactancesShuntSeries);



    net=2-(type=='C');


    net(:,1)=net(:,1)+2;

end