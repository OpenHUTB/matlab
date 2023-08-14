function loadMATFileInBase(filename)




    evalin('base',['load(''',filename,''');']);

end
