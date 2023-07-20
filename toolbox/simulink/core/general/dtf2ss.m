function[a,b,c,d]=dtf2ss(num,den)

























    [dn,dm]=size(den);
    [nn,nm]=size(num);


    dm_nm=dm-nm;
    num=[num,zeros(nn,dm_nm)];
    den=[den,zeros(dn,-dm_nm)];


    [a,b,c,d]=tf2ss(num,den);


