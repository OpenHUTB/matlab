function sfcnProps=getSFcnProps(this)




    sfcnProps=find(this.classhandle.properties,'accessflags.publicset',...
    'on','accessflags.publicget','on','visible','off');%#ok;
    if~isempty(sfcnProps)
        sfcnPrefix='DVSFcn';
        propNames=get(sfcnProps,'Name');
        sfcnProps=sfcnProps(strncmp(sfcnPrefix,propNames,numel(sfcnPrefix)));
    end
