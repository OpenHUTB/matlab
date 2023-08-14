function objHandle=getTestObject(~,~)







    dictPath=fullfile(matlabroot,...
    'toolbox/rptgenext/rptgenextdemos/slrgex_fuelsys.sldd');
    objHandle=Simulink.data.dictionary.open(dictPath);

