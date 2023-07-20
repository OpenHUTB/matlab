function[lutsize,lutsizedisp]=getLUTSize(this,dalut,fl)






    [lutsize,lutsizestr]=getLUTSizeforDApart(this,dalut,this.Coefficients);
    lutsizedisp=uniquifyLUTDetails(this,lutsizestr);


