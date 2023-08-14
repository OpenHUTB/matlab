function configPlatform(cbinfo)


    mdl=cbinfo.editorModel.handle;
    filter='*.sldd';
    title='Select Embedded Coder Dictionary';

    [file,path]=uigetfile(filter,title);
    if~isequal(file,0)&&~isequal(path,0)
        set_param(mdl,'EmbeddedCoderDictionary',file);
    end

